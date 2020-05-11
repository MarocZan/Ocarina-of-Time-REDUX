; Grotto Load Table
;
; This table describes all data needed to load into each grotto with the correct content.
; There is one entry for each grotto (33 grottos).
;
; Entry format (4 bytes):
; EEEECC00
; EEEE = Entrance index (to enter the correct grotto room)
; CC = Grotto content (content to load generic grottos with, changes chests, scrubs, gossip stones...)
.area 33 * 4, 0
GROTTO_LOAD_TABLE:
.endarea

; Grotto Return Table
;
; This table describes all data needed to exit at each grotto actor with correct entrance data.
; There is one entry for each grotto (33 grottos).
;
; Entry format (32 bytes):
; EEEERR00 AAAA0000 XXXXXXXX YYYYYYYY ZZZZZZZZ 00000000 00000000 00000000
; EEEE = Entrance index (in the scene where the grotto actor is)
; RR = Room number (where the grotto actor is)
; AAAA = Angle of the returnpoint
; XXXXXXXX = X coordinate of the returnpoint
; YYYYYYYY = Y coordinate of the returnpoint
; ZZZZZZZZ = Z coordinate of the returnpoint
.area 33 * 32, 0
GROTTO_RETURN_TABLE:
.endarea

; Grotto Exit List
;
; This List defines the entrance index used when exiting each grotto.
; There is one entrance index for each grotto, in the same order as the Grotto Load Table.
.area 33 * 2, 0
GROTTO_EXIT_LIST:
.endarea

; Temporary byte used when loading inside grottos to indicate which grotto we are in when exiting
CURRENT_GROTTO_ID:
.byte 0xFF
.align 4


; Player Actor code: Runs when the player hits any exit collision, right after getting the entrance index from the scene exit list
; Adds code to handle exiting grottos to any entrance (needed when randomizing entrances)
; Returns 1 if the resolved entrance is a special grotto entrance or 0 otherwise
; t6 = entrance index of the exit the player just hit
; at = global context + 0x10000
scene_exit_hook:
    la      t2, CURRENT_GROTTO_ID
    lbu     t3, 0x0000(t2)          ; get the value of the dynamic grotto id byte
    li      t4, 0xFF
    sb      t4, 0x0000(t2)          ; reset the dynamic grotto id to 0xFF (default)

    li      t0, 0x7FFF
    bne     t6, t0, @@return        ; if not a grotto exit, just return

    ; Translate to the correct grotto exit
    la      t1, GROTTO_EXIT_LIST
    beq     t3, t4, @@return        ; if the dynamic grotto id is not set (== 0xFF), keep 0x7FFF as the entrance index
    sll     t3, t3, 1
    addu    t1, t1, t3
    lhu     t6, 0x0000(t1)          ; use the entrance index from the grotto exit list for that grotto

@@return:
    addiu   t7, zero, 0x0002        ; displaced code
    sh      t6, 0x1E1A(at)          ; set the next entrance index in global context

    li      t0, 0x7FF9
    sub     t0, t6, t0
    bgez    t0, @@return_false      ; dynamic exits (entrance indexes >= 0x7FF9) are handled specifically later
    li      t0, 0x2000
    sub     t0, t6, t0
    bgez    t0, @@return_true       ; entrance indexes >= 0x2000 and < 0x7FF9 are grotto returnpoints
    li      t0, 0x1000
    sub     t0, t6, t0
    bgez    t0, @@return_true       ; entrance indexes >= 0x1000 and < 0x2000 are grotto loads
    nop

@@return_false:
    jr      ra
    li      v0, 0

@@return_true:
    jr      ra
    li      v0, 1


; Grotto Actor code: Runs when the player hits a grotto collision, right before setting the entrance index to load
; Adds code to allow the actor to lead to any entrance index if the grotto scene var is >= 2 (normally either 0 or 1)
; t5 = entrance index to use (already set to a grotto entrance index based on the usual grotto actor routine)
; s0 = grotto actor data pointer
grotto_entrance:
    lhu     t0, 0x001C(s0)          ; t0 = actor variable
    sra     t0, t0, 12
    andi    t0, t0, 0xF             ; t0 = grotto scene var (0 = grotto scene, 1 = fairy fountain scene, 2+ = use zrot)
    slti    t1, t0, 2
    bne     t1, zero, @@return      ; if scene var < 2, skip to use the already defined grotto entrance index
    nop
    lhu     t5, 0x0018(s0)          ; else, use the actor zrot as the entrance index

@@return:
    jr      ra
    addu    at, at, a3              ; displaced code


; Hook variants to override special grotto entrances in different places in the code
override_special_grotto_entrances_1:
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    jal     override_special_grotto_entrances
    lw      v1, -0x5A28(v1)         ; displaced code
    lw      ra, 0x04(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop              

override_special_grotto_entrances_2:
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    jal     override_special_grotto_entrances
    sw      t5, 0x0010(s0)          ; displaced code
    lw      ra, 0x04(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

override_special_grotto_entrances_3:
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    jal     override_special_grotto_entrances
    sw      t9, 0x0010(s0)          ; displaced code
    lw      ra, 0x04(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

override_special_grotto_entrances_4:
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    jal     override_special_grotto_entrances
    sw      v0, 0x000C(s0)          ; displaced code
    lw      ra, 0x04(sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

override_special_grotto_entrances_5:
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    jal     override_special_grotto_entrances
    nop
    lw      ra, 0x04(sp)
    addiu   sp, sp, 0x18

    ; displaced code
    lui     v0, 0x8012
    addiu   v0, v0, 0xA5D0
    lw      t6, 0x0010(v0)
    lui     t0, 0x8010
    lw      t8, 0x0004(v0)
    lw      t7, 0x0004(v0)

    jr      ra
    nop

; Translates and overrides the entrance index in Global Context if it corresponds to a special grotto entrance (grotto load or returnpoint)
override_special_grotto_entrances:
    li      t0, GLOBAL_CONTEXT
    lui     at, 0x0001
    addu    at, at, t0
    lh      t1, 0x1E1A(at)          ; next entrance index

    li      t0, 0x2000
    sub     t0, t1, t0
    bgez    t0, @@grotto_return     ; entrance indexes >= 0x2000 are translated to grotto returnpoints
    nop
    li      t0, 0x1000
    sub     t0, t1, t0
    bgez    t0, @@grotto_load       ; entrance indexes >= 0x1000 and < 0x2000 are translated to grotto loads
    nop
    b       @@return

@@grotto_load:
    la      t1, SAVE_CONTEXT
    la      t2, GROTTO_LOAD_TABLE
    la      t3, CURRENT_GROTTO_ID
    sb      t0, 0x0000(t3)          ; set the grotto id to use when exiting the grotto
    sll     t0, t0, 2
    addu    t2, t2, t0
    lhu     t0, 0x0000(t2)
    sh      t0, 0x1E1A(at)          ; set the entrance index of the grotto we want to load in
    lbu     t0, 0x0002(t2)
    sb      t0, 0x1397(t1)          ; set the grotto content to load with
    b       @@return

@@grotto_return:
    la      t1, SAVE_CONTEXT
    la      t2, GLOBAL_CONTEXT
    la      t3, GROTTO_RETURN_TABLE
    sll     t0, t0, 5
    addu    t3, t3, t0

    addiu   sp, sp, -0x28
    sw      ra, 0x04(sp)
    sw      a0, 0x08(sp)
    sw      a1, 0x0C(sp)
    sw      a2, 0x10(sp)
    sw      a3, 0x14(sp)
    sw      t1, 0x18(sp)
    sw      t2, 0x1C(sp)
    sw      t3, 0x20(sp)
    sw      t4, 0x24(sp)

    addiu   sp, sp, -0x28
    move    a0, t2                  ; global context
    li      a1, 1                   ; zone-out type 1
    lhu     a2, 0x0000(t3)          ; entrance index in the scene where the grotto exit is
    lb      a3, 0x0002(t3)          ; room number where the grotto exit is
    li      t0, 0x04FF
    sw      t0, 0x0010(sp)          ; player variable to spawn with (0x04FF = exiting grotto with no initial camera focus)
    addiu   t0, t3, 0x0008          
    sw      t0, 0x0014(sp)          ; pointer to XYZ coordinates
    lh      t0, 0x0004(t3)
    sw      t0, 0x0018(sp)          ; angle when exiting the grotto

    jal     0x8009D8DC              ; set grotto checkpoint data with the above parameters
    nop
    addiu   sp, sp, 0x28

    lw      ra, 0x04(sp)
    lw      a0, 0x08(sp)
    lw      a1, 0x0C(sp)
    lw      a2, 0x10(sp)
    lw      a3, 0x14(sp)
    lw      t1, 0x18(sp)
    lw      t2, 0x1C(sp)
    lw      t3, 0x20(sp)
    lw      t4, 0x24(sp)
    addiu   sp, sp, 0x28

    lhu     t0, 0x0000(t3)
    sh      t0, 0x1E1A(at)          ; set entrance index in the scene where we want to load
    addiu   t0, zero, 0x0002
    sw      t0, 0x1364(t1)          ; set zone-out respawn type to "grotto"

@@return:
    jr      ra
    nop
