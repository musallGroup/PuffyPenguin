EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "LED panel"
Date ""
Rev "0"
Comp "Churchland lab - Joao Couto"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Device:R R1
U 1 1 5E4559AE
P 2170 2330
F 0 "R1" V 2170 2380 50  0000 C CNN
F 1 "R" V 2170 2260 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2330 50  0001 C CNN
F 3 "~" H 2170 2330 50  0001 C CNN
	1    2170 2330
	0    1    1    0   
$EndComp
$Comp
L Device:R R2
U 1 1 5E456231
P 2170 2430
F 0 "R2" V 2170 2480 50  0000 C CNN
F 1 "R" V 2170 2360 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2430 50  0001 C CNN
F 3 "~" H 2170 2430 50  0001 C CNN
	1    2170 2430
	0    1    1    0   
$EndComp
$Comp
L Device:R R3
U 1 1 5E45655E
P 2170 2535
F 0 "R3" V 2170 2585 50  0000 C CNN
F 1 "R" V 2170 2465 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2535 50  0001 C CNN
F 3 "~" H 2170 2535 50  0001 C CNN
	1    2170 2535
	0    1    1    0   
$EndComp
$Comp
L Device:R R4
U 1 1 5E4568AF
P 2170 2630
F 0 "R4" V 2170 2680 50  0000 C CNN
F 1 "R" V 2170 2560 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2630 50  0001 C CNN
F 3 "~" H 2170 2630 50  0001 C CNN
	1    2170 2630
	0    1    1    0   
$EndComp
$Comp
L Device:R R5
U 1 1 5E456B30
P 2170 2730
F 0 "R5" V 2170 2780 50  0000 C CNN
F 1 "R" V 2170 2660 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2730 50  0001 C CNN
F 3 "~" H 2170 2730 50  0001 C CNN
	1    2170 2730
	0    1    1    0   
$EndComp
$Comp
L Device:R R6
U 1 1 5E456E2F
P 2170 2830
F 0 "R6" V 2170 2880 50  0000 C CNN
F 1 "R" V 2170 2760 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2830 50  0001 C CNN
F 3 "~" H 2170 2830 50  0001 C CNN
	1    2170 2830
	0    1    1    0   
$EndComp
$Comp
L Device:R R7
U 1 1 5E4570C9
P 2170 2930
F 0 "R7" V 2170 2980 50  0000 C CNN
F 1 "R" V 2170 2860 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 2930 50  0001 C CNN
F 3 "~" H 2170 2930 50  0001 C CNN
	1    2170 2930
	0    1    1    0   
$EndComp
$Comp
L Device:R R8
U 1 1 5E457574
P 2170 3030
F 0 "R8" V 2170 3080 50  0000 C CNN
F 1 "R" V 2170 2960 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 3030 50  0001 C CNN
F 3 "~" H 2170 3030 50  0001 C CNN
	1    2170 3030
	0    1    1    0   
$EndComp
$Comp
L LED:HDSP-4830_2 BAR2
U 1 1 5E4484DB
P 1470 2860
F 0 "BAR2" H 1465 3445 50  0000 C CNN
F 1 "HDSP-4830_2" H 1435 3545 50  0000 C CNN
F 2 "Display:HDSP-4830" H 1470 2060 50  0001 C CNN
F 3 "https://docs.broadcom.com/docs/AV02-1798EN" H -530 3060 50  0001 C CNN
	1    1470 2860
	-1   0    0    1   
$EndComp
$Comp
L LED:HDSP-4830_2 BAR1
U 1 1 5E44713F
P 1465 1730
F 0 "BAR1" H 1465 963 50  0000 C CNN
F 1 "HDSP-4830_2" H 1465 1054 50  0000 C CNN
F 2 "Display:HDSP-4830" H 1465 930 50  0001 C CNN
F 3 "https://docs.broadcom.com/docs/AV02-1798EN" H -535 1930 50  0001 C CNN
	1    1465 1730
	-1   0    0    1   
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5E4777C4
P 2670 1130
F 0 "#PWR02" H 2670 880 50  0001 C CNN
F 1 "GND" V 2675 1002 50  0000 R CNN
F 2 "" H 2670 1130 50  0001 C CNN
F 3 "" H 2670 1130 50  0001 C CNN
	1    2670 1130
	0    1    1    0   
$EndComp
Wire Wire Line
	2670 1130 2790 1130
$Comp
L Device:R R9
U 1 1 5E476D71
P 2170 3125
F 0 "R9" V 2170 3175 50  0000 C CNN
F 1 "R" V 2170 3055 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 3125 50  0001 C CNN
F 3 "~" H 2170 3125 50  0001 C CNN
	1    2170 3125
	0    1    1    0   
$EndComp
$Comp
L Device:R R10
U 1 1 5E477935
P 2170 3225
F 0 "R10" V 2170 3275 50  0000 C CNN
F 1 "R" V 2170 3155 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2100 3225 50  0001 C CNN
F 3 "~" H 2170 3225 50  0001 C CNN
	1    2170 3225
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR01
U 1 1 5E4949F1
P 1055 2220
F 0 "#PWR01" H 1055 1970 50  0001 C CNN
F 1 "GND" V 1060 2092 50  0000 R CNN
F 2 "" H 1055 2220 50  0001 C CNN
F 3 "" H 1055 2220 50  0001 C CNN
	1    1055 2220
	0    1    1    0   
$EndComp
Connection ~ 1055 2220
$Comp
L power:+5V #PWR04
U 1 1 5E4B4B34
P 5080 1590
F 0 "#PWR04" H 5080 1440 50  0001 C CNN
F 1 "+5V" H 5095 1763 50  0000 C CNN
F 2 "" H 5080 1590 50  0001 C CNN
F 3 "" H 5080 1590 50  0001 C CNN
	1    5080 1590
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR03
U 1 1 5E4B522D
P 5090 2325
F 0 "#PWR03" H 5090 2075 50  0001 C CNN
F 1 "GND" H 5095 2152 50  0000 C CNN
F 2 "" H 5090 2325 50  0001 C CNN
F 3 "" H 5090 2325 50  0001 C CNN
	1    5090 2325
	1    0    0    -1  
$EndComp
Wire Wire Line
	5080 1590 5080 1715
$Comp
L Device:R R30
U 1 1 5E454D8F
P 9740 3410
F 0 "R30" V 9740 3460 50  0000 C CNN
F 1 "R" V 9740 3340 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3410 50  0001 C CNN
F 3 "~" H 9740 3410 50  0001 C CNN
	1    9740 3410
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R29
U 1 1 5E454D95
P 9740 3305
F 0 "R29" V 9740 3355 50  0000 C CNN
F 1 "R" V 9740 3235 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3305 50  0001 C CNN
F 3 "~" H 9740 3305 50  0001 C CNN
	1    9740 3305
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R28
U 1 1 5E454D9B
P 9740 3210
F 0 "R28" V 9740 3260 50  0000 C CNN
F 1 "R" V 9740 3140 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3210 50  0001 C CNN
F 3 "~" H 9740 3210 50  0001 C CNN
	1    9740 3210
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R27
U 1 1 5E454DA1
P 9740 3110
F 0 "R27" V 9740 3160 50  0000 C CNN
F 1 "R" V 9740 3040 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3110 50  0001 C CNN
F 3 "~" H 9740 3110 50  0001 C CNN
	1    9740 3110
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R26
U 1 1 5E454DA7
P 9740 3010
F 0 "R26" V 9740 3060 50  0000 C CNN
F 1 "R" V 9740 2940 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3010 50  0001 C CNN
F 3 "~" H 9740 3010 50  0001 C CNN
	1    9740 3010
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R25
U 1 1 5E454DAD
P 9740 2910
F 0 "R25" V 9740 2960 50  0000 C CNN
F 1 "R" V 9740 2840 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 2910 50  0001 C CNN
F 3 "~" H 9740 2910 50  0001 C CNN
	1    9740 2910
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R24
U 1 1 5E454DB3
P 9740 2810
F 0 "R24" V 9740 2860 50  0000 C CNN
F 1 "R" V 9740 2740 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 2810 50  0001 C CNN
F 3 "~" H 9740 2810 50  0001 C CNN
	1    9740 2810
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R23
U 1 1 5E454DB9
P 9740 2710
F 0 "R23" V 9740 2760 50  0000 C CNN
F 1 "R" V 9740 2640 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 2710 50  0001 C CNN
F 3 "~" H 9740 2710 50  0001 C CNN
	1    9740 2710
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R42
U 1 1 5E454DBF
P 9785 2510
F 0 "R42" V 9785 2560 50  0000 C CNN
F 1 "R" V 9785 2440 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2510 50  0001 C CNN
F 3 "~" H 9785 2510 50  0001 C CNN
	1    9785 2510
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R41
U 1 1 5E454DC5
P 9785 2410
F 0 "R41" V 9785 2460 50  0000 C CNN
F 1 "R" V 9785 2340 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2410 50  0001 C CNN
F 3 "~" H 9785 2410 50  0001 C CNN
	1    9785 2410
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R40
U 1 1 5E454DCB
P 9785 2305
F 0 "R40" V 9785 2355 50  0000 C CNN
F 1 "R" V 9785 2235 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2305 50  0001 C CNN
F 3 "~" H 9785 2305 50  0001 C CNN
	1    9785 2305
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R39
U 1 1 5E454DD1
P 9785 2210
F 0 "R39" V 9785 2260 50  0000 C CNN
F 1 "R" V 9785 2140 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2210 50  0001 C CNN
F 3 "~" H 9785 2210 50  0001 C CNN
	1    9785 2210
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R38
U 1 1 5E454DD7
P 9785 2110
F 0 "R38" V 9785 2160 50  0000 C CNN
F 1 "R" V 9785 2040 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2110 50  0001 C CNN
F 3 "~" H 9785 2110 50  0001 C CNN
	1    9785 2110
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R37
U 1 1 5E454DDD
P 9785 2010
F 0 "R37" V 9785 2060 50  0000 C CNN
F 1 "R" V 9785 1940 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 2010 50  0001 C CNN
F 3 "~" H 9785 2010 50  0001 C CNN
	1    9785 2010
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R36
U 1 1 5E454DE3
P 9785 1910
F 0 "R36" V 9785 1960 50  0000 C CNN
F 1 "R" V 9785 1840 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 1910 50  0001 C CNN
F 3 "~" H 9785 1910 50  0001 C CNN
	1    9785 1910
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R35
U 1 1 5E454DE9
P 9785 1810
F 0 "R35" V 9785 1860 50  0000 C CNN
F 1 "R" V 9785 1740 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 1810 50  0001 C CNN
F 3 "~" H 9785 1810 50  0001 C CNN
	1    9785 1810
	0    -1   -1   0   
$EndComp
$Comp
L LED:HDSP-4830_2 BAR3
U 1 1 5E454DEF
P 10485 1980
F 0 "BAR3" H 10480 2565 50  0000 C CNN
F 1 "HDSP-4830_2" H 10450 2665 50  0000 C CNN
F 2 "Display:HDSP-4830" H 10485 1180 50  0001 C CNN
F 3 "https://docs.broadcom.com/docs/AV02-1798EN" H 8485 2180 50  0001 C CNN
	1    10485 1980
	1    0    0    -1  
$EndComp
$Comp
L LED:HDSP-4830_2 BAR4
U 1 1 5E454DF5
P 10490 3110
F 0 "BAR4" H 10490 2343 50  0000 C CNN
F 1 "HDSP-4830_2" H 10490 2434 50  0000 C CNN
F 2 "Display:HDSP-4830" H 10490 2310 50  0001 C CNN
F 3 "https://docs.broadcom.com/docs/AV02-1798EN" H 8490 3310 50  0001 C CNN
	1    10490 3110
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR06
U 1 1 5E454DFB
P 9285 3710
F 0 "#PWR06" H 9285 3460 50  0001 C CNN
F 1 "GND" V 9290 3582 50  0000 R CNN
F 2 "" H 9285 3710 50  0001 C CNN
F 3 "" H 9285 3710 50  0001 C CNN
	1    9285 3710
	0    -1   -1   0   
$EndComp
Wire Wire Line
	9285 3710 9165 3710
Wire Wire Line
	10290 3610 9890 3610
Wire Wire Line
	10290 3510 9890 3510
Wire Wire Line
	10290 3410 9890 3410
Wire Wire Line
	10290 3310 9890 3305
Wire Wire Line
	10290 3210 9890 3210
Wire Wire Line
	10290 3110 9890 3110
Wire Wire Line
	10290 3010 9890 3010
Wire Wire Line
	10290 2910 9890 2910
Wire Wire Line
	10290 2810 9890 2810
Wire Wire Line
	9590 3610 9165 3610
Wire Wire Line
	9590 3510 9165 3510
Wire Wire Line
	9590 3410 9165 3410
Wire Wire Line
	9590 3305 9165 3310
Wire Wire Line
	9590 3210 9165 3210
Wire Wire Line
	9590 3110 9165 3110
Wire Wire Line
	9590 3010 9165 3010
Wire Wire Line
	9590 2910 9165 2910
Wire Wire Line
	9590 2810 9165 2810
Wire Wire Line
	9590 2710 9165 2710
$Comp
L Device:R R34
U 1 1 5E454E15
P 9785 1715
F 0 "R34" V 9785 1765 50  0000 C CNN
F 1 "R" V 9785 1645 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 1715 50  0001 C CNN
F 3 "~" H 9785 1715 50  0001 C CNN
	1    9785 1715
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R33
U 1 1 5E454E1B
P 9785 1615
F 0 "R33" V 9785 1665 50  0000 C CNN
F 1 "R" V 9785 1545 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9715 1615 50  0001 C CNN
F 3 "~" H 9785 1615 50  0001 C CNN
	1    9785 1615
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10285 2480 9935 2510
Wire Wire Line
	10285 2380 9935 2410
Wire Wire Line
	10285 2180 9935 2210
Wire Wire Line
	10285 2080 9935 2110
Wire Wire Line
	10285 1980 9935 2010
Wire Wire Line
	10285 1880 9935 1910
Wire Wire Line
	10285 1780 9935 1810
Wire Wire Line
	10285 1680 9935 1715
Wire Wire Line
	10285 1580 9935 1615
Wire Wire Line
	9635 2510 9165 2610
Wire Wire Line
	9635 2410 9165 2510
Wire Wire Line
	9635 2305 9165 2410
$Comp
L power:GND #PWR08
U 1 1 5E454E34
P 10900 2620
F 0 "#PWR08" H 10900 2370 50  0001 C CNN
F 1 "GND" V 10905 2492 50  0000 R CNN
F 2 "" H 10900 2620 50  0001 C CNN
F 3 "" H 10900 2620 50  0001 C CNN
	1    10900 2620
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10690 3610 10900 3610
Wire Wire Line
	10900 3610 10900 3510
Wire Wire Line
	10900 1580 10685 1580
Connection ~ 10900 2620
Wire Wire Line
	10690 3510 10900 3510
Connection ~ 10900 3510
Wire Wire Line
	10900 3510 10900 3410
Wire Wire Line
	10690 3410 10900 3410
Connection ~ 10900 3410
Wire Wire Line
	10900 3410 10900 3310
Wire Wire Line
	10690 3310 10900 3310
Connection ~ 10900 3310
Wire Wire Line
	10900 3310 10900 3210
Wire Wire Line
	10690 3210 10900 3210
Connection ~ 10900 3210
Wire Wire Line
	10690 3110 10900 3110
Wire Wire Line
	10900 3210 10900 3110
Connection ~ 10900 3110
Wire Wire Line
	10900 3110 10900 3010
Wire Wire Line
	10690 3010 10900 3010
Connection ~ 10900 3010
Wire Wire Line
	10900 3010 10900 2910
Wire Wire Line
	10690 2910 10900 2910
Connection ~ 10900 2910
Wire Wire Line
	10900 2910 10900 2810
Wire Wire Line
	10690 2810 10900 2810
Connection ~ 10900 2810
Wire Wire Line
	10900 2810 10900 2710
Wire Wire Line
	10690 2710 10900 2710
Connection ~ 10900 2710
Wire Wire Line
	10900 2710 10900 2620
Wire Wire Line
	10685 2480 10900 2480
Wire Wire Line
	10900 2620 10900 2480
Connection ~ 10900 2480
Wire Wire Line
	10900 2480 10900 2380
Wire Wire Line
	10685 2380 10900 2380
Connection ~ 10900 2380
Wire Wire Line
	10900 2380 10900 2280
Wire Wire Line
	10685 2280 10900 2280
Connection ~ 10900 2280
Wire Wire Line
	10900 2280 10900 2180
Wire Wire Line
	10685 2180 10900 2180
Connection ~ 10900 2180
Wire Wire Line
	10900 2180 10900 2080
Wire Wire Line
	10685 2080 10900 2080
Connection ~ 10900 2080
Wire Wire Line
	10900 2080 10900 1980
Wire Wire Line
	10685 1980 10900 1980
Connection ~ 10900 1980
Wire Wire Line
	10900 1980 10900 1880
Wire Wire Line
	10685 1880 10900 1880
Connection ~ 10900 1880
Wire Wire Line
	10685 1780 10900 1780
Wire Wire Line
	10900 1880 10900 1780
Connection ~ 10900 1780
Wire Wire Line
	10900 1780 10900 1680
Wire Wire Line
	10685 1680 10900 1680
Connection ~ 10900 1680
Wire Wire Line
	10900 1680 10900 1580
$Comp
L Device:R R31
U 1 1 5E454E77
P 9740 3510
F 0 "R31" V 9740 3560 50  0000 C CNN
F 1 "R" V 9740 3440 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3510 50  0001 C CNN
F 3 "~" H 9740 3510 50  0001 C CNN
	1    9740 3510
	0    -1   -1   0   
$EndComp
$Comp
L Device:R R32
U 1 1 5E454E7D
P 9740 3610
F 0 "R32" V 9740 3660 50  0000 C CNN
F 1 "R" V 9740 3540 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9670 3610 50  0001 C CNN
F 3 "~" H 9740 3610 50  0001 C CNN
	1    9740 3610
	0    -1   -1   0   
$EndComp
Wire Wire Line
	10285 2280 9935 2305
Wire Wire Line
	10290 2710 9890 2710
Text Notes 5590 4800 1    39   ~ 0
5V
Text Notes 5665 4845 1    39   ~ 0
GND
Text Notes 5400 5100 1    39   ~ 0
right trigger
Text Notes 5500 5100 1    39   ~ 0
LED1 trigger
Wire Wire Line
	6650 730  6650 1110
$Comp
L Device:LED D1
U 1 1 5E4975E5
P 4755 5375
F 0 "D1" H 4775 5145 50  0000 C CNN
F 1 "LED" H 4760 5240 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2_1x02_P5.00mm_Horizontal" H 4755 5375 50  0001 C CNN
F 3 "~" H 4755 5375 50  0001 C CNN
	1    4755 5375
	-1   0    0    1   
$EndComp
$Comp
L Device:LED D2
U 1 1 5E4986DD
P 9725 5520
F 0 "D2" H 9710 5260 50  0000 C CNN
F 1 "LED" H 9720 5365 50  0000 C CNN
F 2 "TerminalBlock_Phoenix:TerminalBlock_Phoenix_MKDS-1,5-2_1x02_P5.00mm_Horizontal" H 9725 5520 50  0001 C CNN
F 3 "~" H 9725 5520 50  0001 C CNN
	1    9725 5520
	1    0    0    -1  
$EndComp
$Comp
L Device:R R21
U 1 1 5E4998A3
P 4905 5525
F 0 "R21" H 4740 5575 50  0000 L CNN
F 1 "R" H 4765 5465 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 4835 5525 50  0001 C CNN
F 3 "~" H 4905 5525 50  0001 C CNN
	1    4905 5525
	-1   0    0    1   
$EndComp
$Comp
L Device:R R22
U 1 1 5E49A72A
P 9575 5370
F 0 "R22" H 9400 5425 50  0000 L CNN
F 1 "R" H 9440 5315 50  0000 L CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 9505 5370 50  0001 C CNN
F 3 "~" H 9575 5370 50  0001 C CNN
	1    9575 5370
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5E49CEAA
P 9875 5520
F 0 "#PWR07" H 9875 5270 50  0001 C CNN
F 1 "GND" V 9880 5392 50  0000 R CNN
F 2 "" H 9875 5520 50  0001 C CNN
F 3 "" H 9875 5520 50  0001 C CNN
	1    9875 5520
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR05
U 1 1 5E49DC63
P 4605 5375
F 0 "#PWR05" H 4605 5125 50  0001 C CNN
F 1 "GND" V 4610 5247 50  0000 R CNN
F 2 "" H 4605 5375 50  0001 C CNN
F 3 "" H 4605 5375 50  0001 C CNN
	1    4605 5375
	0    1    1    0   
$EndComp
Wire Wire Line
	4905 5675 5710 5675
Wire Wire Line
	9575 5220 9575 5135
Text Notes 4980 4984 2    79   ~ 0
LED1
Text Notes 9465 5960 0    79   ~ 0
LED2
NoConn ~ 4790 1130
NoConn ~ 4790 1230
NoConn ~ 4790 1330
NoConn ~ 4790 1430
NoConn ~ 4790 1530
NoConn ~ 4790 1630
NoConn ~ 4790 1730
NoConn ~ 4790 1830
NoConn ~ 4790 1930
NoConn ~ 4790 2030
NoConn ~ 4790 2130
NoConn ~ 4790 2230
NoConn ~ 4790 2330
NoConn ~ 4790 2430
NoConn ~ 4790 2530
NoConn ~ 4790 3030
NoConn ~ 4790 3130
NoConn ~ 4790 3230
NoConn ~ 4790 3330
NoConn ~ 4790 3530
NoConn ~ 4790 3630
NoConn ~ 7165 3710
NoConn ~ 7165 3610
NoConn ~ 7165 3510
NoConn ~ 7165 3410
NoConn ~ 7165 3310
NoConn ~ 7165 3210
NoConn ~ 7165 3110
NoConn ~ 7165 3010
NoConn ~ 7165 2910
NoConn ~ 7165 2810
NoConn ~ 7165 2710
NoConn ~ 7165 2610
NoConn ~ 7165 2510
NoConn ~ 7165 2410
NoConn ~ 7165 2310
NoConn ~ 7165 2110
NoConn ~ 7165 1810
NoConn ~ 7165 1710
NoConn ~ 7165 1610
NoConn ~ 7165 1510
NoConn ~ 7165 1310
NoConn ~ 7165 1210
$Comp
L Connector:TestPoint led2
U 1 1 5E614DAD
P 9575 5070
F 0 "led2" H 9633 5188 50  0000 L CNN
F 1 "LED2 test" H 9633 5097 50  0000 L CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 9775 5070 50  0001 C CNN
F 3 "~" H 9775 5070 50  0001 C CNN
	1    9575 5070
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint led1
U 1 1 5E6162B9
P 5710 5675
F 0 "led1" H 5652 5701 50  0000 R CNN
F 1 "LED1 test" H 5652 5792 50  0000 R CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 5910 5675 50  0001 C CNN
F 3 "~" H 5910 5675 50  0001 C CNN
	1    5710 5675
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint 5v1
U 1 1 5E617549
P 5080 1715
F 0 "5v1" H 5022 1741 50  0000 R CNN
F 1 "5V" H 5022 1832 50  0000 R CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 5280 1715 50  0001 C CNN
F 3 "~" H 5280 1715 50  0001 C CNN
	1    5080 1715
	-1   0    0    1   
$EndComp
$Comp
L Connector:TestPoint gnd1
U 1 1 5E618313
P 5090 2325
F 0 "gnd1" H 5148 2443 50  0000 L CNN
F 1 "GND" H 5148 2352 50  0000 L CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 5290 2325 50  0001 C CNN
F 3 "~" H 5290 2325 50  0001 C CNN
	1    5090 2325
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint righttrigger1
U 1 1 5E618E1C
P 5350 3900
F 0 "righttrigger1" H 5425 4060 50  0000 L CNN
F 1 "right trigger" H 5408 3927 50  0000 L CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 5550 3900 50  0001 C CNN
F 3 "~" H 5550 3900 50  0001 C CNN
	1    5350 3900
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint lefttrigger1
U 1 1 5E61A2BB
P 6650 730
F 0 "lefttrigger1" H 6708 848 50  0000 L CNN
F 1 "left trigger" H 6708 757 50  0000 L CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 6850 730 50  0001 C CNN
F 3 "~" H 6850 730 50  0001 C CNN
	1    6650 730 
	1    0    0    -1  
$EndComp
NoConn ~ 4790 2730
Text Notes 1435 4730 0    197  ~ 0
Right visual graph bar
Text Notes 3745 6365 0    197  ~ 0
connector\n
Wire Wire Line
	2600 2330 2600 2230
Wire Wire Line
	2600 2230 2790 2230
Wire Wire Line
	2790 2330 2625 2330
Wire Wire Line
	2625 2330 2625 2430
Wire Wire Line
	2665 2535 2665 2430
Wire Wire Line
	2665 2430 2790 2430
Wire Wire Line
	2790 3030 2665 3030
Wire Wire Line
	2665 3030 2665 2630
Wire Wire Line
	2630 2730 2630 3130
Wire Wire Line
	2630 3130 2790 3130
Wire Wire Line
	2790 3230 2595 3230
Wire Wire Line
	2595 3230 2595 2830
Wire Wire Line
	2550 2930 2550 3330
Wire Wire Line
	2550 3330 2790 3330
Wire Wire Line
	2500 3030 2500 3430
Wire Wire Line
	2500 3430 2790 3430
$Comp
L teensy:Teensy3.2 U1
U 1 1 5E425AE6
P 3790 2480
F 0 "U1" H 3790 4117 60  0000 C CNN
F 1 "Teensy3.2" H 3790 4011 60  0000 C CNN
F 2 "lib:Teensy30_31_32_LC" H 3790 1730 60  0001 C CNN
F 3 "" H 3790 1730 60  0000 C CNN
	1    3790 2480
	1    0    0    -1  
$EndComp
Wire Wire Line
	2460 3530 2790 3530
Wire Wire Line
	2790 3630 2415 3630
NoConn ~ 2790 3730
NoConn ~ 2790 2530
NoConn ~ 2790 2630
NoConn ~ 2790 2830
NoConn ~ 2790 2930
NoConn ~ 9165 2310
NoConn ~ 9165 2210
NoConn ~ 9165 2110
NoConn ~ 9165 2010
NoConn ~ 9165 1910
Wire Wire Line
	9635 2210 9250 2210
Wire Wire Line
	9250 2210 9250 1810
Wire Wire Line
	9250 1810 9165 1810
Wire Wire Line
	9165 1710 9290 1710
Wire Wire Line
	9290 1710 9290 2130
Wire Wire Line
	9290 2130 9635 2130
Wire Wire Line
	9635 2130 9635 2110
Wire Wire Line
	9635 2010 9345 2010
Wire Wire Line
	9345 2010 9345 1610
Wire Wire Line
	9345 1610 9165 1610
Wire Wire Line
	9165 1510 9390 1510
Wire Wire Line
	9390 1510 9390 1910
Wire Wire Line
	9390 1910 9635 1910
Wire Wire Line
	9635 1810 9425 1810
Wire Wire Line
	9425 1810 9425 1410
Wire Wire Line
	9425 1410 9165 1410
Wire Wire Line
	9635 1715 9455 1715
Wire Wire Line
	9455 1715 9455 1310
Wire Wire Line
	9455 1310 9165 1310
Wire Wire Line
	9165 1210 9505 1210
Wire Wire Line
	9505 1210 9505 1615
Wire Wire Line
	9505 1615 9635 1615
NoConn ~ 9165 1110
Wire Wire Line
	7165 1110 6650 1110
NoConn ~ 2790 2730
Wire Wire Line
	2415 3225 2320 3225
Wire Wire Line
	2415 3630 2415 3225
Wire Wire Line
	2460 3125 2460 3530
Wire Wire Line
	2460 3125 2320 3125
Wire Wire Line
	2320 3030 2500 3030
Wire Wire Line
	2320 2930 2550 2930
Wire Wire Line
	2595 2830 2320 2830
Wire Wire Line
	2320 2730 2630 2730
Wire Wire Line
	2665 2630 2320 2630
Wire Wire Line
	2320 2535 2665 2535
Wire Wire Line
	2625 2430 2320 2430
Wire Wire Line
	2320 2330 2600 2330
$Comp
L Device:R R11
U 1 1 5E452CAC
P 2215 1230
F 0 "R11" V 2215 1280 50  0000 C CNN
F 1 "R" V 2215 1160 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1230 50  0001 C CNN
F 3 "~" H 2215 1230 50  0001 C CNN
	1    2215 1230
	0    1    1    0   
$EndComp
$Comp
L Device:R R12
U 1 1 5E451E46
P 2215 1330
F 0 "R12" V 2215 1380 50  0000 C CNN
F 1 "R" V 2215 1260 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1330 50  0001 C CNN
F 3 "~" H 2215 1330 50  0001 C CNN
	1    2215 1330
	0    1    1    0   
$EndComp
Wire Wire Line
	2365 2130 2790 2130
Wire Wire Line
	2365 2030 2790 2030
Wire Wire Line
	2365 1930 2790 1930
Wire Wire Line
	2365 1830 2790 1830
Wire Wire Line
	2365 1730 2790 1730
Wire Wire Line
	2365 1630 2790 1630
Wire Wire Line
	2365 1535 2790 1530
Wire Wire Line
	2365 1430 2790 1430
Wire Wire Line
	2365 1330 2790 1330
Wire Wire Line
	2365 1230 2790 1230
$Comp
L Device:R R20
U 1 1 5E45569B
P 2215 2130
F 0 "R20" V 2215 2180 50  0000 C CNN
F 1 "R" V 2215 2060 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 2130 50  0001 C CNN
F 3 "~" H 2215 2130 50  0001 C CNN
	1    2215 2130
	0    1    1    0   
$EndComp
$Comp
L Device:R R19
U 1 1 5E4547BC
P 2215 2030
F 0 "R19" V 2215 2080 50  0000 C CNN
F 1 "R" V 2215 1960 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 2030 50  0001 C CNN
F 3 "~" H 2215 2030 50  0001 C CNN
	1    2215 2030
	0    1    1    0   
$EndComp
$Comp
L Device:R R18
U 1 1 5E4541F3
P 2215 1930
F 0 "R18" V 2215 1980 50  0000 C CNN
F 1 "R" V 2215 1860 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1930 50  0001 C CNN
F 3 "~" H 2215 1930 50  0001 C CNN
	1    2215 1930
	0    1    1    0   
$EndComp
$Comp
L Device:R R17
U 1 1 5E453EC9
P 2215 1830
F 0 "R17" V 2215 1880 50  0000 C CNN
F 1 "R" V 2215 1760 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1830 50  0001 C CNN
F 3 "~" H 2215 1830 50  0001 C CNN
	1    2215 1830
	0    1    1    0   
$EndComp
$Comp
L Device:R R16
U 1 1 5E453B99
P 2215 1730
F 0 "R16" V 2215 1780 50  0000 C CNN
F 1 "R" V 2215 1660 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1730 50  0001 C CNN
F 3 "~" H 2215 1730 50  0001 C CNN
	1    2215 1730
	0    1    1    0   
$EndComp
$Comp
L Device:R R15
U 1 1 5E453844
P 2215 1630
F 0 "R15" V 2215 1680 50  0000 C CNN
F 1 "R" V 2215 1560 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1630 50  0001 C CNN
F 3 "~" H 2215 1630 50  0001 C CNN
	1    2215 1630
	0    1    1    0   
$EndComp
$Comp
L Device:R R14
U 1 1 5E453515
P 2215 1535
F 0 "R14" V 2215 1585 50  0000 C CNN
F 1 "R" V 2215 1465 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1535 50  0001 C CNN
F 3 "~" H 2215 1535 50  0001 C CNN
	1    2215 1535
	0    1    1    0   
$EndComp
$Comp
L Device:R R13
U 1 1 5E453060
P 2215 1430
F 0 "R13" V 2215 1480 50  0000 C CNN
F 1 "R" V 2215 1360 50  0000 C CNN
F 2 "Resistor_THT:R_Axial_DIN0207_L6.3mm_D2.5mm_P2.54mm_Vertical" V 2145 1430 50  0001 C CNN
F 3 "~" H 2215 1430 50  0001 C CNN
	1    2215 1430
	0    1    1    0   
$EndComp
Wire Wire Line
	1055 3160 1055 3260
Connection ~ 1055 3160
Wire Wire Line
	1270 3160 1055 3160
Wire Wire Line
	1055 3060 1055 3160
Connection ~ 1055 3060
Wire Wire Line
	1270 3060 1055 3060
Wire Wire Line
	1055 2960 1055 3060
Connection ~ 1055 2960
Wire Wire Line
	1270 2960 1055 2960
Wire Wire Line
	1055 2860 1055 2960
Connection ~ 1055 2860
Wire Wire Line
	1270 2860 1055 2860
Wire Wire Line
	1055 2760 1055 2860
Connection ~ 1055 2760
Wire Wire Line
	1270 2760 1055 2760
Wire Wire Line
	1055 2660 1055 2760
Connection ~ 1055 2660
Wire Wire Line
	1270 2660 1055 2660
Wire Wire Line
	1055 2560 1055 2660
Connection ~ 1055 2560
Wire Wire Line
	1270 2560 1055 2560
Wire Wire Line
	1055 2460 1055 2560
Connection ~ 1055 2460
Wire Wire Line
	1270 2460 1055 2460
Wire Wire Line
	1055 2360 1055 2460
Wire Wire Line
	1055 2220 1055 2360
Connection ~ 1055 2360
Wire Wire Line
	1270 2360 1055 2360
Wire Wire Line
	1055 2130 1055 2220
Connection ~ 1055 2130
Wire Wire Line
	1265 2130 1055 2130
Wire Wire Line
	1055 2030 1055 2130
Connection ~ 1055 2030
Wire Wire Line
	1265 2030 1055 2030
Wire Wire Line
	1055 1930 1055 2030
Connection ~ 1055 1930
Wire Wire Line
	1265 1930 1055 1930
Wire Wire Line
	1055 1830 1055 1930
Connection ~ 1055 1830
Wire Wire Line
	1265 1830 1055 1830
Wire Wire Line
	1055 1730 1055 1830
Connection ~ 1055 1730
Wire Wire Line
	1265 1730 1055 1730
Wire Wire Line
	1055 1630 1055 1730
Connection ~ 1055 1630
Wire Wire Line
	1265 1630 1055 1630
Wire Wire Line
	1055 1530 1055 1630
Connection ~ 1055 1530
Wire Wire Line
	1265 1530 1055 1530
Wire Wire Line
	1055 1430 1055 1530
Connection ~ 1055 1430
Wire Wire Line
	1265 1430 1055 1430
Wire Wire Line
	1055 1330 1055 1430
Wire Wire Line
	1055 1230 1055 1330
Connection ~ 1055 1330
Wire Wire Line
	1265 1330 1055 1330
Wire Wire Line
	1055 3260 1270 3260
Wire Wire Line
	1265 1230 1055 1230
Wire Wire Line
	1665 2130 2065 2130
Wire Wire Line
	1670 2560 2020 2535
Wire Wire Line
	1670 3260 2020 3225
Wire Wire Line
	1670 3160 2020 3125
Wire Wire Line
	1670 3060 2020 3030
Wire Wire Line
	1670 2960 2020 2930
Wire Wire Line
	1670 2860 2020 2830
Wire Wire Line
	1670 2760 2020 2730
Wire Wire Line
	1670 2660 2020 2630
Wire Wire Line
	1670 2460 2020 2430
Wire Wire Line
	1670 2360 2020 2330
Wire Wire Line
	1665 2030 2065 2030
Wire Wire Line
	1665 1930 2065 1930
Wire Wire Line
	1665 1830 2065 1830
Wire Wire Line
	1665 1730 2065 1730
Wire Wire Line
	1665 1630 2065 1630
Wire Wire Line
	1665 1530 2065 1535
Wire Wire Line
	1665 1430 2065 1430
Wire Wire Line
	1665 1330 2065 1330
Wire Wire Line
	1665 1230 2065 1230
Text Notes 7730 4380 0    197  ~ 0
Left visual graph bar
Text Notes 5270 4945 1    39   ~ 0
Audio -
Text Notes 5185 4955 1    39   ~ 0
Audio +
$Comp
L Connector:Screw_Terminal_01x06 RightJ1
U 1 1 5F135465
P 5450 4600
F 0 "RightJ1" V 5322 4880 50  0000 L CNN
F 1 "Right screw terminal" V 6020 4475 50  0000 L CNN
F 2 "TerminalBlock_4Ucon:TerminalBlock_4Ucon_1x06_P3.50mm_Horizontal" H 5450 4600 50  0001 C CNN
F 3 "~" H 5450 4600 50  0001 C CNN
	1    5450 4600
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0101
U 1 1 5F136169
P 5650 4400
F 0 "#PWR0101" H 5650 4150 50  0001 C CNN
F 1 "GND" H 5655 4227 50  0000 C CNN
F 2 "" H 5650 4400 50  0001 C CNN
F 3 "" H 5650 4400 50  0001 C CNN
	1    5650 4400
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR0102
U 1 1 5F136A7A
P 5550 4400
F 0 "#PWR0102" H 5550 4250 50  0001 C CNN
F 1 "+5V" H 5565 4573 50  0000 C CNN
F 2 "" H 5550 4400 50  0001 C CNN
F 3 "" H 5550 4400 50  0001 C CNN
	1    5550 4400
	1    0    0    -1  
$EndComp
Wire Wire Line
	4790 3730 5165 3730
Wire Wire Line
	5165 3730 5165 3900
Wire Wire Line
	5165 3900 5350 3900
Wire Wire Line
	5350 3900 5350 4400
Connection ~ 5350 3900
Wire Wire Line
	5710 5675 5770 5675
Wire Wire Line
	5770 5675 5770 4295
Wire Wire Line
	5770 4295 5450 4295
Wire Wire Line
	5450 4295 5450 4400
Connection ~ 5710 5675
$Comp
L power:+5V #PWR0103
U 1 1 5F27B550
P 7165 1410
F 0 "#PWR0103" H 7165 1260 50  0001 C CNN
F 1 "+5V" V 7180 1538 50  0000 L CNN
F 2 "" H 7165 1410 50  0001 C CNN
F 3 "" H 7165 1410 50  0001 C CNN
	1    7165 1410
	0    -1   -1   0   
$EndComp
$Comp
L power:+5V #PWR0104
U 1 1 5F27E2E1
P 4790 3430
F 0 "#PWR0104" H 4790 3280 50  0001 C CNN
F 1 "+5V" V 4805 3558 50  0000 L CNN
F 2 "" H 4790 3430 50  0001 C CNN
F 3 "" H 4790 3430 50  0001 C CNN
	1    4790 3430
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0105
U 1 1 5F2F9FBD
P 6205 2325
F 0 "#PWR0105" H 6205 2075 50  0001 C CNN
F 1 "GND" H 6210 2152 50  0000 C CNN
F 2 "" H 6205 2325 50  0001 C CNN
F 3 "" H 6205 2325 50  0001 C CNN
	1    6205 2325
	1    0    0    -1  
$EndComp
$Comp
L Connector:TestPoint gnd2
U 1 1 5F2F9FC3
P 6205 2325
F 0 "gnd2" H 6263 2443 50  0000 L CNN
F 1 "GND" H 6263 2352 50  0000 L CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 6405 2325 50  0001 C CNN
F 3 "~" H 6405 2325 50  0001 C CNN
	1    6205 2325
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0106
U 1 1 5F326FD0
P 6235 1680
F 0 "#PWR0106" H 6235 1530 50  0001 C CNN
F 1 "+5V" H 6250 1853 50  0000 C CNN
F 2 "" H 6235 1680 50  0001 C CNN
F 3 "" H 6235 1680 50  0001 C CNN
	1    6235 1680
	1    0    0    -1  
$EndComp
Wire Wire Line
	6235 1680 6235 1805
$Comp
L Connector:TestPoint 5v2
U 1 1 5F326FD7
P 6235 1805
F 0 "5v2" H 6177 1831 50  0000 R CNN
F 1 "5V" H 6177 1922 50  0000 R CNN
F 2 "Connector_Pin:Pin_D0.7mm_L6.5mm_W1.8mm_FlatFork" H 6435 1805 50  0001 C CNN
F 3 "~" H 6435 1805 50  0001 C CNN
	1    6235 1805
	-1   0    0    1   
$EndComp
$Comp
L teensy:Teensy3.2 U2
U 1 1 5E454D89
P 8165 2360
F 0 "U2" H 8165 3997 60  0000 C CNN
F 1 "Teensy3.2" H 8165 3891 60  0000 C CNN
F 2 "lib:Teensy30_31_32_LC" H 8165 1610 60  0001 C CNN
F 3 "" H 8165 1610 60  0000 C CNN
	1    8165 2360
	-1   0    0    1   
$EndComp
NoConn ~ 9165 1010
NoConn ~ 7165 1010
NoConn ~ 4790 3830
NoConn ~ 2790 3830
Text Notes 7500 4920 1    39   ~ 0
5V
Text Notes 7595 4940 1    39   ~ 0
GND
Text Notes 7305 5220 1    39   ~ 0
left trigger
Text Notes 7405 5220 1    39   ~ 0
LED2 trigger
Text Notes 7185 5100 1    39   ~ 0
Audio -
Text Notes 7070 5095 1    39   ~ 0
Audio +
$Comp
L Connector:Screw_Terminal_01x06 LeftJ1
U 1 1 5F418C2B
P 7355 4720
F 0 "LeftJ1" V 7227 5000 50  0000 L CNN
F 1 "Left screw terminal" V 7380 5250 50  0000 L CNN
F 2 "TerminalBlock_4Ucon:TerminalBlock_4Ucon_1x06_P3.50mm_Horizontal" H 7355 4720 50  0001 C CNN
F 3 "~" H 7355 4720 50  0001 C CNN
	1    7355 4720
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 5F418C31
P 7555 4520
F 0 "#PWR0107" H 7555 4270 50  0001 C CNN
F 1 "GND" H 7560 4347 50  0000 C CNN
F 2 "" H 7555 4520 50  0001 C CNN
F 3 "" H 7555 4520 50  0001 C CNN
	1    7555 4520
	-1   0    0    1   
$EndComp
$Comp
L power:+5V #PWR0108
U 1 1 5F418C37
P 7455 4520
F 0 "#PWR0108" H 7455 4370 50  0001 C CNN
F 1 "+5V" H 7470 4693 50  0000 C CNN
F 2 "" H 7455 4520 50  0001 C CNN
F 3 "" H 7455 4520 50  0001 C CNN
	1    7455 4520
	1    0    0    -1  
$EndComp
Wire Wire Line
	7355 4415 7355 4520
Wire Wire Line
	7355 4415 9370 4415
Wire Wire Line
	9370 4415 9370 5135
Wire Wire Line
	9370 5135 9575 5135
Connection ~ 9575 5135
Wire Wire Line
	9575 5135 9575 5070
Wire Wire Line
	7255 3860 6650 3860
Wire Wire Line
	6650 3860 6650 1110
Wire Wire Line
	7255 3860 7255 4520
Connection ~ 6650 1110
$Comp
L Connector:Screw_Terminal_01x02 AudioLeft01
U 1 1 5F4B5FF5
P 7155 4320
F 0 "AudioLeft01" V 7295 4085 50  0000 L CNN
F 1 "Audio left" V 7145 3695 50  0000 L CNN
F 2 "lib:speaker" H 7155 4320 50  0001 C CNN
F 3 "~" H 7155 4320 50  0001 C CNN
	1    7155 4320
	0    1    -1   0   
$EndComp
$Comp
L Connector:Screw_Terminal_01x02 AudioRight01
U 1 1 5F4B946C
P 5250 4200
F 0 "AudioRight01" V 5385 3885 50  0000 L CNN
F 1 "Audio right" V 5270 3530 50  0000 L CNN
F 2 "lib:speaker" H 5250 4200 50  0001 C CNN
F 3 "~" H 5250 4200 50  0001 C CNN
	1    5250 4200
	0    1    -1   0   
$EndComp
$Comp
L power:GND #PWR0109
U 1 1 5F50426D
P 7165 2210
F 0 "#PWR0109" H 7165 1960 50  0001 C CNN
F 1 "GND" V 7170 2082 50  0000 R CNN
F 2 "" H 7165 2210 50  0001 C CNN
F 3 "" H 7165 2210 50  0001 C CNN
	1    7165 2210
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0110
U 1 1 5F50A932
P 4790 2630
F 0 "#PWR0110" H 4790 2380 50  0001 C CNN
F 1 "GND" V 4795 2502 50  0000 R CNN
F 2 "" H 4790 2630 50  0001 C CNN
F 3 "" H 4790 2630 50  0001 C CNN
	1    4790 2630
	0    -1   -1   0   
$EndComp
$EndSCHEMATC
