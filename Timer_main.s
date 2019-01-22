
.equ Timer, 0xFF202000
.equ LED, 0xFF200000
.equ ADDR_SLIDESWITCHES, 0xFF200040 


.equ PS2_CONTROLLER_1, 0xFF200100
.equ zero, 0x45
.equ one, 0x16
.equ two, 0x1E
.equ three, 0x26
.equ four, 0x25
.equ five, 0x2E
.equ six, 0x36
.equ seven, 0x3D
.equ eight, 0x3E
.equ nine, 0x46
.equ M, 0x3A
.equ S, 0x1B
.equ z, 0x70
.equ o, 0x69
.equ tw, 0x72
.equ th, 0x7A
.equ fo, 0x6B
.equ fi, 0x73
.equ si, 0x74
.equ se, 0x6C
.equ e, 0x75
.equ n, 0x7D
#.equ DELETE, 0x66
#.equ ENTER, 0x5A

.equ PERIOD, 100000000

	# r5: Stores seconds for argument to hex
	# r6: Stores minutes for argument to hex
	# r22: Stores minutes as Global variable
	# r23: Stores seconds as Global variable
	


.section .exceptions, "ax"
Interrrupt:
	addi sp,sp, -20
	rdctl et, ctl1
	stw et, 0(sp)
	stw ea, 4(sp)
	stw r16, 8(sp)
	stw r17, 12(sp)
	stw ra, 16(sp)

	# check keyboard
	rdctl et, ctl4
	andi et, et, 0x80
	bne et, r0, keyboard_interrupt_handler
	
	
	#check timer
	rdctl et, ctl4
	andi et, et, 1
	beq et, r0, TimerInterrupt
	#br Timer_reset


TimerInterrupt:
	movi r4,2 #Change the VGA
	call draw_screen
	call CLEAR_TIME
	call SHOW_TIME #Display it in vga
	beq r23,r0,Reload
	br Show_In_Hex


Reload:
	beq r22,r0, Blink_Led #All time is at 0
	mov r5,r23 #store the seconds
	mov r6,r22 #store minutes
	call SEVENSEGDISPLAY #display it in hex
	movi r23, 59 #reload seconds
	subi r22, r22, 1 #subtract minutes
	br Timer_reset

Blink_Led:
	xori r11, r11, 1
	movia et, LED
	stwio r11,0(et)
	mov r5,r23 #store the seconds
	mov r6,r22 #store minutes
	call SEVENSEGDISPLAY #display it in hex

	mov r4,r0 #display it on vga
	call draw_screen

	call audio_setup #output audio

	br Timer_reset

Show_In_Hex:
	mov r5,r23 #store the seconds
	mov r6,r22 #store minutes
	call SEVENSEGDISPLAY #display it in hex
	subi r23, r23,1
	br Timer_reset
	
	
Timer_reset:
	movia et, Timer
	stwio r0, 0(et) # acknowledge timer
	movia et, 0x01
	wrctl ctl0, et
	br Exit



Exit:
	ldw et, 0(sp)
	ldw ea, 4(sp)
	ldw r16, 8(sp)
	ldw r17, 12(sp)
	ldw ra, 16(sp)
	wrctl ctl1, et
	addi sp, sp, 20
	subi ea, ea, 4
	eret

	
	
	
	
#.global keyboard_interrupt_handler

keyboard_interrupt_handler:	
	
KEYBOARD:
#store in stack 
	subi sp, sp, 24
	stw r18, 0(sp)
	stw r19, 4(sp)
	stw r20, 8(sp)
	stw r8, 12(sp)
	stw ra, 16(sp)
	stw ea, 20(sp)

	movia r5, PS2_CONTROLLER_1
	
	#disable interrupt in keyboard
	#stwio r0, 4(r5)
	movia r6, 0b0
	stwio r6, 4(r5)
	
LOOP:
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are any characters to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, LOOP
	 
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
	movia r19, M
	beq r8, r19, GET_MINUTES
	
	movia r19, S
	beq r8, r19, GET_SECONDS
	
	br LOOP
	
GET_MINUTES:
    
    movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are any characters to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, GET_MINUTES
	
    # mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, zero
	beq r8, r19, MIN_zero
	
	movia r19, one
    beq r8, r19, MIN_one
	
	movia r19, two
    beq r8, r19, MIN_two
    
    movia r19, three
	beq r8, r19, MIN_three
	
	movia r19, four
    beq r8, r19, MIN_four
	
	movia r19, five
    beq r8, r19, MIN_five
    
    movia r19, six
	beq r8, r19, MIN_six
	
	movia r19, seven
    beq r8, r19, MIN_seven
	
	movia r19, eight
    beq r8, r19, MIN_eight
    
    movia r19, nine
	beq r8, r19, MIN_nine
	
	br GET_MINUTES
	

GET_SECONDS:

    movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are any characters to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, GET_SECONDS
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, zero
	beq r8, r19, SEC_zero
	
	movia r19, one
    beq r8, r19, SEC_one
	
	movia r19, two
    beq r8, r19, SEC_two
    
    movia r19, three
	beq r8, r19, SEC_three
	
	movia r19, four
    beq r8, r19, SEC_four
	
	movia r19, five
    beq r8, r19, SEC_five
    
    movia r19, six
	beq r8, r19, SEC_six
	
	movia r19, seven
    beq r8, r19, SEC_seven
	
	movia r19, eight
    beq r8, r19, SEC_eight
    
    movia r19, nine
	beq r8, r19, SEC_nine
	
	br GET_SECONDS
	
MIN_zero:
	
	movi r20, 0
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_zero
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_zero
	
MIN_one:
	
	movi r20, 1
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_one
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_one

MIN_two:
	
	movi r20, 2
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_two
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_two
	
MIN_three:
	
	movi r20, 3
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_three
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_three
	
MIN_four:
	
	movi r20, 4
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_four
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_four
	
MIN_five:
	
	movi r20, 5
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_five
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_five
	
MIN_six:
	
	movi r20, 6
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_six
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_six
	
MIN_seven:
	
	movi r20, 7
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_seven
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_seven
	
MIN_eight:
	
	movi r20, 8
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_eight
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_eight

MIN_nine:
	
	movi r20, 9
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, MIN_nine
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_M_zero
	
	movia r19, o
    beq r8, r19, GET_M_one
	
	movia r19, tw
    beq r8, r19, GET_M_two
    
    movia r19, th
	beq r8, r19, GET_M_three
	
	movia r19, fo
    beq r8, r19, GET_M_four
	
	movia r19, fi
    beq r8, r19, GET_M_five
    
    movia r19, si
	beq r8, r19, GET_M_six
	
	movia r19, se
    beq r8, r19, GET_M_seven
	
	movia r19, e
    beq r8, r19, GET_M_eight
    
    movia r19, n
	beq r8, r19, GET_M_nine
	
	br MIN_nine
	
SEC_zero:
	
	movi r20, 0
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_zero
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_zero
	
SEC_one:
	
	movi r20, 1
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_one
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_one

SEC_two:
	
    movi r20, 2
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_two
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_two
	
SEC_three:
	
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_three
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
	
	movi r20, 3
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_three
	
SEC_four:
	
	movi r20, 4
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_four
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_four
	
SEC_five:
	
	movi r20, 5
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_five
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_five
	
SEC_six:
	
	movi r20, 6
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_six
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_six
	
SEC_seven:
	
    movi r20, 7
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_seven
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_seven
	
SEC_eight:
	
	movi r20, 8
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_eight
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_eight

SEC_nine:
	
	
	movi r20, 9
	
	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	beq r8, r0, SEC_zero
	
	# mask the last 8 bits of data
	andi r8, r18, 0xFF
	
    movia r19, z
	beq r8, r19, GET_S_zero
	
	movia r19, o
    beq r8, r19, GET_S_one
	
	movia r19, tw
    beq r8, r19, GET_S_two
    
    movia r19, th
	beq r8, r19, GET_S_three
	
	movia r19, fo
    beq r8, r19, GET_S_four
	
	movia r19, fi
    beq r8, r19, GET_S_five
    
    movia r19, si
	beq r8, r19, GET_S_six
	
	movia r19, se
    beq r8, r19, GET_S_seven
	
	movia r19, e
    beq r8, r19, GET_S_eight
    
    movia r19, n
	beq r8, r19, GET_S_nine
	
	br SEC_nine

GET_M_zero:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    # first place digit is zero so no need to add anything 
    mov r22, r20
    
    br GET_SECONDS
    
GET_M_one:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 1
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_two:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 2
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_three:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 3
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_four:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 4
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_five:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 5
    
    mov r22, r20
    
    br GET_SECONDS
    
GET_M_six:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 6
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_seven:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 7
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_eight:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 8
    
    mov r22, r20
    
    br GET_SECONDS

GET_M_nine:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 9
    
    mov r22, r20
    
    br GET_SECONDS
	

GET_S_zero:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    # first place digit is zero so no need to add anything 
    mov r23, r20
    
    br EXIT_INPUT
    
GET_S_one:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 1
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_two:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 2
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_three:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 3
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_four:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 4
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_five:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 5
    
    mov r23, r20
    
    br EXIT_INPUT
    
GET_S_six:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 6
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_seven:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 7
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_eight:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 8
    
    mov r23, r20
    
    br EXIT_INPUT

GET_S_nine:
    # multiply content in r20 by 10
    mov r16, r20
    add r16, r16, r16
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r20
    add r20, r20, r16
    
    #add new value (first place digit)
    addi r20, r20, 9
    
    mov r23, r20
    
    br EXIT_INPUT
	
EXIT_INPUT:

	movia r8, PS2_CONTROLLER_1
	ldwio r18, 0(r8)
	
	#check if there are still chars to read
	movia r8, 0x8000
	and r8, r18, r8
	bne r8, r0, EXIT_INPUT
	
    #epilogue
	ldw r18, 0(sp)
	ldw r19, 4(sp)
	ldw r20, 8(sp)	
	ldw ra, 16(sp)
	ldw r8, 12(sp)
	ldw ea, 20(sp)
	addi sp, sp, 24
	
	movia r5, PS2_CONTROLLER_1
	
	#enable interrupt in keyboard
	stwio r0, 4(r5)
	movia r6, 0b1
	stwio r6, 4(r5)
	
	br Exit
	
	
	
	

.section .text
.global _start
_start:
#initialize

#Global Variable
movi r23, 2 #default seconds time
movi r22,0 #minutes
movia sp, 0x40000000
movia  r4,100000000


movia r2, ADDR_SLIDESWITCHES
ldwio r3, 0(r2)

mov r22, r3

movi r4, 1 #display background
call draw_screen

call GET_INPUT

movia r9, Timer
movia r10, LED
movia r11, 0x00
stwio r11,0(r10)
movi r8, %lo(PERIOD)
stwio r8, 8(r9)
movi r8, %hi(PERIOD)
stwio r8, 12(r9)
stwio r0, 0(r9) #clear
movi r8, 0b111
stwio r8, 4(r9) #initialize interrupt, continue and start


#enable IRQ line
movia r6, 0x81
wrctl ctl3, r6
	
#enable global master enable
movi r6, 1
wrctl ctl0, r6

loop:
br loop
















######################Keyboard#################################



	

.global GET_INPUT

GET_INPUT:

    subi sp, sp, 12
	stw r5, 0(sp)
	stw r6, 4(sp)
	stw ra, 8(sp)
	
	
	movia r5, PS2_CONTROLLER_1
	
	#enable interrupt in keyboard
	stwio r0, 4(r5)
	movia r6, 0b1
	stwio r6, 4(r5)
	
	
	
	ldw r5, 0(sp)
	ldw r6, 4(sp)
	ldw ra, 8(sp)
	addi sp, sp, 12
	ret
	
	



