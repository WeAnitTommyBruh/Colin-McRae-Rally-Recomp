#!/usr/bin/env python3
"""Stage a PS1 disc dump under fixed names, whatever the originals are called.

The rest of the project only ever looks at ``disc/game.cue`` and
``disc/game_trackN.bin``.  This tool builds those from whatever you have:

  python3 tools/stage_disc.py <folder | .cue | .bin> [--out disc] [--copy]

* Any .cue name works.  Its FILE lines may name files that do not exist
  (different case, underscores instead of spaces/parentheses, renamed tracks,
  a different cue's names, ...).  Each FILE is matched to a real file by, in order:
  exact name, case-insensitive, punctuation-insensitive, "Track N" number,
  closest name, and finally natural sort order.
* No .cue at all also works: one .bin -> single-track cue; several .bin
  (natural sort order) -> track 1 data + audio tracks (Redump-style pregaps).
* Bin files are hardlinked when possible, else copied (no symlinks: later tools
  resolve them back to the original names).  Originals are never
  modified.  The TRACK / INDEX lines of the original cue are kept verbatim.
"""
from __future__ import annotations

import argparse
import difflib
import os
import re
import shutil
import sys
from pathlib import Path

BIN_EXTS = {".bin", ".img", ".iso"}
SECTOR = 2352


def natural_key(s: str):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r"(\d+)", s)]


def norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]", "", s.lower())


def track_no(s: str):
    m = re.search(r"(?i)track\W*_*0*(\d+)", s)
    return int(m.group(1)) if m else None


def read_text(p: Path) -> str:
    raw = p.read_bytes()
    for enc in ("utf-8-sig", "utf-16", "latin-1"):
        try:
            return raw.decode(enc)
        except UnicodeError:
            continue
    return raw.decode("latin-1", "replace")


FILE_RE = re.compile(r'^(\s*FILE\s+)(?:"([^"]*)"|(\S+))(\s+\S+.*)$', re.I)


def parse_cue(text: str):
    """Return (lines, [(line_index, name)])"""
    lines = text.splitlines()
    refs = []
    for i, ln in enumerate(lines):
        m = FILE_RE.match(ln)
        if m:
            refs.append((i, m.group(2) if m.group(2) is not None else m.group(3)))
    return lines, refs


def resolve(names, folder: Path):
    """Map each wanted file name to a real file in `folder`. Returns list[Path]."""
    cands = sorted(
        (p for p in folder.iterdir()
         if p.is_file() and p.suffix.lower() in BIN_EXTS),
        key=lambda p: natural_key(p.name))
    used: set[Path] = set()
    out: list[Path | None] = [None] * len(names)

    def take(i, p):
        out[i] = p
        used.add(p)

    def pool():
        return [p for p in cands if p not in used]

    def unique(matches):
        return matches[0] if len(matches) == 1 else None

    for step in ("exact", "ci", "norm", "track", "close"):
        for i, name in enumerate(names):
            if out[i] is not None:
                continue
            base = Path(name.replace("\\", "/")).name
            avail = pool()
            hit = None
            if step == "exact":
                hit = unique([p for p in avail if p.name == base])
            elif step == "ci":
                hit = unique([p for p in avail if p.name.lower() == base.lower()])
            elif step == "norm":
                hit = unique([p for p in avail if norm(p.name) == norm(base)])
            elif step == "track":
                tn = track_no(base)
                if tn is not None:
                    m = [p for p in avail if track_no(p.name) == tn]
                    if len(m) > 1:  # several discs in one folder: prefer closest stem
                        m.sort(key=lambda p: -difflib.SequenceMatcher(
                            None, norm(p.name), norm(base)).ratio())
                        if (difflib.SequenceMatcher(None, norm(m[0].name), norm(base)).ratio()
                                > difflib.SequenceMatcher(None, norm(m[1].name), norm(base)).ratio()):
                            m = m[:1]
                    hit = unique(m)
                elif len(names) == 1 and len(avail) == 1:
                    hit = avail[0]
            elif step == "close":
                scored = sorted(
                    ((difflib.SequenceMatcher(None, norm(p.name), norm(base)).ratio(), p)
                     for p in avail), key=lambda t: -t[0])
                if scored and scored[0][0] >= 0.6 and (
                        len(scored) == 1 or scored[0][0] - scored[1][0] > 0.05):
                    hit = scored[0][1]
            if hit is not None:
                take(i, hit)

    missing = [i for i, p in enumerate(out) if p is None]
    if missing:  # last resort: same count left -> natural order
        rest = pool()
        if len(rest) == len(missing):
            for i, p in zip(missing, rest):
                take(i, p)
    if any(p is None for p in out):
        bad = [names[i] for i, p in enumerate(out) if p is None]
        raise SystemExit(
            "could not match these cue FILE entries to any file in "
            f"{folder}:\n  " + "\n  ".join(bad))
    return out  # type: ignore[return-value]


def place(src: Path, dst: Path, mode: str):
    if dst.is_symlink() or dst.exists():
        dst.unlink()
    if mode != "copy":
        try:
            os.link(src.resolve(), dst)
            return "hardlink"
        except OSError:
            pass
    shutil.copy2(src, dst)
    return "copy"


def synth_cue(bins: list[Path]) -> tuple[list[str], list[Path]]:
    lines = []
    for n, b in enumerate(bins, 1):
        lines.append(f'FILE "{b.name}" BINARY')
        if n == 1:
            if b.stat().st_size % SECTOR:
                raise SystemExit(
                    f"{b.name}: size is not a multiple of 2352; this is not a raw "
                    "MODE2/2352 dump. Use psxrecomp/tools/prepare_disc.py for "
                    ".iso / 2048 / 2448 images.")
            lines += [f"  TRACK {n:02d} MODE2/2352", "    INDEX 01 00:00:00"]
        else:
            lines += [f"  TRACK {n:02d} AUDIO", "    INDEX 00 00:00:00",
                      "    INDEX 01 00:02:00"]
    return lines, bins


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("source", help="folder holding the dump, or a .cue / .bin in it")
    ap.add_argument("--out", default="disc", help="output dir (default: disc)")
    ap.add_argument("--copy", action="store_true", help="copy instead of linking")
    ap.add_argument("--cue", help="pick a specific .cue when the folder has several")
    a = ap.parse_args()

    src = Path(a.source).expanduser()
    if not src.exists():
        raise SystemExit(f"not found: {src}")
    folder = src if src.is_dir() else src.parent
    cue_path = Path(a.cue) if a.cue else (src if src.suffix.lower() == ".cue" else None)
    if cue_path is None:
        cues = sorted(folder.glob("*.[cC][uU][eE]"))
        if len(cues) > 1:
            raise SystemExit("several .cue files here; pick one with --cue:\n  "
                             + "\n  ".join(map(str, cues)))
        cue_path = cues[0] if cues else None

    out = Path(a.out)
    out.mkdir(parents=True, exist_ok=True)

    if cue_path is not None:
        lines, refs = parse_cue(read_text(cue_path))
        if not refs:
            raise SystemExit(f"no FILE lines in {cue_path}")
        real = resolve([n for _, n in refs], cue_path.parent)
        note = "cue"
    else:
        bins = sorted((p for p in folder.iterdir()
                       if p.is_file() and p.suffix.lower() in BIN_EXTS),
                      key=lambda p: natural_key(p.name))
        if not bins:
            raise SystemExit(f"no .cue or .bin/.img files in {folder}")
        lines, real = synth_cue(bins)
        refs = [(i, "") for i, ln in enumerate(lines) if ln.startswith("FILE")]
        note = "synthesized (no .cue found; verify track layout)"

    # One output file per distinct source file, in first-use order.
    order: list[Path] = []
    for p in real:
        if p not in order:
            order.append(p)
    single = len(order) == 1
    newname = {p: ("game.bin" if single else f"game_track{i}.bin")
               for i, p in enumerate(order, 1)}

    for i, (li, _) in enumerate(refs):
        m = FILE_RE.match(lines[li]) if cue_path is not None else None
        rest = m.group(4) if m else " BINARY"
        lines[li] = f'FILE "{newname[real[i]]}"{rest.rstrip()}'
    for p in order:
        how = place(p, out / newname[p], "copy" if a.copy else "link")
        print(f"  {p.name}  ->  {out / newname[p]}  ({how})")
    (out / "game.cue").write_text("\r\n".join(lines) + "\r\n", encoding="utf-8")
    print(f"staged ({note}): {out / 'game.cue'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
