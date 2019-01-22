 .equ ADDR_VGA, 0x08000000
 .equ SCREEN_WIDTH, 319
 .equ SCREEN_HEIGHT, 239

BACKGROUND:
    .incbin "Background.bmp"

TIMER_OUT:
	.incbin "Time_out.bmp"

COUNT_DOWN:
	.incbin "Count_Down.bmp"

.global draw_screen

draw_screen:
# PROLOGUE
	addi sp, sp, -48
	stw r14, 0(sp)
	stw r15, 4(sp)
	stw r16, 8(sp)
	stw r17, 12(sp)
	stw r18, 16(sp)
	stw r19, 20(sp)
	stw r20, 24(sp)
	stw r21, 28(sp)
	stw r13, 22(sp)
	stw r12, 36(sp)
	stw r11, 40(sp)
	stw ra, 44(sp)
	
	beq r4,r0,End_Screen #if time out then display the end screen
	movi r11, 2
	beq r4,r11,Count_Down #When the time is counting down change to this screen
	movia r16, BACKGROUND
	br Set_up_VGA
	
End_Screen:
	movia r16, TIMER_OUT
	br Set_up_VGA

Count_Down:
	movia r16, COUNT_DOWN

	
Set_up_VGA:
	addi r16, r16, 115
	#addi r17, r0, r0 # comparator for y
	addi r18, r0, SCREEN_WIDTH 	# comparator for x
	
	# start at (x,y) = (0,0)
	movi r20, 0 # starting x coordinate
	movi r21, SCREEN_HEIGHT			# starting y coordinate
	
draw_screen_yloop:
	bgt r0, r21, end_draw_screen_yloop
	
	draw_screen_xloop: 
		bgt r20, r18, end_draw_screen_xloop:
		
	    muli r14, r20, 2		# 2*x
	    muli r15, r21, 1024	    # 1024*y

	    add r13, r14, r15	# sum up offset
	    movia r11, ADDR_VGA
	    add r13, r13, r11
	
		mov r19, r13
		ldb r12, 0(r16)	
		sthio r12, 0(r19)	# store pixel into buffer
		
		addi r16,r16,1
		
		addi r20, r20, 1		# increment x by 1
		br draw_screen_xloop

	end_draw_screen_xloop:
		movi r20, 0 			# reset x to 0
		addi r21, r21, -1		# decrement y by 1
		br draw_screen_yloop
	
end_draw_screen_yloop:
# EPILOGUE
	ldw r14, 0(sp)
	ldw r15, 4(sp)
	ldw r16, 8(sp)
	ldw r17, 12(sp)
	ldw r18, 16(sp)
	ldw r19, 20(sp)
	ldw r20, 24(sp)
	ldw r21, 28(sp)
	ldw r13, 32(sp)
	ldw r12, 36(sp)
	ldw r11, 40(sp)
	ldw ra, 44(sp)
	addi sp, sp, 48
	
	ret
	





