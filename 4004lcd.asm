;"%d\as-v1.42\bin\asw.exe -cpu 4004 -L %e.asm"
;"%d\as-v1.42\bin\p2hex.exe %e.p %e.hex -F Intel"
    CPU 4004
    RELAXED ON

    LDM 0               ; Load 0 to accumulator
    DCL                 ; Select CM-RAM0 line

    FIM R4R5, 0         ; Clear R4R5 register pair
    SRC R4R5            ; Select position in RAM (zero)
    LDM 5               ; Load 0101 pattern
    WMP                 ; Write to selected RAM port
    CMA                 ; Complement accumulator (1010)
    WRR                 ; Write ROM port (4289 I/O)

    LDM 2               ; Load 2 to acc
    DCL                 ; Select CM-RAM2 bank
;   LDM 4                ;
;   WMP                  ;
;   LDM 15               ;
;   WMP                  ;
    FIM R4R5, $80       ; Load 0x80
    SRC R4R5            ; Select position in 4265 chip
    LDM 4               ; Load 4 to acc
    WMP                 ; Write
    LDM 15              ; Load 15 to acc
    WMP                 ; Write

    ;WRR                 ;
    LDM 15              ; Load 15 to acc
    WRM                 ; Write to main memory
    
    JMS DELAY16MS        ; 

    LDM 3               ; LCD initialization start, 8-bit mode
    JMS LCDdirect       ;
    JMS DELAY5MS4        ; 
    
    LDM 3               ; 8-bit mode
    JMS LCDdirect       ;
    JMS DELAY320US        ; 

    LDM 3               ; 8-bit mode
    JMS LCDdirect       ;
    ;JMS DELAY1S4        ; 
    
    LDM 2               ; 4-bit mode
    JMS LCDdirect       ;
    ;JMS DELAY1S4        ; 
    
    FIM R8R9, 0x28      ;
    JMS LCDctrl         ; nastav 2 radky, 5x7 font
    ;JMS DELAY1S4        ; 
    FIM R8R9, 0x08      ;
    JMS LCDctrl         ; nastav displej off, kurzor off, blikani off
    ;JMS DELAY1S4        ; 
    FIM R8R9, 0x01      ;
    JMS LCDctrl         ; displej clear, pozice 0
    JMS DELAY5MS4        ; 

    FIM R8R9, 0x06      ; posun kurzoru doprava
    JMS LCDctrl         ;
    ;JMS DELAY1S4        ; 
    FIM R8R9, 0x0C      ; nastav displej on, kurzor off, blikani off 0C
    JMS LCDctrl         ;
    ;JMS DELAY1S4        ; 

    FIM R0R1, LCDmsg0   ;
    JMS LCDmsgloop      ;
    FIM R8R9, 0xC0      ;
    JMS LCDctrl         ; second row on LCD
    FIM R0R1, LCDmsg1   ;
    JMS LCDmsgloop      ;

    FIM RaRb, 0         ;
    JUN SHIFT

DELAY320US
    FIM R4R5, 0
DELAY320USLOOP
    ISZ R4, DELAY320USLOOP
    BBL 0

DELAY5MS4
    FIM R4R5, 0
DELAY5MS4LOOP
    ISZ R4, DELAY5MS4LOOP
    ISZ R5, DELAY5MS4LOOP
    BBL 0

DELAY16MS
    FIM R4R5, 0
    FIM R6R7, 0xD0
DELAY16MSLOOP
    ISZ R4, DELAY16MSLOOP
    ISZ R5, DELAY16MSLOOP
    ISZ R6, DELAY16MSLOOP
    BBL 0

DELAY87MS
    FIM R4R5, 0
    FIM R6R7, 0
DELAY87MSLOOP
    ISZ R4, DELAY87MSLOOP   ; Delay loop, 320 us 1x
    ISZ R5, DELAY87MSLOOP   ; Delay loop, 5.4 ms 2x
    ISZ R6, DELAY87MSLOOP   ; Delay loop, 87.36 ms 3x
    BBL 0

DELAY1S4
    FIM R4R5, 0
    FIM R6R7, 0
DELAY1S4LOOP
    ISZ R4, DELAY1S4LOOP
    ISZ R5, DELAY1S4LOOP
    ISZ R6, DELAY1S4LOOP
    ISZ R7, DELAY1S4LOOP
    BBL 0

SHIFT
    ISZ R4, SHIFT       ;
    ISZ R5, SHIFT       ;
    ISZ R6, SHIFT       ;87.36ms 3x
    ;ISZ R7, SHIFT       ;
    
    ;LDM 2
    ;DCL
    ;FIM R0R1, 0x1C      ;
    ;JMS LCDctrl         ;
    
    LDM 0               ;
    DCL
    ;INC R9
    ;SRC R8R9
    ;WMP                 ;
    ;LDM 5               ;
    ;WR3                 ;
    ;WRM                 ;
    ;WRR                 ;
    LD Rb               ;
    IAC                 ;
    ;WRR                 ;
    ;SRC RaRb
    WMP                 ;
    XCH Rb              ;
    TCC                 ;
    ADD Ra              ;
    WRR                 ;
    ;WR1                 ;
    XCH Ra              ;
    SRC RaRb            ;
    
    JUN SHIFT           ;


LCDmsgloop
    FIN R8R9            ;
    LD R9               ;
    JCN NZ, LCDmsgloop2         ;
    LD R8               ;
    JCN Z, LCDmsgloopend        ;
LCDmsgloop2
    JMS LCDdata         ;
    LD R1               ;
    IAC                 ;
    XCH R1              ;
    TCC                 ;
    ADD R0              ;
    XCH R0              ;
    JUN LCDmsgloop      ;
LCDmsgloopend
    BBL 0               ;

LCDdata
    FIM R2R3, 3         ; Load 3 to R3 (RS = 1)
    LD R3               ; R3 -> ACC
    WR0                 ; Write to port W on 4265 (ctrl)
    JUN LCDbyte         ;

LCDctrl
    FIM R2R3, 1         ; Load 1 to R3 (RS = 0)
    LD R3               ; R3 -> ACC
    WR0                 ; Write to port W on 4265 (ctrl)
    JUN LCDbyte         ;

LCDbyte
    LD R8               ; R8 -> ACC
    WR1                 ; Write to port X on 4265 (data)
    LDM 8               ; 8 -> ACC
    ADD R3              ; 8 + R3 -> EN + RS + R/W
    WR0                 ; Write to port W on 4265 (ctrl)
    CLB                 ; 0 -> ACC, 0 -> Carry flag
    ADD R3              ; 0 + R3 -> EN + RS + R/W
    WR0                 ; Write to port W on 4265 (ctrl)
    LD R9               ; R9 -> ACC

LCDdirect
    WR1                 ; Write to port X on 4265 (data)
    LDM 8               ; 8 -> ACC
    ADD R3              ; 8 + R3 -> EN + RS + R/W
    WR0                 ; Write to port W on 4265 (ctrl)
    CLB                 ; 0 -> ACC, 0 -> Carry flag
    ADD R3              ; 0 + R3 -> EN + RS + R/W
    WR0                 ; Write to port W on 4265 (ctrl)
    BBL 0               ; Return

;   DATA "123456789012345678901234"
LCDmsg0
    DATA "Intel 4004 CPU working! ",0

LCDmsg1
    DATA "Intel 4004 system by Jan",0
