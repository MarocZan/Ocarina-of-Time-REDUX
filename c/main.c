#include "triforce.h"
#include "dungeon_info.h"
#include "file_select.h"
#include "get_items.h"
#include "models.h"
#include "gfx.h"
#include "text.h"
#include "util.h"
#include "dpad.h"
#include "rainbow_sword.h"
#include "hud_colors.h"
#include "z64.h"
#include "chests.h"
#include "ganon.h"
#include "twinrova.h"
#include "extern_ctxt.h"
#include "fog.h"

void c_init() {
    heap_init();
    gfx_init();
    text_init();
    item_overrides_init();
    models_init();
}

void before_game_state_update() {
    handle_pending_items();
    handle_dpad();
    update_color();
    update_hud_colors();
    process_extern_ctxt();
    override_fog_state();
}

void after_game_state_update() {

}

void after_scene_init() {
    check_ganon_entry();
    clear_twinrova_flag();
    models_reset();
    extern_scene_init();
}
