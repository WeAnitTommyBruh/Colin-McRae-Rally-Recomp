#!/usr/bin/env python3
"""Apply this project's psxrecomp patches (patches/*.patch) to the psxrecomp checkout.

    python3 tools/apply_patches.py            # apply the ones not yet applied
    python3 tools/apply_patches.py --revert   # undo them (reverse order)
    python3 tools/apply_patches.py --status   # list state

Patches are ordered by filename and stack: each is a diff against the tree with the
earlier ones applied, so they go on in order and come off in reverse. Applied names are
recorded in psxrecomp/.psxrecomp_applied_patches (context checks alone can't tell
"already applied" from "conflicts", once a later patch has shifted the same file).
Written against psxrecomp 1a0897ca; another commit may reject them.
"""
import subprocess, sys
from pathlib import Path

root = Path(__file__).resolve().parent.parent
fw = root / "psxrecomp"
state = fw / ".psxrecomp_applied_patches"


def git(*a):
    return subprocess.run(["git", "-C", str(fw), *a], capture_output=True, text=True)


def applied_list():
    if not state.exists():
        return []
    return [l.strip() for l in state.read_text().splitlines() if l.strip()]


def present_in_tree(patch):
    """True if every line a patch adds is already in its target file(s). Used to adopt
    patches applied by an older version of this script (which kept no record)."""
    target, added, seen = None, {}, False
    for line in patch.read_text(errors="replace").splitlines():
        if line.startswith("+++ b/"):
            target = line[6:]
            added.setdefault(target, [])
        elif line.startswith("+") and not line.startswith("+++") and target:
            if line[1:].strip():
                added[target].append(line[1:])
    for f, lines in added.items():
        path = fw / f
        if not path.exists():
            return False
        text = path.read_text(errors="replace")
        for l in lines:
            seen = True
            if l not in text:
                return False
    return seen


def save(names):
    if names:
        state.write_text("\n".join(names) + "\n")
    elif state.exists():
        state.unlink()


def main():
    if not (fw / ".git").exists():
        sys.exit("psxrecomp/ is not a git checkout; clone it (see NOTES.md step 1)")
    patches = sorted((root / "patches").glob("*.patch"))
    if not patches:
        sys.exit("no patches found")
    done = applied_list()

    if "--status" in sys.argv:
        for p in patches:
            print(("applied    " if p.name in done else "not applied") + "  " + p.name)
        return 0

    if "--revert" in sys.argv:
        for p in reversed(patches):
            if p.name not in done:
                print("not applied: " + p.name)
                continue
            r = git("apply", "--reverse", str(p))
            if r.returncode:
                print("FAILED to revert " + p.name + ":\n" + r.stderr)
                save(done)
                return 1
            done.remove(p.name)
            print("reverted " + p.name)
        save(done)
        return 0

    for p in patches:
        if p.name in done:
            print("already applied: " + p.name)
            continue
        if present_in_tree(p):
            done.append(p.name)
            print("already in tree (adopted): " + p.name)
            continue
        c = git("apply", "--check", str(p))
        if c.returncode:
            print("CANNOT apply " + p.name + " (wrong psxrecomp commit, or local edits?):\n" + c.stderr)
            save(done)
            return 1
        git("apply", str(p))
        done.append(p.name)
        print("applied " + p.name)
    save(done)
    return 0


if __name__ == "__main__":
    sys.exit(main())
