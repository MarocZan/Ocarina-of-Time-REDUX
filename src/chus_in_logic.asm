; 0x00E2D714 (bombchu bowling hook)

logic_chus__bowling_lady_1:
; Change Bowling Alley check to Bombchus or Bomb Bag (Part 1)

    lw      at, BOMBCHUS_IN_LOGIC
    beq     at, r0, @@logic_chus_false
    nop

@@logic_chus_true:
    lb      t7, lo(0x8011A64C)(t7)
    li      t8, 0x09; Bombchus

    beq     t7, t8, @@return
    li      t8, 1
    li      t8, 0

@@return:
    jr      ra
    nop

@@logic_chus_false:
    lw      t7, lo(0x8011A670)(t7)
    andi    t8, t7, 0x18
    jr      ra
    nop


logic_chus__bowling_lady_2:
; Change Bowling Alley check to bombchus or Bomb Bag (Part 2)

    lw      at, BOMBCHUS_IN_LOGIC
    beq     at, r0, @@logic_chus_false
    nop

@@logic_chus_true:
    lb      t3, lo(0x8011A64C)(t3)
    li      t4, 0x09; Bombchus

    beq     t3, t4, @@return
    li      t4, 1
    li      t4, 0

@@return:
    jr      ra
    nop

@@logic_chus_false:
    lw      t3, lo(0x8011A670)(t3)
    andi    t4, t3, 0x18
    jr      ra
    nop

logic_chus__shopkeeper:
; Cannot buy bombchu refills without Bomb Bag

    lw      at, BOMBCHUS_IN_LOGIC
    beq     at, r0, @@logic_chus_false
    nop
    
@@logic_chus_true:
    lui     t1, hi(SAVE_CONTEXT + 0x7C)
    lb      t2, lo(SAVE_CONTEXT + 0x7C)(t1) ; bombchu item
    li      t3, 9
    beq     t2, t3, @@return ; if has bombchu, return 0 (can buy)
    li      v0, 0
    jr      ra
    li      v0, 2 ; else, return 2 (can't buy)

@@logic_chus_false:
    lui     t1, hi(SAVE_CONTEXT + 0xA3)
    lb      t2, lo(SAVE_CONTEXT + 0xA3)(t1) ; bombbag size
    andi    t2, t2, 0x38
    bnez    t2, @@return       ; If has bombbag, return 0 (can buy)
    li      v0, 0
    li      v0, 2              ; else, return 2, (can't buy)

@@return:
    jr      ra
    nop

; Convert bomb drop to bombchu drop under certain circumstances
; v0 = save context
; returns v1 = 0 to drop nothing, else drops the item id indicated by a0
bomb_drop_convert:
    addiu   t0, zero, 0x00FF
    lw      at, BOMBCHUS_IN_LOGIC
    beqz    at, @@logic_chus_false
    lbu     t1, 0x0076(v0)      ; bomb slot

@@logic_chus_true:
    beq     t1, t0, @@bomb_slot_empty
    lbu     t1, 0x007C(v0)      ; bombchu slot

@@bomb_slot_not_empty:
    beq     t1, t0, @@drop_bombs ; if chu slot is empty, drop bombs
    nop
    b       @@drop_bombs_or_chus ; else, drop either bombs or chus
    nop

@@bomb_slot_empty:
    beq     t1, t0, @@drop_nothing ; if chu slot is empty, drop nothing
    nop
    b       @@drop_chus         ; else, drop chus
    nop

@@logic_chus_false:
    beq     t1, t0, @@drop_nothing ; if bomb slot is empty, drop nothing
    nop
    b       @@drop_bombs        ; else, drop bombs (no chu drops if chus in logic is off)
    nop

@@drop_bombs_or_chus:
    lbu     t0, 0x008E(v0)      ; bomb count
    lbu     t1, 0x0094(v0)      ; bombchu count
    slti    at, t0, 16
    beqz    at, @@enough_bombs  ; if bomb count > 15, player has enough bombs
@@need_bombs:                   ; else, player needs at least bombs and may need chus
    slt     at, t1, t0
    beqz    at, @@drop_bombs    ; if bomb count <= bombchu count, drop bombs
    nop
    b       @@drop_chus         ; else, drop chus
@@enough_bombs:                 ; player doesn't need bombs and may or may not need chus
    slti    at, t1, 16
    bnez    at, @@drop_chus     ; if bombchu count <= 15, drop chus
    nop
@@enough_bombs_and_chus:        ; else, drop either chus or bombs randomly (50/50)
    addiu   sp, sp, -0x18
    sw      ra, 0x04(sp)
    sw      a0, 0x08(sp)
    sw      v0, 0x0C(sp)
    jal     0x800CDCCC          ; get a random float between 0 and 1
    nop
    lw      ra, 0x04(sp)
    lui     at, 0x3F00
    mtc1    at, f16             ; f16 = 0.5
    lw      a0, 0x08(sp)
    c.lt.s  f0, f16
    lw      v0, 0x0C(sp)
    bc1f    @@drop_bombs        ; 50% chance to drop bombs
    addiu   sp, sp, 0x18

@@drop_chus:
    li      a0, 0x0005          ; convert the current bomb drop to a bombchu drop
    jr      ra                  ; return with v1 = 1
    li      v1, 1

@@drop_bombs:
    jr      ra
    li      v1, 1               ; keep the bomb drop as is and return with v1 = 1

@@drop_nothing:
    jr      ra
    li      v1, 0               ; return with v1 = 0 to drop nothing

; Override the segment offset to use to draw bombchu drops (Collectible 05)
; a1 = drop icon segment offset to use for this collectible
chu_drop_draw:
    lw      v1, 0x0038(sp)
    lh      v1, 0x001C(v1)      ; actor variable (collectible id)
    li      t0, 0x0005
    bne     v1, t0, @@return    ; if not a bombchu drop, return
    nop
    li      a1, 0x0403FD80      ; else, override the icon segment offset with bombchu drop icon

@@return:
    jr      ra
    lui     at, 0x00FF          ; displaced code
