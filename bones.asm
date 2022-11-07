.686
.model	flat, stdcall
option	casemap :none

include		resID.inc
include 	algo.asm
include 	rotatingcube.asm

$invoke MACRO Fun:REQ, A:VARARG
  IFB <A>
    invoke Fun
  ELSE
    invoke Fun, A
  ENDIF
  EXITM <eax>
ENDM

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
ENDM

.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	AllowSingleInstance addr szTitle
	invoke	InitCommonControls
	invoke	DialogBoxParam, hInstance, IDD_KEYGEN, 0, offset DlgProc, 0
	invoke	ExitProcess, eax

DlgProc proc hDlg:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD

    .if [uMsg] == WM_INITDIALOG  
        mov eax,hDlg
        mov hDlgWnd,eax
        invoke LoadIcon,hInstance,200
		invoke SendMessage,hDlg,WM_SETICON,1,eax
		invoke SetWindowText,hDlg,addr szTitle
		invoke SetDlgItemText,hDlg,IDC_MAIL,addr szDefault
		invoke SendDlgItemMessage,hDlg,IDC_MAIL,EM_SETLIMITTEXT,41,0
        invoke DrawXXControlButtons,hDlg
        invoke CreateFontIndirect,addr TxtFont
		mov hFont,eax
		invoke GetDlgItem,hDlg,IDC_MAIL
		mov hMail,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,hDlg,IDC_SERIAL
		mov hSerial,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,hDlg,2006
		mov hREGBOX,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,hDlg,2011
		mov hDate,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,hDlg,IDB_QUIT
		mov hQuit,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
		invoke GetDlgItem,hDlg,IDB_ABOUT
		mov hAbout,eax
		invoke SendMessage,eax,WM_SETFONT,hFont,1
        invoke CreateThread, 0, 0, offset Draw, 0, 0, offset ThreadID
        mov hThread,eax
        invoke SetThreadPriority,hThread,THREAD_PRIORITY_NORMAL
        invoke SIDOpen, IDC_TUNE, 0, SID_RESOURCE, SID_DEFAULT, 0
		call SIDPlay
        jmp @return1
    .elseif [uMsg] == WM_LBUTTONDOWN
        invoke ReleaseCapture
        invoke SendMessageA,hDlgWnd,WM_NCLBUTTONDOWN,HTCAPTION,0
        jmp @return1
    .elseif [uMsg] ==WM_CTLCOLOREDIT || uMsg==WM_CTLCOLORSTATIC
        invoke SetBkMode,wParam,TRANSPARENT
        invoke SetBkColor,wParam,000000h
        invoke SetTextColor,wParam,White
        invoke GetStockObject,BLACK_BRUSH
        ret
    .elseif [uMsg] == WM_CTLCOLORDLG
        mov eax,wParam
        invoke SetBkColor,eax,Black
        invoke GetStockObject,BLACK_BRUSH
        ret
    .elseif [uMsg] == WM_COMMAND
        mov eax,wParam
        mov edx,eax
        shr edx,16
        and eax,0FFFFh
            .if edx == EN_CHANGE
                .if eax == IDC_MAIL
                    invoke GenKey,hDlg
                 .endif
            .endif
            .if eax== IDOK
            	invoke GenKey,hDlg
            .elseif eax== IDB_ABOUT
            	invoke DialogBoxParam,0,IDD_ABOUT,hDlg,addr AboutProc,0
            .elseif eax== IDB_QUIT
                invoke SendMessage,hDlg,WM_CLOSE,0,0
            .endif
    .elseif [uMsg] == WM_CLOSE
    	call SIDStop
	    call SIDClose
        invoke TerminateThread,hThread,0
        invoke DeleteObject,hBlackBrush
        invoke EndDialog,hDlg,0
    .endif
    mov eax, 0
    ret
@return1:
    mov eax, 1
    ret
DlgProc endp

Draw proc near uses ebx edi esi ThreadParam:DWORD 
LOCAL var_888:DWORD
LOCAL pv[18h]:BYTE
    
    invoke  GetDlgItem,hDlgWnd,2009
    invoke  GetDC, eax
    mov     hStarsDC, eax

    invoke  CreateCompatibleDC, eax
    mov     hLogoDC, eax
    mov     edi, eax

    invoke  SetBkMode, edi, TRANSPARENT
	
	invoke GetModuleHandle,0
    invoke LoadBitmap,eax,123
    push eax
    invoke CreateCompatibleDC,0
    mov BitmapDC,eax
	pop var_888
	invoke SelectObject,BitmapDC,var_888
	lea eax,pv
	push eax             ; pv                               
	push 18h             ; c                                
	push var_888    ; h                                
	call GetObjectA                                         
	invoke SetBkMode,hDC,1
	
    lea     esi, pbmi
    xor     edx, edx
    mov     pbmi.bmiHeader.biSize, sizeof BITMAPINFOHEADER
    mov     pbmi.bmiHeader.biWidth, nWidth
    mov     pbmi.bmiHeader.biHeight, not nHeight
    mov     pbmi.bmiHeader.biPlanes, 1
    mov     pbmi.bmiHeader.biBitCount, 32
    mov     pbmi.bmiHeader.biCompression, 0
    mov     pbmi.bmiHeader.biSizeImage, edx
    mov     pbmi.bmiHeader.biXPelsPerMeter, edx
    mov     pbmi.bmiHeader.biYPelsPerMeter, edx
    mov     pbmi.bmiHeader.biClrUsed, edx
    mov     pbmi.bmiHeader.biClrImportant, edx
    mov     dword ptr pbmi.bmiColors.rgbBlue, edx

    invoke  CreateDIBSection, hStarsDC, esi, edx, offset ppvBits, edx, edx
    invoke  SelectObject, edi, eax

    ; generate random X coords for the stars
    mov     ecx, nStarCount
    xor     ebx, ebx
    mov     randomMaxVal, nWidth
@loopRandomStarX:
    mov     dx, randomSeed
    add     dx, 9248h
    ror     dx, 3
    mov     randomSeed, dx
    mov     ax, randomMaxVal
    mul     dx
    mov     starArrayX[ebx], dx
    add     ebx, 2
    loop    @loopRandomStarX

    ; generate random Y coords for the stars
    mov     ecx, nStarCount
    xor     ebx, ebx
    mov     randomMaxVal, nHeight
@loopRandomStarY:
    mov     dx, randomSeed
    add     dx, 9248h
    ror     dx, 3
    mov     randomSeed, dx
    mov     ax, randomMaxVal
    mul     dx
    mov     starArrayY[ebx], dx
    add     ebx, 2
    loop    @loopRandomStarY

    ; never-ending loop begins here ---------------------------
loop_draw:
    ; draw slow stars
    xor     ecx, ecx
    mov     eax, ppvBits
@loopDrawSlowStars:
    movzx   ebx, starArrayY[ecx*2]
    imul    ebx, nWidth
    movzx   edx, starArrayX[ecx*2]
    add     edx, ebx
    mov     dword ptr [eax+edx*4], StarColSlow
    inc     ecx
    cmp     ecx, nStarzSlow
    jnz     @loopDrawSlowStars

    ; draw normal stars
@loopDrawNormStars:
    movzx   ebx, starArrayY[ecx*2]
    imul    ebx, nWidth
    movzx   edx, starArrayX[ecx*2]
    add     edx, ebx
    mov     dword ptr [eax+edx*4], StarColNorm
    inc     ecx
    cmp     ecx, nStarzSlow + nStarzNorm
    jnz     @loopDrawNormStars

    ; draw fast stars
@loopDrawFastStars:
    movzx   ebx, starArrayY[ecx*2]
    imul    ebx, nWidth
    movzx   edx, starArrayX[ecx*2]
    add     edx, ebx
    mov     dword ptr [eax+edx*4], StarColFast
    inc     ecx
    cmp     ecx, nStarCount
    jnz     @loopDrawFastStars

@notScrolledToTop:

    xor     edx, edx
    
    invoke  BitBlt, hStarsDC, 0, 0, nWidth, nHeight, hLogoDC, edx, edx, SRCCOPY
	invoke BitBlt,hLogoDC,18,-7,dword ptr [pv+4],dword ptr [pv+8],BitmapDC,0,0,SRCPAINT
    xor     ecx, ecx
    mov     eax, ppvBits
@loopEraseStars:
    movzx   ebx, starArrayY[ecx*2]
    imul    ebx, nWidth
    movzx   edx, starArrayX[ecx*2]
    add     edx, ebx
    mov     dword ptr [eax+edx*4], 0
    inc     ecx
    cmp     ecx, nStarCount
    jnz     @loopEraseStars

    ; move slowest stars
    xor     ebx, ebx
@loopMoveSlowStars:
    inc     starArrayX[ebx]
    cmp     starArrayX[ebx], nWidth-2
    jb      @F
    mov     starArrayX[ebx], 0
@@:
    add     ebx, 2
    cmp     ebx, nStarzSlow * 2
    jb      @loopMoveSlowStars

    ; move normal stars
@loopMoveNormStars:
    add     starArrayX[ebx], 2
    cmp     starArrayX[ebx], nWidth-2
    jb      @F
    mov     starArrayX[ebx], 0
@@:
    add     ebx, 2
    cmp     ebx, (nStarzSlow + nStarzNorm) * 2
    jb      @loopMoveNormStars

    ; move the fastest stars
@loopMoveFastStars:
    add     starArrayX[ebx], 3
    cmp     starArrayX[ebx], nWidth-2
    jb      @F
    mov     starArrayX[ebx], 0
@@:
    add     ebx, 2
    cmp     ebx, nStarCount * 2
    jb      @loopMoveFastStars

    ; sleep a bit and repeat
    invoke  Sleep, ScrollerSpeed
    jmp     loop_draw

    ; thread never returns
Draw endp

DrawXXControlButtons    Proc    hWnd:HWND
LOCAL sButtonStructure:XXBUTTON,hSmallButtonFont:HFONT,hBtn:HWND
    mov hSmallButtonFont,$invoke(CreateFont,8,0,0,0,FW_NORMAL,FALSE,FALSE,FALSE,DEFAULT_CHARSET,OUT_CHARACTER_PRECIS,CLIP_CHARACTER_PRECIS,PROOF_QUALITY,FF_DONTCARE,chr$('MS Sans Serif'))
    invoke RtlZeroMemory,addr sButtonStructure,sizeof sButtonStructure
    invoke LoadCursor,NULL,IDC_HAND
    mov sButtonStructure.hCursor_hover,eax
    mov sButtonStructure.hover_clr,White
    mov sButtonStructure.push_clr,White
    mov sButtonStructure.normal_clr,White
    mov sButtonStructure.btn_prop,08000000Fh
    mov hBtn,$invoke(GetDlgItem,hWnd,IDB_ABOUT )
    invoke RedrawButton,hBtn,addr sButtonStructure
    mov hBtn,$invoke(GetDlgItem,hWnd,IDB_QUIT )
    invoke RedrawButton,hBtn,addr sButtonStructure
    mov sButtonStructure.push_clr,0B0B0B0h
    mov sButtonStructure.btn_prop,08000000Bh
    invoke RedrawButton,hBtn,addr sButtonStructure
    invoke SetFocus,eax
    mov eax,TRUE
    Ret
DrawXXControlButtons endp

AboutProc proc iWnd:DWORD,uMsgs:DWORD,wParamz:DWORD,lParamz:DWORD
LOCAL X:DWORD
LOCAL Y:DWORD
LOCAL Aboutrkt:RECT

	mov	eax,uMsgs

	push iWnd
	pop xWnd
	
	.if	eax==WM_INITDIALOG          
		invoke GetParent, xWnd
		mov ecx, eax
		invoke GetWindowRect, ecx, addr Aboutrkt
		mov edi, Aboutrkt.left
		mov esi, Aboutrkt.top
		add edi, 3
		add esi, 3
		invoke SetWindowPos,xWnd,HWND_TOP,edi,esi,DCWidth,DCHeight,SWP_SHOWWINDOW
		invoke GetClientRect,xWnd,offset CubeRekt
		invoke CreateThread,0,0,offset CubeProc,0,0,offset ThreadId
		mov CubeThread,eax
		invoke SetThreadPriority,offset CubeThread,THREAD_PRIORITY_ABOVE_NORMAL
	.elseif eax==WM_CTLCOLORDLG
		mov eax,wParamz
		invoke SetBkColor,eax,Black
		invoke GetStockObject,BLACK_BRUSH
		ret
	.elseif eax==WM_CTLCOLOREDIT || eax==WM_CTLCOLORSTATIC
		invoke SetBkMode,wParamz,TRANSPARENT
		invoke SetBkColor,wParamz,Black
		invoke SetTextColor,wParamz,White
		invoke GetStockObject,BLACK_BRUSH
		ret
	.elseif eax==WM_LBUTTONDOWN
		invoke SendMessage,xWnd,WM_CLOSE,0,0
	.elseif	eax==WM_CLOSE
		invoke DeleteObject,cubeDC
		invoke TerminateThread,CubeThread,0
		invoke EndDialog,xWnd,0
	.endif

	xor	eax,eax
	ret
	
AboutProc endp

end start