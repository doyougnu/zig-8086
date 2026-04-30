; ========================================================================
; LISTING 39
; ========================================================================

bits 16

; Register-to-register
mov si, bx
mov dh, al

; 8-bit immediate-to-register
;; mov cl, 12
mov ch, -12

; 16-bit immediate-to-register
mov cx, 12
mov cx, -12
mov dx, 3948
mov dx, -3948

; Source address calculation
mov al, [bx + si]
mov bx, [bp + di]
mov si, bx
mov bx, [bp + di]
mov dx, [bp] ; this one is where we start to diverge
mov si, bx

; Source address calculation plus 8-bit displacement
mov ah, [bx + si + 4]

; Source address calculation plus 16-bit displacement
mov al, [bx + si + 499]

; Dest address calculation
mov [bx + di], cx ; next up: wrong but exited gracefully
mov [bp + si], cl               ; wrong but exited gracefully
mov [bp], ch  ;; we exit successfully here
