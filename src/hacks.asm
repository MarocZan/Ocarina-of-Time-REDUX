; Prevent Kokiri Sword from being added to inventory on game load
; Replaces:
;   sh      t9, 0x009C (v0)
.orga 0xBAED6C ; In memory: 0x803B2B6C
    nop

;==================================================================================================
; Time Travel
;==================================================================================================

; Prevents FW from being unset on time travel
; Replaces:
;   SW  R0, 0x0E80 (V1)
.orga 0xAC91B4 ; In memory: 0x80053254
    nop

; Replaces:
;   jal     8006FDCC ; Give Item
.orga 0xCB6874 ; Bg_Toki_Swd addr 809190F4 in func_8091902C
    jal     give_master_sword

; Replaces:
;   lui/addiu a1, 0x8011A5D0
.orga 0xAE5764
    j       before_time_travel
    nop

; After time travel
; Replaces:
;   jr      ra
.orga 0xAE59E0 ; In memory: 0x8006FA80
    j       after_time_travel

;==================================================================================================
; Every frame hooks
;==================================================================================================

; Runs before the game state update function
; Replaces:
;   lw      t6, 0x0018 (sp)
;   lui     at, 0x8010
.orga 0xB12A34 ; In memory: 0x8009CAD4
    jal     before_game_state_update_hook
    nop

; Runs after the game state update function
; Replaces:
;   jr      ra
;   nop
.orga 0xB12A60 ; In memory: 0x8009CB00
    j       after_game_state_update
    nop

;==================================================================================================
; Scene init hook
;==================================================================================================

; Runs after scene init
; Replaces:
;   jr      ra
;   nop
.orga 0xB12E44 ; In memory: 0x8009CEE4
    j       after_scene_init
    nop

;==================================================================================================
; File select hash
;==================================================================================================

; Runs after the file select menu is rendered
; Replaces: code that draws the fade-out rectangle on file load
.orga 0xBAF738 ; In memory: 0x803B3538
.area 0x60, 0
    or      a1, r0, s0   ; menu data
    jal     draw_file_select_hash
    andi    a0, t8, 0xFF ; a0 = alpha channel of fade-out rectangle

    lw      s0, 0x18 (sp)
    lw      ra, 0x1C (sp)
    jr      ra
    addiu   sp, sp, 0x88
.endarea

;==================================================================================================
; Pause menu
;==================================================================================================

; Create a blank texture, overwriting a Japanese item description
.orga 0x89E800
.fill 0x400, 0

; Don't display hover boots in the bullet bag/quiver slot if you haven't gotten a slingshot before becoming adult
; Replaces:
;   lbu     t4, 0x0000 (t7)
;   and     t6, v1, t5
.orga 0xBB6CF0
    jal     equipment_menu_fix
    nop

; Use a blank item description texture if the cursor is on an empty slot
; Replaces:
;   sll     t4, v1, 10
;   addu    a1, t4, t5
.orga 0xBC088C ; In memory: 0x8039820C
    jal     menu_use_blank_description
    nop

;==================================================================================================
; Equipment menu
;==================================================================================================

; Left movement check
; Replaces:
;   beqz    t3, 0x8038D9FC
;   nop
.orga 0xBB5EAC ; In memory: 0x8038D834
    nop
    nop

; Right movement check
; Replaces:
;   beqz    t3, 0x8038D9FC
;   nop
.orga 0xBB5FDC ; In memory: 0x8038D95C
nop
nop

; Upward movement check
; Replaces:
;   beqz    t6, 0x8038DB90
;   nop
.orga 0xBB6134 ; In memory: 0x8038DABC
nop
nop

; Downward movement check
; Replaces:
;   beqz    t9, 0x8038DB90
;   nop
.orga 0xBB61E0 ; In memory: 0x8038DB68
nop
nop

; Remove "to Equip" text if the cursor is on an empty slot
; Replaces:
;   lbu     v1, 0x0000 (t4)
;   addiu   at, r0, 0x0009
.orga 0xBB6688 ; In memory: 0x8038E008
    jal     equipment_menu_prevent_empty_equip
    nop

; Prevent empty slots from being equipped
; Replaces:
;   addu    t8, t4, v0
;   lbu     v1, 0x0000 (t8)
.orga 0xBB67C4 ; In memory: 0x8038E144
    jal     equipment_menu_prevent_empty_equip
    addu    t4, t4, v0

;==================================================================================================
; Item menu
;==================================================================================================

; Left movement check
; Replaces:
;   beq     s4, t5, 0x8038F2B4
;   nop
.orga 0xBB77B4 ; In memory: 0x8038F134
    nop
    nop

; Right movement check
; Replaces:
;   beq     s4, t4, 0x8038F2B4
;   nop
.orga 0xBB7894 ; In memory: 0x8038F214
    nop
    nop

; Upward movement check
; Replaces:
;   beq     s4, t4, 0x8038F598
;   nop
.orga 0xBB7BA0 ; In memory: 0x8038F520
    nop
    nop

; Downward movement check
; Replaces:
;   beq     s4, t4, 0x8038F598
;   nop
.orga 0xBB7BFC ; In memory: 0x8038F57C
    nop
    nop

; Remove "to Equip" text if the cursor is on an empty slot
; Replaces:
;   addu    s1, t6, t7
;   lbu     v0, 0x0000 (s1)
.orga 0xBB7C88 ; In memory: 0x8038F608
    jal     item_menu_prevent_empty_equip
    addu    s1, t6, t7

; Prevent empty slots from being equipped
; Replaces:
;   lbu     v0, 0x0000 (s1)
;   addiu   at, r0, 0x0009
.orga 0xBB7D10 ; In memory: 0x8038F690
    jal     item_menu_prevent_empty_equip
    nop

;==================================================================================================
; V1.0 Scarecrow Song Bug
;==================================================================================================

; Replaces:
;   jal     0x80057030 ; copies Scarecrow Song from active space to save context
.orga 0xB55A64 ; In memory 800DFB04
    jal     save_scarecrow_song

;==================================================================================================
; Empty Bomb Fix
;==================================================================================================

; Replaces:
;sw      r0, 0x0428(v0)
;sw      t5, 0x066C(v0)

.orga 0xC0E77C
    jal     empty_bomb
    sw      r0, 0x0428(v0)

;==================================================================================================
; Patches.py imports
;==================================================================================================

; Fix Link the Goron to always work
.orga 0xED2FAC
    lb      t6, 0x0F18(v1)

.orga 0xED2FEC
    li      t2, 0

.orga 0xAE74D8
    li      t6, 0


; Fix King Zora Thawed to always work
.orga 0xE55C4C
    li t4, 0

.orga 0xE56290
    nop
    li t3, 0x401F
    nop

; Learning Serenade tied to opening chest in room
.orga 0xC7BCF0
    lw      t9, 0x1D38(a1) ; Chest Flags
    li      t0, 0x0004     ; flag mask
    lw      v0, 0x1C44(a1) ; needed for following code
    nop
    nop
    nop
    nop

; Dampe Chest spawn condition looks at chest flag instead of having obtained hookshot
.orga 0xDFEC3C
    lw      t8, (SAVE_CONTEXT + 0xDC + (0x48 * 0x1C)) ; Scene clear flags
    addiu   a1, sp, 0x24
    andi    t9, t8, 0x0010 ; clear flag 4
    nop

; Darunia sets an event flag and checks for it
; TODO: Figure out what is this for. Also rewrite to make things cleaner
.orga 0xCF1AB8
    nop
    lw      t1, lo(SAVE_CONTEXT + 0xED8)(t8)
    andi    t0, t1, 0x0040
    ori     t9, t1, 0x0040
    sw      t9, lo(SAVE_CONTEXT + 0xED8)(t8)
    li      t1, 6

;==================================================================================================
; Easier Fishing
;==================================================================================================

; Make fishing less obnoxious
.orga 0xDBF428
    jal     easier_fishing
    lui     at, 0x4282
    mtc1    at, f8
    mtc1    t8, f18
    swc1    f18, 0x019C(s2)

.orga 0xDBF484
    nop

.orga 0xDBF4A8
    nop

; set adult fish size requirement
.orga 0xDCBEA8
    lui     at, 0x4248

.orga 0xDCBF24
    lui     at, 0x4248

; set child fish size requirements
.orga 0xDCBF30
    lui     at, 0x4230

.orga 0xDCBF9C
    lui     at, 0x4230

; Fish bite guaranteed when the hook is stable
; Replaces: lwc1    f10, 0x0198(s0)
;           mul.s   f4, f10, f2
.orga 0xDC7090
    jal     fishing_bite_when_stable
    lwc1    f10, 0x0198(s0)

; Remove most fish loss branches
.orga 0xDC87A0
    nop
.orga 0xDC87BC
    nop
.orga 0xDC87CC
    nop

; Prevent RNG fish loss
; Replaces: addiu   at, zero, 0x0002
.orga 0xDC8828
    move    at, t5

;==================================================================================================
; Override Collectible 05 to be a Bombchus (5) drop instead of the unused Arrow (1) drop
;==================================================================================================
; Replaces: 0x80011D30
.orga 0xB7BD24
    .word 0x80011D88

; Replaces: li   a1, 0x03
.orga 0xA8801C
    li      a1, 0x96 ; Give Item Bombchus (5)
.orga 0xA88CCC
    li      a1, 0x96 ; Give Item Bombchus (5)

; Replaces: lui     t5, 0x8012
;           lui     at, 0x00FF
.orga 0xA89268
    jal     chu_drop_draw
    lui     t5, 0x8012

;==================================================================================================
; Potion Shop Fix
;==================================================================================================

.orga 0xE2C03C
    jal     potion_shop_fix
    addiu   v0, v0, 0xA5D0 ; displaced

;==================================================================================================
; Jabu Jabu Elevator
;==================================================================================================

;Replaces: addiu t5, r0, 0x0200
.orga 0xD4BE6C
    jal     jabu_elevator

;==================================================================================================
; DPAD Display
;==================================================================================================
;
; Replaces lw    t6, 0x1C44(s6)
;          lui   t8, 0xDB06
.orga 0xAEB67C ; In Memory: 0x8007571C
    jal     dpad_draw
    nop

;==================================================================================================
; Stone of Agony indicator
;==================================================================================================

; Replaces:
;   c.lt.s  f0, f2
.orga 0xBE4A14
    jal     agony_distance_hook

    ; Replaces:
;   c.lt.s  f4, f6
.orga 0xBE4A40
    jal     agony_vibrate_hook

; Replaces:
;   addiu   sp, sp, 0x20
;   jr      ra
.orga 0xBE4A60
    j       agony_post_hook
    nop

;==================================================================================================
; Cast Fishing Rod without B Item
;==================================================================================================

.orga 0xBCF914 ; 8038A904
    jal     keep_fishing_rod_equipped
    nop

.orga 0xBCF73C ; 8038A72C
    sw      ra, 0x0000(sp)
    jal     cast_fishing_rod_if_equipped
    nop
    lw      ra, 0x0000(sp)

;==================================================================================================
; Big Goron Fix
;==================================================================================================
;
;Replaces: beq     $zero, $zero, lbl_80B5AD64

.orga 0xED645C
    jal     bgs_fix
    nop

;==================================================================================================
; Dampe Digging Fix
;==================================================================================================
;
; Dig Anywhere
.orga 0xCC3FA8
    sb      at, 0x1F8(s0)

; Always First Try
.orga 0xCC4024
    nop

; Leaving without collecting dampe's prize won't lock you out from that prize
.orga 0xCC4038
    jal     dampe_fix
    addiu   t4, r0, 0x0004

.orga 0xCC453C
    .word 0x00000806
;==================================================================================================
; Drawbridge change
;==================================================================================================
;
; Replaces: SH  T9, 0x00B4 (S0)
.orga 0xC82550
   nop

;==================================================================================================
; Never override menu subscreen index
;==================================================================================================

; Replaces: bnezl t7, 0xAD1988 ; 0x8005BA28
.orga 0xAD193C ; 0x8005B9DC
    b . + 0x4C

;==================================================================================================
; Make Bunny Hood like Majora's Mask
;==================================================================================================

; Replaces: mfc1    a1, f12
;           mtc1    t7, f4
.orga 0xBD9A04
    jal bunny_hood
    nop

;==================================================================================================
; Prevent hyrule guards from casuing a softlock if they're culled 
;==================================================================================================
.orga 0xE24E7C
    jal guard_catch
    nop

;==================================================================================================
; static context init hook
;==================================================================================================
.orga 0xAC7AD4
    jal     Static_ctxt_Init

;==================================================================================================
; burning kak from any entrance to kak
;==================================================================================================
; Replaces: lw      t9, 0x0000(s0)
;           addiu   at, 0x01E1
.orga 0xACCD34
    jal     burning_kak
    lw      t9, 0x0000(s0)

;==================================================================================================
; Load Audioseq using dmadata
;==================================================================================================
; Replaces: lui     a1, 0x0003
;           addiu   a1, a1, -0x6220
.orga 0xB2E82C ; in memory 0x800B88CC
    lw      a1, 0x8000B188

;==================================================================================================
; Load Audiotable using dmadata
;==================================================================================================
; Replaces: lui     a1, 0x0008
;           addiu   a1, a1, -0x6B90
.orga 0xB2E854
    lw      a1, 0x8000B198

;==================================================================================================
; Getting Caught by Gerudo NPCs in ER
;==================================================================================================
; Replaces: lui     at, 0x0001
;           addu    at, at, a1
.orga 0xE11F90  ; White-clothed Gerudo
    jal     gerudo_caught_entrance
    nop
.orga 0xE9F678  ; Patrolling Gerudo
    jal     gerudo_caught_entrance
    nop
.orga 0xE9F7A8  ; Patrolling Gerudo
    jal     gerudo_caught_entrance
    nop

; Replaces: lui     at, 0x0001
;           addu    at, at, v0
.orga 0xEC1120  ; Gerudo Fighter
    jal     gerudo_caught_entrance
    nop

;==================================================================================================
; Song of Storms Effect Trigger Changes
;==================================================================================================
; Allow a storm to be triggered with the song in any environment
; Replaces: lui     t5, 0x800F
;           lbu     t5, 0x1648(t5)
.orga 0xE6BF4C
    li      t5, 0
    nop

; Remove the internal cooldown between storm effects (to open grottos, grow bean plants...)
; Replaces: bnez     at, 0x80AECC6C
.orga 0xE6BEFC
    nop

;==================================================================================================
; Fix Lab Diving to always be available
;==================================================================================================
; Replaces: lbu     t7, -0x709C(t7)
;           lui     a1, 0x8012
;           addiu   a1, a1, 0xA5D0      ; a1 = save context
;           addu    t8, a1, t7
;           lbu     t9, 0x0074(t8)      ; t9 = owned adult trade item
.orga 0xE2CC1C
    lui     a1, 0x8012
    addiu   a1, a1, 0xA5D0      ; a1 = save context
    lh      t0, 0x0270(s0)      ; t0 = recent diving depth (in meters)
    bne     t0, zero, @skip_eyedrops_dialog
    lbu     t9, 0x008A(a1)      ; t9 = owned adult trade item

.orga 0xE2CC50
@skip_eyedrops_dialog:

;==================================================================================================
; Change Gerudo Guards to respond to the Gerudo's Card, not freeing the carpenters.
;==================================================================================================
; Patrolling Gerudo
.orga 0xE9F598
    lui     t6, 0x8012
    lhu     t7, 0xA674(t6)
    andi    t8, t7, 0x0040
    beqzl   t8, @@return
    move    v0, zero
    li      v0, 1
@@return:
    jr      ra
    nop
    nop
    nop
    nop

; White-clothed Gerudo
.orga 0xE11E94
    lui     v0, 0x8012
    lhu     v0, 0xA674(v0)
    andi    t6, v0, 0x0040
    beqzl   t6, @@return
    move    v0, zero
    li      v0, 1
@@return:
    jr      ra
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

;==================================================================================================
; HUD Rupee Icon color
;==================================================================================================
; Replaces: lui     at, 0xC8FF
;           addiu   t8, s1, 0x0008
;           sw      t8, 0x02B0(s4)
;           sw      t9, 0x0000(s1)
;           lhu     t4, 0x0252(s7)
;           ori     at, at, 0x6400      ; at = HUD Rupee Icon Color
.orga 0xAEB764
    addiu   t8, s1, 0x0008
    sw      t8, 0x02B0(s4)
    jal     rupee_hud_color
    sw      t9, 0x0000(s1)
    lhu     t4, 0x0252(s7)
    move    at, v0

;==================================================================================================
; Expand Audio Thread memory
;==================================================================================================

.headersize (0x800110A0 - 0xA87000)

//reserve the audio thread's heap
.org 0x800C7DDC 
.area 0x1C
    lui     at, hi(AUDIO_THREAD_INFO_MEM_START)
    lw      a0, lo(AUDIO_THREAD_INFO_MEM_START)(at)
    jal     0x800B8654
    lw      a1, lo(AUDIO_THREAD_INFO_MEM_SIZE)(at)
    lw      ra, 0x0014(sp)
    jr      ra
    addiu   sp, sp, 0x0018
.endarea

//allocate memory for fanfares and primary/secondary bgm
.org 0x800B5528
.area 0x18, 0
    jal     get_audio_pointers
.endarea

.org 0x800B5590
.area (0xE0 - 0x90), 0
    li      a0, 0x80128A50
    li      a1, AUDIO_THREAD_INFO
    jal     0x80057030 //memcopy
    li      a2, 0x18
    li      a0, 0x80128A50
    jal     0x800B3D18
    nop
    li      a0, 0x80128A5C
    jal     0x800B3DDC
    nop
.endarea

.headersize 0

;==================================================================================================
; Fix Links Angle in Fairy Fountains
;==================================================================================================

;Hook great fairy update function and set position/angle when conditions are met
; Replaces: or      a0, s0, r0
;           or      a1, s1, r0
.orga 0xC8B24C
    jal     fountain_set_posrot
    or      a0, s0, r0

;==================================================================================================
; Prevent Carpenter Boss Softlock
;==================================================================================================
; Replaces: or      a1, s1, r0
;           addiu   a2, r0, 0x22 
.orga 0xE0EC50
    jal     prevent_carpenter_boss_softlock
    or      a1, s1, r0

;==================================================================================================
; First try Truth Spinner
;==================================================================================================
;
;Replaces: addiu t5, t4, at

.org 0xDB9E7C 
    jal    truth_spinner_fix
    nop
