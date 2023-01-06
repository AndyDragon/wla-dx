
;������������������������������������������������������������������������������
; a small example for testing WLA DX's enhanced .SECTION definitions
; written by ville helin <ville.helin@iki.fi> in 2023
;������������������������������������������������������������������������������

.MEMORYMAP
   DEFAULTSLOT     0
   ; ROM area
   SLOTSIZE                $4000
   SLOT            0       $0000
   SLOT            1       $4000
   SLOT            2       $8000
   ; RAM area
   SLOTSIZE                $2000
   SLOT            3       $C000
   SLOT            4       $E000
.ENDME

.ROMBANKMAP
BANKSTOTAL 2
BANKSIZE $4000
BANKS 2
.ENDRO

.ROMSIZE $11
        
.EMPTYFILL $69

        ; @BT linked.rom

        ;------------------------------------------------------------------------------
        ; .SECTIONs with BANK, SLOT and ORG/ORGA
        ;------------------------------------------------------------------------------

        .section "Bank1Slot1Org6000Semifree1" bank 1 slot 1 orga $6000 semifree keep returnorg
        .db "04>"        ; @BT TEST-04 04 START
        .dw CADDR        ; @BT 0B 60
hello1: .db :hello1      ; @BT 01
        .db "<04"        ; @BT END
        .ends

        .section "Bank1Slot1Org6000" bank 1 slot 1 orga $6000 force keep returnorg
        .db "01>"        ; @BT TEST-01 01 START
        .dw CADDR        ; @BT 03 60
        .db "<01"        ; @BT END
        .ends

        .section "Bank0Slot0Org0000" keep
        .db "02>"        ; @BT TEST-02 02 START
        .dw CADDR        ; @BT 03 00
        .db "<02"        ; @BT END
        .ends

        .section "Bank0Slot0Org0200A" keep orga $0200 semifree
        .db "03>"        ; @BT TEST-03 03 START
        .dw CADDR        ; @BT 0B 02
        .db "<03"        ; @BT END
        .ends
        
        .bank 1 slot 1
        .orga $6000

        .section "Bank1Slot1Org6000Semifree2" semifree keep returnorg
        .db "05>"        ; @BT TEST-05 05 START
        .dw CADDR+0      ; @BT 14 60
        .db "<05"        ; @BT END
        .ends
        
        .section "Bank0Slot0Org0200B" bank 0 slot 0 orga $0200 semifree priority 100 keep
        .db "06>"        ; @BT TEST-06 06 START
        .dw CADDR+0      ; @BT 03 02
        .db "<06"        ; @BT END
        .ends
        
        ;------------------------------------------------------------------------------
        ; .RAMSECTIONs with BANK, SLOT and ORG/ORGA
        ;------------------------------------------------------------------------------

        .ramsection "Ramsection1" bank 0 slot 3 orga $C100 semifree priority 100 keep
        ramsection1a_5 db
        ramsection1b_6 db
        .ends

        .ramsection "Ramsection2" bank 0 orga $C100 slot 3 semifree priority 1000 keep
        ramsection2a_3 db
        ramsection2b_4 db
        .ends

        .ramsection "Ramsection3" orga $c100 bank 0 slot 3 semifree priority 10000 keep
        ramsection3a_1 db
        ramsection3b_2 db
        .ends

        .section "RamsectionTests" bank 0 slot 0 keep org $1000 semifree
        .db "07>"               ; @BT TEST-07 07 START
        .dw CADDR+1             ; @BT 04 10
        .dw ramsection3b_2      ; @BT 01 C1
        .dw ramsection1a_5+0    ; @BT 04 C1
        .db ramsection3b_2 - ramsection3a_1 ; @BT 01
delta_a:
        .db 2                   ; @BT 02
delta_b:
        .db delta_b - delta_a   ; @BT 01
        .db "<07"               ; @BT END
        .ends
        

        
