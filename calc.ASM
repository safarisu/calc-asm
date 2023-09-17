org 100h

konwert:
	call enter
	mov ah, 9
	mov dx, prompt
	int 21h
	
	call enter
	mov ah, 10
	mov dx, wejscie
	int 21h
	
	mov bp, wejscie
	add bp, 2
	
	;call enter
    ;mov ah, 9
	;mov dx, bp
	;int 21h
	
	mov bx, wyjscie ;wskaznik na wyjscie	
	
	;call enter
	
	push 36 ;dolar na stos
	
	wczytaj:
		mov al, [bp] ;wczytaj z wejscia
		;mov cl, al
		
		;call enter
		
		;mov ah, 2
		;mov dl, cl
		;int 21h 
		
		cmp al, 13 ;36
		je zdejmij
		
		;zdecyduj co za znak
		;bp wskaznik na wejscie?
		;w dx przechowuj priorytet obecnego?
		;w bx wskaznik na wyjscie?
		;cx wolne?
		cmp al, 40 ;lewy nawias
		je lewy
		
		cmp al, 41 ;prawy nawias
		je prawy
		
		cmp al, 43 ;plus 
		je oper1 
		
		cmp al, 45 ;minus
		je oper1
		
		cmp al, 42 ;mnoz 
		je oper2
		
		cmp al, 47 ;dziel
		je oper2
		
		jmp stala
		
	lewy:
		push ax
		jmp inkrem
		
	prawy:
		pop ax
		
		cmp al, 40
		je inkrem
		
		mov [bx], al
		inc bx
		mov al, 32
		mov [bx], al
		inc bx
		
		jmp prawy
		
	oper1: ;operatory o priorytecie 1
		mov dx, ax ;przechowaj obecnie wczytany
	
	oper1s:	
		pop ax
		
		cmp al, 36
		je dolar
		
		cmp al, 40
		je prior1
		
		mov [bx], al
		inc bx
		mov al, 32
		mov [bx], al
		inc bx
		
		jmp oper1s ;moze byc zle
		
		
	oper2: ;operatory o priorytecie 2
		mov dx, ax
	
	oper2s:
		pop ax
		
		cmp al, 36
		je dolar
		
		cmp al, 40
		je prior1
		
		cmp al, 43
		je prior1
		
		cmp al, 45
		je prior1 
		
		cmp al, 42
		je prior2
		
		cmp al, 47
		je prior2
		
	prior1:
		push ax
		push dx
		jmp inkrem
		
	prior2:
		mov [bx], al
		inc bx
		mov al, 32
		mov [bx], al
		inc bx
		
		jmp oper2s
		
		
	stala:
		mov [bx], al
		inc bx
		mov al, 32
		mov [bx], al
		inc bx
		
	inkrem:
		inc bp
		jmp wczytaj
		
	nawias:
		push dx
		jmp inkrem
		
	zdejmij:
		pop ax
		
		cmp al, 36
		je wyswietl
		
		mov [bx], al
		inc bx
		mov al, 32
		mov [bx], al
		inc bx
		
		jmp zdejmij
	
	wyswietl:
		call enter
		mov ah, 9
		mov dx, wyjscie
		int 21h
	
mov bp, wyjscie

;mov ah,2
;mov dx, 36
;int 21h
	
wartosc:
	mov cl, [bp]
	
	cmp cl, 36
	je wynik
	
	cmp cl, 32
	je inkrem1
	
	cmp cl, 48
	jl operacja
	
	sub cl, 48
	push cx
	
	jmp inkrem1
	
	operacja:
		pop bx
		pop ax
		
		cmp cl, 43 ;plus 
		je plus
			
		cmp cl, 45 ;minus
		je minus
			
		cmp cl, 42 ;mnoz 
		je mnoz
			
		cmp cl, 47 ;dziel
		je dziel
	
	plus:
		add ax, bx
		push ax
		jmp inkrem1
		
	minus:
		sub ax, bx
		push ax
		jmp inkrem1
		
	mnoz:
		mul bx
		push ax
		jmp inkrem1
		
	dziel:
		cmp bx, 0
		je dzielzero
		xor dx,dx
		div bx
		push ax
		
	inkrem1:
		inc bp
		jmp wartosc

przerwa: 		
call enter
mov ah, 2
pop dx
add dx, 48
int 21h

jmp koniec
;call enter 
		
wynik:
	pop ax
	xor dx, dx
	xor cx, cx
	xor bx, bx
	mov bx, 10
	
	dzies:
		div bx
		push dx
		inc cx
		xor dx, dx
		cmp ax, 0
		jg dzies
	
	mov ah,2
	
	call enter
	
	czytaj:
		pop dx
		add dx, 48
		int 21h
		dec cx
		cmp cx, 0
		jg czytaj
		
	
koniec:
	mov ax, 4C00h
	int 21h
	
dolar:
	push 36
	push dx
	jmp inkrem
			
enter:
	pusha
	mov ah, 2
	mov dl, 10
	int 21h
	
	mov ah, 2
	mov dl, 13
	int 21h
	popa
ret

space:
	pusha
	mov ah, 2
	mov dl, 32
	int 21h
	popa
ret
	
dzielzero:
	mov ah, 9
	mov dx, zeronapis
	int 21h
	jmp koniec
	
	
zmienne:
	prompt db "Podaj wyrazenie: $"
	
	wejscie 	db 25
				db 0
				times 26 db "$"
				
	
	wyjscie   	times 50 db 36
						db 36
						
	zeronapis	db "Blad! Dzielenie przez 0!$"					
	