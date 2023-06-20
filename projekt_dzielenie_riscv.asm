	.globl	main
	.data
promp1:	.asciz	"Double: "
promp2:	.asciz	"Float: "
end1:	.asciz	"\nDouble: "
end2:	.asciz	"\nFloat: "
result:	.asciz	"\nWynik: "

.macro	nextbit
	slli	t4, t4, 1
	li	a3, 0x80000000
	and	a3, a3, t5
	slli	t5, t5, 1
	srli	a3, a3, 31
	or	t4, t4, a3	
.end_macro

	.text
main:
    	li	a7, 4
    	la	a0, promp1
    	ecall
    	
    	li	a7, 7
    	ecall
    	
    	fmv.d	fa1, fa0
    	
    	
    	fsd	fa0, -100
    	
    	
    	
    	li	a7, 4
    	la	a0, promp2
    	ecall
    	
    	li	a7, 6
    	ecall
    	
    	fmv.s	fa2, fa0
    	
    	
    	li	a1, 0
    	li	a2, 0


	
getting_double:
 	# wyodrebnienie elementów doubla z pamiêci do rejestrów sta³opozycyjnych
 	#t0 - bardziej znacz¹cca po³owa doubla, po zapisaniu bitow u¿ywany do chwilowych operacji
 	#t1 - zczytana mniej znacz¹ca po³owa doubla
 	#t2 - znak
 	#t3 - 11 bitowy wyk³adnik doubla
 	#t4 - pierwsze 30 bitów mantysy (2 najbardziej znacz¹ce bity na 01)
 	#t5 - kolejne 22 bitów mantysy
 	#t6 - pomoc przy operacjach

	lw	t1, -100
    	lw	t0, -96
    	
	li	t6, 0x80000000	# znak
    	and	t2, t0, t6
    	
    	li	t6, 0x7FF00000 # wyodrebnienie 11 bitow wykladnika
    	and	t3, t0, t6
    	srli	t3, t3, 20
    	

	li	t6, 0xFFFFF # mantysa 1 czesc
	and	t0, t0, t6
	slli	t0, t0, 10
	
	li	t6, 1
	slli	t6, t6, 30
	
	or	t4, t6, t0
	

	srli	t6, t1, 22 
	
	or	t4, t4, t6	# t4 = 01+30bitów

	slli	t5, t1, 10 # mantysa 2 czesc

	li	t0, 0
	li	t1, 0

# double w czesciach w rejestrach: t2, t3, t4, t5
# t0, t1, t6 wolne

getting_float:

	# wyodrebnienie floata do rejestrów
	#t0 - reprezentacja binarna floata
	#t1 - 8 bitów wyk³
	#t6 - znak, potem  01+23 mantysa+0000000

    	fmv.x.w	t0, fa0

	li	t6, 0x80000000 # znak wyniku
    	and	t6, t0, t6
    	xor	t2, t2, t6

    	slli	t1, t0, 1 # 01+mantysa	
    	srli	t1, t1, 24
    	


    	beqz	t0, inf_end	# dzielenie przez 0,  wynik nieskonczonosc
    	li	a3, 0x80000000
    	beq	t0, a3,	inf_end	# dzilenie przez -0
    	li	a3, 0x7F800000	# dzielenie przez nieskonczonosc
    	beq	t0, a3, zro_end
    	li	a3, 0xFF800000	# dzielenie przez minus nieskonczonosc
    	beq	t0, a3, zro_end
    	
    	li	t6, 0x7FFFFF
    	and	t0, t0, t6
    	slli	t0, t0, 7
 
    	li	t6, 1
    	slli	t6, t6, 30
    	
    	or	t6, t6, t0
div:
	# poczatek dzielenia
	#jeœli mantysa dzielnika(floata) bedzie wieksza od mantysy doubla, to przesuwamy mantyse doubla o 1 i odejmujemy 1 od wyk³adnika
	#w a1 - pierwsza czêœæ mantysy nowego doubla - 20 bitów
	#w a2 - druga czêœæ mantysy nowego doubla - 32 bity
	#a3 - do sprawdzenia nieskonczonosci, oraz do pomocy przy operacjach bitowych

 	li	a3, 0x7ff	# sprawdzenie inf
	bgeu	t3, a3, inf_end		# zostawienie w a3 wartosci nie wp³ywa na wynik, w macro instrukcji ladowana jest tam wartosc
 
    	bge	t4, t6, stdiv
  	nextbit			# if t4 < t6, slli o 1 bit
  	addi	t3, t3, -1	# wykladnik -= 1
stdiv:
	addi	t1, t1, -127
	sub	t3, t3, t1	# t1 juz nieuzywane
	li	a3, 0x7ff
	bgeu	t3, a3,inf_end
	blez	t3, zro_end
# ³adujemy 20 do counter, aby format bitów w a1 po pêtli dzielenia by³ gotowy do po³¹czenia ze znakiem i wyk³anikiem tworz¹c pierwsz¹ po³owê doubla
	li	t0, 20		
	sub	t4, t4, t6	# nie zapisujemy 1 poniewa¿ to jest domyœlna ca³kowita 1 przed mantys¹
	nextbit
divloop1:
	addi	t0, t0, -1
	bltz	t0, stdivloop2
	slli	a1, a1, 1
	bltu	t4, t6, ngreat
	addi	a1, a1, 1
	sub	t4, t4, t6
ngreat:
	nextbit
	b	divloop1
stdivloop2:
	li	t0, 32
divloop2:
	addi	t0, t0, -1
	bltz	t0, fix_dble
	slli	a2, a2, 1
	bltu	t4, t6, ngreat2	
	addi	a2, a2, 1
	sub	t4, t4, t6
ngreat2:
	nextbit
	b	divloop2
	
inf_end:
	li	a1, 0x7FF00000
	or	a1, a1, t2
	li	a2, 0
	j	end
	
zro_end:
	li	a1, 0
	or	a1, a1, t2
	li	a2, 0
	j	end

fix_dble:
	slli	t3, t3, 20
	or	a1, t3, a1
	or	a1, t2, a1
	
end:
	sw	a2, -100
	sw	a1, -96

	li	a7, 4
    	la	a0, end1
    	ecall
	
	fmv.d	fa0, fa1	#wypisanie doubla
	li	a7, 3
	ecall
	
	li	a7, 4
    	la	a0, end2
    	ecall
	
	
	fmv.s	fa0, fa2	#wypisanie floata
	li	a7, 2
	ecall
	
	li	a7, 4		
    	la	a0, result
    	ecall
    	
    	fld	fa0, -100	#wypisanie wyniku
    	li	a7, 3
	ecall

	
   	li	a7, 10
   	ecall
