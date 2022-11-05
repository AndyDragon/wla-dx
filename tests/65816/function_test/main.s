
//////////////////////////////////////////////////////////////////////
// function tests
//////////////////////////////////////////////////////////////////////
        
        .memorymap
        slotsize $8000
        defaultslot 1
        slot 0 $0000
        slot 1 $8000
        .endme                    

        .lorom

        .rombanksize $8000
        .rombanks 3

; @BT result.rom

//////////////////////////////////////////////////////////////////////
// tests
//////////////////////////////////////////////////////////////////////

        .bank 0 slot 0
        .org 0

        .define varA 1
        .define varB 2
        .define var1 3
        .define var2 4
        .define var3 5
        .define var4 1

        .function sumAB(varA,varB) varA+varB
        .function sumABC(var1,var2,var3) sumAB(var1,var2)+var3
        .function sumAB1(varA, varB) sumAB(varA, varB) + sumAB(1, 0)
        .function sumCD(var{%.1d{1+0}},var2) var{%.1d{0+var4}}+var{%.1d{1+1}}
        .function constant() 1+2+3

        .db "01>"               ; @BT TEST-01 01 START
        .db sumAB(1,2)          ; @BT 03
        .db 1 + sumAB(1,2)      ; @BT 04
        .db sumABC(3,4,5)       ; @BT 0C
        .db sumAB(0+1,0+1+2-1)  ; @BT 03
        .db sumABC(1+2,2+2,2+3) ; @BT 0C
        .db sumAB(1,2) + sumAB(3,4) ; @BT 0A
        .db sumABC(3,4,5) - sumABC(2,3,4) ; @BT 03
        .db sumAB(sumAB(1,2), sumAB(3,4)) ; @BT 0A
        .db constant()                    ; @BT 06
        .db constant() + 1                ; @BT 07
        .db "<01"               ; @BT END

        .db "02>"                ; @BT TEST-02 02 START
        .db sumAB(VALUE_1,1)     ; @BT 02
        .db 1 + sumAB(VALUE_1,2) ; @BT 04
        .db 1 + sumAB(VALUE_1+VALUE_2,2) ; @BT 06
        .db VALUE_2 - sumABC(VALUE_1-1, VALUE_2-2, sumAB(VALUE_1-1,VALUE_2-1)) + sumAB(constant(), VALUE_2-1) ; @BT 08
        .db sumAB1(1, 2)         ; @BT 04
        .db sumAB1(sumAB1(1, 2), 3)  ; @BT 08
        .db sumAB1(VALUE_1, VALUE_2) ; @BT 04
        .db sumAB1(VALUE_1+1, VALUE_2+2) ; @BT 07
        .db sumAB1(sumAB(1,2),sumABC(sumAB(1,2),sumAB(1,2),sumAB(1,2))) ; @BT 0D
        .db sumAB1(sumAB(VALUE_1,VALUE_2),sumABC(sumAB(VALUE_1,VALUE_2),sumAB(1,2),sumAB(1,2))) ; @BT 0D
        .db sumAB1(sumAB(VALUE_1+1,VALUE_2+1),sumABC(sumAB(VALUE_1,VALUE_2),sumAB(1,2),sumAB(1,2))) ; @BT 0F
        .db "<02"                ; @BT END

        .db "03>"               ; @BT TEST-03 03 START
        asl sumAB(5,4)          ; @BT 06 09
        cmp #sumABC(1,2,3)      ; @BT C9 06
        cmp [sumABC(1,2,3)]     ; @BT C7 06
        asl sumAB(VALUE_1,VALUE_2) ; @BT 06 03
        cmp #sumAB1(VALUE_1,VALUE_2) ; @BT C9 04
        cmp [sumABC(VALUE_1,VALUE_2,3)] ; @BT C7 06
        asl sumAB(VALUE_1+1,VALUE_2+1) ; @BT 06 05
        cmp #sumAB1(VALUE_1+1,VALUE_2-1) ; @BT C9 04
        cmp [sumABC(VALUE_1+1,VALUE_2+1,3+1)] ; @BT C7 09
        lda sumABC(1,2,3)                     ; @BT A5 06
        lda sumABC(VALUE_1,VALUE_2,3)         ; @BT A5 06
        lda sumABC(1,2,3).w                   ; @BT AD 06 00
        lda sumABC(1,2,3).w + sumABC(0,1,2).w ; @BT AD 09 00
        lda (sumABC(1,2,3))                   ; @BT B2 06
        lda sumABC(sumAB1(0+0,0-0),2,3).w     ; @BT AD 06 00
        .db "<03"               ; @BT END

        .db "04>"               ; @BT TEST-04 04 START
        .db varA                ; @BT 01
        .db varB                ; @BT 02
        .db var1                ; @BT 03
        .db var2                ; @BT 04
        .db var3                ; @BT 05
        .db "<04"               ; @BT END

        .db "05>"                ; @BT TEST-05 05 START
        .db varA + sumAB(varA,1) ; @BT 03
        .db varA + sumABC(varA,var1,var2) + var3 ; @BT 0E
        .redefine varA 2
        .db varA + sumAB(varA,1) ; @BT 05
        .db varA + sumABC(varA,var1,var2) + var3 ; @BT 10
        .db varA                 ; @BT 02
        .db sumAB(var{%.1d{2-1}},2) ; @BT 05
        .db sumCD(sumCD(1,2),max(VALUE_1+VALUE_1+1,VALUE_1+VALUE_1))+sumCD(1,2) ; @BT 09
        .db "<05"                ; @BT END

        .db "06>"               ; @BT TEST-06 06 START
        .redefine varA = 1
        .define RUNNER{%.1d{varA+0}} = varA
        .rept sumAB(1+1,0+1)
        .db sumAB1(0,RUNNER{%.1d{2-varA}}) ; @BT 02 03 04
        .redefine RUNNER{%.1d{2-varA}} = RUNNER{%.1d{0+varA}} + 1
        .endr
        .rept sumABC(0+max(1-0+0,1),0+2,0+3)+sumAB1(sumAB(0,1),0+varA*2)
        .db 1                   ; @BT 01 01 01 01 01 01 01 01 01 01
        .endr
        .db "<06"               ; @BT END

        .db "07>"               ; @BT TEST-07 07 START
        asl sumAB(VALUE_1,VALUE_3+1) ; @BT 06 05
        cmp #sumABC(1,2,VALUE_3)     ; @BT C9 06
        cmp [sumABC(1,VALUE_4/2,VALUE_4-1)] ; @BT C7 06
        .db "<07"               ; @BT END

        // just testing that 0x7F -> 0x100 jump works in listfiles
        .org $100
_0x100: .db "08>"               ; @BT TEST-08 08 START
        .db _0x100 >> 8, _0x100 & 0xff ; @BT 01 00
        .db "<08"                      ; @BT END
        
        .db "09>"               ; @BT TEST-09 09 START
        .db max(10, 5)          ; @BT 0A
        .db max(5, 6)           ; @BT 06
        .db min(10, 5)          ; @BT 05
        .db min(1, 2)           ; @BT 01
        .db max(10,5) + min(10,5) ; @BT 0F
        .db max(1,2)+max(3,4)     ; @BT 06
        .db min(1,2)+min(3,4)     ; @BT 04
        .db min(0,1)*max(1,2)+max(3,4) ; @BT 04
        .db max(10+1, 5+1)        ; @BT 0B
        .db min(10+2, 5+2)        ; @BT 07
        .db max(10+1,5+2) + min(10+1,5+2) ; @BT 12
        .db max(1+0,2+1)+max(3+2,4+3)     ; @BT 0A
        .db min(1+1,2+2)+min(3+3,4+4)     ; @BT 08
        .db min(0+0,1+1)*max(1+2,2+3)+max(3+4,4+5) ; @BT 09
        .db 1+max(10, 5)          ; @BT 0B
        .db 0+min(10, 5)-2        ; @BT 03
        .db 16-(max(10,5) + min(10,5)) ; @BT 01
        .db 2*(max(1,2)+max(3,4))+1    ; @BT 0D
        .db 2*min(1,2)+2*min(3,4)-3    ; @BT 05
        .db 2*(min(0,1)*max(1,2)+max(3,4))+1 ; @BT 09
        .db 2*max(10+1, 5+1)-11        ; @BT 0B
        .db 3*min(10+2, 5+2)-20        ; @BT 01
        .db 0x12*2-(max(10+1,5+2) + min(10+1,5+2) + 1) ; @BT 11
        .db "<09"               ; @BT END
        
        .db "10>"               ; @BT TEST-10 10 START
        .db max(VALUE_1, VALUE_2) ; @BT 02
        .db max(VALUE_2, VALUE_1) ; @BT 02
        .db min(VALUE_2, VALUE_1) ; @BT 01
        .db min(VALUE_1, VALUE_2) ; @BT 01
        .db max(VALUE_1,VALUE_2) + min(VALUE_1,VALUE_2) ; @BT 03
        .db max(VALUE_1,VALUE_2)+max(VALUE_1,VALUE_2)   ; @BT 04
        .db min(VALUE_0,VALUE_1)*max(VALUE_1,VALUE_2)+max(VALUE_1,VALUE_2) ; @BT 02
        .db max(10+VALUE_1, 5+VALUE_1) ; @BT 0B
        .db min(10+VALUE_2, 5+VALUE_2) ; @BT 07
        .db max(10+VALUE_1,5+VALUE_2) + min(10+VALUE_1,5+VALUE_2) ; @BT 12
        .db max(VALUE_1+VALUE_0,VALUE_2+VALUE_1)+max(VALUE_3+VALUE_2,VALUE_4+VALUE_3) ; @BT 0A
        .db min(VALUE_1+VALUE_1,VALUE_2+VALUE_2)+min(VALUE_3+VALUE_3,VALUE_4+VALUE_4) ; @BT 08
        .db min(VALUE_0+VALUE_0,VALUE_1+1)*max(1+VALUE_2,VALUE_2+3)+max(VALUE_3+4,VALUE_4+5) ; @BT 09
        .db 1+max(10, VALUE_4+1)  ; @BT 0B
        .db 0+min(10, VALUE_2+VALUE_3)-VALUE_2 ; @BT 03
        .db 16-(max(10,3+VALUE_2) + min(10,VALUE_4+1)) ; @BT 01
        .db VALUE_2*(max(VALUE_1,2)+max(3,VALUE_4))+VALUE_1 ; @BT 0D
        .db (VALUE_1*2)*min(VALUE_1,VALUE_1+1)+2*min(VALUE_3,VALUE_2*2)-VALUE_3 ; @BT 05
        .db 2*(min(VALUE_0,1)*max(1,VALUE_2)+max(3,VALUE_4))+VALUE_1 ; @BT 09
        .db VALUE_2*max(10+VALUE_1, VALUE_4+1+1)-11 ; @BT 0B
        .db (VALUE_1+VALUE_1+VALUE_1)*min(10+VALUE_1+1, 5+VALUE_2)-18-VALUE_2 ; @BT 01
        .db 0x12*VALUE_2-(max(10+VALUE_1,5+2) + min(10+VALUE_1,VALUE_4+1+2) + VALUE_1) ; @BT 11
        .db "<10"               ; @BT END

        .db "11>"               ; @BT TEST-11 11 START
        asl sumAB(min(5,VALUE_5*2),max(4,4))          ; @BT 06 09
        cmp #sumABC(min(1+1,max(max(-VALUE_1,0),VALUE_1)),2,3)      ; @BT C9 06
        cmp [sumABC(1,2,max(VALUE_3,-VALUE_3))]     ; @BT C7 06
        asl sumAB(max(max(-VALUE_5-VALUE_5-100, 6-VALUE_5),-VALUE_5+3+2),max(2+2-VALUE_2,VALUE_5-4)) ; @BT 06 03
        cmp #max(sumAB1(VALUE_1+0,0+VALUE_2),-VALUE_3-VALUE_5) ; @BT C9 04
        .db "<11"               ; @BT END

        .db "12>"               ; @BT TEST-12 12 START
        .define runnerA = max(min(-1-1-1-1-1, 1+1+1+1+1-1-1-1), -var3+var3*2-1) // 4
        .rept max(2+floor(17/runnerA)-1, 1)
        .db runnerA ; @BT 04 03 02 01 00
        .redefine runnerA = min(runnerA + 0, max(1+runnerA-1, runnerA-runnerA) - 1)
        .endr
        .db "<12"               ; @BT END

        .db "13>"               ; @BT TEST-13 13 START
        .db sqrt(9+0+0+1-1)     ; @BT 03
        .db floor(sqrt(VALUE_16+1)) ; @BT 04
        .db sqrt(9+0+0+1-1) + floor(sqrt(1+VALUE_16)) ; @BT 07
        .db floor(sqrt(1*sqrt(4+3+2) + floor(sqrt(1+VALUE_16)) + 1*1*1*1 + floor(sqrt(16))*1 + sqrt(VALUE_16+1+VALUE_5*2))) ; @BT 04
        .db floor(sqrt(5.5)*3)   ; @BT 07

        .define FIVE_POINT_FIVE = 5.5
        // calculated here
        .db floor(sqrt(FIVE_POINT_FIVE)*3)   ; @BT 07
        // calculated in WLALINK
        .db floor(sqrt(FIVE_POINT_FIVEONE)*3)   ; @BT 07

        .db floor(sqrt(FIVE_POINT_FIVE+0.0001)*3)   ; @BT 07
        .db floor(sqrt(FIVE_POINT_FIVEONE+0.0001)*3)   ; @BT 07
        
        .rept min(2+floor(sqrt(8+1)), floor(sqrt(1+8)))
        .db 1                   ; @BT 01 01 01
        .endr
        .db "<13"               ; @BT END

        .function localAbs(a) abs(a)
        .function makeNegative(a) -abs(a)
        .function negative2X(a) -(abs(a) + abs(a))
        
        .db "14>"               ; @BT TEST-14 14 START
        .db abs(0xf0)           ; @BT F0
        .db abs(-9.1)           ; @BT 09
        .db abs(abs(abs(abs(-3.3)))) ; @BT 03
        .db abs(-8.9 - 0.2)     ; @BT 09
        .db abs(FIVE_POINT_FIVE) ; @BT 05
        .db abs(FIVE_POINT_FIVE+0.0001) ; @BT 05
        .db floor(sqrt(abs(-FIVE_POINT_FIVE))) ; @BT 02
        .db floor(sqrt(localAbs(-FIVE_POINT_FIVE*3))) ; @BT 04
        .db floor(sqrt(abs(-FIVE_POINT_FIVE+0.0001))*3) ; @BT 07
        .db floor(sqrt(abs(-FIVE_POINT_FIVEONE+0.0001))*3) ; @BT 07
        .db abs(abs(abs(abs(-FIVE_POINT_FIVEONE)))) ; @BT 05
        .db abs(abs(abs(abs(-FIVE_POINT_FIVEONE+0.0001)))) ; @BT 05
        .db abs(abs(abs(localAbs(-FIVE_POINT_FIVEONE)))) ; @BT 05
        .db abs(localAbs(localAbs(abs(-FIVE_POINT_FIVEONE+0.0001)))) ; @BT 05
        .db abs(localAbs(localAbs(abs(makeNegative(FIVE_POINT_FIVEONE+1.0001))))) ; @BT 06
        .db makeNegative(-2)    ; @BT FE
        .db makeNegative(FIVE_POINT_FIVEONE+1.0001) ; @BT FA
        .db negative2X(-2)                          ; @BT FC
        .db -(abs(-1) + abs(-3) - abs(-2))          ; @BT FE
        .db -(abs(-1) + 3 - abs(-2))                ; @BT FE
        .db -(1 + abs(-3) - 2)                      ; @BT FE
        .db -(abs(1) + abs(3) - abs(2))             ; @BT FE
        .db -(-abs(-1) - abs(-3) + abs(-2))         ; @BT 02
        .db -(-1 - abs(-3) + 2)                     ; @BT 02
        .db -(-abs(-1) - 3 + abs(-2))               ; @BT 02
        .db "<14"                                   ; @BT END

        .function negate1(a) -a
        .function negate2(b) -b+0
        .function negate3(c) 0-c
        .function nothing(d) d

        .db "15>"                              ; @BT TEST-15 15 START
        .db negate1(-2)                        ; @BT 02
        .db negate1(FIVE_POINT_FIVEONE+1.0001) ; @BT FA
        .db negate2(-2)                        ; @BT 02
        .db negate2(FIVE_POINT_FIVEONE+1.0001) ; @BT FA
        .db negate3(-2)                        ; @BT 02
        .db negate3(FIVE_POINT_FIVEONE+1.0001) ; @BT FA
        .db nothing(-2)                        ; @BT FE
        .db nothing(FIVE_POINT_FIVEONE+1.0001) ; @BT 06
        .db "<15"                              ; @BT END

        .function mulOnePointFiveOne(b) 1.51*b
        .function justCos(c) cos(c)
        .function minusCos(d) -cos(d)

        .db "16>"                 ; @BT TEST-16 16 START
        .db mulOnePointFiveOne(2) ; @BT 03
        .db -(cos(0.5)*1.0001)*1.5       ; @BT 01
        .db -negate1(cos(0.5)*1.0001)*1.5 ; @BT 01
        .db mulOnePointFiveOne(FIVE_POINT_FIVEONE-3.51) ; @BT 03
        .db -(cos(FIVE_POINT_FIVEONE-5.01)*1.0001)*1.5  ; @BT 01
        .db -(justCos(FIVE_POINT_FIVEONE-5.01)*1.0001)*1.5  ; @BT 01
        .db (minusCos(FIVE_POINT_FIVEONE-5.01)*-1.0001)*1.5  ; @BT 01
        .db -(-cos(0.1)-0.1)*6                               ; @BT 06
        .db -(-cos(FIVE_POINT_FIVEONE-5.41)-0.1)*6           ; @BT 06
        .db -(-cos(0.1)-0.1 - cos(0.1)-0.1)*2                ; @BT 04
        .db -(-cos(FIVE_POINT_FIVEONE-5.41)-0.1 - cos(FIVE_POINT_FIVEONE-5.41)-0.1)*2 ; @BT 04
        .db (ceil(cos(FIVE_POINT_FIVEONE-5.41)+0.1)) ; @BT 02
        .db (ceil(-cos(FIVE_POINT_FIVEONE-5.41)-0.1 - cos(FIVE_POINT_FIVEONE-5.41)-0.1))*2 ; @BT FC
        .db -(ceil(cos(FIVE_POINT_FIVEONE-5.41)+0.1)) ; @BT FE
        .db -(ceil(-cos(FIVE_POINT_FIVEONE-5.41)-0.1 - cos(FIVE_POINT_FIVEONE-5.41)-0.1))*2 ; @BT 04
        .db "<16"                 ; @BT END

        .function simpleSumAB(a,b) a+b
        .function simpleSumABC(a,b,c) a+b+c
        
        .db "17>"               ; @BT TEST-17 17 START
        .db -(-simpleSumAB(1,2)) ; @BT 03
        .db -(-simpleSumABC(1,2,3)) ; @BT 06
        .db -(simpleSumAB(1,2)) ; @BT FD
        .db -(simpleSumABC(1,2,3)) ; @BT FA
        .db -(-simpleSumAB(1+0,2+0)) ; @BT 03
        .db -(-simpleSumABC(1+0,2+0,3+0)) ; @BT 06
        .db -(simpleSumAB(1+0,2+0)) ; @BT FD
        .db -(simpleSumABC(1+0,2+0,3+0)) ; @BT FA
        .db -(-simpleSumAB(1,2)+1) ; @BT 02
        .db -(-simpleSumABC(1,2,3)+1) ; @BT 05
        .db -(simpleSumAB(1,2)+1) ; @BT FC
        .db -(simpleSumABC(1,2,3)+1) ; @BT F9
        .db -(-simpleSumAB(1+0,2+0)+1) ; @BT 02
        .db -(-simpleSumABC(1+0,2+0,3+0)+1) ; @BT 05
        .db -(simpleSumAB(1+0,2+0)+1) ; @BT FC
        .db -(simpleSumABC(1+0,2+0,3+0)+1) ; @BT F9
        .db 1 +
            1                   ; @BT 02
        .db -(simpleSumABC(VALUE_16-15, simpleSumAB(1+1,2-1), simpleSumABC(VALUE_16-14,VALUE_16-17,1+1-6))) ; @BT FF
        .db -(simpleSumABC(VALUE_16-15, simpleSumAB(1+1,2-1), simpleSumABC(VALUE_16-14,VALUE_16-17,1+1-6)) +
              simpleSumABC(VALUE_16-15, simpleSumAB(1+1,2-1), simpleSumABC(VALUE_16-14,VALUE_16-17,1+1-6))) ; @BT FE
        .db "<17"               ; @BT END

        .db "18>"               ; @BT TEST-18 18 START
        .db lobyte(0x1122)      ; @BT 22
        .db -lobyte(0x1102)     ; @BT FE
        .db lobyte(VALUE_16)    ; @BT 10
        .db -lobyte(VALUE_16)   ; @BT F0
        .db lobyte(0x1122+1)    ; @BT 23
        .db -lobyte(0x1102+1)   ; @BT FD
        .db lobyte(VALUE_16+1)  ; @BT 11
        .db -lobyte(VALUE_16+1) ; @BT EF        
        .db -(lobyte(0x1122+1)-0x24) ; @BT 01
        .db -(lobyte(VALUE_16+1)-15) ; @BT FE
        .db -(lobyte(0x0102) - hibyte(0x0304) + lobyte(16)/16) ; @BT 02
        .db -(lobyte(0x0102) + (-hibyte(0x0304) + lobyte(16)/16)) ; @BT 02
        .db 1 +
        2+0*0+
        1                       ; @BT 04
        .db "<18"               ; @BT END
