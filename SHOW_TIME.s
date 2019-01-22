.equ ADDR_CHAR, 0x09000000

.equ SEMICOLON, 0x3A
.equ SPACE, 0x20

.equ CHAR_ZERO, 0x30
.equ CHAR_ONE, 0x31
.equ CHAR_TWO, 0x32
.equ CHAR_THREE, 0x33
.equ CHAR_FOUR, 0x34
.equ CHAR_FIVE, 0x35
.equ CHAR_SIX, 0x36
.equ CHAR_SEVEN, 0x37
.equ CHAR_EIGHT, 0x38
.equ CHAR_NINE, 0x39



.global SHOW_TIME

SHOW_TIME:

	addi sp, sp, -32
	stw r5, 0(sp)
	stw r6, 4(sp)
	stw r7, 8(sp)
	stw r8, 12(sp)
	stw r9, 16(sp)
	stw r10, 20(sp)
	stw r11, 24(sp)
	stw ra, 28(sp)

    # get minutes 
    mov r9, r22
    movi r10, 10
    div r11, r9, r10
    
    muli r10, r11, 10
    sub r10, r9, r10
    
	mov r5, r11
    addi r5, r5, 48 #0x30
	mov r6, r10
    addi r6, r6, 48 #0x30
	
	# get seconds
	mov r9, r23
    movi r10, 10
    div r11, r9, r10
    
    muli r10, r11, 10
    sub r10, r9, r10
    
	mov r7, r11
    addi r7, r7, 48 #0x30
	mov r8, r10
    addi r8, r8, 48 #0x30
	
	# display time
	
	call DISPLAY_TIME
	

	ldw r5, 0(sp)
	ldw r6, 4(sp)
	ldw r7, 8(sp)
	ldw r8, 12(sp)
	ldw r9, 16(sp)
	ldw r10, 20(sp)
	ldw r11, 24(sp)
	ldw ra, 28(sp)
	addi sp, sp, 32
	
	ret
    
.global CLEAR_TIME

CLEAR_TIME:
    addi sp, sp, -12
    stw r3, 0(sp)
    stw r4, 4(sp)
	stw ra, 8(sp)
  
    movia r3, ADDR_CHAR
    
    movi  r4, SPACE
    stbio r4, 3878(r3) /* character (28,30) is x + y*128 so (24 + 30*128 = 3864) */
  
    movi  r4, SPACE
    stbio r4, 3879(r3) /* character (39,30) is x + y*128 so (32 + 30*128 = 3872) */

    movi  r4, SPACE   
    stbio r4, 3880(r3) /* character (40,30) is x + y*128 so (40 + 30*128 = 3880) */

    movi  r4, SPACE
    stbio r4, 3881(r3) /* character (41,30) is x + y*128 so (48 + 30*128 = 3888) */

    movi  r4, SPACE
    stbio r4, 3882(r3) /* character (52,30) is x + y*128 so (56 + 30*128 = 3896) */
    
    ldw r3, 0(sp)
	ldw r4, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
    
    ret

.global DISPLAY_TIME

DISPLAY_TIME:

    addi sp, sp, -12
    stw r3, 0(sp)
    stw r4, 4(sp)
	stw ra, 8(sp)
  
    movia r3, ADDR_CHAR
    
    mov  r4, r5
    stbio r4, 3878(r3) /* character (28,30) is x + y*128 so (24 + 30*128 = 3864) */
  
    mov  r4, r6
    stbio r4, 3879(r3) /* character (39,30) is x + y*128 so (32 + 30*128 = 3872) */

    movi  r4, SEMICOLON   /* ASCII for ':' */
    stbio r4, 3880(r3) /* character (40,30) is x + y*128 so (40 + 30*128 = 3880) */

    mov  r4, r7
    stbio r4, 3881(r3) /* character (41,30) is x + y*128 so (48 + 30*128 = 3888) */

    mov  r4, r8
    stbio r4, 3882(r3) /* character (52,30) is x + y*128 so (56 + 30*128 = 3896) */
    
    ldw r3, 0(sp)
	ldw r4, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
    
    ret