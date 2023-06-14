.model small
.stack 100h
brick struc
	x dw 0
	y dw 0
	health db 0	
brick ends	
.data

isPaddle db 0
level_str db "Level: ",'$'

win_str db "You win",'$'
return_menu_str db "Press any key to return to main menu",'$'
lose_str db "Game over",'$'

row1 brick 10 dup (<>)
row2 brick 10 dup (<>)
row3 brick 10 dup (<>)
row4 brick 10 dup (<>)
row5 brick 10 dup (<>)
row6 brick 10 dup (<>)


uname db 14 dup('$')
menu_mode db 0
level db 1
lives db 3
score db 0
x dw 0
y dw 0
color db 0
curr_health db 0

brick_length dw 30
brick_height dw 11

slider_x dw 130
slider_y dw 180
slength dw 80
sheight dw 8

ball_x dw 160
ball_y dw 150
radius dw 4
ball_color db 0fh

vec_x dw 0
vec_y dw -1

bricks_left db 0

prev_time db 0

initial_sp dw 0

gameNameStr db "Brick Breaker Game",'$'
newGameStr db "New Game",'$'
ResumeStr db "Resume", '$'
InstructionStr db "Instructions",'$'
HighScoreStr db "High Score",'$'
Exitstr db "Exit",'$'

askname db "UserName : ",'$'
userName db 20 dup('$')
menu_x dw 70
menu_y dw 59
lineLength dw 6
TriangleColor db ?
MenuSelect db 1

handle dw ?
filename db "HighScores.txt",0
buffer db 65 dup('$')

InstructionMsg db "<- ARROW key will move the slider left ",10,"-> Arrow key will move slider right",10,10," You can hold the slider to move faster",10,10,"Try to beat the HighScore <3",10,10,"Break All the Blocks to move to proceed ",'$'
.code

brick_collision macro
	push cx

	mov ax,dx
	sub ax,30
	mov cl,11
	div cl
	mov ah,0
	mov cx,10
	mul cx
	mov dx,ax

	pop cx
	mov ax,cx
	sub ax,10
	mov cl,30
	div cl
	mov ah,0
	add ax,dx

	mov cx,type brick
	mul cx
	mov si,offset row1
	add si,ax

	mov ax,[si]
	mov x,ax
	mov ax,[si+2]
	mov y,ax
	mov al,[si+4]
	mov curr_health,al
	dec byte ptr[si+4]
	mov color,00h
	call drawBrick

	mov ax,0
	mov al,curr_health
	mov cl,3
	div cl

	mov al,ah
	mov ah,0
	mov cl,2
	div cl
	mov al,ah

	sub bricks_left,al
	mov cl,level
	mul cl
	add score,al
	call displayScore
	mov al,bricks_left
	cmp al,0
	je level2
endm

print3D macro v1
	pusha
	mov ax, 0
	mov bx,0
	mov cx,0
	mov dx,0
	mov al,v1
	mov bl, 100
	div bl
	mov dl, al
	mov cl, ah
	mov ah, 2h
	add dl,48
	int 21h
	mov al,cl
	mov ah,0
	mov bl,10
	div bl
	mov dl,al
	mov cl,ah
	mov ah,2h
	add dl,48
	int 21h
	mov dl, cl
	add dl, 48
	int 21h
	popa
endm

printStr macro p1
    pusha
        mov dx,offset p1
        mov ah,09h
        int 21h
    popa

endm

takeinputstr macro p2
    pusha
		mov cx,20
		mov dx,offset p2
		mov ah,3fh
		int 21h
    popa
endm

clearStack macro
	mov sp,initial_sp
endm

ClearScreen macro
	mov al,13h
	mov ah,0
	int 10h
endm

reset_values macro
	mov level,1
	mov lives,3
	mov slength,80
	mov score,0
endm

main proc

mov ax,@data
mov ds,ax
mov ax,0

mov initial_sp,sp
mov al, 13h ;activate video mode
int 10h

Title_Screen::
ClearScreen
call TitleScreen


Main_menu::
clearStack
reset_values
call menu

cmp byte ptr menuSelect,byte ptr 5
je exit
cmp byte ptr menuSelect, byte ptr 3
jne NotInstruction
call Instructions
jmp Main_menu
NotInstruction:

call InitBoard

call runGame

level2::
clearStack
mov al,level
cmp al,2
jae level3
mov level,2
inc lives
mov slength,70

call InitBoard

call runGame

level3::
mov al,level
cmp al,3
je WinScreen
mov slength,60
mov level,3
inc lives

call InitBoard
call runGame

WinScreen::
	call drawWinScreen

game_over::
	call drawGameover
exit::
mov ah,04ch
int 21h

main endp

TitleScreen proc
       
        mov al,0
        mov ah,02h
        mov dl,10
        mov dh,8
        int 10h
        printStr gameNameStr
        mov al,0
        mov ah,02h
        mov dl,9
        mov dh,12
        int 10h
        printstr askname
        takeinputstr username
        l1:
            mov bl,dh
            mov ah,1
            int 16h
        jnz l1
        ;mov ah,0
        ;int 16h
        ClearScreen 
    ret
TitleScreen endp

Menu proc
        mov al,0
        mov ah,02h
        mov dl,10
        mov dh,2
        int 10h
        printStr gameNameStr
        mov ah,02h
        mov dl,12
        add dh,5
        int 10h
        printStr NewGameStr
        mov ah,02h
        add dh,3
        int 10h
        printStr ResumeStr
        mov ah,02h
        add dh,3
        int 10h
        printStr InstructionStr
        mov ah,02h
        add dh,3
        int 10h
        printStr HighScoreStr
        mov ah,02h
        add dh,3
        int 10h
        printStr ExitStr

        l1:
            mov TriangleColor,0Bh
            call DrawTriangle
            mov bl,dh
            mov ah,1
            int 16h
        jnz l1
        mov ah,0
        int 16h
        .if(ah==48h)
            .if(menu_y > 59)
                mov TriangleColor, 00h
                call DrawTriangle
                sub menu_y,24
                sub menuSelect,1
            .endif
        .elseif(ah==50h)
            .if(menu_y<155)
                mov TriangleColor, 00h
                call DrawTriangle
                add menu_y,24
                add menuSelect,1
            .endif
        .endif
        .if(al!=13)
            jmp l1
        .endif

        ClearScreen
    ret

Menu endp

Instructions proc
	Zf=0
 		mov al,0
        mov ah,02h
        mov dl,1
        mov dh,8
        int 10h
        printStr InstructionMsg
		 l1:
            mov bl,dh
            mov ah,1
            int 16h
        jnz l1
        mov ah,0
        int 16h
        ClearScreen 
	ret
Instructions endp

DrawTriangle proc
    mov cx,menu_x
    mov dx,menu_y
    mov bx,0
    push Linelength
    
    .while( bx !=  4)
        sub LineLength,1
        inc bx
        push bx
        mov bx,0
        mov dx,menu_y
        .while(bx < Linelength)
            inc bx
            mov ah,0ch
            mov al,trianglecolor
            int 10h
            inc dx
        .endw
        inc cx
        pop bx
    .endw

    pop Linelength

    push Linelength
    mov cx,menu_x
    mov dx,menu_y
    mov bx,0
    .while( bx !=  6)
        sub LineLength,1
        inc bx
        push bx
        mov bx,0
        mov dx,menu_y
        .while(bx < Linelength)
            inc bx
            mov ah,0ch
            mov al,trianglecolor
            int 10h
            dec dx
        .endw
        inc cx
        pop bx
    .endw

    pop linelength
    ret
DrawTriangle endp

drawBrick proc
	push cx
	mov cx,x
    mov dx,y
	mov al,curr_health
	cmp al,2
	je broken1
	jg broken2
    s2:
    	s1:
    	    mov ah,0ch
    	    mov al,color
    	    int 10h
    	    inc cx
    	    mov ax,x
    	    add ax,brick_length
    	    cmp cx,ax
    	jne s1

	    inc dx
	    mov cx,x
	    mov ax,y
	    add ax,brick_height
	    cmp dx,ax
	jne s2
	pop cx
	ret

	broken1:
		mov cx,x
		mov dx,y 
		
		add dx,2
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		add cx,4
		sub dx,5
		mov ah,0ch
		mov al,08h
		int 10h

		add cx,12
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		sub cx,3
		add dx,3
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		dec cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		dec cx
		mov ah,0ch
		mov al,08h
		int 10h

		add cx,12
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		add cx,5
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		mov ah,0ch
		mov al,08h
		int 10h

		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		sub dx,5
		sub cx,7
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

	broken2:
		mov cx,x
		mov dx,y 
		add cx,6
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		dec cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		mov cx,x 
		mov dx,y 
		add cx,12
		add dx,4
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		push cx
		push dx

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		pop dx
		pop cx

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc dx
		mov ah,0ch
		mov al,08h
		int 10h

		inc cx
		dec dx
		mov ah,0ch
		mov al,08h
		int 10h

	pop cx
	ret

drawBrick endp

InitBoard proc
	mov bricks_left,60
	mov curr_health,1
	mov cx,60
	mov ax,brick_length
	mov bx,10
	mul bl
	mov dx,10
	add dx,ax
	mov ax,10
	mov bx,30
	mov si, offset row1
	l1:
		mov word ptr [si],ax
		mov word ptr [si+2],bx
		push ax
		mov al,level
		mov byte ptr [si+4],al
		pop ax
		add ax,brick_length
		cmp ax,dx
		jne rerun
		mov ax,10
		add bx,brick_height
		rerun:
		add si, type brick
	loop l1
	call drawBoard

	call drawSlider

	call drawBall

	call drawBorder
	ret	
InitBoard endp

drawBoard proc
	mov si,offset row1
	mov cx,60
	mov color,3
	l1:
		mov ax, word ptr[si]
		mov x,ax
		mov ax, word ptr[si+2]
		mov y,ax
		add si,type brick

		mov ax,cx
		mov bl,10
		div bl
		cmp ah,0
		je rerun

		mov al,color
		cmp al,3
		jne blue
		mov color,0dh
		jmp rerun
		blue:
		mov color,3
		rerun:
		call drawBrick
	loop l1

	mov al,level
	cmp al,3
	jne return
	mov si,offset row3
	add si,type brick
	add si,type brick
	add si,type brick
	mov cx,[si]
	mov x,cx
	mov dx,[si+2]
	mov y,dx
	mov color,7
	call drawBrick
	add si,type brick
	add si,type brick
	add si,type brick
	mov cx,[si]
	mov x,cx
	mov dx,[si+2]
	mov y,dx
	mov color,7
	call drawBrick

	return:
	ret
drawBoard endp

drawSlider proc
	mov cx,slider_x
    mov dx,slider_y

    s2:
    	s1:
    	    mov ah,0ch
    	    mov al,07h
    	    int 10h
    	    inc cx
    	    mov ax,slider_x
    	    add ax,slength
    	    cmp cx,ax
    	jne s1

	    inc dx
	    mov cx,slider_x
	    mov ax,slider_y
	    add ax,sheight
	    cmp dx,ax
	jne s2
	ret
drawSlider endp

delSlider proc
	mov cx,slider_x
    mov dx,slider_y

    s2:
    	s1:
    	    mov ah,0ch
    	    mov al,00h
    	    int 10h
    	    inc cx
    	    mov ax,slider_x
    	    add ax,10
    	    cmp cx,ax
    	jne s1

	    inc dx
	    mov cx,slider_x
	    mov ax,slider_y
	    add ax,sheight
	    cmp dx,ax
	jne s2
	mov cx,slider_x
    mov dx,slider_y
	add cx, slength
	sub cx,10

    s4:
    	s3:
    	    mov ah,0ch
    	    mov al,00h
    	    int 10h
    	    inc cx
    	    mov ax,slider_x
    	    add ax,slength
    	    cmp cx,ax
    	jne s3

	    inc dx
	    mov cx,slider_x
		add cx, slength
		sub cx,10
	    mov ax,slider_y
	    add ax,sheight
	    cmp dx,ax
	jne s4
	ret
delSlider endp

removeSlider proc
	mov cx,slider_x
    mov dx,slider_y

    s2:
    	s1:
    	    mov ah,0ch
    	    mov al,00h
    	    int 10h
    	    inc cx
    	    mov ax,slider_x
    	    add ax,slength
    	    cmp cx,ax
    	jne s1

	    inc dx
	    mov cx,slider_x
	    mov ax,slider_y
	    add ax,sheight
	    cmp dx,ax
	jne s2
	ret
removeSlider endp

drawBall proc
	mov cx,ball_x
	mov dx,ball_y
	s2:
    	s1:
    	    mov ah,0ch
    	    mov al,ball_color
    	    int 10h
    	    inc cx
    	    mov ax,ball_x
    	    add ax,radius
    	    cmp cx,ax
    	jne s1

	    inc dx
	    mov cx,ball_x
	    mov ax,ball_y
	    add ax,radius
	    cmp dx,ax
	jne s2

	mov cx,ball_x
	mov dx,ball_y
	inc cx
	dec dx
	mov ah,0ch
    mov al,ball_color
    int 10h
	inc cx
	mov ah,0ch
    mov al,ball_color
    int 10h
	add cx,2
	add dx,2
	mov ah,0ch
    mov al,ball_color
    int 10h
	inc dx
	mov ah,0ch
    mov al,ball_color
    int 10h
	add dx,2
	sub cx,2
	mov ah,0ch
    mov al,ball_color
    int 10h
	dec cx
	mov ah,0ch
    mov al,ball_color
    int 10h
	sub cx,2
	sub dx,2
	mov ah,0ch
    mov al,ball_color
    int 10h
	dec dx
	mov ah,0ch
    mov al,ball_color
    int 10h
	ret
drawBall endp

runGame proc
	mov bp,sp
	timed_loop:
	call moveSlider
	mov ah,2ch
	int 21h
	cmp dl,prev_time
	je timed_loop

	mov prev_time,dl

	call moveBall
	call moveBall
	call moveBall
	call moveBall

	cmp level,2
	jb timed_loop
	call moveBall

	cmp level,3
	jb timed_loop
	call moveBall
	
	jmp timed_loop
	mov sp,bp
	ret
runGame endp

moveSlider proc
	mov ah,1
	int 16h
	jz return
	mov ah,0
	int 16h
	cmp ah,4bh
	je move_left
	cmp ah,4dh
	je move_right
	cmp al,01
	jmp return
	move_left:
		mov ax,slider_x
		cmp ax,10
		jg move1
		mov slider_x,11
		move1:
		call delSlider
		sub slider_x,10
		call drawSlider
		jmp return
	move_right:
		mov ax,slider_x
		mov bx,310
		sub bx,slength
		cmp ax,bx
		jl move2
		mov slider_x,bx
		dec slider_x
		move2:
		call delSlider
		add slider_x,10
		call drawSlider
	return:
	ret
moveSlider endp

moveBall proc
	call check_collision
	mov ball_color,00h
	call drawBall
	mov ax,vec_x
	add ball_x,ax
	mov ax,vec_y
	add ball_y,ax
	mov ball_color,0fh
	call drawBall
	ret
moveBall endp

check_collision proc
	mov ax,ball_y
	mov isPaddle,0
	cmp ax,174
	jg special_case
	temp_here:
	mov ax,vec_x
	mov bx,vec_y
		cmp ax,0
		je top_bot
		jg right_botright_topright
		jmp left_botleft_topleft
	top_bot:
		cmp bx,1
		je bot
		jmp top
	right_botright_topright:
		cmp bx,0
		je right
		jg botright
		jmp topright
	left_botleft_topleft:
		cmp bx,0
		je left
		jg botleft
		jmp topleft
	top:
		mov cx,ball_x
		mov dx,ball_y

		dec cx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbot

		inc cx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbot

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl
		ret
	bot:
		mov cx,ball_x
		mov dx,ball_y

		dec cx
		add dx,3
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne sett

		inc cx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne sett

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl


		ret
	right:
		mov cx,ball_x
		mov dx,ball_y

		dec dx
		add cx,3
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setr

		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		ret
	left:
		mov cx,ball_x
		mov dx,ball_y

		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setr

		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr
		ret
	topright:
		mov cx,ball_x
		mov dx,ball_y

		inc dx
		add cx,5
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl

		dec cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl

		dec cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl

		dec cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		ret
	topleft:
		mov cx,ball_x
		mov dx,ball_y

		inc dx
		sub cx,2
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		inc cx
		dec dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl

		ret
	botright:
		mov cx,ball_x
		mov dx,ball_y

		add dx,2
		add cx,5
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbl

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl

		dec cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr
		ret
	botleft:
		mov cx,ball_x
		mov dx,ball_y

		add dx,2
		sub cx,2
		mov ah,0dh
		int 10h
		cmp al,00h
		jne setbr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settr

		inc cx
		inc dx
		mov ah,0dh
		int 10h
		cmp al,00h
		jne settl
		ret
	sett:
		cmp al,07h
		je l1
		brick_collision
		l1:
		mov bl,isPaddle
		cmp bl,0
		je next1
		mov isPaddle,0
		mov bx,slength
		shr bx,1
		sub bx,6  ;center hitbox
		add bx,slider_x
		cmp cx,bx
		jb settl
		add bx,12
		cmp cx,bx
		ja settr
		next1:
		mov vec_x,0
		mov vec_y,-1
		ret
	setbot:
		cmp al,07h
		je l2
		brick_collision
		l2:
		mov vec_x,0
		mov vec_y,1
		ret
	setr:
		cmp al,07h
		je l3
		brick_collision
		l3:
		mov vec_x,1
		mov vec_y,0
		ret
	setleft:
		cmp al,07h
		je l4
		brick_collision
		l4:
		mov vec_x,-1
		mov vec_y,0
		ret
	setbr:
		cmp al,07h
		je l5
		brick_collision
		l5:
		mov vec_x,1
		mov vec_y,1
		ret
	setbl:
		cmp al,07h
		je l6
		brick_collision
		l6:
		mov vec_x,-1
		mov vec_y,1
		ret
	settr:
		cmp al,07h
		je l7
		brick_collision
		l7:
		call drawSides
		mov bl,isPaddle
		cmp bl,0
		je next7
		mov isPaddle,0
		mov bx,slength
		shr bx,1
		sub bx,6
		add bx,slider_x
		cmp cx,bx
		jb settl
		add bx,12
		cmp cx,bx
		ja settr
		jmp sett
		next7:
		mov ball_color,00h
		call drawBall
		dec ball_x
		mov vec_x,1
		mov vec_y,-1
		ret
	settl:
		cmp al,07h
		je l8
		brick_collision
		l8:
		call drawSides
		mov bl,isPaddle
		cmp bl,0
		je next8
		mov isPaddle,0
		mov bx,slength
		shr bx,1
		sub bx,6
		add bx,slider_x
		cmp cx,bx
		jb settl
		add bx,12
		cmp cx,bx
		ja settr
		jmp sett
		next8:
		mov ball_color,00h
		call drawBall
		inc ball_x
		mov ball_color,0fh
		mov vec_x,-1
		mov vec_y,-1
		ret
	special_case:
		cmp ax,194
		jle paddle_check
		mov ball_color,00h
		call drawBall
		mov ball_x,160
		mov ball_y,150
		mov ball_color,0fh
		call drawBall
		call removeSlider
		mov slider_x, 130
		mov slider_y, 180
		call drawSlider
		mov vec_x,1
		mov vec_y,-1
		dec lives
		cmp lives,0
		je game_over  ;change later
		call drawLives
		mov ah,00h
		int 16h
		ret
		paddle_check:
		mov isPaddle,1
		jmp temp_here
	ret	
check_collision endp

drawHeart proc
	mov cx,x
	mov dx,y
outline:
	s1:
		mov ah,0ch
		mov al,00h
		int 10h
		inc cx
		dec dx
		mov ax,x
		add ax,4
		cmp cx,ax
	jne s1
	s2:
		mov ah,0ch
		mov al,00h
		int 10h
		dec dx
		mov ax,y
		sub ax,6
		cmp dx,ax
	jne s2

	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	dec dx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	dec dx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	inc dx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	dec dx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	inc dx
	mov ah,0ch
	mov al,00h
	int 10h

	dec cx
	inc dx
	mov ah,0ch
	mov al,00h
	int 10h

	inc dx
	mov ah,0ch
	mov al,00h
	int 10h

	inc dx
	mov ah,0ch
	mov al,00h
	int 10h

	inc dx
	inc cx
	mov ah,0ch
	mov al,00h
	int 10h

	inc dx
	inc cx
	mov ah,0ch
	mov al,00h
	int 10h

	inc dx
	inc cx
	mov ah,0ch
	mov al,00h
	int 10h

fill_heart:
	mov dx,y
	mov cx,x
	sub cx,3
	sub dx,6
	l1:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,3
		cmp dx,ax
	jne l1
	sub dx,4
	inc cx
	l2:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,2
		cmp dx,ax
	jne l2
	sub dx,5
	inc cx
	l3:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,1
		cmp dx,ax
	jne l3
	sub dx,5
	inc cx
	l4:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		cmp dx,ax
	jne l4
	sub dx,7
	inc cx
	l5:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,1
		cmp dx,ax
	jne l5
	sub dx,6
	inc cx
	l6:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,2
		cmp dx,ax
	jne l6
	sub dx,4
	inc cx
	l7:
		mov ah,0ch
		mov al,04h
		int 10h
		inc dx
		mov ax,y
		sub ax,3
		cmp dx,ax
	jne l7
	mov cx,x
	mov dx,y
	sub dx,6
	sub cx,2
	mov ah,0ch
	mov al,0fh
	int 10h
	ret
drawHeart endp

drawBorder proc
	mov cx,0
	mov dx,0
	s1:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc dx
        cmp dx,200
    jne s1
	mov dx,0
	s2:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc cx
        cmp cx,320
    jne s2
		inc dx
	    mov cx,0
	    cmp dx,20
	jne s2

	dec cx
	s3:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc dx
        cmp dx,200
    jne s3
	mov ah,02h
	mov bx,0
	mov dh, 1 ;Row Number
	mov dl, 30 ;Column Number
	int 10h
	mov dx,offset level_str
	mov ah,9h
	int 21h
	mov dx,0
	mov dl,level
	mov ah,2h
	add dl,"0"
	int 21h
	mov cx,210
	mov dx,5
	s4:
   	    mov ah,0dh
	    int 10h
		cmp al,07h
		je rerun
		cmp al,0fh
		jne next
		mov ah,0ch
		mov al,00h
		int 10h
		jmp rerun
		next:
		mov ah,0ch
		mov al,07h
		int 10h
		rerun:
        inc cx
        cmp cx,320
    jne s4
		inc dx
	    mov cx,210
	    cmp dx,20
	jne s4

	call drawLives
	call displayScore
	ret
drawBorder endp

displayScore proc
	mov ah,02h
	mov bx,0
	mov dh, 1 ;Row Number
	mov dl, 20 ;Column Number
	int 10h
	print3d score
	mov cx,140
	mov dx,5
	s1:
   	    mov ah,0dh
	    int 10h
		cmp al,07h
		je rerun
		cmp al,0fh
		jne next
		mov ah,0ch
		mov al,00h
		int 10h
		jmp rerun
		next:
		mov ah,0ch
		mov al,07h
		int 10h
		rerun:
        inc cx
        cmp cx,200
    jne s1
		inc dx
	    mov cx,140
	    cmp dx,20
	jne s1
	ret
displayScore endp

drawlives proc
	mov cx,0
	mov dx,0
	s1:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc cx
        cmp cx,90
    jne s1
		inc dx
	    mov cx,0
	    cmp dx,20
	jne s1
	mov x,15
	mov y,13
	mov cx,0
	mov cl,lives
	l1:
		push cx
		call drawHeart
		pop cx
		add x,15
	loop l1
	ret
drawLives endp

drawWinScreen proc
	ClearScreen
	mov ah,02h
	mov bx,0
	mov dh, 8 ;Row Number
	mov dl, 17 ;Column Number
	int 10h
	mov dx,offset win_str
	mov ah,9h
	int 21h
	mov ah,02h
	mov bx,0
	mov dh, 13 ;Row Number
	mov dl, 3 ;Column Number
	int 10h
	mov dx,offset return_menu_str
	mov ah,9h
	int 21h
	mov ah,0
	int 16h
	ClearScreen
	jmp Main_menu;SUBJECT TO CHANGE
drawWinScreen endp

drawGameover proc
	ClearScreen
	mov ah,02h
	mov bx,0
	mov dh, 8 ;Row Number
	mov dl, 17 ;Column Number
	int 10h
	mov dx,offset lose_str
	mov ah,9h
	int 21h
	mov ah,02h
	mov bx,0
	mov dh, 13 ;Row Number
	mov dl, 3 ;Column Number
	int 10h
	mov dx,offset return_menu_str
	mov ah,9h
	int 21h
	mov ah,0
	int 16h
	ClearScreen

	mov ah,3ch
	mov cx,0
	mov dx,offset filename
	int 21h

	mov ah,3dh ; STARTED FROM HERE
	mov al,1
	mov dx,offset filename
	int 21h
	mov handle,ax


	mov cx,0
	mov dx,0
	mov ah,42h
	mov al,2
	int 21h
	mov ah,40h
	mov bx,handle
	mov cx,lengthof username
	mov dx,offset username
	int 21h

	mov cx,0
	mov dx,0
	mov ah,42h
	mov al,2
	int 21h
	mov ah,40h
	mov bx,handle
	mov cx,lengthof score
	mov dx,offset score
	int 21h

	mov ah,3eh
	mov bx,handle
	int 21h

	ClearScreen
	jmp Main_menu;subject to change
drawGameover endp

drawSides proc
	push ax
	push bx
	push cx
	push dx
	mov cx,0
	mov dx,0
	s1:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc dx
        cmp dx,200
    jne s1
	mov dx,0
	mov cx,319
	s2:
   	    mov ah,0ch
   	    mov al,07h
	    int 10h
        inc dx
        cmp dx,200
	jne s2
	pop dx
	pop cx
	pop bx
	pop ax
	ret
drawSides endp

pauseScreen proc
	ret
pauseScreen endp

end main