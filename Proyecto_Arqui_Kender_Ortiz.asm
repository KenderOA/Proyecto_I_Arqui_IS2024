%include "/home/kali/ProyectoArqui/linux64.inc.asm"

section .data
    student_file       db "/home/kali/ProyectoArqui/myfile.txt",0
    config_file        db "/home/kali/ProyectoArqui/configuracion.txt",0
    emb                db " ",10

section .bss
    config_text_buffer  resb 150  ; Reserva espacio para el buffer de texto del archivo de configuración
    data_text_buffer    resb 1000 ; Reserva espacio para el buffer de texto del archivo de datos
    ttc                 resb 150  ; Reserva espacio para el tamaño del buffer de configuración
    ttd                 resb 1000 ; Reserva espacio para el tamaño del buffer de datos

    current_byte        resw 1  ; Byte actual en el proceso de lectura
    start_of_row_1      resw 1  ; Inicio de la primera fila
    end_of_row_1        resw 1  ; Fin de la primera fila			
    start_of_row_2      resw 1	; Inicio de la segunda fila		
    end_of_row_2        resw 1	; Fin de la segunda fila	

    bytefinaltext       resw 1  ; Byte final del texto
    letter_controller   resw 1  ; Controlador de letras para ordenamiento
    row_copier          resw 1  ; Copiador de filas para ordenamiento
    row_counter         resw 1  ; Contador de filas

    sizef1              resw 1  ; Tamaño de la primera fila
    sizef2              resw 1  ; Tamaño de la segunda fila

    bubletimes          resw 1  ; Contador de iteraciones del ordenamiento burbuja


    num1                resb 2  ; Número 1 para comparación
    num2                resb 2  ; Número 2 para comparación

	all                 resb 1  ; Variable para almacenar un valor específico

	letter_1            resb 1  ; Letra 1 para comparación
	letter_2            resb 1  ; Letra 2 para comparación
    
	row_1_copy          resb 40	; Copia de la primera fila
	row_2_copy          resb 40	; Copia de la segunda fila

section .text
	global _start
	
_start:		

; El Bubble Sort se utiliza para ordenar una secuencia de datos. En este caso, el algoritmo está copiando bytes de una fuente (data_text_buffer)}
; a una matriz de copia (row_1_copy) basándose en el índice actual (current_byte). El proceso implica leer un byte de la fuente, almacenarlo en la 
; matriz de copia en la posición correspondiente (row_copier), incrementar el contador de copia, y luego actualizar el índice actual (current_byte)
; para el siguiente byte. Este proceso se repite hasta que se encuentra un byte con el valor 10 (que representa el carácter de nueva línea en ASCII),
; lo que indica el final de una fila. Al final de cada iteración, se actualiza el tamaño de la primera fila, se reinicia el contador de copia
; y se prepara para comenzar a copiar la siguiente fila, incrementando el contador de filas.

	mov  rax, SYS_OPEN
	mov  rdi, config_file
	mov  rsi, O_RDONLY
	mov  rdx, 0
	syscall

	push rax
	mov  rdi, rax
	mov  rax, SYS_READ
	mov  rsi, config_text_buffer
	mov  rdx, ttc
	syscall

	mov  rax, SYS_CLOSE
	pop  rdi
	syscall

	print config_text_buffer

    mov  rax, 1
    mov  rdi, 1
    mov  rsi, emb
    mov  rdx, 2
    syscall

    mov  rax, 1
    mov  rdi, 1
    mov  rsi, emb
    mov  rdx, 2
    syscall

    mov  al, [config_text_buffer+122]
    mov  byte [all], al

    mov  rax, SYS_OPEN
    mov  rdi, student_file
    mov  rsi, O_RDONLY
    mov  rdx, 0
    syscall

    push rax
    mov  rdi, rax
    mov  rax, SYS_READ
    mov  rsi, data_text_buffer
    mov  rdx, ttd
    syscall


    mov  rax, SYS_CLOSE
    pop  rdi
    syscall

    mov word [bubletimes],0d

clear_variables:

;Se ponen todas las variables a utilizar en el bublesort a 0

    mov word [current_byte],0
    mov word [start_of_row_1],0
    mov word [end_of_row_1],0
    mov word [start_of_row_2],0
    mov word [end_of_row_2],0
    mov word [bytefinaltext],900
    mov word [letter_controller],0
    mov word [row_copier],0
    mov word [sizef1],0
    mov word [sizef2],0
    mov word [row_counter],1


bublesort:

; Se abre un archivo de configuración, lee su contenido en un búfer, y luego cierra el archivo, todo mediante llamadas al sistema.
; Después, intenta imprimir el contenido del búfer de texto de configuracion, se realiza dos llamadas al sistema SYS_WRITE para escribir en la salida estándar,
; Posteriormente, manipula un byte del contenido leído y abre, lee y cierra otro archivo, similar al proceso con el archivo de configuración. 
; Finalmente, inicializa una variable a cero.

    mov word bx,[current_byte]
	mov byte al, [data_text_buffer +rbx ]

	mov word r10w,[row_copier]
	mov byte [row_1_copy+r10],al

	add word r10w,1
	mov word [row_copier],r10w

    mov word cx,[current_byte]
	mov word  [end_of_row_1], cx

	mov word [current_byte],cx
	add word cx, 1
	mov word [current_byte],cx

	cmp byte al,10
	jne bublesort

	mov word r9w,[row_copier]
	mov word [sizef1],r9w

	mov word [row_copier],0

	mov word [start_of_row_2],cx

	mov word r11w,[row_counter]
	add word r11w, 1d
	mov word [row_counter],r11w

Row:		
    
    mov word ax,[current_byte]
	mov byte bl,[data_text_buffer+rax]

	mov word r8w,[row_copier]
	mov byte [row_2_copy+r8],bl

	add word r8w,1d
	mov word [row_copier],r8w

	mov word [end_of_row_2],ax

	add word ax,1d
	mov word [current_byte],ax

    mov byte r13b,[data_text_buffer+rax]
    cmp byte r13b,0d
    jne igualenter

    mov word  [bytefinaltext],ax
	mov word [bytefinaltext],ax

igualenter:

	cmp byte bl,10d
    jne Row

before_ord:

	mov word r8w,[row_copier]
	mov word [sizef2],r8w

	mov word [row_copier],0d

ord:

	mov byte al,[all]
	cmp byte al,65d
	je alph

    mov byte al,[all]
    cmp byte al,97d
    je alph

	mov word ax,[end_of_row_1]
	mov word bx,[end_of_row_2]

	sub word ax,1d
	sub word bx,1d

	mov byte cl,[data_text_buffer+rax]
	mov byte dl,[data_text_buffer+rbx]
	mov byte [num1+1],cl
	mov byte [num2+1],dl

	sub word ax,1d
    sub word bx,1d

    mov byte cl,[data_text_buffer+rax]
    mov byte dl,[data_text_buffer+rbx]
    mov byte [num1],cl
    mov byte [num2],dl

	mov byte al,[num1]
	mov byte bl,[num2]
	cmp byte al,bl

	jg smll1
	jb mayor

    mov byte al,[num1+1]
    mov byte bl,[num2+1]
    cmp byte al,bl
    jg smll1
    jb mayor

alph:

	mov word ax,[start_of_row_1]
	add word ax,[letter_controller]
	mov byte cl,[data_text_buffer+rax]
	mov byte [letter_1],cl

    mov word ax,[start_of_row_2]
    add word ax,[letter_controller]
    mov byte cl,[data_text_buffer+rax]
    mov byte [letter_2],cl

	mov word dx,[letter_controller]
	add word dx,1d
	mov word [letter_controller],dx

	mov byte al,[letter_1]
	mov byte bl,[letter_2]
	cmp byte al,bl
	je alph

    mov byte [letter_controller],0d

	mov byte [row_copier],0d

	jg  mayor

smll1:

	mov word r12w,[start_of_row_2]
	mov word [start_of_row_1],r12w

	mov word [current_byte],r12w

	jmp end_of_replacement

mayor:

	mov word bx,[row_copier]
	mov byte al,[row_2_copy+rbx]

	add word bx,[start_of_row_1]
	mov byte [data_text_buffer+rbx],al

	mov word dx,[row_copier]
	add word dx,1d
	mov word [row_copier],dx

	mov word ax,[sizef2]
	cmp word dx,ax
	jb mayor


	mov word ax,[row_copier]
	add ax,[start_of_row_1]
	mov word [current_byte],ax

    mov word [row_copier],0d


rcopy1:

	mov word bx,[row_copier]
	mov byte al,[row_1_copy+rbx]


	add word bx,[current_byte]
	mov byte [data_text_buffer+rbx],al

	mov word bx,[row_copier]
	add word bx,1d
	mov word [row_copier],bx

	mov word ax,[sizef1]
	cmp word bx,ax
	jb rcopy1

	mov word [row_copier],0d

	mov word ax,[current_byte]
	mov word [start_of_row_1],ax

end_of_replacement:

	mov word ax,[end_of_row_2]
	mov word bx, [bytefinaltext]
	cmp word ax,bx

	jb bublesort

	mov word ax,[bubletimes]
	add word ax,1d
	mov word [bubletimes],ax

	mov word bx,[row_counter]
	mov word [row_counter],0d
	cmp word ax,bx
	jb clear_variables

     mov rax, 1
     mov rdi, 1
     mov rsi, 10
     mov rdx, 2
     syscall

     print data_text_buffer

.end_of_code:

	mov rax,60	
	mov rdi,0	
	syscall	