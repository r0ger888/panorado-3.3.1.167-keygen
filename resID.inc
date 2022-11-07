include        \masm32\include\windows.inc

include        \masm32\include\user32.inc
include        \masm32\include\kernel32.inc
include        \masm32\include\masm32.inc
include        \masm32\include\gdi32.inc  
include        \masm32\include\comctl32.inc
include		   \masm32\include\winmm.inc
include		   \masm32\include\msvcrt.inc
include        \masm32\macros\macros.asm
include        XXControls.inc

includelib     \masm32\lib\user32.lib
includelib     \masm32\lib\kernel32.lib
includelib     \masm32\lib\masm32.lib
includelib     \masm32\lib\gdi32.lib
includelib     \masm32\lib\comctl32.lib
includelib     \masm32\lib\winmm.lib
includelib     \masm32\lib\msvcrt.lib
includelib     XXControls.lib

include		titchysid.inc
includelib  titchysid_extras.lib

DlgProc                	PROTO :DWORD,:DWORD,:DWORD,:DWORD
Draw					 PROTO :DWORD
DrawXXControlButtons    PROTO :DWORD


.const
IDD_ABOUT			 equ 11
IDD_KEYGEN             equ 2000
IDB_QUIT                 equ 2002
IDC_MAIL                 equ 2007
IDC_SERIAL               equ 2008
IDB_ABOUT				 equ 2010
IDC_TUNE                 equ 488

.data
TxtFont		LOGFONT	<0FFFFFFF6h,0,0,0,320h,0,0,0,0,0,0,0,0,'Verdana'>
szTitle                  db "KEYITEM 100% CERTIFIED WAREZ",0
szDefault				 db "prfteam@hush.com",0
;these should match dialog size in pixels

xStarzPos                equ 7
yStarzPos                equ 31
nWidth                   equ 340
nHeight                  equ 168

nStarzSlow               equ 50
nStarzNorm               equ 50
nStarzFast               equ 50
StarColSlow              equ 777777h
StarColNorm              equ 0AAAAAAh
StarColFast              equ 0FFFFFFh

ScrollerSpeed            equ 1
nStarCount               equ nStarzSlow + nStarzNorm + nStarzFast

.data?
NameLen                  dd         ?
hInstance                dd         ?
hBlackBrush              HBRUSH     ?
hExit                    BOOL       ?
hMatrix                  DWORD      ?
hDC                      HANDLE     ?
hFont					 dd			?
hMail					 dd			?
hSerial					 dd			?
hREGBOX					 dd			?
hDate					 dd			?
hQuit					 dd 		?
hAbout					 dd			?
pbmi                     BITMAPINFO <>
ppvBits                  dd         ?
randomSeed               dw         ?
randomMaxVal             dw         ?
starArrayX               dw nStarCount dup(?)
starArrayY               dw nStarCount dup(?)
scrollerCurrentY         dd         ?
freezeCounter            dd         ?
ThreadID                 dd         ?
hDlgWnd                  dd         ?
hStarsDC                 dd         ?
hLogoDC                  dd         ?
hThread                  dd         ?
BitmapDC				 dd         ?
xHeight    				 dd 		?
xWidth					 dd 		?
xPos					 dd			?
yPos					 dd			?