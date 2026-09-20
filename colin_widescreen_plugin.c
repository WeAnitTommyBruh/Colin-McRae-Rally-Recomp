/*
 * Colin McRae Rally widescreen: a trusted, statically linked psxrecomp mod plugin.
 *
 * In this framework version the launcher no longer has a generic "Aspect ratio"
 * setting; the display view is owned by a game mod. The manifest in
 * mods/preloaded/packages/colinmcrae.widescreen declares the feature and its
 * "View" option (they show up in the launcher's Mods view); this file is the
 * implementation it names. Activation runs before the renderer/window exist.
 */
#include "mod_plugins.h"

#include <string.h>

/* Added by patches/psxrecomp-stretch-2d-frames.patch. Declared weak so this file still
 * links against an unpatched psxrecomp (the "menus" option then simply does nothing). */
#if defined(__GNUC__) || defined(__clang__)
extern void psx_mod_set_stretch_2d_frames(int enabled) __attribute__((weak));
extern void psx_mod_set_gte_scene_overhang_gate(int enabled) __attribute__((weak));
extern void psx_mod_set_scene_overhang_min_prims(uint32_t min_prims) __attribute__((weak));
#define HAVE_STRETCH_2D_API (psx_mod_set_stretch_2d_frames != 0)
#define HAVE_OVERHANG_GATE_API (psx_mod_set_gte_scene_overhang_gate != 0)
#define HAVE_OVERHANG_MIN_API  (psx_mod_set_scene_overhang_min_prims != 0)
#else
#define HAVE_STRETCH_2D_API 0
#define HAVE_OVERHANG_GATE_API 0
#define HAVE_OVERHANG_MIN_API  0
#endif

#define PKG_ID     "colinmcrae.widescreen"
#define FEATURE_ID "widescreen"
#define PLUGIN_ID  "colinmcrae.widescreen"

static void colinmcrae_widescreen_activate(void) {
    char view[32] = "";
    char menus[32] = "";
    char detect[32] = "";
    if (!psx_mod_option_value(PKG_ID, FEATURE_ID, "aspect", view, sizeof view))
        strcpy(view, "16-9");                 /* untouched option: manifest default */

    if (!psx_mod_option_value(PKG_ID, FEATURE_ID, "menus", menus, sizeof menus))
        strcpy(menus, "pillarbox");
    if (HAVE_STRETCH_2D_API)
        psx_mod_set_stretch_2d_frames(strcmp(menus, "stretch") == 0);

    /* Menus/title use the GTE (spinning globe, ring text), so the bare gte_game_mode
     * detector calls them gameplay. Require window-overhanging polygons too; "strict"
     * asks for enough of them that a menu backdrop can't flap the classification. */
    if (!psx_mod_option_value(PKG_ID, FEATURE_ID, "detect", detect, sizeof detect))
        strcpy(detect, "strict");
    if (HAVE_OVERHANG_GATE_API)
        psx_mod_set_gte_scene_overhang_gate(strcmp(detect, "any-3d") != 0);
    if (HAVE_OVERHANG_MIN_API)
        psx_mod_set_scene_overhang_min_prims(strcmp(detect, "strict") == 0 ? 16u : 0u);

    if (strcmp(view, "21-9") == 0) {
        (void)psx_mod_set_fixed_display_aspect(21u, 9u);
    } else if (strcmp(view, "adaptive-16-9") == 0) {
        (void)psx_mod_set_fixed_display_aspect(16u, 9u);   /* initial window shape */
        (void)psx_mod_set_adaptive_display_aspect(16u, 9u);
    } else if (strcmp(view, "adaptive-21-9") == 0) {
        (void)psx_mod_set_fixed_display_aspect(16u, 9u);
        (void)psx_mod_set_adaptive_display_aspect(21u, 9u);
    } else {
        (void)psx_mod_set_fixed_display_aspect(16u, 9u);
    }
}

PSX_MOD_CONSTRUCTOR(colinmcrae_register_widescreen_plugin) {
    (void)psx_mod_register_activation_plugin(PLUGIN_ID,
                                             colinmcrae_widescreen_activate);
}
