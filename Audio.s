
.equ ADDR_AUDIODACFIFO, 0xFF203040
.equ no_of_bytes_audio, 9186212
#.equ no_of_bytes_audio, 65535
.equ ADDR_SLIDESWITCHES, 0xFF200040 
.equ PS2_CONTROLLER_1, 0xFF200100

	# r19: Stores max unsigned number
	# r21: Stores the number to multiphy r19 by to play it for specific bytes
	# r22: Stores minutes as Global variable
	# r23: Stores seconds as Global variable
	

.global audio_setup

ALARM1:
.incbin "guitar.wav"


ALARM2:
.incbin "drums.wav"

ALARM3:
.incbin "bass.wav"

audio_setup:	
	#prologue
	subi sp, sp, 44
	stw r21, 0(sp)
	stw r16, 4(sp)
	stw r17, 8(sp)
	stw r18, 12(sp)
	stw r19, 16(sp)
	stw r20, 20(sp)
	stw r2, 24(sp)
	stw r3, 28(sp)
	stw r6, 32(sp)
	stw ra, 36(sp)
	stw ea, 40(sp)
	
	

	
	
	

	movia r16,ADDR_AUDIODACFIFO #address of the audio
	#clear the audio fifo
	ldwio r17,0(r16)
	ori r17,r17,0x0c
	stwio r17,0(r16)
	subi r17,r17,0x0c
	stwio r17,0(r16)
	
	#get the user's choice for alarm sound
	movia r2, ADDR_SLIDESWITCHES
	ldwio r3, 0(r2)
	
	#Check what the user wants for the sound
	movi r18, 1
	beq r3, r18, play_alarm1
	
	movi r18, 2
	beq r3, r18, play_alarm2
		
	#default alarm
	movia r17, ALARM1
	addi r17, r17, 44 #skip the header of WAV
	movui r19, 65535
	movi r21, 30
	br WaitForWriteSpace
	
#Alarm is played for same amount of time	
play_alarm1:
	movia r17, ALARM2
	addi r17, r17, 44 #skip the header of WAV
	movui r19, 65535
	movi r21, 30
	br WaitForWriteSpace

play_alarm2:
	movia r17, ALARM3
	addi r17, r17, 44 #skip the header of WAV
	movui r19, 65535
	movi r21, 30
	br WaitForWriteSpace

	
WaitForWriteSpace:
	movia r3, PS2_CONTROLLER_1
	ldwio r18, 0(r3)
	
	#check if there are any characters to read
	movia r2, 0x8000
	and r2, r18, r2
	bne r2, r0, exit
	
    ldwio r18, 4(r16)
    andhi r3, r18, 0xff00
    beq r3, r0, WaitForWriteSpace
    andhi r3, r18, 0xff
    beq r3, r0, WaitForWriteSpace
	
produce_sound:
#check if minute is 0, if it is not then check seconds
	bne r22,r0,exit_check 
play:
	ldw r18, 0(r17)	#load sample which are 16 bits
	stwio r18, 8(r16) #output audio to the left channel
	stwio r18, 12(r16) #output audio to the right channel
	addi r17, r17,2 #16 bit per sample
	subi r19, r19,2	
	bgt r19,r0, WaitForWriteSpace #keep playing until it runs out
	movui r19, 65535 
	subi r21,r21,1
	bne r21, r0, WaitForWriteSpace
	br stop_sound


stop_sound:
	stwio r0, 8(r16) #output audio to the left channel
	stwio r0, 12(r16) #output audio to the right channel
	br exit 

#Check if seconds is 0, if it is not do not play alarm
exit_check:
	bne r23,r0,exit
	br play 
	
exit:

	#epilogue
	
	ldw r21, 0(sp)
	ldw r16, 4(sp)
	ldw r17, 8(sp)
	ldw r18, 12(sp)
	ldw r19, 16(sp)
	ldw r20, 20(sp)
	ldw r2, 24(sp)
	ldw r3, 28(sp)
	ldw r6, 32(sp)
	ldw ra, 36(sp)
	ldw ea, 40(sp)
	addi sp, sp, 44
	ret

	
	