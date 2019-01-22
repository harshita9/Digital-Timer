.equ ADDR_7SEG1, 0xFF200020


.global SEVENSEGDISPLAY

SEVENSEGDISPLAY:
	subi sp, sp, 28
	stw r5, 0(sp)
	stw r6, 4(sp)
	stw r17, 8(sp)
	stw r18, 12(sp)
	stw r19, 16(sp)
	stw ra, 20(sp)
	stw ea, 24(sp)
	br M_TW0_DIGIT

ONE_DIGIT:
	beq r5, r0, ZERO
	movi r18, 1
	beq r5, r18, ONE
	movi r18, 2
	beq r5, r18, TWO
	movi r18, 3
	beq r5, r18, THREE
	movi r18, 4
	beq r5, r18, FOUR
	movi r18, 5
	beq r5, r18, FIVE
	movi r18, 6
	beq r5, r18, SIX
	movi r18, 7
	beq r5, r18, SEVEN
	movi r18, 8
	beq r5, r18, EIGHT
	movi r18, 9
	beq r5, r18, NINE
	br EXIT
	
M_ONE_DIGIT:
	beq r6, r0, M_ZERO
	movi r18, 1
	beq r6, r18, M_ONE
	movi r18, 2
	beq r6, r18, M_TWO
	movi r18, 3
	beq r6, r18, M_THREE
	movi r18, 4
	beq r6, r18, M_FOUR
	movi r18, 5
	beq r6, r18, M_FIVE
	movi r18, 6
	beq r6, r18, M_SIX
	movi r18, 7
	beq r6, r18, M_SEVEN
	movi r18, 8
	beq r6, r18, M_EIGHT
	movi r18, 9
	beq r6, r18, M_NINE
	br EXIT
	
M_TW0_DIGIT:
	movia r18, 10
	blt r6, r18, M_ONES
	movia r18, 20
	blt r6, r18, M_TENS
	movia r18, 30
	blt r6, r18, M_TWENTIES
	movia r18, 40
	blt r6, r18, M_THIRTIES
	movia r18, 50
	blt r6, r18, M_FOURTIES
	movia r18, 60
	blt r6, r18, M_FIFTIES
	
    M_ONES:
		movia r17, 0x3F000000
		br M_ONE_DIGIT
	M_TENS:
		movia r17, 0x06000000
		subi r6, r6, 10
		br M_ONE_DIGIT
	M_TWENTIES:
		movia r17, 0x5B000000
		subi r6, r6, 20
		br M_ONE_DIGIT
	M_THIRTIES:
		movia r17, 0x4F000000
		subi r6, r6, 30
		br M_ONE_DIGIT
	M_FOURTIES:
		movia r17, 0x66000000
		subi r6, r6, 40
		br M_ONE_DIGIT
	M_FIFTIES:
		movia r17, 0x6D000000
		subi r6, r6, 50
		br M_ONE_DIGIT

TW0_DIGIT:
	movia r18, 10
	blt r5, r18, ONES
	movia r18, 20
	blt r5, r18, TENS
	movia r18, 30
	blt r5, r18, TWENTIES
	movia r18, 40
	blt r5, r18, THIRTIES
	movia r18, 50
	blt r5, r18, FOURTIES
	movia r18, 60
	blt r5, r18, FIFTIES
	
    ONES:
		movia r17, 0x00003F00
		or r19, r19, r17
		br ONE_DIGIT
	TENS:
		movia r17, 0x00000600
		or r19, r19, r17
		subi r5, r5, 10
		br ONE_DIGIT
	TWENTIES:
		movia r17, 0x00005B00
		or r19, r19, r17
		subi r5, r5, 20
		br ONE_DIGIT
	THIRTIES:
		movia r17, 0x00004F00
		or r19, r19, r17
		subi r5, r5, 30
		br ONE_DIGIT
	FOURTIES:
		movia r17, 0x00006600
		or r19, r19, r17
		subi r5, r5, 40
		br ONE_DIGIT
	FIFTIES:
		movia r17, 0x00006D00
		or r19, r19, r17
		subi r5, r5, 50
		br ONE_DIGIT

EXIT:
	ldw r5, 0(sp)
	ldw r6, 4(sp)
	ldw r17, 8(sp)
	ldw r18, 12(sp)
	ldw r19, 16(sp)
	ldw ra, 20(sp)
	ldw ea, 24(sp)
	addi sp, sp, 28
	ret
	
M_ZERO:
	movia r18, ADDR_7SEG1
	movia r19, 0x003F0000 # 00011111 will activate segments 0, 1, 2, 3, 4, 5
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_ONE:
	movia r18, ADDR_7SEG1
	movia r19, 0x00060000 # 00000110 will activate segments 1 and 2
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_TWO:
	movia r18, ADDR_7SEG1
	movia r19, 0x005B0000 # 01011011 will activate segments 0, 1, 3, 4, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_THREE:
	movia r18, ADDR_7SEG1
	movia r19, 0x004F0000 # 01001111 will activate segments 0, 1, 2, 3, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_FOUR:
	movia r18, ADDR_7SEG1
	movia r19, 0x00660000 # 01100110 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_FIVE:
	movia r18, ADDR_7SEG1
	movia r19, 0x006D0000 # 01101101 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_SIX:
	movia r18, ADDR_7SEG1
	movia r19, 0x007D0000 # 01111101 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT
	
M_SEVEN:
	movia r18, ADDR_7SEG1
	movia r19, 0x00070000 # 00000111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT

M_EIGHT:
	movia r18, ADDR_7SEG1
	movia r19, 0x007F0000 # 01111111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT

M_NINE:
	movia r18, ADDR_7SEG1
	movia r19, 0x006F0000 # 01101111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	#stwio r19, 0(r18)
	br TW0_DIGIT

ZERO:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000003F # 00011111 will activate segments 0, 1, 2, 3, 4, 5
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
ONE:
	movia r18, ADDR_7SEG1
	movia r17, 0x00000006 # 00000110 will activate segments 1 and 2
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
TWO:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000005B # 01011011 will activate segments 0, 1, 3, 4, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
THREE:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000004F # 01001111 will activate segments 0, 1, 2, 3, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
FOUR:
	movia r18, ADDR_7SEG1
	movia r17, 0x00000066 # 01100110 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
FIVE:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000006D # 01101101 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
SIX:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000007D # 01111101 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	
SEVEN:
	movia r18, ADDR_7SEG1
	movia r17, 0x00000007 # 00000111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT

EIGHT:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000007F # 01111111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT

NINE:
	movia r18, ADDR_7SEG1
	movia r17, 0x0000006F # 01101111 will activate segments 1, 2, 5, 6
	or r19, r19, r17
	stwio r19, 0(r18)
	br EXIT
	