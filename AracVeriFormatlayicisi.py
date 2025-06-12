import re
from collections import defaultdict

veri = """
🚗 Araç Türü: https://www.arabam.com/ikinci-el/otomobil
  🔹 Marka: Acura (https://www.arabam.com/ikinci-el/otomobil/acura)
    📌 Model: CL - 1 ilan
    📌 Model: Integra - 3 ilan
  🔹 Marka: Alfa Romeo (https://www.arabam.com/ikinci-el/otomobil/alfa-romeo)
    📌 Model: 145 - 10 ilan
    📌 Model: 146 - 5 ilan
    📌 Model: 147 - 34 ilan
    📌 Model: 155 - 1 ilan
    📌 Model: 156 - 65 ilan
    📌 Model: 159 - 28 ilan
    📌 Model: 166 - 3 ilan
    📌 Model: 33 - 1 ilan
    📌 Model: Giulia - 3 ilan
    📌 Model: Giulietta - 100 ilan
    📌 Model: MiTo - 7 ilan
    📌 Model: Spider - 1 ilan
  🔹 Marka: Anadol (https://www.arabam.com/ikinci-el/otomobil/anadol)
    📌 Model: A2 SL - 9 ilan
  🔹 Marka: Aston Martin (https://www.arabam.com/ikinci-el/otomobil/aston-martin)
    📌 Model: DB9 - 1 ilan
    📌 Model: DB11 - 1 ilan
    📌 Model: Rapide - 1 ilan
    📌 Model: Vanquish - 1 ilan
    📌 Model: Vantage - 3 ilan
    📌 Model: Virage - 1 ilan
  🔹 Marka: Audi (https://www.arabam.com/ikinci-el/otomobil/audi)
    📌 Model: A1 - 16 ilan
    📌 Model: E-Tron GT - 2 ilan
    📌 Model: TTS - 3 ilan
    📌 Model: A3 - 1.393 ilan
    📌 Model: A4 - 846 ilan
    📌 Model: A5 - 244 ilan
    📌 Model: A6 - 568 ilan
    📌 Model: A7 - 39 ilan
    📌 Model: A8 - 38 ilan
    📌 Model: R8 - 3 ilan
    📌 Model: RS - 24 ilan
    📌 Model: S - 15 ilan
    📌 Model: TT - 15 ilan
    📌 Model: 80 Serisi - 5 ilan
    📌 Model: 90 Serisi - 3 ilan
    📌 Model: 100 Serisi - 2 ilan
    📌 Model: 200 Serisi - 1 ilan
  🔹 Marka: Bentley (https://www.arabam.com/ikinci-el/otomobil/bentley)
    📌 Model: Continental - 13 ilan
    📌 Model: Flying Spur - 2 ilan
  🔹 Marka: BMW (https://www.arabam.com/ikinci-el/otomobil/bmw)
    📌 Model: 1 Serisi - 631 ilan
    📌 Model: 2 Serisi - 145 ilan
    📌 Model: 3 Serisi - 2.292 ilan
    📌 Model: 4 Serisi - 258 ilan
    📌 Model: 5 Serisi - 1.611 ilan
    📌 Model: 6 Serisi - 26 ilan
    📌 Model: 7 Serisi - 96 ilan
    📌 Model: 8 Serisi - 1 ilan
    📌 Model: i Serisi - 77 ilan
    📌 Model: M Serisi - 67 ilan
    📌 Model: Z Serisi - 15 ilan
  🔹 Marka: Buick (https://www.arabam.com/ikinci-el/otomobil/buick)
    📌 Model: Regal - 1 ilan
  🔹 Marka: BYD (https://www.arabam.com/ikinci-el/otomobil/byd)
    📌 Model: Seal U - 2 ilan
  🔹 Marka: Cadillac (https://www.arabam.com/ikinci-el/otomobil/cadillac)
    📌 Model: Eldorado - 2 ilan
    📌 Model: Seville - 1 ilan
  🔹 Marka: Chery (https://www.arabam.com/ikinci-el/otomobil/chery)
    📌 Model: Alia - 27 ilan
    📌 Model: Chance - 3 ilan
    📌 Model: Kimo - 18 ilan
    📌 Model: Niche - 3 ilan
  🔹 Marka: Chevrolet (https://www.arabam.com/ikinci-el/otomobil/chevrolet)
    📌 Model: Aveo - 561 ilan
    📌 Model: Camaro - 14 ilan
    📌 Model: Corvette - 10 ilan
    📌 Model: Cruze - 606 ilan
    📌 Model: Epica - 18 ilan
    📌 Model: Evanda - 5 ilan
    📌 Model: Kalos - 221 ilan
    📌 Model: Lacetti - 203 ilan
    📌 Model: Rezzo - 22 ilan
    📌 Model: Spark - 37 ilan
  🔹 Marka: Chrysler (https://www.arabam.com/ikinci-el/otomobil/chrysler)
    📌 Model: 300 C - 25 ilan
    📌 Model: 300 M - 4 ilan
    📌 Model: Concorde - 1 ilan
    📌 Model: Crossfire - 2 ilan
    📌 Model: PT Cruiser - 3 ilan
    📌 Model: Sebring - 19 ilan
    📌 Model: Stratus - 7 ilan
  🔹 Marka: Citroen (https://www.arabam.com/ikinci-el/otomobil/citroen)
    📌 Model: AMİ - 49 ilan
    📌 Model: BX - 1 ilan
    📌 Model: C-Elysee - 1.011 ilan
    📌 Model: C1 - 38 ilan
    📌 Model: C2 - 29 ilan
    📌 Model: C3 - 780 ilan
    📌 Model: C3 Picasso - 24 ilan
    📌 Model: C4 - 795 ilan
    📌 Model: C4 Grand Picasso - 64 ilan
    📌 Model: C4 Picasso - 63 ilan
    📌 Model: C4 X - 104 ilan
    📌 Model: C5 - 306 ilan
    📌 Model: C6 - 2 ilan
    📌 Model: C8 - 5 ilan
    📌 Model: e-C4 - 12 ilan
    📌 Model: e-C4 X - 21 ilan
    📌 Model: Evasion - 2 ilan
    📌 Model: Saxo - 79 ilan
    📌 Model: Xantia - 8 ilan
    📌 Model: XM - 1 ilan
    📌 Model: Xsara - 110 ilan
    📌 Model: ZX - 10 ilan
  🔹 Marka: Cupra (https://www.arabam.com/ikinci-el/otomobil/cupra)
    📌 Model: Leon - 31 ilan
  🔹 Marka: Dacia (https://www.arabam.com/ikinci-el/otomobil/dacia)
    📌 Model: Jogger - 26 ilan
    📌 Model: Lodgy - 152 ilan
    📌 Model: Logan - 421 ilan
    📌 Model: Sandero - 774 ilan
    📌 Model: Solenza - 85 ilan
  🔹 Marka: Daewoo (https://www.arabam.com/ikinci-el/otomobil/daewoo)
    📌 Model: Chairman - 1 ilan
    📌 Model: Espero - 4 ilan
    📌 Model: Lanos - 20 ilan
    📌 Model: Leganza - 3 ilan
    📌 Model: Matiz - 6 ilan
    📌 Model: Nexia - 15 ilan
    📌 Model: Nubira - 14 ilan
    📌 Model: Racer - 1 ilan
    📌 Model: Tico - 5 ilan
  🔹 Marka: Daihatsu (https://www.arabam.com/ikinci-el/otomobil/daihatsu)
    📌 Model: Applause - 7 ilan
    📌 Model: Charade - 3 ilan
    📌 Model: Copen - 1 ilan
    📌 Model: Cuore - 12 ilan
    📌 Model: Materia - 2 ilan
    📌 Model: Move - 5 ilan
    📌 Model: Sirion - 18 ilan
    📌 Model: YRV - 5 ilan
  🔹 Marka: Dodge (https://www.arabam.com/ikinci-el/otomobil/dodge)
    📌 Model: Challenger - 4 ilan
    📌 Model: Charger - 2 ilan
    📌 Model: Magnum - 1 ilan
  🔹 Marka: DS Automobiles (https://www.arabam.com/ikinci-el/otomobil/ds-automobiles)
    📌 Model: DS3 - 12 ilan
    📌 Model: DS4 - 55 ilan
    📌 Model: DS5 - 7 ilan
    📌 Model: DS9 - 15 ilan
  🔹 Marka: Ferrari (https://www.arabam.com/ikinci-el/otomobil/ferrari)
    📌 Model: 360 - 1 ilan
    📌 Model: 430 - 2 ilan
    📌 Model: 458 - 4 ilan
    📌 Model: 550 - 1 ilan
    📌 Model: 599 - 1 ilan
    📌 Model: California - 2 ilan
    📌 Model: F8 - 2 ilan
  🔹 Marka: Fiat (https://www.arabam.com/ikinci-el/otomobil/fiat)
    📌 Model: 124 Spider - 1 ilan
    📌 Model: 126 Bis - 12 ilan
    📌 Model: 500 Abarth - 2 ilan
    📌 Model: 500 Ailesi - 172 ilan
    📌 Model: Albea - 1.059 ilan
    📌 Model: Brava - 185 ilan
    📌 Model: Bravo - 138 ilan
    📌 Model: Coupe - 3 ilan
    📌 Model: Croma - 1 ilan
    📌 Model: Egea - 4.620 ilan
    📌 Model: Idea - 35 ilan
    📌 Model: Linea - 2.647 ilan
    📌 Model: Marea - 414 ilan
    📌 Model: Palio - 1.342 ilan
    📌 Model: Panda - 90 ilan
    📌 Model: Punto - 1.093 ilan
    📌 Model: Regata - 1 ilan
    📌 Model: Sedici - 1 ilan
    📌 Model: Siena - 324 ilan
    📌 Model: Stilo - 88 ilan
    📌 Model: Tempra - 490 ilan
    📌 Model: Tipo - 519 ilan
    📌 Model: Topolino - 6 ilan
    📌 Model: Uno - 559 ilan
  🔹 Marka: Ford (https://www.arabam.com/ikinci-el/otomobil/ford)
    📌 Model: B-Max - 56 ilan
    📌 Model: C-Max - 367 ilan
    📌 Model: Cougar - 1 ilan
    📌 Model: Escort - 501 ilan
    📌 Model: Festiva - 9 ilan
    📌 Model: Fiesta - 2.442 ilan
    📌 Model: Focus - 4.646 ilan
    📌 Model: Fusion - 229 ilan
    📌 Model: Galaxy - 13 ilan
    📌 Model: Granada - 2 ilan
    📌 Model: Grand C-Max - 20 ilan
    📌 Model: Ka - 53 ilan
    📌 Model: Mondeo - 583 ilan
    📌 Model: Mustang - 15 ilan
    📌 Model: Probe - 1 ilan
    📌 Model: S-Max - 17 ilan
    📌 Model: Scorpio - 8 ilan
    📌 Model: Sierra - 8 ilan
    📌 Model: Taunus - 103 ilan
    📌 Model: Taurus - 1 ilan
  🔹 Marka: Geely (https://www.arabam.com/ikinci-el/otomobil/geely)
    📌 Model: Echo - 12 ilan
    📌 Model: Emgrand - 49 ilan
    📌 Model: Familia - 22 ilan
    📌 Model: FC - 11 ilan
  🔹 Marka: Honda (https://www.arabam.com/ikinci-el/otomobil/honda)
    📌 Model: Accord - 155 ilan
    📌 Model: City - 282 ilan
    📌 Model: Civic - 3.111 ilan
    📌 Model: CR-Z - 2 ilan
    📌 Model: CRX - 3 ilan
    📌 Model: Integra - 6 ilan
    📌 Model: Jazz - 218 ilan
    📌 Model: Legend - 2 ilan
    📌 Model: Prelude - 3 ilan
    📌 Model: S2000 - 6 ilan
    📌 Model: Shuttle - 1 ilan
    📌 Model: Stream - 1 ilan
  🔹 Marka: Hyundai (https://www.arabam.com/ikinci-el/otomobil/hyundai)
    📌 Model: Accent - 1.271 ilan
    📌 Model: Accent Blue - 694 ilan
    📌 Model: Accent Era - 1.050 ilan
    📌 Model: Atos - 42 ilan
    📌 Model: Coupe - 15 ilan
    📌 Model: Elantra - 420 ilan
    📌 Model: Excel - 59 ilan
    📌 Model: Genesis - 4 ilan
    📌 Model: Getz - 930 ilan
    📌 Model: i10 - 153 ilan
    📌 Model: i20 - 1.604 ilan
    📌 Model: i20 Active - 24 ilan
    📌 Model: i20 N - 12 ilan
    📌 Model: i20 Troy - 121 ilan
    📌 Model: i30 - 376 ilan
    📌 Model: i40 - 7 ilan
    📌 Model: Ioniq - 18 ilan
    📌 Model: ix20 - 9 ilan
    📌 Model: Matrix - 67 ilan
    📌 Model: Sonata - 38 ilan
    📌 Model: Trajet - 1 ilan
  🔹 Marka: I-GO (https://www.arabam.com/ikinci-el/otomobil/ı-go)
    📌 Model: J4 - 1 ilan
  🔹 Marka: Ikco (https://www.arabam.com/ikinci-el/otomobil/ikco)
    📌 Model: Samand - 4 ilan
  🔹 Marka: Infiniti (https://www.arabam.com/ikinci-el/otomobil/infiniti)
    📌 Model: G - 2 ilan
    📌 Model: I30 - 4 ilan
    📌 Model: Q30 - 2 ilan
    📌 Model: Q50 - 1 ilan
    📌 Model: Q60 - 2 ilan
  🔹 Marka: Isuzu (https://www.arabam.com/ikinci-el/otomobil/isuzu)
    📌 Model: Gemini - 1 ilan
  🔹 Marka: Jaguar (https://www.arabam.com/ikinci-el/otomobil/jaguar)
    📌 Model: Daimler - 2 ilan
    📌 Model: S-Type - 10 ilan
    📌 Model: Sovereign - 1 ilan
    📌 Model: X-Type - 25 ilan
    📌 Model: XE - 15 ilan
    📌 Model: XF - 22 ilan
    📌 Model: XJ - 11 ilan
    📌 Model: XKR - 1 ilan
  🔹 Marka: Joyce (https://www.arabam.com/ikinci-el/otomobil/joyce)
    📌 Model: One - 2 ilan
  🔹 Marka: Kia (https://www.arabam.com/ikinci-el/otomobil/kia)
    📌 Model: Capital - 4 ilan
    📌 Model: Carens - 7 ilan
    📌 Model: Carnival - 10 ilan
    📌 Model: Ceed - 199 ilan
    📌 Model: Cerato - 219 ilan
    📌 Model: Clarus - 1 ilan
    📌 Model: Magentis - 4 ilan
    📌 Model: Opirus - 1 ilan
    📌 Model: Optima - 1 ilan
    📌 Model: Picanto - 172 ilan
    📌 Model: Pride - 23 ilan
    📌 Model: Pro Ceed - 14 ilan
    📌 Model: Rio - 438 ilan
    📌 Model: Sephia - 42 ilan
    📌 Model: Shuma - 8 ilan
    📌 Model: Venga - 25 ilan
  🔹 Marka: Lada (https://www.arabam.com/ikinci-el/otomobil/lada)
    📌 Model: Kalina - 15 ilan
    📌 Model: Priora - 1 ilan
    📌 Model: Samara - 211 ilan
    📌 Model: VAZ - 4 ilan
    📌 Model: Vega - 197 ilan
  🔹 Marka: Lamborghini (https://www.arabam.com/ikinci-el/otomobil/lamborghini)
    📌 Model: Gallardo - 1 ilan
    📌 Model: Huracan - 1 ilan
  🔹 Marka: Lancia (https://www.arabam.com/ikinci-el/otomobil/lancia)
    📌 Model: Delta - 21 ilan
    📌 Model: Ypsilon - 10 ilan
  🔹 Marka: Leapmotor (https://www.arabam.com/ikinci-el/otomobil/leapmotor)
    📌 Model: T03 - 2 ilan
  🔹 Marka: Lexus (https://www.arabam.com/ikinci-el/otomobil/lexus)
    📌 Model: ES - 7 ilan
    📌 Model: GS - 12 ilan
    📌 Model: IS - 1 ilan
    📌 Model: LS - 2 ilan
  🔹 Marka: Lincoln (https://www.arabam.com/ikinci-el/otomobil/lincoln)
    📌 Model: Mark - 1 ilan
  🔹 Marka: Lotus (https://www.arabam.com/ikinci-el/otomobil/lotus)
    📌 Model: Emira - 1 ilan
    📌 Model: Esprit - 1 ilan
  🔹 Marka: Maserati (https://www.arabam.com/ikinci-el/otomobil/maserati)
    📌 Model: Ghibli - 13 ilan
    📌 Model: GranCabrio - 1 ilan
    📌 Model: GranTurismo - 3 ilan
    📌 Model: Quattroporte - 6 ilan
  🔹 Marka: Mazda (https://www.arabam.com/ikinci-el/otomobil/mazda)
    📌 Model: 121 - 5 ilan
    📌 Model: 2 - 19 ilan
    📌 Model: 3 - 144 ilan
    📌 Model: 323 - 151 ilan
    📌 Model: 5 - 4 ilan
    📌 Model: 6 - 22 ilan
    📌 Model: 626 - 87 ilan
    📌 Model: Lantis - 14 ilan
    📌 Model: MPV - 2 ilan
    📌 Model: MX - 5 ilan
    📌 Model: Premacy - 1 ilan
    📌 Model: RX - 1 ilan
    📌 Model: Xedos - 3 ilan
  🔹 Marka: Mercedes - Benz (https://www.arabam.com/ikinci-el/otomobil/mercedes-benz)
    📌 Model: A - 386 ilan
    📌 Model: CLE - 1 ilan
    📌 Model: EQE - 30 ilan
    📌 Model: EQS - 11 ilan
    📌 Model: AMG GT - 8 ilan
    📌 Model: B - 136 ilan
    📌 Model: C - 1.597 ilan
    📌 Model: CL - 5 ilan
    📌 Model: CLA - 334 ilan
    📌 Model: CLC - 11 ilan
    📌 Model: CLK - 54 ilan
    📌 Model: CLS - 62 ilan
    📌 Model: E - 1.349 ilan
    📌 Model: Maybach S - 19 ilan
    📌 Model: S - 236 ilan
    📌 Model: SL - 21 ilan
    📌 Model: SLC - 5 ilan
    📌 Model: SLK - 18 ilan
    📌 Model: SLS - 1 ilan
    📌 Model: 190 - 114 ilan
    📌 Model: 200 - 147 ilan
    📌 Model: 230 - 45 ilan
    📌 Model: 240 - 3 ilan
    📌 Model: 250 - 30 ilan
    📌 Model: 260 - 7 ilan
    📌 Model: 280 - 9 ilan
    📌 Model: 300 - 60 ilan
    📌 Model: 320 - 1 ilan
    📌 Model: 500 - 3 ilan
    📌 Model: 560 - 1 ilan
    📌 Model: 600 - 1 ilan
  🔹 Marka: Mercury (https://www.arabam.com/ikinci-el/otomobil/mercury)
    📌 Model: Cougar - 1 ilan
  🔹 Marka: MG (https://www.arabam.com/ikinci-el/otomobil/mg)
    📌 Model: F - 1 ilan
    📌 Model: MG4 - 12 ilan
  🔹 Marka: MINI (https://www.arabam.com/ikinci-el/otomobil/mini)
    📌 Model: Cooper - 196 ilan
    📌 Model: Cooper Clubman - 17 ilan
    📌 Model: Cooper S - 46 ilan
    📌 Model: John Cooper - 5 ilan
    📌 Model: One - 15 ilan
  🔹 Marka: Mitsubishi (https://www.arabam.com/ikinci-el/otomobil/mitsubishi)
    📌 Model: Attrage - 11 ilan
    📌 Model: Carisma - 102 ilan
    📌 Model: Colt - 70 ilan
    📌 Model: Diamante - 1 ilan
    📌 Model: Galant - 2 ilan
    📌 Model: Grandis - 1 ilan
    📌 Model: Lancer - 114 ilan
    📌 Model: Lancer Evolution - 4 ilan
    📌 Model: Space Star - 34 ilan
    📌 Model: Space Wagon - 1 ilan
  🔹 Marka: Nieve (https://www.arabam.com/ikinci-el/otomobil/nieve)
    📌 Model: Evzoom - 3 ilan
  🔹 Marka: Nissan (https://www.arabam.com/ikinci-el/otomobil/nissan)
    📌 Model: 200 SX - 3 ilan
    📌 Model: Almera - 122 ilan
    📌 Model: Altima - 2 ilan
    📌 Model: Bluebird - 3 ilan
    📌 Model: Laurel Altima - 2 ilan
    📌 Model: Maxima - 13 ilan
    📌 Model: Micra - 463 ilan
    📌 Model: Note - 92 ilan
    📌 Model: NX Coupe - 4 ilan
    📌 Model: Primera - 175 ilan
    📌 Model: Pulsar - 22 ilan
    📌 Model: Sunny - 24 ilan
  🔹 Marka: Opel (https://www.arabam.com/ikinci-el/otomobil/opel)
    📌 Model: Agila - 1 ilan
    📌 Model: Ascona - 4 ilan
    📌 Model: Astra - 5.687 ilan
    📌 Model: Calibra - 1 ilan
    📌 Model: Corsa - 3.156 ilan
    📌 Model: Corsa-e - 21 ilan
    📌 Model: Insignia - 738 ilan
    📌 Model: Kadett - 9 ilan
    📌 Model: Meriva - 173 ilan
    📌 Model: Omega - 27 ilan
    📌 Model: Rekord - 1 ilan
    📌 Model: Signum - 1 ilan
    📌 Model: Tigra - 23 ilan
    📌 Model: Vectra - 1.440 ilan
    📌 Model: Zafira - 106 ilan
  🔹 Marka: Peugeot (https://www.arabam.com/ikinci-el/otomobil/peugeot)
    📌 Model: 106 - 127 ilan
    📌 Model: 107 - 34 ilan
    📌 Model: 205 - 3 ilan
    📌 Model: 206 - 991 ilan
    📌 Model: 206+ - 195 ilan
    📌 Model: 207 - 540 ilan
    📌 Model: 208 - 386 ilan
    📌 Model: 301 - 877 ilan
    📌 Model: 305 - 2 ilan
    📌 Model: 306 - 162 ilan
    📌 Model: 307 - 794 ilan
    📌 Model: 308 - 588 ilan
    📌 Model: 405 - 6 ilan
    📌 Model: 406 - 100 ilan
    📌 Model: 407 - 231 ilan
    📌 Model: 508 - 355 ilan
    📌 Model: 607 - 4 ilan
    📌 Model: 806 - 1 ilan
    📌 Model: 807 - 4 ilan
    📌 Model: e-308 - 6 ilan
    📌 Model: RCZ - 17 ilan
  🔹 Marka: Porsche (https://www.arabam.com/ikinci-el/otomobil/porsche)
    📌 Model: 718 - 10 ilan
    📌 Model: 911 - 32 ilan
    📌 Model: Boxster - 5 ilan
    📌 Model: Cayman - 5 ilan
    📌 Model: Panamera - 73 ilan
    📌 Model: Taycan - 32 ilan
  🔹 Marka: Proton (https://www.arabam.com/ikinci-el/otomobil/proton)
    📌 Model: 218 - 1 ilan
    📌 Model: 315 - 6 ilan
    📌 Model: 413 - 1 ilan
    📌 Model: 415 - 24 ilan
    📌 Model: 416 - 17 ilan
    📌 Model: 418 - 8 ilan
    📌 Model: 420 - 3 ilan
    📌 Model: Gen 2 - 8 ilan
    📌 Model: Savvy - 4 ilan
    📌 Model: Waja - 7 ilan
  🔹 Marka: Rainwoll (https://www.arabam.com/ikinci-el/otomobil/rainwoll)
    📌 Model: RW10 - 2 ilan
  🔹 Marka: Regal Raptor (https://www.arabam.com/ikinci-el/otomobil/regal-raptor)
    📌 Model: K4 - 1 ilan
    📌 Model: K5 Long - 4 ilan
  🔹 Marka: Renault (https://www.arabam.com/ikinci-el/otomobil/renault)
    📌 Model: Clio - 6.091 ilan
    📌 Model: Espace - 15 ilan
    📌 Model: Fluence - 1.891 ilan
    📌 Model: Fluence Z.E - 1 ilan
    📌 Model: Grand Scenic - 52 ilan
    📌 Model: Laguna - 468 ilan
    📌 Model: Latitude - 116 ilan
    📌 Model: Megane - 5.724 ilan
    📌 Model: Megane E-Tech - 33 ilan
    📌 Model: Modus - 65 ilan
    📌 Model: R 5 - 6 ilan
    📌 Model: Safrane - 12 ilan
    📌 Model: Scenic - 304 ilan
    📌 Model: Symbol - 2.127 ilan
    📌 Model: Taliant - 200 ilan
    📌 Model: Talisman - 103 ilan
    📌 Model: Twingo - 63 ilan
    📌 Model: Twizy - 2 ilan
    📌 Model: Vel Satis - 3 ilan
    📌 Model: Zoe - 36 ilan
    📌 Model: R 9 - 1.217 ilan
    📌 Model: R 11 - 133 ilan
    📌 Model: R 12 - 517 ilan
    📌 Model: R 19 - 841 ilan
    📌 Model: R 21 - 76 ilan
    📌 Model: R 25 - 1 ilan
  🔹 Marka: RKS (https://www.arabam.com/ikinci-el/otomobil/rks)
    📌 Model: A1 - 2 ilan
    📌 Model: M5 - 3 ilan
    📌 Model: MT3 - 2 ilan
  🔹 Marka: Rolls-Royce (https://www.arabam.com/ikinci-el/otomobil/rolls-royce)
    📌 Model: Ghost - 3 ilan
    📌 Model: Phantom - 1 ilan
    📌 Model: Silver - 1 ilan
    📌 Model: Spectre - 2 ilan
    📌 Model: Wraith - 3 ilan
  🔹 Marka: Rover (https://www.arabam.com/ikinci-el/otomobil/rover)
    📌 Model: 25 - 5 ilan
    📌 Model: 45 - 1 ilan
    📌 Model: 75 - 4 ilan
    📌 Model: 200 - 2 ilan
    📌 Model: 214 - 9 ilan
    📌 Model: 216 - 18 ilan
    📌 Model: 414 - 12 ilan
    📌 Model: 416 - 20 ilan
    📌 Model: 420 - 4 ilan
    📌 Model: 620 - 7 ilan
    📌 Model: 820 - 4 ilan
    📌 Model: Streetwise - 1 ilan
  🔹 Marka: Saab (https://www.arabam.com/ikinci-el/otomobil/saab)
    📌 Model: 9-3 - 11 ilan
    📌 Model: 9-5 - 3 ilan
    📌 Model: 9000 - 1 ilan
  🔹 Marka: Seat (https://www.arabam.com/ikinci-el/otomobil/seat)
    📌 Model: Alhambra - 4 ilan
    📌 Model: Altea - 36 ilan
    📌 Model: Cordoba - 275 ilan
    📌 Model: Exeo - 7 ilan
    📌 Model: Ibiza - 571 ilan
    📌 Model: Leon - 1.096 ilan
    📌 Model: Malaga - 1 ilan
    📌 Model: Marbella - 1 ilan
    📌 Model: Toledo - 224 ilan
  🔹 Marka: Skoda (https://www.arabam.com/ikinci-el/otomobil/skoda)
    📌 Model: Citigo - 6 ilan
    📌 Model: Fabia - 515 ilan
    📌 Model: Favorit - 147 ilan
    📌 Model: Felicia - 170 ilan
    📌 Model: Forman - 66 ilan
    📌 Model: Octavia - 1.007 ilan
    📌 Model: Rapid - 158 ilan
    📌 Model: Roomster - 39 ilan
    📌 Model: Scala - 156 ilan
    📌 Model: SuperB - 783 ilan
  🔹 Marka: Smart (https://www.arabam.com/ikinci-el/otomobil/smart)
    📌 Model: ForFour - 14 ilan
    📌 Model: ForTwo - 6 ilan
    📌 Model: Roadster - 2 ilan
  🔹 Marka: Subaru (https://www.arabam.com/ikinci-el/otomobil/subaru)
    📌 Model: BRZ - 2 ilan
    📌 Model: Impreza - 38 ilan
    📌 Model: Justy - 1 ilan
    📌 Model: Legacy - 10 ilan
    📌 Model: Levorg - 4 ilan
    📌 Model: Vivio - 3 ilan
  🔹 Marka: Suzuki (https://www.arabam.com/ikinci-el/otomobil/suzuki)
    📌 Model: Alto - 17 ilan
    📌 Model: Baleno - 12 ilan
    📌 Model: Liana - 1 ilan
    📌 Model: Maruti - 28 ilan
    📌 Model: Splash - 11 ilan
    📌 Model: Swift - 174 ilan
    📌 Model: SX4 - 32 ilan
  🔹 Marka: Tata (https://www.arabam.com/ikinci-el/otomobil/tata)
    📌 Model: Indica - 43 ilan
    📌 Model: Indigo - 37 ilan
    📌 Model: Manza - 5 ilan
    📌 Model: Marina - 32 ilan
    📌 Model: Vista - 18 ilan
  🔹 Marka: Tesla (https://www.arabam.com/ikinci-el/otomobil/tesla)
    📌 Model: Model 3 - 11 ilan
    📌 Model: Model S - 3 ilan
    📌 Model: Model Y - 108 ilan
  🔹 Marka: The London Taxi (https://www.arabam.com/ikinci-el/otomobil/the-london-taxi)
    📌 Model: TX4 - 2 ilan
  🔹 Marka: Tofaş (https://www.arabam.com/ikinci-el/otomobil/tofas)
    📌 Model: Doğan - 1.295 ilan
    📌 Model: Kartal - 400 ilan
    📌 Model: Murat - 69 ilan
    📌 Model: Şahin - 1.635 ilan
    📌 Model: Serçe - 71 ilan
  🔹 Marka: Toyota (https://www.arabam.com/ikinci-el/otomobil/toyota)
    📌 Model: Auris - 596 ilan
    📌 Model: Avensis - 286 ilan
    📌 Model: Camry - 8 ilan
    📌 Model: Carina - 30 ilan
    📌 Model: Corolla - 4.223 ilan
    📌 Model: Corona - 45 ilan
    📌 Model: Crown - 1 ilan
    📌 Model: Prius - 2 ilan
    📌 Model: Starlet - 8 ilan
    📌 Model: Urban Cruiser - 4 ilan
    📌 Model: Verso - 82 ilan
    📌 Model: Yaris - 434 ilan
  🔹 Marka: Volkswagen (https://www.arabam.com/ikinci-el/otomobil/volkswagen)
    📌 Model: Arteon - 26 ilan
    📌 Model: Bora - 545 ilan
    📌 Model: EOS - 5 ilan
    📌 Model: Golf - 2.834 ilan
    📌 Model: Jetta - 2.005 ilan
    📌 Model: New Beetle - 64 ilan
    📌 Model: Passat - 4.021 ilan
    📌 Model: Passat Alltrack - 1 ilan
    📌 Model: Passat Variant - 164 ilan
    📌 Model: Phaeton - 1 ilan
    📌 Model: Polo - 3.527 ilan
    📌 Model: Scirocco - 121 ilan
    📌 Model: Sharan - 7 ilan
    📌 Model: The Beetle - 4 ilan
    📌 Model: Touran - 31 ilan
    📌 Model: Vento - 7 ilan
    📌 Model: VW CC - 270 ilan
  🔹 Marka: Volta (https://www.arabam.com/ikinci-el/otomobil/volta)
    📌 Model: EV1 - 6 ilan
  🔹 Marka: Volvo (https://www.arabam.com/ikinci-el/otomobil/volvo)
    📌 Model: C30 - 12 ilan
    📌 Model: C70 - 4 ilan
    📌 Model: S40 - 236 ilan
    📌 Model: S60 - 331 ilan
    📌 Model: S70 - 7 ilan
    📌 Model: S80 - 75 ilan
    📌 Model: S90 - 66 ilan
    📌 Model: V40 - 91 ilan
    📌 Model: V40 Cross Country - 29 ilan
    📌 Model: V50 - 7 ilan
    📌 Model: V60 - 7 ilan
    📌 Model: V60 Cross Country - 4 ilan
    📌 Model: V70 - 5 ilan
    📌 Model: V90 Cross Country - 17 ilan
    📌 Model: 460 - 1 ilan
    📌 Model: 740 - 1 ilan
    📌 Model: 850 - 7 ilan
    📌 Model: 940 - 2 ilan
    📌 Model: 960 - 2 ilan
  🔹 Marka: XEV (https://www.arabam.com/ikinci-el/otomobil/xev)
    📌 Model: Yoyo - 2 ilan
  🔹 Marka: Yuki (https://www.arabam.com/ikinci-el/otomobil/yuki)
    📌 Model: Amy - 2 ilan
  🔹 Marka: Zeekr (https://www.arabam.com/ikinci-el/otomobil/zeekr)
    📌 Model: 001 - 1 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/arazi-suv-pick-up
  🔹 Marka: Alfa Romeo (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/alfa-romeo)
    📌 Model: Junior Ibrida - 1 ilan
    📌 Model: Stelvio - 1 ilan
    📌 Model: Tonale - 36 ilan
  🔹 Marka: Audi (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/audi)
    📌 Model: E-Tron - 9 ilan
    📌 Model: Q2 - 94 ilan
    📌 Model: Q3 - 133 ilan
    📌 Model: Q5 - 88 ilan
    📌 Model: Q7 - 98 ilan
    📌 Model: Q8 - 24 ilan
    📌 Model: Q8 E-Tron - 4 ilan
    📌 Model: Q8 Sportback E-Tron - 6 ilan
    📌 Model: RS Q8 - 7 ilan
  🔹 Marka: Bentley (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/bentley)
    📌 Model: Bentayga - 1 ilan
  🔹 Marka: BMW (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/bmw)
    📌 Model: iX - 21 ilan
    📌 Model: iX1 - 24 ilan
    📌 Model: iX2 - 8 ilan
    📌 Model: iX3 - 14 ilan
    📌 Model: X1 - 217 ilan
    📌 Model: X2 - 20 ilan
    📌 Model: X3 - 171 ilan
    📌 Model: X4 - 1 ilan
    📌 Model: X5 - 199 ilan
    📌 Model: X6 - 55 ilan
    📌 Model: X7 - 2 ilan
  🔹 Marka: BYD (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/byd)
    📌 Model: Atto 3 - 5 ilan
    📌 Model: Seal U - 5 ilan
  🔹 Marka: Cadillac (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/cadillac)
    📌 Model: Escalade - 11 ilan
  🔹 Marka: Chery (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/chery)
    📌 Model: Omoda 5 - 118 ilan
    📌 Model: Omoda 5 Pro - 6 ilan
    📌 Model: Tiggo - 51 ilan
    📌 Model: Tiggo 7 Pro - 119 ilan
    📌 Model: Tiggo 7 Pro Max - 13 ilan
    📌 Model: Tiggo 8 Pro - 134 ilan
    📌 Model: Tiggo 8 Pro Max - 12 ilan
  🔹 Marka: Chevrolet (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/chevrolet)
    📌 Model: Avalanche - 3 ilan
    📌 Model: Blazer - 8 ilan
    📌 Model: Captiva - 334 ilan
    📌 Model: Equinox - 1 ilan
    📌 Model: HHR - 1 ilan
    📌 Model: Silverado - 5 ilan
    📌 Model: Suburban - 2 ilan
    📌 Model: Tahoe - 2 ilan
    📌 Model: Trax - 20 ilan
  🔹 Marka: Citroen (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/citroen)
    📌 Model: C3 Aircross - 167 ilan
    📌 Model: C4 Cactus - 71 ilan
    📌 Model: C4 SUV - 7 ilan
    📌 Model: C5 Aircross - 180 ilan
  🔹 Marka: Cupra (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/cupra)
    📌 Model: Ateca - 4 ilan
    📌 Model: Formentor - 141 ilan
  🔹 Marka: Dacia (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/dacia)
    📌 Model: Duster - 1.123 ilan
    📌 Model: Sandero Stepway - 108 ilan
    📌 Model: Spring - 12 ilan
  🔹 Marka: Daewoo (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/daewoo)
    📌 Model: Korando - 1 ilan
    📌 Model: Musso - 1 ilan
  🔹 Marka: Daihatsu (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/daihatsu)
    📌 Model: Feroza - 4 ilan
    📌 Model: Terios - 66 ilan
  🔹 Marka: DFM (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/dfm)
    📌 Model: Rich - 1 ilan
  🔹 Marka: DFSK (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/dfsk)
    📌 Model: E5 - 10 ilan
    📌 Model: Fengon - 5 ilan
    📌 Model: Glory 580 - 2 ilan
  🔹 Marka: Dodge (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/dodge)
    📌 Model: Caliber - 1 ilan
    📌 Model: Journey - 4 ilan
    📌 Model: Nitro - 27 ilan
    📌 Model: Ram - 4 ilan
  🔹 Marka: DS Automobiles (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/ds-automobiles)
    📌 Model: DS3 Crossback - 11 ilan
    📌 Model: DS7 Crossback - 59 ilan
  🔹 Marka: Fiat (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/fiat)
    📌 Model: 500 X - 48 ilan
    📌 Model: Egea Cross - 612 ilan
    📌 Model: Freemont - 23 ilan
    📌 Model: Fullback - 15 ilan
    📌 Model: Sedici - 3 ilan
  🔹 Marka: Ford (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/ford)
    📌 Model: EcoSport - 69 ilan
    📌 Model: Edge - 2 ilan
    📌 Model: Expedition - 1 ilan
    📌 Model: Explorer - 7 ilan
    📌 Model: F - 3 ilan
    📌 Model: Kuga - 349 ilan
    📌 Model: Maverick - 1 ilan
    📌 Model: Mustang Mach-E - 3 ilan
    📌 Model: Puma - 98 ilan
    📌 Model: Ranger - 348 ilan
  🔹 Marka: GMC (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/gmc)
    📌 Model: Jimmy - 1 ilan
    📌 Model: Sierra - 11 ilan
    📌 Model: Typhoon - 1 ilan
  🔹 Marka: Honda (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/honda)
    📌 Model: CR-V - 374 ilan
    📌 Model: HR-V - 82 ilan
  🔹 Marka: Hummer (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/hummer)
    📌 Model: H Serisi - 5 ilan
  🔹 Marka: Hyundai (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/hyundai)
    📌 Model: Bayon - 247 ilan
    📌 Model: Galloper - 3 ilan
    📌 Model: Ioniq 5 - 13 ilan
    📌 Model: ix35 - 230 ilan
    📌 Model: ix55 - 1 ilan
    📌 Model: Kona - 108 ilan
    📌 Model: Santa Fe - 65 ilan
    📌 Model: Tucson - 713 ilan
  🔹 Marka: Infiniti (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/infiniti)
    📌 Model: FX - 18 ilan
    📌 Model: QX - 4 ilan
  🔹 Marka: Isuzu (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/isuzu)
    📌 Model: D-Max - 167 ilan
    📌 Model: Trooper - 1 ilan
  🔹 Marka: Jaecoo (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/jaecoo)
    📌 Model: J7 - 17 ilan
  🔹 Marka: Jaguar (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/jaguar)
    📌 Model: E-Pace - 2 ilan
    📌 Model: F-Pace - 19 ilan
    📌 Model: I-Pace - 10 ilan
  🔹 Marka: Jeep (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/jeep)
    📌 Model: Avenger Electric - 12 ilan
    📌 Model: Cherokee - 56 ilan
    📌 Model: CJ - 11 ilan
    📌 Model: Commander - 7 ilan
    📌 Model: Compass - 78 ilan
    📌 Model: Grand Cherokee - 133 ilan
    📌 Model: Liberty - 1 ilan
    📌 Model: Patriot - 9 ilan
    📌 Model: Renegade - 170 ilan
    📌 Model: Wrangler - 12 ilan
  🔹 Marka: Kia (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/kia)
    📌 Model: EV3 - 2 ilan
    📌 Model: EV6 - 9 ilan
    📌 Model: EV9 - 7 ilan
    📌 Model: Niro - 18 ilan
    📌 Model: Sorento - 211 ilan
    📌 Model: Soul - 13 ilan
    📌 Model: Sportage - 769 ilan
    📌 Model: Stonic - 131 ilan
    📌 Model: XCeed - 18 ilan
  🔹 Marka: Lada (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/lada)
    📌 Model: Niva - 51 ilan
  🔹 Marka: Lamborghini (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/lamborghini)
    📌 Model: Urus - 8 ilan
  🔹 Marka: Land Rover (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/land-rover)
    📌 Model: Defender - 54 ilan
    📌 Model: Discovery - 71 ilan
    📌 Model: Discovery Sport - 35 ilan
    📌 Model: Freelander - 179 ilan
    📌 Model: Range Rover - 218 ilan
    📌 Model: Range Rover Evoque - 99 ilan
    📌 Model: Range Rover Sport - 289 ilan
    📌 Model: Range Rover Velar - 61 ilan
  🔹 Marka: Lexus (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/lexus)
    📌 Model: LX - 2 ilan
    📌 Model: NX - 1 ilan
    📌 Model: RX - 8 ilan
  🔹 Marka: Lincoln (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/lincoln)
    📌 Model: Navigator - 8 ilan
  🔹 Marka: Lynk & Co (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/lynk-co)
    📌 Model: 01 - 3 ilan
  🔹 Marka: Mahindra (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mahindra)
    📌 Model: Goa - 5 ilan
    📌 Model: Pick-Up - 1 ilan
  🔹 Marka: Maserati (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/maserati)
    📌 Model: Grecale - 8 ilan
    📌 Model: Levante - 18 ilan
  🔹 Marka: Mazda (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mazda)
    📌 Model: B2500 - 19 ilan
    📌 Model: BT50 - 7 ilan
    📌 Model: CX-3 - 17 ilan
    📌 Model: CX-5 - 7 ilan
    📌 Model: CX-9 - 4 ilan
  🔹 Marka: Mercedes - Benz (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mercedes-benz)
    📌 Model: EQA - 4 ilan
    📌 Model: EQB - 24 ilan
    📌 Model: EQC - 11 ilan
    📌 Model: G - 59 ilan
    📌 Model: GL - 13 ilan
    📌 Model: GLA - 86 ilan
    📌 Model: GLB - 51 ilan
    📌 Model: GLC - 52 ilan
    📌 Model: GLE - 12 ilan
    📌 Model: GLK - 32 ilan
    📌 Model: GLS - 9 ilan
    📌 Model: ML - 63 ilan
    📌 Model: X 250 d - 41 ilan
    📌 Model: X 350 d - 4 ilan
  🔹 Marka: MG (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mg)
    📌 Model: EHS - 7 ilan
    📌 Model: HS - 67 ilan
    📌 Model: ZS - 36 ilan
    📌 Model: ZS EV - 10 ilan
  🔹 Marka: MINI (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mini)
    📌 Model: Cooper Countryman - 132 ilan
    📌 Model: Countryman E - 9 ilan
  🔹 Marka: Mitsubishi (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/mitsubishi)
    📌 Model: ASX - 51 ilan
    📌 Model: Eclipse Cross - 6 ilan
    📌 Model: L 200 - 447 ilan
    📌 Model: Outlander - 12 ilan
    📌 Model: Pajero - 25 ilan
  🔹 Marka: Nissan (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/nissan)
    📌 Model: Country - 9 ilan
    📌 Model: Juke - 405 ilan
    📌 Model: Murano - 1 ilan
    📌 Model: Navara - 176 ilan
    📌 Model: Pathfinder - 8 ilan
    📌 Model: Patrol - 6 ilan
    📌 Model: Pick Up - 18 ilan
    📌 Model: Qashqai - 1.341 ilan
    📌 Model: Qashqai+2 - 27 ilan
    📌 Model: Skystar - 104 ilan
    📌 Model: Terrano - 25 ilan
    📌 Model: X-Trail - 225 ilan
  🔹 Marka: Opel (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/opel)
    📌 Model: Antara - 14 ilan
    📌 Model: Crossland - 203 ilan
    📌 Model: Crossland X - 56 ilan
    📌 Model: Frontera - 10 ilan
    📌 Model: Grandland - 88 ilan
    📌 Model: Grandland X - 92 ilan
    📌 Model: Mokka - 311 ilan
    📌 Model: Mokka X - 39 ilan
    📌 Model: Mokka-e - 34 ilan
  🔹 Marka: Peugeot (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/peugeot)
    📌 Model: 2008 - 535 ilan
    📌 Model: 3008 - 733 ilan
    📌 Model: 408 - 103 ilan
    📌 Model: e-2008 - 15 ilan
    📌 Model: e-3008 - 8 ilan
    📌 Model: e-5008 - 2 ilan
    📌 Model: 5008 - 156 ilan
  🔹 Marka: Porsche (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/porsche)
    📌 Model: Cayenne - 135 ilan
    📌 Model: Macan - 32 ilan
  🔹 Marka: Renault (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/renault)
    📌 Model: Austral - 62 ilan
    📌 Model: Captur - 240 ilan
    📌 Model: Duster - 7 ilan
    📌 Model: Kadjar - 209 ilan
    📌 Model: Koleos - 19 ilan
    📌 Model: Rafale - 1 ilan
    📌 Model: Scenic RX4 - 3 ilan
  🔹 Marka: Rolls-Royce (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/rolls-royce)
    📌 Model: Cullinan - 4 ilan
  🔹 Marka: Seat (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/seat)
    📌 Model: Arona - 156 ilan
    📌 Model: Ateca - 103 ilan
    📌 Model: Tarraco - 11 ilan
  🔹 Marka: Seres (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/seres)
    📌 Model: 3 - 10 ilan
  🔹 Marka: Skoda (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/skoda)
    📌 Model: Felicia Pickup - 4 ilan
    📌 Model: Kamiq - 117 ilan
    📌 Model: Karoq - 85 ilan
    📌 Model: Kodiaq - 114 ilan
    📌 Model: Yeti - 76 ilan
  🔹 Marka: Skywell (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/skywell)
    📌 Model: ET5 - 31 ilan
  🔹 Marka: Ssangyong (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/ssangyong)
    📌 Model: Actyon - 12 ilan
    📌 Model: Actyon Sports - 53 ilan
    📌 Model: Korando - 26 ilan
    📌 Model: Korando Sports - 32 ilan
    📌 Model: Kyron - 40 ilan
    📌 Model: Musso - 3 ilan
    📌 Model: Musso Grand - 45 ilan
    📌 Model: Rexton - 28 ilan
    📌 Model: Rodius - 7 ilan
    📌 Model: Tivoli - 15 ilan
    📌 Model: Torres - 39 ilan
    📌 Model: XLV - 2 ilan
  🔹 Marka: Subaru (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/subaru)
    📌 Model: Crosstrek - 1 ilan
    📌 Model: Forester - 65 ilan
    📌 Model: Outback - 7 ilan
    📌 Model: Solterra - 1 ilan
    📌 Model: Tribeca - 1 ilan
    📌 Model: XV - 33 ilan
  🔹 Marka: Suzuki (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/suzuki)
    📌 Model: Grand Vitara - 108 ilan
    📌 Model: Jimny - 29 ilan
    📌 Model: S-Cross - 14 ilan
    📌 Model: SJ - 14 ilan
    📌 Model: SX4 S-Cross - 14 ilan
    📌 Model: Vitara - 140 ilan
  🔹 Marka: SWM (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/swm)
    📌 Model: G01F - 2 ilan
    📌 Model: G01F Premium DCT - 3 ilan
    📌 Model: G05 Pro - 1 ilan
  🔹 Marka: Tata (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/tata)
    📌 Model: Safari - 2 ilan
    📌 Model: Telcoline - 48 ilan
    📌 Model: Xenon - 33 ilan
  🔹 Marka: Tesla (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/tesla)
    📌 Model: Model X - 1 ilan
  🔹 Marka: TOGG (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/togg)
    📌 Model: T10X - 109 ilan
  🔹 Marka: Toyota (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/toyota)
    📌 Model: 4 Runner - 1 ilan
    📌 Model: C-HR - 131 ilan
    📌 Model: Corolla Cross - 78 ilan
    📌 Model: FJ Cruiser - 4 ilan
    📌 Model: Hilux - 293 ilan
    📌 Model: Land Cruiser - 30 ilan
    📌 Model: RAV4 - 76 ilan
    📌 Model: Yaris Cross - 23 ilan
  🔹 Marka: Volkswagen (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/volkswagen)
    📌 Model: Amarok - 285 ilan
    📌 Model: ID.4 - 21 ilan
    📌 Model: T-Cross - 85 ilan
    📌 Model: T-Roc - 224 ilan
    📌 Model: Taigo - 138 ilan
    📌 Model: Tiguan - 799 ilan
    📌 Model: Tiguan All Space - 8 ilan
    📌 Model: Touareg - 92 ilan
  🔹 Marka: Volvo (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/volvo)
    📌 Model: C40 - 4 ilan
    📌 Model: XC40 - 63 ilan
    📌 Model: XC60 - 120 ilan
    📌 Model: XC70 - 4 ilan
    📌 Model: XC90 - 184 ilan
  🔹 Marka: Voyah (https://www.arabam.com/ikinci-el/arazi-suv-pick-up/voyah)
    📌 Model: Free - 1 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/elektrik_li-araclar
  🔹 Marka: Elektrikli Motosiklet (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-motosiklet)
    📌 Model: Apachi - 6 ilan
    📌 Model: Apec - 11 ilan
    📌 Model: Arnica - 1 ilan
    📌 Model: Arora - 96 ilan
    📌 Model: Beyaz Motor - 3 ilan
    📌 Model: Bftalx - 1 ilan
    📌 Model: Cenntro - 1 ilan
    📌 Model: CityCoco - 2 ilan
    📌 Model: Diğer Markalar - 15 ilan
    📌 Model: E-Mon - 44 ilan
    📌 Model: E-Scooter - 3 ilan
    📌 Model: Ekobis - 3 ilan
    📌 Model: Falcon - 22 ilan
    📌 Model: Fiat - 2 ilan
    📌 Model: Goe - 4 ilan
    📌 Model: Horwin - 2 ilan
    📌 Model: Kanuni - 3 ilan
    📌 Model: Karoval - 1 ilan
    📌 Model: Kral Motor - 13 ilan
    📌 Model: Kuba - 25 ilan
    📌 Model: Lampago - 1 ilan
    📌 Model: Leksas - 2 ilan
    📌 Model: Mobilette - 3 ilan
    📌 Model: Mondial - 31 ilan
    📌 Model: Motolux - 72 ilan
    📌 Model: Musatti - 6 ilan
    📌 Model: Regal Raptor - 19 ilan
    📌 Model: Relive - 5 ilan
    📌 Model: RKS - 39 ilan
    📌 Model: SFM - 3 ilan
    📌 Model: Silence - 5 ilan
    📌 Model: Smarda - 19 ilan
    📌 Model: Stmax - 19 ilan
    📌 Model: Super Soco - 3 ilan
    📌 Model: Vespa - 3 ilan
    📌 Model: Volta - 67 ilan
    📌 Model: Yetobis - 1 ilan
    📌 Model: Yuki - 76 ilan
    📌 Model: Zeeho - 1 ilan
    📌 Model: Zlin - 5 ilan
  🔹 Marka: Elektrikli Minivan & Panelvan (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-minivan_-panelvan_)
    📌 Model: Piaggio - 1 ilan
  🔹 Marka: Elektrikli Scooter (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-scooter)
    📌 Model: BMW - 2 ilan
    📌 Model: Citymate - 2 ilan
    📌 Model: Diğer Markalar - 8 ilan
    📌 Model: Dualtron - 1 ilan
    📌 Model: Electro Wind - 1 ilan
    📌 Model: Inmotion - 1 ilan
    📌 Model: Kral Motor - 2 ilan
    📌 Model: Kuba - 3 ilan
    📌 Model: RKS - 9 ilan
    📌 Model: Segway - 5 ilan
    📌 Model: Volta - 26 ilan
    📌 Model: Vsett - 1 ilan
    📌 Model: Xiaomi - 2 ilan
    📌 Model: Yuki - 3 ilan
    📌 Model: Zero - 1 ilan
  🔹 Marka: Elektrikli Kickscooter (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-kickscooter)
    📌 Model: BMW - 2 ilan
    📌 Model: Citycoco - 1 ilan
    📌 Model: Citymate - 1 ilan
    📌 Model: Diğer Markalar - 4 ilan
    📌 Model: Electro Wind - 1 ilan
    📌 Model: HiFree - 1 ilan
    📌 Model: Honda - 1 ilan
    📌 Model: Kaabo - 1 ilan
    📌 Model: Kral Motor - 5 ilan
    📌 Model: Kuba - 16 ilan
    📌 Model: Meka Motor - 1 ilan
    📌 Model: Ninebot - 3 ilan
    📌 Model: Onvo - 15 ilan
    📌 Model: RKS - 5 ilan
    📌 Model: Segway - 2 ilan
    📌 Model: Stmax - 2 ilan
    📌 Model: Sway - 1 ilan
    📌 Model: Volta - 1 ilan
    📌 Model: Wawasaky - 7 ilan
    📌 Model: Xiaomi - 2 ilan
  🔹 Marka: Elektrikli ATV & UTV (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-atv-utv)
    📌 Model: Kral Motor - 1 ilan
    📌 Model: Rine - 1 ilan
    📌 Model: Yuki - 2 ilan
  🔹 Marka: Elektrikli Hizmet Araçları (https://www.arabam.com/ikinci-el/elektrik_li-araclar/elektrikli-hizmet-araclari)
    📌 Model: Clubcar - 1 ilan
    📌 Model: Regal Raptor - 5 ilan
    📌 Model: Volta - 5 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/motosiklet
  🔹 Marka: Abush (https://www.arabam.com/ikinci-el/motosiklet/abush)
    📌 Model: CG 50 Plus - 2 ilan
    📌 Model: CGA 125i - 1 ilan
    📌 Model: Speedy 100i - 3 ilan
    📌 Model: Speedy 125i - 1 ilan
  🔹 Marka: Altai (https://www.arabam.com/ikinci-el/motosiklet/altai)
    📌 Model: Carrier 110 Pro - 4 ilan
    📌 Model: F1Max 50 - 3 ilan
    📌 Model: F1Max Pro 50 - 5 ilan
    📌 Model: Misk 50 - 1 ilan
    📌 Model: Ristretto 125 - 6 ilan
    📌 Model: Tank S50 - 3 ilan
    📌 Model: Tank X125 - 4 ilan
    📌 Model: Uma 50 - 5 ilan
    📌 Model: XLine 50 - 1 ilan
    📌 Model: XLine 50 Pro - 8 ilan
  🔹 Marka: Apachi (https://www.arabam.com/ikinci-el/motosiklet/apachi)
    📌 Model: Alfa 50 - 1 ilan
    📌 Model: Beauty 125 - 9 ilan
    📌 Model: Beauty 50 - 2 ilan
    📌 Model: Diğer Modeller - 8 ilan
    📌 Model: Joy 125 - 4 ilan
    📌 Model: Nova 125 - 7 ilan
    📌 Model: Pusat - 1 ilan
    📌 Model: True 50 - 1 ilan
    📌 Model: XRS - 8 ilan
  🔹 Marka: Apec (https://www.arabam.com/ikinci-el/motosiklet/apec)
    📌 Model: APX5 - 35 ilan
    📌 Model: APX7 - 7 ilan
    📌 Model: PS3 - 14 ilan
    📌 Model: PS5 - 33 ilan
  🔹 Marka: Aprilia (https://www.arabam.com/ikinci-el/motosiklet/aprilia)
    📌 Model: Classic - 1 ilan
    📌 Model: Leonardo 250 - 1 ilan
    📌 Model: Mojito 125 Custom - 2 ilan
    📌 Model: RS 125 - 5 ilan
    📌 Model: RS 660 - 1 ilan
    📌 Model: RS4 RF - 1 ilan
    📌 Model: Scarabeo 200 - 2 ilan
    📌 Model: SR 125 - 6 ilan
    📌 Model: SR GT 200 - 13 ilan
    📌 Model: Tuono 125 - 3 ilan
    📌 Model: Tuono 660 - 1 ilan
    📌 Model: Tuono V4 1100 Factory - 1 ilan
  🔹 Marka: Arora (https://www.arabam.com/ikinci-el/motosiklet/arora)
    📌 Model: Alfa 110 - 5 ilan
    📌 Model: AR 06 - 11 ilan
    📌 Model: AR 100-7 - 1 ilan
    📌 Model: AR 100-7 Special Alfa - 2 ilan
    📌 Model: AR 100-8 A Modifiye - 5 ilan
    📌 Model: AR 100-8 Klasik Çelik - 1 ilan
    📌 Model: AR 100-8 Klasik Tel - 1 ilan
    📌 Model: AR 100T 2A Special - 2 ilan
    📌 Model: AR 125-3 - 1 ilan
    📌 Model: AR 125-43 Yebere - 1 ilan
    📌 Model: AR 150-5 Kargo - 4 ilan
    📌 Model: AR 150-A - 1 ilan
    📌 Model: AR 150-T - 3 ilan
    📌 Model: AR 150T-N2 Nostalji - 1 ilan
    📌 Model: AR 180-16 C - 1 ilan
    📌 Model: AR 185-20 Fırtına - 2 ilan
    📌 Model: AR 200-16C Jaguar - 6 ilan
    📌 Model: AR 50 Cappuccino - 88 ilan
    📌 Model: AR 50 Special - 3 ilan
    📌 Model: AR 50-10 Toros - 1 ilan
    📌 Model: AR 50-11 Ares - 1 ilan
    📌 Model: AR 50-30 - 1 ilan
    📌 Model: AR 50-50 Kasırga - 37 ilan
    📌 Model: AR 50-6 Capirossi - 2 ilan
    📌 Model: AR 50-8 Espresso - 2 ilan
    📌 Model: AR-200-16C Jaguar - 5 ilan
    📌 Model: ARS 200 - 19 ilan
    📌 Model: Beatrix - 44 ilan
    📌 Model: Boss 125 - 9 ilan
    📌 Model: Cappucino 125 - 71 ilan
    📌 Model: CG50 - 20 ilan
    📌 Model: Chinf 318 - 8 ilan
    📌 Model: CP 250 - 4 ilan
    📌 Model: CR 250 - 11 ilan
    📌 Model: CRV 125 - 4 ilan
    📌 Model: Dazzle 125 - 1 ilan
    📌 Model: Dazzle 50 - 21 ilan
    📌 Model: Dazzle 80 - 3 ilan
    📌 Model: Diğer Modeller - 13 ilan
    📌 Model: Fırtına 50 - 6 ilan
    📌 Model: Freedom 125 - 9 ilan
    📌 Model: Freedom 50 - 37 ilan
    📌 Model: Gemma 125 - 7 ilan
    📌 Model: GP 250 - 2 ilan
    📌 Model: GS 525 - 1 ilan
    📌 Model: GT 125 - 11 ilan
    📌 Model: GT 250 - 2 ilan
    📌 Model: Malibu - 16 ilan
    📌 Model: Max Jet - 6 ilan
    📌 Model: Max Pro - 25 ilan
    📌 Model: Max-T - 46 ilan
    📌 Model: Max-T Easy - 18 ilan
    📌 Model: Mojito 125 - 5 ilan
    📌 Model: Mojito 50 - 4 ilan
    📌 Model: Mojito Pro - 4 ilan
    📌 Model: Mojito Pro S - 19 ilan
    📌 Model: MT 125 - 12 ilan
    📌 Model: Quantum 125 - 4 ilan
    📌 Model: Quantum 50 - 31 ilan
    📌 Model: Safari 125 - 4 ilan
    📌 Model: Safari 50 - 13 ilan
    📌 Model: Safari Pro - 37 ilan
    📌 Model: SK 250 K - 6 ilan
    📌 Model: SK 250 KV - 3 ilan
    📌 Model: Smart 50 - 15 ilan
    📌 Model: Special 125 - 6 ilan
    📌 Model: Verano 50 - 7 ilan
    📌 Model: Verano AR 125-25 - 7 ilan
    📌 Model: Verano AR 50-9 - 3 ilan
    📌 Model: VESTA 50 - 11 ilan
    📌 Model: ZRX 200 - 12 ilan
  🔹 Marka: Asya (https://www.arabam.com/ikinci-el/motosiklet/asya)
    📌 Model: AS 100-7 Turkcub - 1 ilan
    📌 Model: AS 125 - 1 ilan
    📌 Model: AS 150 T 7B - 1 ilan
    📌 Model: AS 150 T1 - 3 ilan
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Efsane Eco 100 - 1 ilan
    📌 Model: Elegant 150 - 1 ilan
    📌 Model: Nostalji 125 - 1 ilan
    📌 Model: Pulsar N 160 - 4 ilan
    📌 Model: Rx-250 Cross - 1 ilan
  🔹 Marka: Bajaj (https://www.arabam.com/ikinci-el/motosiklet/bajaj)
    📌 Model: Boxer - 1 ilan
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Discover 125 ST - 3 ilan
    📌 Model: Discover 150 F - 3 ilan
    📌 Model: Dominar 250 D - 123 ilan
    📌 Model: Dominar 400 - 2 ilan
    📌 Model: Dominar 400 UG - 61 ilan
    📌 Model: Dominar D 400 - 21 ilan
    📌 Model: Pulsar 125 NS - 22 ilan
    📌 Model: Pulsar 150 NS - 8 ilan
    📌 Model: Pulsar 160 NS - 4 ilan
    📌 Model: Pulsar 200 NS - 33 ilan
    📌 Model: Pulsar 200 NS ABS - 67 ilan
    📌 Model: Pulsar 200 RS - 213 ilan
    📌 Model: Pulsar AS 150 - 2 ilan
    📌 Model: Pulsar F 250 - 20 ilan
    📌 Model: Pulsar N 250 - 49 ilan
    📌 Model: Pulsar NS 200 UG - 29 ilan
    📌 Model: V 15 - 8 ilan
  🔹 Marka: Barossa (https://www.arabam.com/ikinci-el/motosiklet/barossa)
    📌 Model: ADV 125 - 1 ilan
    📌 Model: Jedi - 2 ilan
  🔹 Marka: Bashan (https://www.arabam.com/ikinci-el/motosiklet/bashan)
    📌 Model: 125 - 82 ilan
  🔹 Marka: Belderia (https://www.arabam.com/ikinci-el/motosiklet/belderia)
    📌 Model: FC 150 - 1 ilan
  🔹 Marka: Benelli (https://www.arabam.com/ikinci-el/motosiklet/benelli)
    📌 Model: 125 S - 48 ilan
    📌 Model: 502 C - 2 ilan
    📌 Model: 752 S - 2 ilan
    📌 Model: BN 251 - 3 ilan
    📌 Model: Leoncino - 1 ilan
    📌 Model: Leoncino 250 - 6 ilan
    📌 Model: TNT 125 - 3 ilan
    📌 Model: TNT 249 S - 1 ilan
    📌 Model: TNT 25 - 4 ilan
    📌 Model: TNT 250 - 4 ilan
    📌 Model: TRK 251 - 13 ilan
    📌 Model: TRK 502 - 4 ilan
    📌 Model: TRK 502 X - 8 ilan
    📌 Model: TRK 702X - 8 ilan
    📌 Model: Zafferano - 1 ilan
  🔹 Marka: Beta (https://www.arabam.com/ikinci-el/motosiklet/beta)
    📌 Model: RR 4T 525 Racing - 6 ilan
    📌 Model: RR 4T Enduro 250 - 4 ilan
  🔹 Marka: Bisan (https://www.arabam.com/ikinci-el/motosiklet/bisan)
    📌 Model: Atlas 125 - 1 ilan
    📌 Model: NYSA 150 - 1 ilan
    📌 Model: Pasific 125 - 1 ilan
    📌 Model: Sunway FKS 125 - 1 ilan
    📌 Model: Teos 125 - 1 ilan
    📌 Model: Toprak WRC 125 - 1 ilan
  🔹 Marka: BMW (https://www.arabam.com/ikinci-el/motosiklet/bmw)
    📌 Model: Diğer Modeller - 4 ilan
    📌 Model: F 650 GS - 8 ilan
    📌 Model: F 700 GS - 4 ilan
    📌 Model: F 750 GS - 2 ilan
    📌 Model: F 800 GS - 4 ilan
    📌 Model: F 800 GS Adventure - 1 ilan
    📌 Model: F 850 GS - 1 ilan
    📌 Model: F 850 GS Adventure - 3 ilan
    📌 Model: F 900 XR - 1 ilan
    📌 Model: G 310 GS - 1 ilan
    📌 Model: G 310 R - 2 ilan
    📌 Model: K 1100 LT - 1 ilan
    📌 Model: K 1200 GT - 1 ilan
    📌 Model: K 1200 S - 1 ilan
    📌 Model: K 1300 GT - 1 ilan
    📌 Model: K 1300 R - 7 ilan
    📌 Model: K 1300 S - 1 ilan
    📌 Model: K 1600 GT - 2 ilan
    📌 Model: K 1600 GTL - 2 ilan
    📌 Model: K 1600 GTL Exclusive - 1 ilan
    📌 Model: M 1000 R - 2 ilan
    📌 Model: M 1000 RR - 1 ilan
    📌 Model: R 1150 GS - 1 ilan
    📌 Model: R 1150 GS Adventure - 2 ilan
    📌 Model: R 1150 R - 11 ilan
    📌 Model: R 1150 RT - 1 ilan
    📌 Model: R 1200 CL - 1 ilan
    📌 Model: R 1200 GS - 12 ilan
    📌 Model: R 1200 GS Adventure - 5 ilan
    📌 Model: R 1200 RT - 4 ilan
    📌 Model: R 1250 GS - 2 ilan
    📌 Model: R 1250 GS Adventure - 15 ilan
    📌 Model: R 1250 RS - 1 ilan
    📌 Model: R 18 - 1 ilan
    📌 Model: R 80 GS - 1 ilan
    📌 Model: R Nine T Blue Planet - 1 ilan
    📌 Model: R Nine T Scrambler - 1 ilan
    📌 Model: S 1000 RR - 4 ilan
    📌 Model: S 1000 XR - 3 ilan
  🔹 Marka: Borelli Ledow (https://www.arabam.com/ikinci-el/motosiklet/borelli-ledow)
    📌 Model: CXM 250a - 2 ilan
  🔹 Marka: Brixton (https://www.arabam.com/ikinci-el/motosiklet/brixton)
    📌 Model: Crossfire 125 - 1 ilan
    📌 Model: Crossfire 125 XS - 1 ilan
    📌 Model: Felsberg 125 X - 1 ilan
    📌 Model: Felsberg 250 - 2 ilan
    📌 Model: Sunray 125 - 1 ilan
  🔹 Marka: BuMoto/Jinling (https://www.arabam.com/ikinci-el/motosiklet/bumoto-jinling)
    📌 Model: Eagle XR 250CC - 1 ilan
    📌 Model: Ventura F250CC - 1 ilan
  🔹 Marka: Can-Am (https://www.arabam.com/ikinci-el/motosiklet/can-am)
    📌 Model: Ryker - 6 ilan
    📌 Model: Spyder Roadster1 - 6 ilan
  🔹 Marka: Çelik Motor (https://www.arabam.com/ikinci-el/motosiklet/celik-motor)
    📌 Model: CK100-3 Sport - 2 ilan
    📌 Model: Crown 150 - 1 ilan
  🔹 Marka: CFmoto (https://www.arabam.com/ikinci-el/motosiklet/cfmoto)
    📌 Model: 150NK - 12 ilan
    📌 Model: 250CL-X - 20 ilan
    📌 Model: 250NK - 200 ilan
    📌 Model: 250SR - 226 ilan
    📌 Model: 400NK - 4 ilan
    📌 Model: 450CL-C - 3 ilan
    📌 Model: 450MT - 9 ilan
    📌 Model: 450NK - 19 ilan
    📌 Model: 450SR - 64 ilan
    📌 Model: 650 MT - 16 ilan
    📌 Model: 650 TK - 1 ilan
    📌 Model: 650NK - 11 ilan
    📌 Model: 700 CL-X Sport - 3 ilan
    📌 Model: 700 CLX Heritage - 6 ilan
    📌 Model: 700MT - 3 ilan
    📌 Model: 800 MT Sport - 1 ilan
    📌 Model: 800MT Touring - 1 ilan
    📌 Model: CF 150 - 2 ilan
  🔹 Marka: Cq (https://www.arabam.com/ikinci-el/motosiklet/cq)
    📌 Model: HS - 4 ilan
  🔹 Marka: CSN Motor (https://www.arabam.com/ikinci-el/motosiklet/csn-motor)
    📌 Model: Arrebol 125 - 2 ilan
    📌 Model: Pluton - 1 ilan
    📌 Model: Snake 125X - 2 ilan
  🔹 Marka: Daelim (https://www.arabam.com/ikinci-el/motosiklet/daelim)
    📌 Model: S3 Advance 250 - 4 ilan
  🔹 Marka: Dayun (https://www.arabam.com/ikinci-el/motosiklet/dayun)
    📌 Model: DY 125-36A - 1 ilan
  🔹 Marka: Derbi (https://www.arabam.com/ikinci-el/motosiklet/derbi)
    📌 Model: STX - 1 ilan
    📌 Model: Terra 125 - 15 ilan
  🔹 Marka: Diğer Markalar (https://www.arabam.com/ikinci-el/motosiklet/diger_-markalar)
  🔹 Marka: Dofern (https://www.arabam.com/ikinci-el/motosiklet/dofern)
    📌 Model: JDF 125ZD - 7 ilan
    📌 Model: JDF 250T - 3 ilan
  🔹 Marka: Dorado (https://www.arabam.com/ikinci-el/motosiklet/dorado)
    📌 Model: Akida Scooter 150 - 1 ilan
  🔹 Marka: Ducati (https://www.arabam.com/ikinci-el/motosiklet/ducati)
    📌 Model: 1098 - 1 ilan
    📌 Model: Diavel 1260 S - 1 ilan
    📌 Model: Diavel Dark - 2 ilan
    📌 Model: Diavel XDiavel Dark - 1 ilan
    📌 Model: Monster 696 - 1 ilan
    📌 Model: Monster 821 - 2 ilan
    📌 Model: Monster 937 - 3 ilan
    📌 Model: Multistrada 1200 - 1 ilan
    📌 Model: Multistrada 1200 Pikes Peak - 1 ilan
    📌 Model: Multistrada 1200 S - 2 ilan
    📌 Model: Multistrada 1260 Enduro - 1 ilan
    📌 Model: Multistrada 1260 Pikes Peak - 1 ilan
    📌 Model: Multistrada 1260 S - 1 ilan
    📌 Model: Multistrada 950 - 2 ilan
    📌 Model: Multistrada V2 S - 1 ilan
    📌 Model: Multistrada V4 Pikes Peak - 2 ilan
    📌 Model: Multistrada V4 S - 3 ilan
    📌 Model: Scrambler 1100 Sport Pro - 1 ilan
    📌 Model: Scrambler Classic - 1 ilan
    📌 Model: Scrambler Full Throttle - 4 ilan
    📌 Model: Scrambler Icon - 2 ilan
    📌 Model: Scrambler Urban Enduro - 1 ilan
    📌 Model: Sport - 2 ilan
    📌 Model: Streetfighter V4 S - 1 ilan
  🔹 Marka: Enbest (https://www.arabam.com/ikinci-el/motosiklet/enbest)
    📌 Model: A02 - 1 ilan
  🔹 Marka: Falcon (https://www.arabam.com/ikinci-el/motosiklet/falcon)
    📌 Model: Attack 100 - 22 ilan
    📌 Model: Breeze 125 - 1 ilan
    📌 Model: C-Max 155 - 4 ilan
    📌 Model: Comfort 180 - 5 ilan
    📌 Model: Cooper 125 EFI - 1 ilan
    📌 Model: Cooper 50 - 2 ilan
    📌 Model: Crazy 125 - 2 ilan
    📌 Model: Crown 150 - 2 ilan
    📌 Model: Desert 277 - 1 ilan
    📌 Model: Diğer Modeller - 3 ilan
    📌 Model: Dolphin 100 - 2 ilan
    📌 Model: Dolphin 100 EFI - 1 ilan
    📌 Model: Dolphin 125 EFI - 2 ilan
    📌 Model: Flash 100 - 1 ilan
    📌 Model: FR 177 - 2 ilan
    📌 Model: FR 250 - 3 ilan
    📌 Model: FR-177 - 4 ilan
    📌 Model: FR-250 - 1 ilan
    📌 Model: Freedom 250 - 3 ilan
    📌 Model: Guppi 110 - 3 ilan
    📌 Model: Magic 100 - 1 ilan
    📌 Model: Martini 125 - 4 ilan
    📌 Model: Martini 50 - 5 ilan
    📌 Model: Master 50 - 10 ilan
    📌 Model: Mexico 150 - 14 ilan
    📌 Model: Mocco 125 - 7 ilan
    📌 Model: Mocco 50 - 6 ilan
    📌 Model: N-288 - 3 ilan
    📌 Model: New Soft 50 - 1 ilan
    📌 Model: Nitro 50 - 4 ilan
    📌 Model: Retro 110 I - 1 ilan
    📌 Model: Salvador 188 - 1 ilan
    📌 Model: Shark 188 - 2 ilan
    📌 Model: SK 125 KMT - 2 ilan
    📌 Model: Soft 50 - 2 ilan
    📌 Model: Style 50 - 1 ilan
    📌 Model: T-Rex 188 - 5 ilan
    📌 Model: Techno 125 EFI - 2 ilan
    📌 Model: Techno 50 - 1 ilan
    📌 Model: Techno 50 EFI - 2 ilan
    📌 Model: Wonder 180 - 1 ilan
  🔹 Marka: Fantic (https://www.arabam.com/ikinci-el/motosiklet/fantic)
    📌 Model: Caballero Anniversary 500 - 2 ilan
    📌 Model: Caballero Rally 500 - 1 ilan
    📌 Model: Caballero Scrambler 500 - 1 ilan
    📌 Model: XEF Rally - 1 ilan
  🔹 Marka: Gaoming (https://www.arabam.com/ikinci-el/motosiklet/gaoming)
    📌 Model: 150 - 5 ilan
  🔹 Marka: Gilera (https://www.arabam.com/ikinci-el/motosiklet/gilera)
    📌 Model: Cross Bones - 1 ilan
    📌 Model: Nexus 300 - 1 ilan
    📌 Model: Nexus 500 - 1 ilan
    📌 Model: R 125 - 2 ilan
    📌 Model: Runner 180 - 1 ilan
  🔹 Marka: Haojue (https://www.arabam.com/ikinci-el/motosiklet/haojue)
    📌 Model: HJ 125-T-10 - 3 ilan
  🔹 Marka: Harley Davidson (https://www.arabam.com/ikinci-el/motosiklet/harley-davidson)
    📌 Model: Breakout 117 - 1 ilan
    📌 Model: Cvo Road Glide - 1 ilan
    📌 Model: Cvo Ultra Limited - 1 ilan
    📌 Model: Fat Boy FLSTFI - 2 ilan
    📌 Model: FLHX Street Glide - 1 ilan
    📌 Model: FLHXSE2 CVO Street Glide - 5 ilan
    📌 Model: Pan America RA1250 Special - 2 ilan
    📌 Model: Softail Deluxe FLSTNI - 1 ilan
    📌 Model: Softail Sport Glide - 1 ilan
    📌 Model: Softail Street Bob - 1 ilan
    📌 Model: Sportster Custom XL 1200C - 2 ilan
    📌 Model: Sportster Forty-Eight - 2 ilan
    📌 Model: Sportster Iron 883 - 1 ilan
    📌 Model: Touring Road Glide Special - 1 ilan
    📌 Model: Touring Road Glide Ultra - 3 ilan
    📌 Model: VRSC V-Road - 1 ilan
    📌 Model: VRSC V-Rod Muscle - 1 ilan
    📌 Model: VRSCDX Night Rod Special - 2 ilan
  🔹 Marka: Hero (https://www.arabam.com/ikinci-el/motosiklet/hero)
    📌 Model: Dash 110i - 19 ilan
    📌 Model: Dash 125 - 36 ilan
    📌 Model: Dash LX 110 - 1 ilan
    📌 Model: Dash VX 110 - 1 ilan
    📌 Model: Duet 110i - 7 ilan
    📌 Model: Duet LX 110 - 1 ilan
    📌 Model: Glamour - 1 ilan
    📌 Model: Hunk - 2 ilan
    📌 Model: Pleasure - 1 ilan
    📌 Model: Xpulse 200 - 33 ilan
    📌 Model: XPulse 200 4V Pro - 35 ilan
    📌 Model: XPulse 200T - 1 ilan
  🔹 Marka: Honda (https://www.arabam.com/ikinci-el/motosiklet/honda)
    📌 Model: Activa 100 - 7 ilan
    📌 Model: Activa 110 - 1 ilan
    📌 Model: Activa 125 - 82 ilan
    📌 Model: Activa S - 31 ilan
    📌 Model: ADV350 - 14 ilan
    📌 Model: Beat - 7 ilan
    📌 Model: C 90 - 1 ilan
    📌 Model: CB 125 - 1 ilan
    📌 Model: CB 125 Ace - 6 ilan
    📌 Model: CB 125 F - 12 ilan
    📌 Model: CB 125 R - 2 ilan
    📌 Model: CB 125E - 9 ilan
    📌 Model: CB 250 - 1 ilan
    📌 Model: CB 250 R - 16 ilan
    📌 Model: CB 500 - 1 ilan
    📌 Model: CB 650 F - 2 ilan
    📌 Model: CB 650 R - 4 ilan
    📌 Model: CB 750 Hornet - 7 ilan
    📌 Model: CB 900 Hornet - 2 ilan
    📌 Model: CBF 150 - 64 ilan
    📌 Model: CBF 250 - 2 ilan
    📌 Model: CBF 500 - 2 ilan
    📌 Model: CBF 600 - 1 ilan
    📌 Model: CBR 1000 RR - 11 ilan
    📌 Model: CBR 1000 RR SP - 1 ilan
    📌 Model: CBR 125 R - 18 ilan
    📌 Model: CBR 250 R - 23 ilan
    📌 Model: CBR 500 R - 10 ilan
    📌 Model: CBR 600 F - 4 ilan
    📌 Model: CBR 600 RR - 11 ilan
    📌 Model: CBR 650 F - 6 ilan
    📌 Model: CBR 650 R - 8 ilan
    📌 Model: CBR 929 RR - 1 ilan
    📌 Model: CG 125 - 3 ilan
    📌 Model: CHS 125 Fizy - 2 ilan
    📌 Model: CL 250 - 14 ilan
    📌 Model: CR 250 - 12 ilan
    📌 Model: CRF 1000 L Africa Twin - 1 ilan
    📌 Model: CRF 250 L - 12 ilan
    📌 Model: CRF 250 Rally - 7 ilan
    📌 Model: CRF 450 R - 1 ilan
    📌 Model: CRF1000L Africa Twin - 1 ilan
    📌 Model: CRF1000L Africa Twin DCT - 5 ilan
    📌 Model: CRF1100L Africa Twin - 1 ilan
    📌 Model: CRF1100L Africa Twin Adventure Sports - 1 ilan
    📌 Model: CTX 1300 - 1 ilan
    📌 Model: Diğer Modeller - 5 ilan
    📌 Model: Dio - 148 ilan
    📌 Model: Fizy 125 - 6 ilan
    📌 Model: Forza 250 (NSS250) - 77 ilan
    📌 Model: Forza 750 - 1 ilan
    📌 Model: Goldwing GL 1800 - 9 ilan
    📌 Model: Goldwing GL 1800 DCT - 6 ilan
    📌 Model: Innova 125 - 2 ilan
    📌 Model: JF 26 - 1 ilan
    📌 Model: Kinetic DX - 7 ilan
    📌 Model: Monkey 125 - 3 ilan
    📌 Model: MSX 125 - 2 ilan
    📌 Model: NC 700 DC Integra - 3 ilan
    📌 Model: NC 700 X - 4 ilan
    📌 Model: NC 750 S - 1 ilan
    📌 Model: NC 750 S DCT - 1 ilan
    📌 Model: NC 750 X - 9 ilan
    📌 Model: NC 750 X DCT - 11 ilan
    📌 Model: NC 750D Integra - 4 ilan
    📌 Model: NSS250 Forza - 18 ilan
    📌 Model: NSS300 Forza - 6 ilan
    📌 Model: NT 1100 - 1 ilan
    📌 Model: NT 1100 DCT - 2 ilan
    📌 Model: NX 250 - 3 ilan
    📌 Model: PCX 125 - 290 ilan
    📌 Model: PCX 150 - 13 ilan
    📌 Model: PS 150i - 4 ilan
    📌 Model: SH 125 - 7 ilan
    📌 Model: Spacy 110 - 22 ilan
    📌 Model: Spacy 110 Alfa - 7 ilan
    📌 Model: Spacy 110 Alpha - 18 ilan
    📌 Model: ST 1300 Pan European - 1 ilan
    📌 Model: Stream 125 - 1 ilan
    📌 Model: Super Cup C125 - 1 ilan
    📌 Model: SW T600 - 3 ilan
    📌 Model: Today 50 - 5 ilan
    📌 Model: VFR 1200 X CrossTourer - 1 ilan
    📌 Model: VFR 1200 X CrossTourer DCT - 1 ilan
    📌 Model: VFR 800 - 3 ilan
    📌 Model: VFR 800 X Crossrunner - 4 ilan
    📌 Model: VT 750 C Shadow - 3 ilan
    📌 Model: VT 750 Shadow ACE - 1 ilan
    📌 Model: X-ADV - 8 ilan
    📌 Model: X-ADV 350 - 14 ilan
    📌 Model: XL 1000V Varadero - 4 ilan
    📌 Model: XL 600 Transalp - 1 ilan
    📌 Model: XL 650 Transalp - 2 ilan
    📌 Model: XL 750 Transalp - 5 ilan
    📌 Model: XRV 750 Africa Twin - 1 ilan
  🔹 Marka: Husqvarna (https://www.arabam.com/ikinci-el/motosiklet/husqvarna)
    📌 Model: FE 350 - 1 ilan
    📌 Model: Svartpilen 250 - 10 ilan
    📌 Model: Svartpilen 401 - 2 ilan
    📌 Model: TE 510 - 1 ilan
    📌 Model: Vitpilen 701 - 1 ilan
  🔹 Marka: Hyosung (https://www.arabam.com/ikinci-el/motosiklet/hyosung)
    📌 Model: GD 250 R - 1 ilan
    📌 Model: GT 250 Naked - 1 ilan
    📌 Model: GV 250 - 8 ilan
    📌 Model: QH 250 - 4 ilan
    📌 Model: RX 125 - 3 ilan
    📌 Model: ST 7 - 1 ilan
  🔹 Marka: Hyundai (https://www.arabam.com/ikinci-el/motosiklet/hyundai)
    📌 Model: Mover 125 - 1 ilan
  🔹 Marka: Italjet (https://www.arabam.com/ikinci-el/motosiklet/italjet)
    📌 Model: Dragster - 6 ilan
  🔹 Marka: IZH (https://www.arabam.com/ikinci-el/motosiklet/izh)
    📌 Model: Jupiter 5 - 1 ilan
    📌 Model: Planet 5 - 1 ilan
  🔹 Marka: Jawa (https://www.arabam.com/ikinci-el/motosiklet/jawa)
    📌 Model: 250 Ceylan - 1 ilan
    📌 Model: 250 Classic - 2 ilan
    📌 Model: 300 CL - 3 ilan
    📌 Model: 350 Twin Sport - 1 ilan
    📌 Model: RVM 500 Adventure - 3 ilan
  🔹 Marka: JPN Motor (https://www.arabam.com/ikinci-el/motosiklet/jpn-motor)
    📌 Model: Bull 50 - 1 ilan
  🔹 Marka: Kamax (https://www.arabam.com/ikinci-el/motosiklet/kamax)
    📌 Model: Cubpro 125 - 2 ilan
  🔹 Marka: Kanuni (https://www.arabam.com/ikinci-el/motosiklet/kanuni)
    📌 Model: Breton 125 - 1 ilan
    📌 Model: Classic 125 - 1 ilan
    📌 Model: Cup 100 - 3 ilan
    📌 Model: Deer 152 - 1 ilan
    📌 Model: GT 250 - 3 ilan
    📌 Model: GT 250R - 1 ilan
    📌 Model: GV 170 - 1 ilan
    📌 Model: GV 650 - 3 ilan
    📌 Model: Mati 125 - 22 ilan
    📌 Model: Merlin S - 1 ilan
    📌 Model: Moped Turbo Sport - 1 ilan
    📌 Model: Nev 50 - 2 ilan
    📌 Model: Reha 250 - 9 ilan
    📌 Model: Resa 125 - 18 ilan
    📌 Model: Ronny S - 1 ilan
    📌 Model: Ruby 100 - 1 ilan
    📌 Model: S170T - 2 ilan
    📌 Model: Seha 125 - 19 ilan
    📌 Model: Seha 150 - 24 ilan
    📌 Model: Seha 250 - 9 ilan
    📌 Model: Seyhan 100c - 1 ilan
    📌 Model: Seyhan 125 - 2 ilan
    📌 Model: Seyhan 150 - 6 ilan
    📌 Model: Seyhan 251c - 1 ilan
    📌 Model: Tigrina 100 - 1 ilan
    📌 Model: Tigrina 50 - 1 ilan
    📌 Model: Trodon 50 - 1 ilan
    📌 Model: Trodon XS 125 - 4 ilan
    📌 Model: Visal 125 - 2 ilan
    📌 Model: Windy 125 - 3 ilan
    📌 Model: WindyS 150 LX - 2 ilan
  🔹 Marka: Karpaty (https://www.arabam.com/ikinci-el/motosiklet/karpaty)
    📌 Model: V 50 - 2 ilan
  🔹 Marka: Kawasaki (https://www.arabam.com/ikinci-el/motosiklet/kawasaki)
    📌 Model: Eliminator 500 - 3 ilan
    📌 Model: ER 5 - 1 ilan
    📌 Model: GTR 1400 - 1 ilan
    📌 Model: J 300 - 1 ilan
    📌 Model: KLE 650 Versys - 4 ilan
    📌 Model: KLR 650 - 1 ilan
    📌 Model: KLX 250 - 1 ilan
    📌 Model: Ninja 1000 SX - 2 ilan
    📌 Model: Ninja 400 - 1 ilan
    📌 Model: Ninja 500 - 2 ilan
    📌 Model: Ninja 500 SE - 1 ilan
    📌 Model: Ninja 650 - 6 ilan
    📌 Model: NİNJA H2-SX SE - 1 ilan
    📌 Model: Ninja ZX 636 - 1 ilan
    📌 Model: Ninja ZX 6R - 10 ilan
    📌 Model: Ninja ZX-10R - 6 ilan
    📌 Model: Ninja ZX-4R - 1 ilan
    📌 Model: Ninja ZX-4RR - 3 ilan
    📌 Model: Versys 1000 - 1 ilan
    📌 Model: Versys 650 - 5 ilan
    📌 Model: Versys X300 - 6 ilan
    📌 Model: VN 1600 - 1 ilan
    📌 Model: Vulcan S - 2 ilan
    📌 Model: Z 1000 - 1 ilan
    📌 Model: Z 1000 SX - 2 ilan
    📌 Model: Z 300 - 1 ilan
    📌 Model: Z 400 - 2 ilan
    📌 Model: Z 500 - 1 ilan
    📌 Model: Z 500 SE - 1 ilan
    📌 Model: Z 650 - 1 ilan
    📌 Model: Z 650 RS - 1 ilan
    📌 Model: Z 800 - 1 ilan
    📌 Model: Z 900 - 5 ilan
    📌 Model: ZZR 1400 ABS - 2 ilan
  🔹 Marka: Keeway (https://www.arabam.com/ikinci-el/motosiklet/keeway)
    📌 Model: Land Cruiser 250 - 1 ilan
    📌 Model: Super Light 150 - 1 ilan
  🔹 Marka: Kimmi (https://www.arabam.com/ikinci-el/motosiklet/kimmi)
    📌 Model: Apricity - 2 ilan
  🔹 Marka: Kinetic (https://www.arabam.com/ikinci-el/motosiklet/kinetic)
    📌 Model: Nova - 1 ilan
  🔹 Marka: Kove (https://www.arabam.com/ikinci-el/motosiklet/kove)
    📌 Model: 125 R - 1 ilan
  🔹 Marka: Kral Motor (https://www.arabam.com/ikinci-el/motosiklet/kral-motor)
    📌 Model: 50 CC - 1 ilan
    📌 Model: Arneb 150 - 3 ilan
    📌 Model: KR 100-7 - 1 ilan
    📌 Model: KR-13 - 1 ilan
    📌 Model: KR-150-G - 1 ilan
    📌 Model: KR-200 Titus 196 CC - 2 ilan
    📌 Model: KR-211 Rana 50 - 1 ilan
    📌 Model: KR-41 Epico - 1 ilan
    📌 Model: KR-44 Pion 50 - 1 ilan
    📌 Model: Rigil 125 - 1 ilan
    📌 Model: Spica 100 - 1 ilan
    📌 Model: Vega 125 - 1 ilan
  🔹 Marka: KTM (https://www.arabam.com/ikinci-el/motosiklet/ktm)
    📌 Model: 125 Duke - 6 ilan
    📌 Model: 125 RC - 2 ilan
    📌 Model: 125 SX - 1 ilan
    📌 Model: 1290 Super Adventure S - 3 ilan
    📌 Model: 1290 Super Duke R - 2 ilan
    📌 Model: 200 Duke - 2 ilan
    📌 Model: 200 Duke ABS - 3 ilan
    📌 Model: 250 Adventure - 17 ilan
    📌 Model: 250 Duke ABS - 19 ilan
    📌 Model: 250 EXC Six Days TPI - 1 ilan
    📌 Model: 250 EXC TPI - 2 ilan
    📌 Model: 250 EXC-F Six Days - 1 ilan
    📌 Model: 250 RC ABS - 1 ilan
    📌 Model: 350 EXC-F Six Days - 1 ilan
    📌 Model: 390 Adventure - 8 ilan
    📌 Model: 390 Adventure Spoke Wheel - 2 ilan
    📌 Model: 390 Duke - 11 ilan
    📌 Model: 390 RC - 4 ilan
    📌 Model: 400 SC - 6 ilan
    📌 Model: 450 EXC - 1 ilan
    📌 Model: 450 EXC-F Six Days - 1 ilan
    📌 Model: 790 Adventure - 1 ilan
    📌 Model: 790 Duke - 1 ilan
    📌 Model: 890 Adventure - 1 ilan
  🔹 Marka: Kuba (https://www.arabam.com/ikinci-el/motosiklet/kuba)
    📌 Model: Arome 125 Pro - 19 ilan
    📌 Model: Bannry 125 - 10 ilan
    📌 Model: Bevely 125 - 19 ilan
    📌 Model: Bevely 50 Pro - 3 ilan
    📌 Model: Black Cat - 1 ilan
    📌 Model: Blueberry - 11 ilan
    📌 Model: Blueberry 50 - 6 ilan
    📌 Model: Blueberry Pro - 1 ilan
    📌 Model: Bluebird - 80 ilan
    📌 Model: Brıllıant 125 - 18 ilan
    📌 Model: Brıllıant 125 Pro - 21 ilan
    📌 Model: Brıllıant 125 Pro-X - 12 ilan
    📌 Model: Brıllıant 50 - 5 ilan
    📌 Model: Brıllıant 50 Plus - 5 ilan
    📌 Model: Brıllıant 50 Pro - 15 ilan
    📌 Model: Cargo - 1 ilan
    📌 Model: CG 100 - 7 ilan
    📌 Model: CG 100/KM125-6 - 5 ilan
    📌 Model: CG 150 - 3 ilan
    📌 Model: CG 50 - 22 ilan
    📌 Model: CG 50 Pro New - 8 ilan
    📌 Model: CG 50 Pro Plus - 3 ilan
    📌 Model: CG 50 Pro Ultra - 10 ilan
    📌 Model: Chia 125 - 38 ilan
    📌 Model: Çita 100 - 2 ilan
    📌 Model: Çita 100 R - 6 ilan
    📌 Model: Çita 100R Gold - 7 ilan
    📌 Model: Çita 125 - 2 ilan
    📌 Model: Çita 150 R - 4 ilan
    📌 Model: Çita 150R Gold - 2 ilan
    📌 Model: Çita 170F - 1 ilan
    📌 Model: Çita 180R - 1 ilan
    📌 Model: Çita 180R Gold - 3 ilan
    📌 Model: Çita 50R Gold - 50 ilan
    📌 Model: CR 1 - 3 ilan
    📌 Model: Cristal 50 - 17 ilan
    📌 Model: Diğer Modeller - 23 ilan
    📌 Model: Dragon 50 - 3 ilan
    📌 Model: Easy Pro 50 - 20 ilan
    📌 Model: Ege 100 - 3 ilan
    📌 Model: Ege 50 - 27 ilan
    📌 Model: Ege 50-100 - 5 ilan
    📌 Model: Filinta 100 - 1 ilan
    📌 Model: Golf 100 - 3 ilan
    📌 Model: Grace 50 - 1 ilan
    📌 Model: GS 125 - 3 ilan
    📌 Model: K250 - 4 ilan
    📌 Model: Kargo 180 - 8 ilan
    📌 Model: KB150-25 - 1 ilan
    📌 Model: KEE 100 - 2 ilan
    📌 Model: KM125-6 - 2 ilan
    📌 Model: Matrix 125 - 2 ilan
    📌 Model: Matrix 150 - 1 ilan
    📌 Model: NewCity 125 - 18 ilan
    📌 Model: Newton 50 - 3 ilan
    📌 Model: Nirvana 150 - 4 ilan
    📌 Model: Novax 200 - 29 ilan
    📌 Model: Pesaro 125 X - 20 ilan
    📌 Model: Pesaro 50 X - 9 ilan
    📌 Model: Pikap 200 Max - 4 ilan
    📌 Model: Platinum - 5 ilan
    📌 Model: Prince 50 - 1 ilan
    📌 Model: Race 125 - 21 ilan
    📌 Model: Rainbow - 4 ilan
    📌 Model: Razore 100 - 3 ilan
    📌 Model: Reiz 100 - 1 ilan
    📌 Model: Reiz 50 - 1 ilan
    📌 Model: Rocca 100 - 3 ilan
    📌 Model: Rosewood - 11 ilan
    📌 Model: Rubano 150 - 4 ilan
    📌 Model: RX9 50 - 4 ilan
    📌 Model: SJ100-16D - 1 ilan
    📌 Model: SJ50 Pro - 6 ilan
    📌 Model: Space 50 - 12 ilan
    📌 Model: Space 50 Max - 2 ilan
    📌 Model: Space 50 Pro - 48 ilan
    📌 Model: Strike 150 - 1 ilan
    📌 Model: Superlight 125 - 36 ilan
    📌 Model: Superlight 200 - 7 ilan
    📌 Model: Terra 125 - 2 ilan
    📌 Model: TK03 - 64 ilan
    📌 Model: Trendy 50 - 2 ilan
    📌 Model: Trendy XC 50 - 7 ilan
    📌 Model: Valentino 50 - 3 ilan
    📌 Model: VN50 Pro - 38 ilan
    📌 Model: X-Boss - 27 ilan
    📌 Model: XR 125 - 2 ilan
    📌 Model: XY100-E - 1 ilan
    📌 Model: Zenzero - 3 ilan
    📌 Model: Zenzero 125 - 5 ilan
  🔹 Marka: Kymco (https://www.arabam.com/ikinci-el/motosiklet/kymco)
    📌 Model: Agility 125 - 7 ilan
    📌 Model: Agility 150 - 1 ilan
    📌 Model: Agility 16+ 150 - 3 ilan
    📌 Model: Agility Carry 125i - 1 ilan
    📌 Model: Agility Carry 50i 4T - 1 ilan
    📌 Model: Agility City 125 - 3 ilan
    📌 Model: Agility Delivery 125i - 1 ilan
    📌 Model: Agility S 125 - 3 ilan
    📌 Model: Ak 550 - 3 ilan
    📌 Model: Aktiv 125 - 1 ilan
    📌 Model: CV3 - 1 ilan
    📌 Model: Diğer Modeller - 3 ilan
    📌 Model: Dink 200i - 2 ilan
    📌 Model: Dink R 150 - 7 ilan
    📌 Model: Downtown 250i - 10 ilan
    📌 Model: Downtown 300i - 1 ilan
    📌 Model: Downtown 350i ABS - 2 ilan
    📌 Model: Downtown GT 350 - 2 ilan
    📌 Model: DTX 250 - 5 ilan
    📌 Model: DTX 360 - 12 ilan
    📌 Model: KRV 200 - 5 ilan
    📌 Model: Like 125 - 7 ilan
    📌 Model: Like 50 - 3 ilan
    📌 Model: People S 125i - 1 ilan
    📌 Model: People S 150i - 1 ilan
    📌 Model: People S 200 - 3 ilan
    📌 Model: People S 200i - 4 ilan
    📌 Model: Sky Town 125 - 3 ilan
    📌 Model: Super 8 125 - 2 ilan
    📌 Model: Xciting 250i - 9 ilan
    📌 Model: Xciting 500 - 1 ilan
    📌 Model: Xciting 500i R - 1 ilan
    📌 Model: Xciting S 400 - 1 ilan
    📌 Model: Xciting VS 400 - 5 ilan
    📌 Model: Xciting VS 400 Limited Edition - 2 ilan
    📌 Model: Xtown 250 CT - 9 ilan
    📌 Model: Xtown 250i - 1 ilan
  🔹 Marka: Lambretta (https://www.arabam.com/ikinci-el/motosiklet/lambretta)
    📌 Model: G350 - 1 ilan
    📌 Model: V125 Special - 6 ilan
    📌 Model: V200 Special - 4 ilan
    📌 Model: X125 - 1 ilan
    📌 Model: X250 - 1 ilan
  🔹 Marka: Leksas (https://www.arabam.com/ikinci-el/motosiklet/leksas)
    📌 Model: Belo - 1 ilan
  🔹 Marka: Lifan (https://www.arabam.com/ikinci-el/motosiklet/lifan)
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Discovery 150 - 2 ilan
    📌 Model: Dragon 125 - 1 ilan
    📌 Model: EM150L - 2 ilan
    📌 Model: Glint 100 - 1 ilan
    📌 Model: LF100-A - 1 ilan
    📌 Model: LF150-10B - 1 ilan
    📌 Model: LF200GY-2 - 1 ilan
    📌 Model: Lion 100 - 1 ilan
    📌 Model: Tay 100 - 3 ilan
  🔹 Marka: Malaguti (https://www.arabam.com/ikinci-el/motosiklet/malaguti)
    📌 Model: Dune X 125 Black Edition - 1 ilan
  🔹 Marka: Maranta (https://www.arabam.com/ikinci-el/motosiklet/maranta)
    📌 Model: Boss 125 - 4 ilan
  🔹 Marka: Megelli (https://www.arabam.com/ikinci-el/motosiklet/megelli)
    📌 Model: 250 R - 1 ilan
  🔹 Marka: Meka Motor (https://www.arabam.com/ikinci-el/motosiklet/meka-motor)
    📌 Model: Alp 125 - 1 ilan
  🔹 Marka: Minsk (https://www.arabam.com/ikinci-el/motosiklet/minsk)
    📌 Model: 125 E - 1 ilan
  🔹 Marka: Mobylette (https://www.arabam.com/ikinci-el/motosiklet/mobylette)
    📌 Model: 51 VK - 1 ilan
    📌 Model: Super 52 - 2 ilan
  🔹 Marka: Modenas (https://www.arabam.com/ikinci-el/motosiklet/modenas)
    📌 Model: Modenas - 2 ilan
  🔹 Marka: Mondial (https://www.arabam.com/ikinci-el/motosiklet/mondial)
    📌 Model: 100 Ardour - 3 ilan
    📌 Model: 100 Masti X - 1 ilan
    📌 Model: 100 MG Prince - 1 ilan
    📌 Model: 100 MG Superboy - 6 ilan
    📌 Model: 100 NT Turkuaz - 2 ilan
    📌 Model: 100 SFC Exclusive - 1 ilan
    📌 Model: 100 SFC Snappy X - 13 ilan
    📌 Model: 100 SFC Snappy Xi - 8 ilan
    📌 Model: 100 SFS Sport - 1 ilan
    📌 Model: 100 Superboy i - 5 ilan
    📌 Model: 100 UAG - 19 ilan
    📌 Model: 100 UKH - 2 ilan
    📌 Model: 110 FT - 7 ilan
    📌 Model: 125 AGK - 1 ilan
    📌 Model: 125 Drift L - 41 ilan
    📌 Model: 125 Drift L CBS - 164 ilan
    📌 Model: 125 Elegante - 14 ilan
    📌 Model: 125 Exon - 15 ilan
    📌 Model: 125 KT - 5 ilan
    📌 Model: 125 Lavinia - 18 ilan
    📌 Model: 125 Lavinia Pro - 11 ilan
    📌 Model: 125 Mash - 4 ilan
    📌 Model: 125 MG Classic - 4 ilan
    📌 Model: 125 MG Deluxe - 1 ilan
    📌 Model: 125 MH Drift - 20 ilan
    📌 Model: 125 MT - 2 ilan
    📌 Model: 125 MX Grumble - 1 ilan
    📌 Model: 125 NT Turkuaz - 1 ilan
    📌 Model: 125 Prostreet - 1 ilan
    📌 Model: 125 Ressivo - 8 ilan
    📌 Model: 125 Road Boy - 13 ilan
    📌 Model: 125 Skuty - 16 ilan
    📌 Model: 125 Strada - 68 ilan
    📌 Model: 125 Superboy i - 16 ilan
    📌 Model: 125 UAG - 2 ilan
    📌 Model: 125 URT - 1 ilan
    📌 Model: 125 Vulture i - 20 ilan
    📌 Model: 125 ZN - 2 ilan
    📌 Model: 125 ZNU - 6 ilan
    📌 Model: 125 ZNU i - 1 ilan
    📌 Model: 150 Argent - 1 ilan
    📌 Model: 150 HS - 1 ilan
    📌 Model: 150 KN - 2 ilan
    📌 Model: 150 Mash - 7 ilan
    📌 Model: 150 MCX Roadracer - 2 ilan
    📌 Model: 150 MG Superboy X - 2 ilan
    📌 Model: 150 MH Drift - 5 ilan
    📌 Model: 150 MR - 1 ilan
    📌 Model: 150 MR Vulture - 2 ilan
    📌 Model: 150 RF - 1 ilan
    📌 Model: 150 RR - 6 ilan
    📌 Model: 150 Z-ONE - 2 ilan
    📌 Model: 151 RS - 1 ilan
    📌 Model: 180 Z-ONE S - 2 ilan
    📌 Model: 250 Buffalo - 1 ilan
    📌 Model: 250 Jet Max - 1 ilan
    📌 Model: 250 MCT - 3 ilan
    📌 Model: 250 Nevada - 8 ilan
    📌 Model: 250 Ressivo - 22 ilan
    📌 Model: 50 Exon - 7 ilan
    📌 Model: 50 HC - 2 ilan
    📌 Model: 50 Loyal - 14 ilan
    📌 Model: 50 Revival - 16 ilan
    📌 Model: 50 SFC - 65 ilan
    📌 Model: 50 TAB - 3 ilan
    📌 Model: 50 TT - 2 ilan
    📌 Model: 50 Turismo - 58 ilan
    📌 Model: 50 UAG - 24 ilan
    📌 Model: 50 Wing - 96 ilan
    📌 Model: 50 ZNU - 6 ilan
    📌 Model: 50 ZNU ec - 18 ilan
    📌 Model: Air Time - 7 ilan
    📌 Model: Airtime 50 - 5 ilan
    📌 Model: Diğer Modeller - 7 ilan
    📌 Model: Fury 110i - 18 ilan
    📌 Model: KD 125 F CBS - 2 ilan
    📌 Model: Resivo 250 - 2 ilan
    📌 Model: Ritmica 100 - 5 ilan
    📌 Model: Ritmica 110 - 2 ilan
    📌 Model: RX1i Evo - 5 ilan
    📌 Model: RX3İ Evo - 6 ilan
    📌 Model: Rx3i Evo-ABS - 8 ilan
    📌 Model: Strada 125 - 2 ilan
    📌 Model: Virago 50 - 25 ilan
    📌 Model: Wing - 1 ilan
    📌 Model: X-Treme Enduro - 3 ilan
    📌 Model: X-Treme Max - 22 ilan
    📌 Model: X-Treme Max 150 - 2 ilan
    📌 Model: X-Treme Max 200 - 9 ilan
    📌 Model: X-Treme Max 200i - 36 ilan
    📌 Model: X-Treme Moto Cross - 1 ilan
  🔹 Marka: Moto Guzzi (https://www.arabam.com/ikinci-el/motosiklet/moto-guzzi)
    📌 Model: Stelvio - 1 ilan
    📌 Model: V100 Mandello S - 1 ilan
    📌 Model: V7 III - 2 ilan
    📌 Model: V7 Special - 1 ilan
    📌 Model: V7 Stone - 2 ilan
    📌 Model: V85 TT - 2 ilan
  🔹 Marka: Moto Morini (https://www.arabam.com/ikinci-el/motosiklet/moto-morini)
    📌 Model: Seiemmezzo - 1 ilan
    📌 Model: X-Cape - 1 ilan
  🔹 Marka: Motolux (https://www.arabam.com/ikinci-el/motosiklet/motolux)
    📌 Model: Africa King - 3 ilan
    📌 Model: Africa Wolf - 5 ilan
    📌 Model: Americano 125 - 1 ilan
    📌 Model: Cappadocia 125 - 5 ilan
    📌 Model: CEO 110 - 17 ilan
    📌 Model: CEO 125 - 5 ilan
    📌 Model: Diğer Modeller - 4 ilan
    📌 Model: Drift 200 - 2 ilan
    📌 Model: Efsane 50 - 2 ilan
    📌 Model: Macchiato 125 - 9 ilan
    📌 Model: MCX 125 - 3 ilan
    📌 Model: MTX 125 - 8 ilan
    📌 Model: MW46 - 3 ilan
    📌 Model: MZ46 A - 2 ilan
    📌 Model: MZ46 T - 1 ilan
    📌 Model: Nirvana 50 - 2 ilan
    📌 Model: Nirvana Pro - 6 ilan
    📌 Model: Rossi 125 - 7 ilan
    📌 Model: Rossi 50 - 2 ilan
    📌 Model: Rossi RS - 6 ilan
    📌 Model: Rossi RS 125 - 2 ilan
    📌 Model: Rossi RS 50 - 7 ilan
    📌 Model: Vegas 125 - 2 ilan
    📌 Model: Vintage 50 - 1 ilan
    📌 Model: W 46 - 4 ilan
    📌 Model: WOW 150 - 6 ilan
  🔹 Marka: Motoran (https://www.arabam.com/ikinci-el/motosiklet/motoran)
    📌 Model: Allegro - 3 ilan
    📌 Model: Elite - 1 ilan
    📌 Model: Etna - 1 ilan
    📌 Model: Fabio 150 - 1 ilan
    📌 Model: Force 150 - 1 ilan
    📌 Model: Maximus 150 - 2 ilan
    📌 Model: MTR 100 - 3 ilan
    📌 Model: Torro LX 100 - 2 ilan
    📌 Model: Vento 100 - 1 ilan
  🔹 Marka: Motosan (https://www.arabam.com/ikinci-el/motosiklet/motosan)
    📌 Model: TR 125R - 1 ilan
  🔹 Marka: Musatti (https://www.arabam.com/ikinci-el/motosiklet/musatti)
    📌 Model: CG 50 Max - 1 ilan
    📌 Model: Dark Pow - 8 ilan
    📌 Model: Glamaro Max 125 - 6 ilan
    📌 Model: Kai-Zen - 8 ilan
    📌 Model: Lemuzin 125 - 1 ilan
    📌 Model: Milanio 250 - 6 ilan
    📌 Model: Milano S400 - 5 ilan
    📌 Model: Siena 110 - 1 ilan
  🔹 Marka: Mutt (https://www.arabam.com/ikinci-el/motosiklet/mutt)
    📌 Model: FSR 125 - 1 ilan
    📌 Model: Hilts 125 - 2 ilan
    📌 Model: Hilts 250 - 1 ilan
    📌 Model: Razorback 125 - 1 ilan
    📌 Model: Razorback 250 - 1 ilan
    📌 Model: RS13 250 - 1 ilan
  🔹 Marka: MV Agusta (https://www.arabam.com/ikinci-el/motosiklet/mv-agusta)
    📌 Model: Brutale 1000 RR - 2 ilan
    📌 Model: Brutale 800 - 1 ilan
    📌 Model: Brutale 800 RR - 1 ilan
    📌 Model: Dragster 800 RR SCS - 3 ilan
    📌 Model: F3 800 - 1 ilan
  🔹 Marka: Nanok (https://www.arabam.com/ikinci-el/motosiklet/nanok)
    📌 Model: Emira 125 - 2 ilan
    📌 Model: Emira 50 - 1 ilan
    📌 Model: Eva 125 - 1 ilan
    📌 Model: Lia 50 - 1 ilan
    📌 Model: S Line 50 - 1 ilan
  🔹 Marka: NSU (https://www.arabam.com/ikinci-el/motosiklet/nsu)
    📌 Model: Max - 5 ilan
  🔹 Marka: Peugeot (https://www.arabam.com/ikinci-el/motosiklet/peugeot)
    📌 Model: Diğer Modeller - 2 ilan
    📌 Model: Django 125 - 17 ilan
    📌 Model: Django 150 - 5 ilan
    📌 Model: Kisbee 50 - 4 ilan
    📌 Model: LXR 200i - 1 ilan
    📌 Model: Metropolis 400 - 6 ilan
    📌 Model: PM-01 125 - 4 ilan
    📌 Model: Pulsion - 1 ilan
    📌 Model: Pulsion 125 - 10 ilan
    📌 Model: Satelis 250 - 2 ilan
    📌 Model: SpeedFight 2 - 1 ilan
    📌 Model: Speedfight 4 - 2 ilan
    📌 Model: Trekker 100 - 1 ilan
    📌 Model: Tweet 125 - 2 ilan
    📌 Model: Tweet 200 - 3 ilan
    📌 Model: Vivacity 125 - 1 ilan
    📌 Model: XP 400 - 16 ilan
    📌 Model: XP 400 Allure - 1 ilan
  🔹 Marka: PGO (https://www.arabam.com/ikinci-el/motosiklet/pgo)
    📌 Model: Diğer Modeller - 1 ilan
  🔹 Marka: Piaggio (https://www.arabam.com/ikinci-el/motosiklet/piaggio)
    📌 Model: Beverly 400 - 7 ilan
    📌 Model: Beverly 500 - 1 ilan
    📌 Model: Beverly S 400 - 5 ilan
    📌 Model: Beverly Sport Touring 350 i.e - 1 ilan
    📌 Model: Carnaby 200 - 1 ilan
    📌 Model: Diğer Modeller - 3 ilan
    📌 Model: FLY 150 - 1 ilan
    📌 Model: Liberty 150 - 2 ilan
    📌 Model: Medley 150 - 7 ilan
    📌 Model: Medley S 150 - 2 ilan
    📌 Model: MP3 300 - 1 ilan
    📌 Model: MP3 500 - 1 ilan
    📌 Model: NRG Power 50 - 1 ilan
    📌 Model: Skipper 150 - 1 ilan
    📌 Model: X EVO 250 - 1 ilan
    📌 Model: X10 350 - 1 ilan
    📌 Model: X8 250 Premium - 1 ilan
    📌 Model: X9 250 - 3 ilan
    📌 Model: X9 500 - 3 ilan
  🔹 Marka: Planet (https://www.arabam.com/ikinci-el/motosiklet/planet)
    📌 Model: Planet5 - 1 ilan
  🔹 Marka: Presto (https://www.arabam.com/ikinci-el/motosiklet/presto)
    📌 Model: PR 150T - 1 ilan
  🔹 Marka: QJ (https://www.arabam.com/ikinci-el/motosiklet/qj)
    📌 Model: ATR125 - 1 ilan
    📌 Model: Fort 350 - 4 ilan
    📌 Model: LTM 125 - 13 ilan
    📌 Model: SRK125 R - 12 ilan
    📌 Model: SRK125 S - 5 ilan
    📌 Model: SRK400 RR - 1 ilan
    📌 Model: SRT800 - 2 ilan
    📌 Model: SRT800 X - 4 ilan
    📌 Model: SRV550 - 1 ilan
    📌 Model: SVT650X - 5 ilan
    📌 Model: VPS125 - 11 ilan
  🔹 Marka: Quadro (https://www.arabam.com/ikinci-el/motosiklet/quadro)
    📌 Model: S - 21 ilan
  🔹 Marka: Ramzey (https://www.arabam.com/ikinci-el/motosiklet/ramzey)
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Kalipso 100 - 1 ilan
    📌 Model: RMZ 100-C - 1 ilan
  🔹 Marka: Regal Raptor (https://www.arabam.com/ikinci-el/motosiklet/regal-raptor)
    📌 Model: Classic 125 - 1 ilan
    📌 Model: DADDYW DD250E-9 - 1 ilan
    📌 Model: Daytona 125 - 1 ilan
    📌 Model: Daytona 250S - 2 ilan
    📌 Model: Daytona 250V - 7 ilan
    📌 Model: DD 125E - 1 ilan
    📌 Model: DD 150E-2 - 3 ilan
    📌 Model: DD 150E-2F - 5 ilan
    📌 Model: DD 250E-6C - 2 ilan
    📌 Model: DD 250E-9 - 1 ilan
    📌 Model: DD 250E-9B - 1 ilan
    📌 Model: DD 250E9-B - 1 ilan
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Nac 250 - 1 ilan
    📌 Model: Pilder 125 - 10 ilan
    📌 Model: Pilder 250 - 13 ilan
    📌 Model: Shark 250 - 1 ilan
    📌 Model: Spyder 250 - 1 ilan
    📌 Model: XSUV 125 - 4 ilan
    📌 Model: XSUV 250 - 4 ilan
  🔹 Marka: Revolt (https://www.arabam.com/ikinci-el/motosiklet/revolt)
  🔹 Marka: RKN (https://www.arabam.com/ikinci-el/motosiklet/rkn)
    📌 Model: 530 ADV - 9 ilan
  🔹 Marka: RKS (https://www.arabam.com/ikinci-el/motosiklet/rks)
    📌 Model: 125-S - 13 ilan
    📌 Model: 125N - 4 ilan
    📌 Model: 125R - 41 ilan
    📌 Model: A 250 - 23 ilan
    📌 Model: Arome 125 - 47 ilan
    📌 Model: Azure 50 - 8 ilan
    📌 Model: Azure 50 Pro - 42 ilan
    📌 Model: Bitter 125 - 16 ilan
    📌 Model: Bitter 50 - 8 ilan
    📌 Model: Bitter 50 Pro - 2 ilan
    📌 Model: Blackster 250i - 2 ilan
    📌 Model: Blackwolf 250 - 17 ilan
    📌 Model: Blade 250 - 12 ilan
    📌 Model: Blade 250 Pro - 8 ilan
    📌 Model: Blade 350 - 15 ilan
    📌 Model: Blade 350 Pro - 1 ilan
    📌 Model: Blazer 50 - 4 ilan
    📌 Model: Blazer 50 XR - 14 ilan
    📌 Model: Blazer 50 XR Max - 1 ilan
    📌 Model: Bolero 50 - 4 ilan
    📌 Model: Cruiser 250 - 1 ilan
    📌 Model: Dark Blue 125 - 6 ilan
    📌 Model: Dark Blue 50 - 1 ilan
    📌 Model: DES 125 - 25 ilan
    📌 Model: Diğer Modeller - 7 ilan
    📌 Model: Easy Pro 50 - 16 ilan
    📌 Model: Fort 250 - 13 ilan
    📌 Model: Freccia 125 - 9 ilan
    📌 Model: Freccia 150 - 85 ilan
    📌 Model: Galaxy Gold 125 - 1 ilan
    📌 Model: Grace 202 - 23 ilan
    📌 Model: Grace 202 Pro - 34 ilan
    📌 Model: Jaguar 100 - 6 ilan
    📌 Model: K-Light 202 - 12 ilan
    📌 Model: K-light 250 - 1 ilan
    📌 Model: LTR 125 - 25 ilan
    📌 Model: M250 - 14 ilan
    📌 Model: M502N - 19 ilan
    📌 Model: Neon 125 - 18 ilan
    📌 Model: Newlight - 8 ilan
    📌 Model: Newlight 125 Pro - 145 ilan
    📌 Model: Next 50 - 1 ilan
    📌 Model: NR200 - 20 ilan
    📌 Model: Outlook 150 - 1 ilan
    📌 Model: Premium 125 - 3 ilan
    📌 Model: PRIDE 125 - 21 ilan
    📌 Model: Private 125 - 5 ilan
    📌 Model: R250 - 62 ilan
    📌 Model: Reale 125 - 40 ilan
    📌 Model: Reale 125 X - 7 ilan
    📌 Model: RK 125-S - 10 ilan
    📌 Model: RK125-R - 18 ilan
    📌 Model: RN 180 - 7 ilan
    📌 Model: RNX Plus - 1 ilan
    📌 Model: Rocca 100 Max - 1 ilan
    📌 Model: Rodos 100 - 2 ilan
    📌 Model: Rodos 50 - 10 ilan
    📌 Model: Rosewood 50 - 1 ilan
    📌 Model: RS 400 - 4 ilan
    📌 Model: RT 250 - 9 ilan
    📌 Model: RZ 125 - 5 ilan
    📌 Model: RZ 125S - 5 ilan
    📌 Model: RZ 150 - 11 ilan
    📌 Model: RZ 150 X - 2 ilan
    📌 Model: RZ 250 S - 35 ilan
    📌 Model: SC 150RE - 12 ilan
    📌 Model: Siesta - 2 ilan
    📌 Model: Siesta 50 - 1 ilan
    📌 Model: Sniper 50 - 9 ilan
    📌 Model: Sniper 50 Pro - 6 ilan
    📌 Model: Sniper 50 Pro X - 15 ilan
    📌 Model: Spontini 110 - 28 ilan
    📌 Model: Spontini 110/125 - 12 ilan
    📌 Model: Spontini 125 - 9 ilan
    📌 Model: SRK 125 - 3 ilan
    📌 Model: SRK 250 RR - 13 ilan
    📌 Model: SRK 250 RS - 4 ilan
    📌 Model: SRK125-R - 29 ilan
    📌 Model: SRK250 - 35 ilan
    📌 Model: SRK400 RR - 2 ilan
    📌 Model: SRK550 - 4 ilan
    📌 Model: SRK550 RS - 11 ilan
    📌 Model: SRT800SX - 4 ilan
    📌 Model: SRV125 - 14 ilan
    📌 Model: SRV250 VS - 6 ilan
    📌 Model: SRV700 - 6 ilan
    📌 Model: Stream 50 - 1 ilan
    📌 Model: Titanic 150 - 3 ilan
    📌 Model: Titanic 150-R - 1 ilan
    📌 Model: Titanic 150-S - 6 ilan
    📌 Model: Titanic 200 - 1 ilan
    📌 Model: Titanium 200 - 5 ilan
    📌 Model: Titanium 220 - 1 ilan
    📌 Model: TNT 125 Pro - 12 ilan
    📌 Model: TNT202 - 23 ilan
    📌 Model: TRV 242 - 2 ilan
    📌 Model: Veloce 150 - 18 ilan
    📌 Model: Viesta 249 - 4 ilan
    📌 Model: Vıeste 249 - 8 ilan
    📌 Model: VPS 125 - 1 ilan
    📌 Model: VPS 125 PRO - 11 ilan
    📌 Model: VRS 125 - 29 ilan
    📌 Model: Wildcat 125 - 26 ilan
    📌 Model: Winner 200 - 3 ilan
    📌 Model: X Power 50 - 1 ilan
    📌 Model: XVR250 - 8 ilan
  🔹 Marka: RMG Moto Gusto (https://www.arabam.com/ikinci-el/motosiklet/rmg-moto-gusto)
    📌 Model: Aston 125 - 4 ilan
    📌 Model: Clasico - 3 ilan
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Fantasy 125 Pro - 2 ilan
    📌 Model: Fortuna - 1 ilan
    📌 Model: Panzer 125 - 2 ilan
    📌 Model: Panzer Cross 125 - 9 ilan
    📌 Model: Prego 125 - 3 ilan
    📌 Model: Rapid 50 - 3 ilan
    📌 Model: Santa 125 - 2 ilan
    📌 Model: Spark 50 - 1 ilan
    📌 Model: Spyder 100 - 1 ilan
    📌 Model: Velocity 50 - 1 ilan
    📌 Model: Venice - 1 ilan
    📌 Model: Verona 50 - 1 ilan
  🔹 Marka: Royal Alloy (https://www.arabam.com/ikinci-el/motosiklet/royal-alloy)
    📌 Model: GP 300 - 1 ilan
    📌 Model: GT 125 - 1 ilan
    📌 Model: Tigara Grande 300 - 1 ilan
  🔹 Marka: Royal Enfield (https://www.arabam.com/ikinci-el/motosiklet/royal-enfield)
    📌 Model: Classic 350 - 1 ilan
    📌 Model: Classic 500 - 1 ilan
    📌 Model: Hunter 350 - 2 ilan
  🔹 Marka: Rutec (https://www.arabam.com/ikinci-el/motosiklet/rutec)
    📌 Model: Badi 125 - 1 ilan
    📌 Model: Cargo 125 - 2 ilan
    📌 Model: Grace 50 - 16 ilan
    📌 Model: Lucca 125 - 5 ilan
    📌 Model: R9 125 - 5 ilan
  🔹 Marka: Salcano (https://www.arabam.com/ikinci-el/motosiklet/salcano)
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Rockstar 125 - 1 ilan
    📌 Model: SM 150-T10 - 1 ilan
    📌 Model: Spider - 1 ilan
    📌 Model: Wind 150 - 1 ilan
    📌 Model: Wings 125 - 2 ilan
  🔹 Marka: Scorpa (https://www.arabam.com/ikinci-el/motosiklet/scorpa)
    📌 Model: T-Ride 250 - 4 ilan
  🔹 Marka: SFM (https://www.arabam.com/ikinci-el/motosiklet/sfm)
    📌 Model: Bundera 5 - 2 ilan
    📌 Model: Konung 110 - 2 ilan
    📌 Model: Mayro - 5 ilan
    📌 Model: Pyxeria 150 - 2 ilan
    📌 Model: Razzi 50 - 5 ilan
    📌 Model: Redof 125 - 1 ilan
    📌 Model: Ventin 50 - 2 ilan
  🔹 Marka: Shinari (https://www.arabam.com/ikinci-el/motosiklet/shinari)
    📌 Model: Taipar 50 CC - 1 ilan
  🔹 Marka: Ski-doo (https://www.arabam.com/ikinci-el/motosiklet/ski-doo)
    📌 Model: Grand Touring 550F - 1 ilan
  🔹 Marka: Skyjet (https://www.arabam.com/ikinci-el/motosiklet/skyjet)
    📌 Model: Diğer Modeller - 10 ilan
    📌 Model: Rivero 125 - 3 ilan
  🔹 Marka: Skyteam (https://www.arabam.com/ikinci-el/motosiklet/skyteam)
    📌 Model: Skymax 125 - 1 ilan
    📌 Model: T-Rex 125 - 3 ilan
    📌 Model: Tracker 125 - 5 ilan
  🔹 Marka: Spada (https://www.arabam.com/ikinci-el/motosiklet/spada)
    📌 Model: Xfire 200 EFI - 1 ilan
  🔹 Marka: Stmax (https://www.arabam.com/ikinci-el/motosiklet/stmax)
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: Lindy 125 - 2 ilan
    📌 Model: Milan 50 - 2 ilan
    📌 Model: Nett 50 - 2 ilan
    📌 Model: Tempo 50 - 1 ilan
  🔹 Marka: Suzuki (https://www.arabam.com/ikinci-el/motosiklet/suzuki)
    📌 Model: Address - 3 ilan
    📌 Model: Address 110 - 2 ilan
    📌 Model: AN 125 HK - 1 ilan
    📌 Model: Avenis 125 - 8 ilan
    📌 Model: Best 110 - 1 ilan
    📌 Model: Burgman AN 400 - 6 ilan
    📌 Model: Burgman AN 650 ABS - 2 ilan
    📌 Model: Burgman Street 125EX - 4 ilan
    📌 Model: DL 650 XT - 1 ilan
    📌 Model: GSF 600 Bandit S - 1 ilan
    📌 Model: GSF 650 Bandit S - 1 ilan
    📌 Model: GSR 600 - 2 ilan
    📌 Model: GSR 750 - 1 ilan
    📌 Model: GSX 1250 FA - 2 ilan
    📌 Model: GSX 600 F - 1 ilan
    📌 Model: GSX 750 F - 1 ilan
    📌 Model: GSX 8S - 1 ilan
    📌 Model: GSX-R 1000 - 2 ilan
    📌 Model: GSX-R 1300 Hayabusa - 8 ilan
    📌 Model: GSX-R 250 - 2 ilan
    📌 Model: GSX-R 600 Srad - 1 ilan
    📌 Model: GSX-S 1000 - 3 ilan
    📌 Model: GSX-S 1000 GT - 3 ilan
    📌 Model: GSX-S 125 - 2 ilan
    📌 Model: GW 250F - 1 ilan
    📌 Model: GW250 Inazuma - 5 ilan
    📌 Model: Marauder 800 - 1 ilan
    📌 Model: SV650A - 1 ilan
    📌 Model: V-Strom 1050 DE - 1 ilan
    📌 Model: V-Strom 250 - 4 ilan
    📌 Model: V-Strom 650 XT ABS - 2 ilan
    📌 Model: V-Strom 800 SE - 3 ilan
    📌 Model: V-Strom DL1000 - 1 ilan
    📌 Model: V-Strom DL650 - 6 ilan
    📌 Model: Van Van 200 - 1 ilan
    📌 Model: VL 1500 Intruder - 1 ilan
    📌 Model: VL 250 Intruder - 1 ilan
    📌 Model: VL 800 Intruder - 2 ilan
    📌 Model: VZR 1800 Intruder - 1 ilan
  🔹 Marka: SWM (https://www.arabam.com/ikinci-el/motosiklet/swm)
    📌 Model: Gran Milano - 1 ilan
    📌 Model: Hoku 400 - 1 ilan
    📌 Model: Superdual T - 1 ilan
  🔹 Marka: SYM (https://www.arabam.com/ikinci-el/motosiklet/sym)
    📌 Model: ADX 125 - 23 ilan
    📌 Model: ADX 300 - 8 ilan
    📌 Model: Cruisym 250i - 4 ilan
    📌 Model: Diğer Modeller - 1 ilan
    📌 Model: DRG 160 - 9 ilan
    📌 Model: Fiddle II 125 - 1 ilan
    📌 Model: Fiddle III 125 - 4 ilan
    📌 Model: Fiddle III 125 i - 2 ilan
    📌 Model: Fiddle III 200 i - 2 ilan
    📌 Model: Fiddle IV 125 - 11 ilan
    📌 Model: GTS 250i EVO - 5 ilan
    📌 Model: HD2 200i - 2 ilan
    📌 Model: Jet 14 - 2 ilan
    📌 Model: JET 14 125 i - 1 ilan
    📌 Model: Jet 14 200 i - 4 ilan
    📌 Model: Jet 14 200i ABS - 35 ilan
    📌 Model: Jet 14 Evo 200 Plus - 12 ilan
    📌 Model: Jet 4 125 - 3 ilan
    📌 Model: Jet Sport X - 3 ilan
    📌 Model: Jet X - 1 ilan
    📌 Model: Jet X 125 - 78 ilan
    📌 Model: Joymax 250i - 10 ilan
    📌 Model: Joymax 250i ABS - 1 ilan
    📌 Model: Joymax Z 250 - 5 ilan
    📌 Model: Joymax Z Plus 250 - 25 ilan
    📌 Model: Joyride 300 - 22 ilan
    📌 Model: Joyride 300 E5 Sıvı - 2 ilan
    📌 Model: Joyride Evo 200 - 2 ilan
    📌 Model: Joyride Evo 200i - 6 ilan
    📌 Model: Joyride S 200i ABS - 1 ilan
    📌 Model: Maxsym 600i ABS - 1 ilan
    📌 Model: Maxsym TL 508 - 8 ilan
    📌 Model: Maxsym TL 508 E5 ABS - 1 ilan
    📌 Model: Mio 50 - 5 ilan
    📌 Model: Mmbcu D53 - 13 ilan
    📌 Model: NH T 200 - 21 ilan
    📌 Model: NH T 200 E5 - 1 ilan
    📌 Model: NH X 125 - 11 ilan
    📌 Model: NH X 125 NFC - 3 ilan
    📌 Model: Orbit 50 - 2 ilan
    📌 Model: Orbit II 125 - 1 ilan
    📌 Model: Orbit II 50 - 7 ilan
    📌 Model: Shark - 10 ilan
    📌 Model: Symphony SR 125 - 6 ilan
    📌 Model: Symphony ST 200i - 1 ilan
    📌 Model: Symphony ST 200i ABS - 11 ilan
    📌 Model: VS 150 - 2 ilan
    📌 Model: Xpro 125 - 5 ilan
    📌 Model: Xpro Cargo 125 - 8 ilan
    📌 Model: Xpro II 125 - 3 ilan
    📌 Model: XS 125K - 1 ilan
  🔹 Marka: Taktas Motor (https://www.arabam.com/ikinci-el/motosiklet/taktas-motor)
    📌 Model: Apollo 150 - 1 ilan
  🔹 Marka: Taro (https://www.arabam.com/ikinci-el/motosiklet/taro)
    📌 Model: GP-1 - 1 ilan
  🔹 Marka: TGB (https://www.arabam.com/ikinci-el/motosiklet/tgb)
    📌 Model: Elegance 50CC - 2 ilan
    📌 Model: X-Race 125 - 4 ilan
  🔹 Marka: Togo (https://www.arabam.com/ikinci-el/motosiklet/togo)
    📌 Model: 800G - 1 ilan
    📌 Model: 800S - 2 ilan
    📌 Model: T800 - 1 ilan
  🔹 Marka: Triumph (https://www.arabam.com/ikinci-el/motosiklet/triumph)
    📌 Model: Bonneville T100 - 2 ilan
    📌 Model: Bonneville T120 - 1 ilan
    📌 Model: Rocket 3 GT - 3 ilan
    📌 Model: Rocket 3 R - 1 ilan
    📌 Model: Scrambler 1200 XE - 2 ilan
    📌 Model: Scrambler 400 X - 1 ilan
    📌 Model: Speed 400 - 1 ilan
    📌 Model: Speed Triple 1200 RR - 1 ilan
    📌 Model: Speed Twin - 3 ilan
    📌 Model: Street Triple RS - 1 ilan
    📌 Model: Thruxton RS - 1 ilan
    📌 Model: Tiger - 1 ilan
    📌 Model: Tiger 1200 GT Pro - 1 ilan
    📌 Model: Tiger 900 GT Pro - 2 ilan
    📌 Model: Tiger 900 Rally - 1 ilan
    📌 Model: Tiger 900 Rally Pro - 1 ilan
    📌 Model: Tiger Explorer 1200 - 2 ilan
    📌 Model: Tiger Explorer XC - 2 ilan
    📌 Model: Tiger Sport 660 - 1 ilan
    📌 Model: Trident 660 - 3 ilan
    📌 Model: Trophy 1200 - 2 ilan
  🔹 Marka: TT (https://www.arabam.com/ikinci-el/motosiklet/tt)
    📌 Model: Chopper - 1 ilan
    📌 Model: Custom - 1 ilan
  🔹 Marka: TVS (https://www.arabam.com/ikinci-el/motosiklet/tvs)
    📌 Model: Apache RR310 - 2 ilan
    📌 Model: Apache RTR 150 - 7 ilan
    📌 Model: Apache RTR 180 - 2 ilan
    📌 Model: Apache RTR 200 - 54 ilan
    📌 Model: Diğer Modeller - 2 ilan
    📌 Model: Jupiter - 53 ilan
    📌 Model: Jupiter 125 - 100 ilan
    📌 Model: Neo X3i - 1 ilan
    📌 Model: Nqtorq 125 - 6 ilan
    📌 Model: Ntorq 125 - 40 ilan
    📌 Model: Raider 125 - 79 ilan
    📌 Model: Scooty Pep Plus - 3 ilan
    📌 Model: Scooty Zest 110 - 1 ilan
    📌 Model: Victor GLX - 1 ilan
    📌 Model: Wego - 6 ilan
  🔹 Marka: UM (https://www.arabam.com/ikinci-el/motosiklet/um)
    📌 Model: Chill Sport - 1 ilan
    📌 Model: Renegade Commando 125 - 1 ilan
    📌 Model: Renegade Freedom ABS 250 - 3 ilan
    📌 Model: Renegade Sport S 125 - 2 ilan
    📌 Model: Renegade Vegas 125 - 2 ilan
  🔹 Marka: Ural (https://www.arabam.com/ikinci-el/motosiklet/ural)
    📌 Model: Retro - 1 ilan
  🔹 Marka: Vespa (https://www.arabam.com/ikinci-el/motosiklet/vespa)
    📌 Model: 946 125 i.e. - 8 ilan
    📌 Model: GT 250 - 1 ilan
    📌 Model: GTS - 3 ilan
    📌 Model: GTS 125 ABS - 1 ilan
    📌 Model: GTS 125 Supersport - 7 ilan
    📌 Model: GTS 125 Supertech - 6 ilan
    📌 Model: GTS 150 ABS - 2 ilan
    📌 Model: GTS 250 - 3 ilan
    📌 Model: GTS 250 ABS - 4 ilan
    📌 Model: GTS 300 - 5 ilan
    📌 Model: GTS 300 Super - 7 ilan
    📌 Model: GTS 300 Super Sport - 3 ilan
    📌 Model: GTS 300 Super Sport S - 12 ilan
    📌 Model: GTS 300 Supertech - 8 ilan
    📌 Model: GTV 300 ie - 8 ilan
    📌 Model: LX 125 3V ie - 1 ilan
    📌 Model: LX 150 - 2 ilan
    📌 Model: LX 150 3V ie - 1 ilan
    📌 Model: LX 150 ie - 2 ilan
    📌 Model: Primavera 125 - 13 ilan
    📌 Model: Primavera 150 - 40 ilan
    📌 Model: Primavera 150 S - 13 ilan
    📌 Model: Primavera 50 - 10 ilan
    📌 Model: Primavera 50 RED - 1 ilan
    📌 Model: PX 150 - 1 ilan
    📌 Model: S125 - 1 ilan
    📌 Model: Sprint 125 - 1 ilan
    📌 Model: Sprint 150 - 12 ilan
    📌 Model: Sprint 50 - 1 ilan
  🔹 Marka: Vitello (https://www.arabam.com/ikinci-el/motosiklet/vitello)
    📌 Model: VT 100 Sport - 1 ilan
  🔹 Marka: Voge (https://www.arabam.com/ikinci-el/motosiklet/voge)
    📌 Model: 125 R - 13 ilan
    📌 Model: 250 Rally - 2 ilan
    📌 Model: 250 RR - 13 ilan
    📌 Model: 300 DS - 3 ilan
    📌 Model: 300 GY - 1 ilan
    📌 Model: 300 R - 1 ilan
    📌 Model: 300 Rally - 5 ilan
    📌 Model: 500DSX - 1 ilan
    📌 Model: 525 DSX - 19 ilan
    📌 Model: 525 R - 1 ilan
    📌 Model: 525 RR - 4 ilan
    📌 Model: SR1 - 16 ilan
    📌 Model: SR1 ADV - 26 ilan
    📌 Model: SR3 - 21 ilan
    📌 Model: SR4 Maksi 350 - 18 ilan
  🔹 Marka: Volta (https://www.arabam.com/ikinci-el/motosiklet/volta)
    📌 Model: Apec 125 - 14 ilan
    📌 Model: Apec 49.4 - 6 ilan
  🔹 Marka: Yamaha (https://www.arabam.com/ikinci-el/motosiklet/yamaha)
    📌 Model: BW's 100 - 3 ilan
    📌 Model: BW's 125 - 2 ilan
    📌 Model: Crypton - 4 ilan
    📌 Model: Cygnus L - 8 ilan
    📌 Model: Cygnus RS - 2 ilan
    📌 Model: D'elight - 13 ilan
    📌 Model: D'elight 125 - 4 ilan
    📌 Model: Fazer 8 - 1 ilan
    📌 Model: Fazer 8 ABS - 2 ilan
    📌 Model: FJR 1300 - 5 ilan
    📌 Model: FZ6 - 4 ilan
    📌 Model: FZ6 Fazer - 3 ilan
    📌 Model: FZ6 Fazer ABS - 1 ilan
    📌 Model: FZ8 - 1 ilan
    📌 Model: FZS 1000 - 1 ilan
    📌 Model: MT 07 - 2 ilan
    📌 Model: MT 07 ABS - 15 ilan
    📌 Model: MT 09 - 5 ilan
    📌 Model: MT 125 - 2 ilan
    📌 Model: MT 25 - 13 ilan
    📌 Model: MT 25 ABS - 28 ilan
    📌 Model: Neos - 6 ilan
    📌 Model: NMax 125 - 33 ilan
    📌 Model: NMax 155 - 52 ilan
    📌 Model: Nouvo - 1 ilan
    📌 Model: R25 TR54 Edition - 2 ilan
    📌 Model: R7 - 6 ilan
    📌 Model: RayZR - 6 ilan
    📌 Model: RX 135 - 1 ilan
    📌 Model: SR 125 - 3 ilan
    📌 Model: Tenere 700 - 1 ilan
    📌 Model: Tenere 700 Rally Edition - 2 ilan
    📌 Model: Tenere 700 World Raid - 2 ilan
    📌 Model: TMax 530 - 2 ilan
    📌 Model: TMax 560 - 7 ilan
    📌 Model: Tracer 7 - 3 ilan
    📌 Model: Tracer 700 - 2 ilan
    📌 Model: Tracer 9 - 1 ilan
    📌 Model: Tracer 900 - 5 ilan
    📌 Model: Tricity 125 - 7 ilan
    📌 Model: Tricity 155 - 5 ilan
    📌 Model: Tricity 300 - 1 ilan
    📌 Model: Virago XV 535 - 1 ilan
    📌 Model: WR 125 R - 1 ilan
    📌 Model: WR 125 X - 1 ilan
    📌 Model: WR 250 R - 1 ilan
    📌 Model: X City 250 - 5 ilan
    📌 Model: X-Max 125 ABS - 7 ilan
    📌 Model: X-Max 125 Iron Max - 2 ilan
    📌 Model: X-Max 125 Iron Max ABS - 4 ilan
    📌 Model: X-Max 250 - 19 ilan
    📌 Model: X-Max 250 ABS - 58 ilan
    📌 Model: X-Max 250 Iron Max ABS - 20 ilan
    📌 Model: X-Max 250 Momo Design - 2 ilan
    📌 Model: X-Max 250 Tech Max - 73 ilan
    📌 Model: X-Max 300 ABS - 6 ilan
    📌 Model: X-Max 300 Iron Max ABS - 2 ilan
    📌 Model: X-Max 400 - 5 ilan
    📌 Model: X-Max 400 ABS - 5 ilan
    📌 Model: X-Max 400 Iron Max - 1 ilan
    📌 Model: X-Max 400 Tech Max - 4 ilan
    📌 Model: XJ 6 - 2 ilan
    📌 Model: XJ 6 Diversion F - 1 ilan
    📌 Model: XJ 600 Diversion - 1 ilan
    📌 Model: XSR 125 - 4 ilan
    📌 Model: XSR 700 - 7 ilan
    📌 Model: XSR 900 - 1 ilan
    📌 Model: XT 1200 Z Super Tenere - 1 ilan
    📌 Model: XTZ 660ZA Tenere - 1 ilan
    📌 Model: XV950 - 1 ilan
    📌 Model: XV950R - 1 ilan
    📌 Model: XVS 1100 Drag Star - 1 ilan
    📌 Model: XVS 1300 A - 2 ilan
    📌 Model: XVS 650 A - 1 ilan
    📌 Model: XVS 650 Dragstar - 1 ilan
    📌 Model: XVS 950 CU - 1 ilan
    📌 Model: YBR 125 - 13 ilan
    📌 Model: YBR 125 ESD - 21 ilan
    📌 Model: YBR 250 - 1 ilan
    📌 Model: YP 250 R x Max - 2 ilan
    📌 Model: YS 125 - 3 ilan
    📌 Model: YZF R1 - 6 ilan
    📌 Model: YZF R125 - 6 ilan
    📌 Model: YZF R25 - 28 ilan
    📌 Model: YZF R25 ABS - 37 ilan
    📌 Model: YZF R3 - 5 ilan
    📌 Model: YZF R6 - 13 ilan
    📌 Model: YZF R6s - 1 ilan
  🔹 Marka: Yiben (https://www.arabam.com/ikinci-el/motosiklet/yiben)
    📌 Model: Palermo - 1 ilan
    📌 Model: YB50QT-21 - 1 ilan
  🔹 Marka: Yuki (https://www.arabam.com/ikinci-el/motosiklet/yuki)
    📌 Model: Active 125 - 3 ilan
    📌 Model: Bellini 125 - 1 ilan
    📌 Model: Bellini 50 - 12 ilan
    📌 Model: Benda Rock 250 - 9 ilan
    📌 Model: C5 ZR250 - 1 ilan
    📌 Model: Casper S 50 - 14 ilan
    📌 Model: Crypto 125 - 6 ilan
    📌 Model: Crypto 50 - 5 ilan
    📌 Model: Defender Maxi ADV - 2 ilan
    📌 Model: Diğer Modeller - 20 ilan
    📌 Model: Dirty Paws Offroad - 4 ilan
    📌 Model: Dirty Paws Z300 - 1 ilan
    📌 Model: Drag 200 - 1 ilan
    📌 Model: Duty 125 - 3 ilan
    📌 Model: Enzo 50 - 4 ilan
    📌 Model: Fifty 50 - 1 ilan
    📌 Model: Funrider 125 - 10 ilan
    📌 Model: Gelato 125 - 20 ilan
    📌 Model: Gelato 150 - 1 ilan
    📌 Model: Gentle 50 - 10 ilan
    📌 Model: Gusto 50 - 11 ilan
    📌 Model: Hammer 125 - 3 ilan
    📌 Model: Hammer 50 - 53 ilan
    📌 Model: Huracan TR250T - 2 ilan
    📌 Model: JJ50QT Picasso 50 - 1 ilan
    📌 Model: Legend 50 - 3 ilan
    📌 Model: Lupo 125 - 3 ilan
    📌 Model: Margherita 50 - 1 ilan
    📌 Model: Mojito 125 - 5 ilan
    📌 Model: Mojito 50 - 14 ilan
    📌 Model: QM50QT-6E Snoopy - 1 ilan
    📌 Model: Risotto 125 - 5 ilan
    📌 Model: Risotto 50 - 16 ilan
    📌 Model: Route 110 - 6 ilan
    📌 Model: Scram 170 - 3 ilan
    📌 Model: Solid 125 - 3 ilan
    📌 Model: T11 Explorer - 3 ilan
    📌 Model: T9 Strom 125 - 5 ilan
    📌 Model: Taro 250R - 1 ilan
    📌 Model: Taro GP1 - 9 ilan
    📌 Model: Taro GP2 - 23 ilan
    📌 Model: Tekken 125 - 1 ilan
    📌 Model: TK50Q3 Picasso 50 - 1 ilan
    📌 Model: TN150-3A Driver - 1 ilan
    📌 Model: TY125-Z Driver - 14 ilan
    📌 Model: Xway 125 - 1 ilan
    📌 Model: YB 150 Jumbo - 1 ilan
    📌 Model: YB150T-15 Jumbo - 2 ilan
    📌 Model: YB50QT-3 Casper - 1 ilan
    📌 Model: YK 100-B - 1 ilan
    📌 Model: YK-09 Neon Classic - 1 ilan
    📌 Model: YK-100M Modify - 1 ilan
    📌 Model: YK-150-9 Goldfox-S - 1 ilan
    📌 Model: YK-162 Goldfox-S - 1 ilan
    📌 Model: YK-24 AYDOS - 1 ilan
    📌 Model: YK-25 Midilli - 1 ilan
    📌 Model: YK-250ZH Ayder - 3 ilan
    📌 Model: YK250 - 2 ilan
    📌 Model: YK250-4 - 1 ilan
  🔹 Marka: Zealsun (https://www.arabam.com/ikinci-el/motosiklet/zealsun)
    📌 Model: ZLS 50 Rex - 1 ilan
    📌 Model: ZS 125-2 - 1 ilan
  🔹 Marka: Zontes (https://www.arabam.com/ikinci-el/motosiklet/zontes)
    📌 Model: 125 M - 2 ilan
    📌 Model: 200 C - 9 ilan
    📌 Model: 250 T-E - 4 ilan
    📌 Model: 350 GK - 2 ilan
    📌 Model: 350 R - 1 ilan
    📌 Model: 350 T1 - 1 ilan
    📌 Model: 350 T2 - 15 ilan
    📌 Model: 350 V - 4 ilan
  🔹 Marka: Zorro (https://www.arabam.com/ikinci-el/motosiklet/zorro)
    📌 Model: ZR 100-8 A Sport - 1 ilan
    📌 Model: ZR 125-48 Yebere - 1 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/minivan-van_panelvan
  🔹 Marka: BMC (https://www.arabam.com/ikinci-el/minivan-van_panelvan/bmc)
    📌 Model: Megastar - 7 ilan
  🔹 Marka: Chery (https://www.arabam.com/ikinci-el/minivan-van_panelvan/chery)
    📌 Model: Taxim - 4 ilan
  🔹 Marka: Chevrolet (https://www.arabam.com/ikinci-el/minivan-van_panelvan/chevrolet)
    📌 Model: Express Van - 1 ilan
    📌 Model: G Serisi - 1 ilan
  🔹 Marka: Chrysler (https://www.arabam.com/ikinci-el/minivan-van_panelvan/chrysler)
    📌 Model: Grand Voyager - 23 ilan
    📌 Model: Town & Country - 2 ilan
    📌 Model: Voyager - 9 ilan
  🔹 Marka: Citroen (https://www.arabam.com/ikinci-el/minivan-van_panelvan/citroen)
    📌 Model: Berlingo - 1.010 ilan
    📌 Model: C15 - 1 ilan
    📌 Model: C25 - 1 ilan
    📌 Model: Jumper - 33 ilan
    📌 Model: Jumpy - 56 ilan
    📌 Model: Nemo - 398 ilan
  🔹 Marka: Dacia (https://www.arabam.com/ikinci-el/minivan-van_panelvan/dacia)
    📌 Model: Dokker - 298 ilan
    📌 Model: Logan - 39 ilan
  🔹 Marka: Daewoo (https://www.arabam.com/ikinci-el/minivan-van_panelvan/daewoo)
    📌 Model: Damas - 1 ilan
  🔹 Marka: DFM (https://www.arabam.com/ikinci-el/minivan-van_panelvan/dfm)
    📌 Model: Panelvan - 1 ilan
    📌 Model: Succe - 18 ilan
  🔹 Marka: Dodge (https://www.arabam.com/ikinci-el/minivan-van_panelvan/dodge)
    📌 Model: Grand Caravan - 4 ilan
  🔹 Marka: Faw (https://www.arabam.com/ikinci-el/minivan-van_panelvan/faw)
    📌 Model: CA5024 - 2 ilan
  🔹 Marka: Fest (https://www.arabam.com/ikinci-el/minivan-van_panelvan/fest)
    📌 Model: E-Box - 1 ilan
  🔹 Marka: Fiat (https://www.arabam.com/ikinci-el/minivan-van_panelvan/fiat)
    📌 Model: Doblo - 4.054 ilan
    📌 Model: Ducato - 204 ilan
    📌 Model: Fiorino - 3.261 ilan
    📌 Model: Palio Van - 48 ilan
    📌 Model: Panda Van - 2 ilan
    📌 Model: Punto Van - 1 ilan
    📌 Model: Scudo - 40 ilan
    📌 Model: Ulysse - 8 ilan
  🔹 Marka: Ford (https://www.arabam.com/ikinci-el/minivan-van_panelvan/ford)
    📌 Model: E Serisi - 2 ilan
    📌 Model: Fiesta Van - 39 ilan
    📌 Model: Tourneo Connect - 1.169 ilan
    📌 Model: Tourneo Courier - 2.327 ilan
    📌 Model: Tourneo Custom - 97 ilan
    📌 Model: Transit - 998 ilan
    📌 Model: Transit Connect - 435 ilan
    📌 Model: Transit Courier - 208 ilan
    📌 Model: Transit Custom - 311 ilan
    📌 Model: Transit Kombi - 8 ilan
    📌 Model: Windstar - 1 ilan
  🔹 Marka: GAZ (https://www.arabam.com/ikinci-el/minivan-van_panelvan/gaz)
    📌 Model: Gazelle - 7 ilan
    📌 Model: Next - 1 ilan
  🔹 Marka: GMC (https://www.arabam.com/ikinci-el/minivan-van_panelvan/gmc)
    📌 Model: Safari - 1 ilan
    📌 Model: Vandura - 2 ilan
  🔹 Marka: Hyundai (https://www.arabam.com/ikinci-el/minivan-van_panelvan/hyundai)
    📌 Model: H 1 - 11 ilan
    📌 Model: H 100 - 169 ilan
    📌 Model: H 350 - 2 ilan
    📌 Model: Starex - 98 ilan
    📌 Model: Staria - 13 ilan
  🔹 Marka: Iveco - Otoyol (https://www.arabam.com/ikinci-el/minivan-van_panelvan/iveco-otoyol)
    📌 Model: 35 - 41 ilan
    📌 Model: 70 - 2 ilan
  🔹 Marka: Kia (https://www.arabam.com/ikinci-el/minivan-van_panelvan/kia)
    📌 Model: Besta - 8 ilan
    📌 Model: Pregio - 22 ilan
  🔹 Marka: Lancia (https://www.arabam.com/ikinci-el/minivan-van_panelvan/lancia)
    📌 Model: Voyager - 2 ilan
  🔹 Marka: MAN (https://www.arabam.com/ikinci-el/minivan-van_panelvan/man)
    📌 Model: TGE - 1 ilan
  🔹 Marka: Maxus (https://www.arabam.com/ikinci-el/minivan-van_panelvan/maxus)
    📌 Model: e-Deliver - 2 ilan
  🔹 Marka: Mazda (https://www.arabam.com/ikinci-el/minivan-van_panelvan/mazda)
    📌 Model: E 2200 - 24 ilan
  🔹 Marka: Mercedes - Benz (https://www.arabam.com/ikinci-el/minivan-van_panelvan/mercedes-benz)
    📌 Model: Citan - 14 ilan
    📌 Model: Sprinter - 32 ilan
    📌 Model: V Serisi - 4 ilan
    📌 Model: Vaneo - 31 ilan
    📌 Model: Viano - 96 ilan
    📌 Model: Vito - 646 ilan
  🔹 Marka: Mitsubishi (https://www.arabam.com/ikinci-el/minivan-van_panelvan/mitsubishi)
    📌 Model: L 300 - 132 ilan
  🔹 Marka: Nissan (https://www.arabam.com/ikinci-el/minivan-van_panelvan/nissan)
    📌 Model: Vanette - 8 ilan
  🔹 Marka: Opel (https://www.arabam.com/ikinci-el/minivan-van_panelvan/opel)
    📌 Model: Combo - 584 ilan
    📌 Model: Corsa Van - 24 ilan
    📌 Model: Movano - 4 ilan
    📌 Model: Sintra - 2 ilan
    📌 Model: Vivaro - 42 ilan
    📌 Model: Zafira Life - 26 ilan
  🔹 Marka: Peugeot (https://www.arabam.com/ikinci-el/minivan-van_panelvan/peugeot)
    📌 Model: 206 Van - 15 ilan
    📌 Model: Bipper - 414 ilan
    📌 Model: Boxer - 48 ilan
    📌 Model: Expert - 47 ilan
    📌 Model: Expert Traveller - 21 ilan
    📌 Model: Partner - 1.202 ilan
    📌 Model: Rifter - 312 ilan
  🔹 Marka: Renault (https://www.arabam.com/ikinci-el/minivan-van_panelvan/renault)
    📌 Model: Express - 25 ilan
    📌 Model: Express Combi - 80 ilan
    📌 Model: Express Van - 37 ilan
    📌 Model: Kangoo - 480 ilan
    📌 Model: Kangoo Express - 190 ilan
    📌 Model: Kangoo Multix - 661 ilan
    📌 Model: Master - 230 ilan
    📌 Model: Trafic - 169 ilan
    📌 Model: Trafic Multix - 52 ilan
  🔹 Marka: Seat (https://www.arabam.com/ikinci-el/minivan-van_panelvan/seat)
    📌 Model: Inca - 1 ilan
  🔹 Marka: Skoda (https://www.arabam.com/ikinci-el/minivan-van_panelvan/skoda)
    📌 Model: Fabia Praktik - 2 ilan
  🔹 Marka: Suzuki (https://www.arabam.com/ikinci-el/minivan-van_panelvan/suzuki)
    📌 Model: Carry - 13 ilan
  🔹 Marka: Toyota (https://www.arabam.com/ikinci-el/minivan-van_panelvan/toyota)
    📌 Model: Hi-Ace - 4 ilan
    📌 Model: Proace City - 95 ilan
    📌 Model: Proace City Cargo - 11 ilan
  🔹 Marka: Volkswagen (https://www.arabam.com/ikinci-el/minivan-van_panelvan/volkswagen)
    📌 Model: Caddy - 1.470 ilan
    📌 Model: Caravelle - 370 ilan
    📌 Model: Crafter - 46 ilan
    📌 Model: ID. Buzz - 3 ilan
    📌 Model: LT - 14 ilan
    📌 Model: MultiVan - 23 ilan
    📌 Model: Transporter - 1.346 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/ticari-arac
  🔹 Marka: Minibüs & Midibüs (https://www.arabam.com/ikinci-el/ticari-arac/minibus---midibus)
    📌 Model: BMC - 9 ilan
    📌 Model: Citroen - 70 ilan
    📌 Model: Fiat - 113 ilan
    📌 Model: Ford - Otosan - 643 ilan
    📌 Model: Hyundai - 11 ilan
    📌 Model: Isuzu - 39 ilan
    📌 Model: Iveco - Otoyol - 27 ilan
    📌 Model: Karsan - 64 ilan
    📌 Model: Magirus - 6 ilan
    📌 Model: Mercedes - Benz - 316 ilan
    📌 Model: Mitsubishi - 5 ilan
    📌 Model: Opel - 4 ilan
    📌 Model: Otokar - 80 ilan
    📌 Model: Peugeot - 64 ilan
    📌 Model: Renault - 139 ilan
    📌 Model: Temsa - 57 ilan
    📌 Model: Volkswagen - 283 ilan
  🔹 Marka: Otobüs (https://www.arabam.com/ikinci-el/ticari-arac/otobus)
    📌 Model: BMC - 4 ilan
    📌 Model: Güleryüz - 3 ilan
    📌 Model: Isuzu - 6 ilan
    📌 Model: Iveco - 10 ilan
    📌 Model: MAN - 5 ilan
    📌 Model: Mercedes - Benz - 35 ilan
    📌 Model: Neoplan - 7 ilan
    📌 Model: Otokar - 6 ilan
    📌 Model: Setra - 1 ilan
    📌 Model: Temsa - 14 ilan
    📌 Model: Tezeller - 1 ilan
    📌 Model: Türkkar - 1 ilan
  🔹 Marka: Kamyon & Kamyonet (https://www.arabam.com/ikinci-el/ticari-arac/kamyon-kamyonet)
    📌 Model: Anadol - 9 ilan
    📌 Model: Askam - 13 ilan
    📌 Model: Bedford - 2 ilan
    📌 Model: BMC - 196 ilan
    📌 Model: Chrysler - 7 ilan
    📌 Model: Citroen - 13 ilan
    📌 Model: Dacia - 12 ilan
    📌 Model: DAF - 1 ilan
    📌 Model: Daihatsu - 2 ilan
    📌 Model: DFM - 7 ilan
    📌 Model: DFSK - 8 ilan
    📌 Model: Dodge - 58 ilan
    📌 Model: Faw - 6 ilan
    📌 Model: Fiat - 162 ilan
    📌 Model: Folkvan - 1 ilan
    📌 Model: Ford Trucks - 1.593 ilan
    📌 Model: GAZ - 27 ilan
    📌 Model: HF Kanuni - 2 ilan
    📌 Model: Hino - 25 ilan
    📌 Model: Hyundai - 228 ilan
    📌 Model: Isuzu - 439 ilan
    📌 Model: Iveco - Otoyol - 392 ilan
    📌 Model: Kia - 206 ilan
    📌 Model: MAN - 49 ilan
    📌 Model: Mazda - 16 ilan
    📌 Model: Mercedes - Benz - 269 ilan
    📌 Model: Mitsubishi - Temsa - 335 ilan
    📌 Model: Nissan - 13 ilan
    📌 Model: Opel - 1 ilan
    📌 Model: Otokar - 8 ilan
    📌 Model: Peugeot - 15 ilan
    📌 Model: Proton - 2 ilan
    📌 Model: Renault - 123 ilan
    📌 Model: Samsung - 3 ilan
    📌 Model: Scania - 19 ilan
    📌 Model: Skoda - 20 ilan
    📌 Model: Suzuki - 11 ilan
    📌 Model: Tata - 4 ilan
    📌 Model: Tenax - 9 ilan
    📌 Model: Toyota - 2 ilan
    📌 Model: Volkswagen - 52 ilan
    📌 Model: Volvo - 2 ilan
  🔹 Marka: Çekici (https://www.arabam.com/ikinci-el/ticari-arac/cekici)
    📌 Model: BMC - 21 ilan
    📌 Model: DAF - 96 ilan
    📌 Model: Fiat - 7 ilan
    📌 Model: Ford - 127 ilan
    📌 Model: Iveco - 65 ilan
    📌 Model: MAN - 79 ilan
    📌 Model: Mercedes - Benz - 268 ilan
    📌 Model: Opel - 8 ilan
    📌 Model: Renault - 100 ilan
    📌 Model: Scania - 109 ilan
    📌 Model: Volvo - 57 ilan
  🔹 Marka: Dorse (https://www.arabam.com/ikinci-el/ticari-arac/dorse)
    📌 Model: Damperli - 167 ilan
    📌 Model: Frigorifik - 34 ilan
    📌 Model: Konteyner Taşıyıcı & Şasi Grubu - 22 ilan
    📌 Model: Kuru Yük - 126 ilan
    📌 Model: Lowbed - 22 ilan
    📌 Model: Özel Amaçlı Dorseler - 5 ilan
    📌 Model: Silobas - 6 ilan
    📌 Model: Tanker - 14 ilan
    📌 Model: Tekstil - 1 ilan
    📌 Model: Tenteli - 158 ilan
  🔹 Marka: Römork (https://www.arabam.com/ikinci-el/ticari-arac/romork)
    📌 Model: Kamyon Römorkları - 4 ilan
    📌 Model: Özel Amaçlı Römorklar - 4 ilan
    📌 Model: Tarım Römorkları - 2 ilan
    📌 Model: Taşıma Römorkları - 7 ilan
  🔹 Marka: Karoser & Üst Yapı (https://www.arabam.com/ikinci-el/ticari-arac/karoser-ust-yapi)
    📌 Model: Damperli Grup - 9 ilan
    📌 Model: Sabit Kabin - 195 ilan
  🔹 Marka: Oto Kurtarıcı & Taşıyıcı (https://www.arabam.com/ikinci-el/ticari-arac/oto-kurtarici-tasiyici)
    📌 Model: Çoklu Araç - 8 ilan
    📌 Model: Tekli Araç - 226 ilan
  🔹 Marka: Ticari Hat & Plaka (https://www.arabam.com/ikinci-el/ticari-arac/ticari-hat-plaka)
    📌 Model: Minibüs & Dolmuş Hattı - 30 ilan
    📌 Model: Nakliye Araçları - 1 ilan
    📌 Model: Otobüs Hattı - 4 ilan
    📌 Model: Servis Plakası - 9 ilan
    📌 Model: Taksi Plakası - 56 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/karavan_
  🔹 Marka: Çekme Karavan (https://www.arabam.com/ikinci-el/karavan_-cekme-karavan)
    📌 Model: 5K Karavan - 1 ilan
    📌 Model: ABC - 1 ilan
    📌 Model: Adle - 1 ilan
    📌 Model: Adria - 4 ilan
    📌 Model: Angora Karavan - 2 ilan
    📌 Model: Ankaravan - 1 ilan
    📌 Model: Arzen Marin - 1 ilan
    📌 Model: Avrupa - 2 ilan
    📌 Model: Ayaz Karavan - 1 ilan
    📌 Model: Badger Karavan - 1 ilan
    📌 Model: Bailey - 1 ilan
    📌 Model: Başkent - 12 ilan
    📌 Model: Başoğlu - 7 ilan
    📌 Model: Baykar - 1 ilan
    📌 Model: BlueSky Karavan - 1 ilan
    📌 Model: Bürstner - 3 ilan
    📌 Model: Camppass - 1 ilan
    📌 Model: Can - 5 ilan
    📌 Model: Capella - 2 ilan
    📌 Model: Caravan Keşif - 1 ilan
    📌 Model: Carriva Karavan - 1 ilan
    📌 Model: Class Karavan - 2 ilan
    📌 Model: Diğer - 52 ilan
    📌 Model: Doğa Karavan - 1 ilan
    📌 Model: Dream House - 4 ilan
    📌 Model: Egem Life - 1 ilan
    📌 Model: Elma Karavan - 1 ilan
    📌 Model: Er Karavan - 6 ilan
    📌 Model: Erba - 20 ilan
    📌 Model: Escape Karavan - 1 ilan
    📌 Model: Fendt - 2 ilan
    📌 Model: Gencer Karavan - 1 ilan
    📌 Model: Gökhan Karavan - 1 ilan
    📌 Model: Gündoğdu - 2 ilan
    📌 Model: Güney - 2 ilan
    📌 Model: Hawk Karavan - 3 ilan
    📌 Model: Hazelser - 1 ilan
    📌 Model: Hobby - 4 ilan
    📌 Model: Hunter Nature - 2 ilan
    📌 Model: İnka Karavan - 3 ilan
    📌 Model: Kam Caravan - 2 ilan
    📌 Model: Kampkon - 5 ilan
    📌 Model: Köken Karavan - 1 ilan
    📌 Model: Kurt Karavan - 1 ilan
    📌 Model: LMC - 1 ilan
    📌 Model: Luxer - 1 ilan
    📌 Model: Marmara Karavan - 1 ilan
    📌 Model: May Karavan - 2 ilan
    📌 Model: Mega - 8 ilan
    📌 Model: Mono Karavan - 1 ilan
    📌 Model: Nehir Karavan - 1 ilan
    📌 Model: Nidus Karavan - 1 ilan
    📌 Model: NK - 5 ilan
    📌 Model: Onyx - 3 ilan
    📌 Model: Ortiz - 6 ilan
    📌 Model: Özel Yapım - 4 ilan
    📌 Model: Pala Karavan - 1 ilan
    📌 Model: Peace Caravan - 3 ilan
    📌 Model: Pino - 2 ilan
    📌 Model: Rekvan - 3 ilan
    📌 Model: Ren Karavan - 1 ilan
    📌 Model: RİO Karavan - 4 ilan
    📌 Model: River & Sea Caravan - 4 ilan
    📌 Model: Saly - 1 ilan
    📌 Model: Semivan - 1 ilan
    📌 Model: Serm & Barr - 1 ilan
    📌 Model: Siesta Karavan - 1 ilan
    📌 Model: Sigma Karavan - 1 ilan
    📌 Model: Stil Karavan - 4 ilan
    📌 Model: Swan Karavan - 2 ilan
    📌 Model: Tabbert - 1 ilan
    📌 Model: Tosbiq - 1 ilan
    📌 Model: Vagon Karavan - 1 ilan
    📌 Model: Weinsberg - 1 ilan
    📌 Model: White Pigeon - 1 ilan
    📌 Model: ZTK Karavan - 5 ilan
  🔹 Marka: Motokaravan (https://www.arabam.com/ikinci-el/karavan_-motokaravan)
    📌 Model: 5K Karavan - 1 ilan
    📌 Model: Adria - 1 ilan
    📌 Model: BMC - 11 ilan
    📌 Model: Carsiva Karavan - 1 ilan
    📌 Model: Citroen - 10 ilan
    📌 Model: Diğer - 17 ilan
    📌 Model: Etrusco - 1 ilan
    📌 Model: Fiat - 49 ilan
    📌 Model: Ford - 10 ilan
    📌 Model: GAZ - 1 ilan
    📌 Model: Gezginci Karavan - 1 ilan
    📌 Model: Hotomobil - 1 ilan
    📌 Model: Hyundai - 1 ilan
    📌 Model: İmaj Karavan - 1 ilan
    📌 Model: Isuzu - 4 ilan
    📌 Model: Iveco - 17 ilan
    📌 Model: Kampkon - 1 ilan
    📌 Model: Karsan - 1 ilan
    📌 Model: Kia - 1 ilan
    📌 Model: Mercedes-Benz - 26 ilan
    📌 Model: Opel - 3 ilan
    📌 Model: Otokar - 2 ilan
    📌 Model: Peugeot - 31 ilan
    📌 Model: Renault - 18 ilan
    📌 Model: Teknik Motors Karavan - 1 ilan
    📌 Model: Tofaş - Fiat - 3 ilan
    📌 Model: Volkswagen - 40 ilan

🚗 Araç Türü: https://www.arabam.com/ikinci-el/atv-utv
  🔹 Marka: Access (https://www.arabam.com/ikinci-el/atv-utv/access)
    📌 Model: Diğer Modeller - 1 ilan
  🔹 Marka: Aeon (https://www.arabam.com/ikinci-el/atv-utv/aeon)
    📌 Model: Cobra 180 - 1 ilan
  🔹 Marka: Arctic Cat (https://www.arabam.com/ikinci-el/atv-utv/arctic-cat)
    📌 Model: Alterra 700 XT - 1 ilan
  🔹 Marka: Arora (https://www.arabam.com/ikinci-el/atv-utv/arora)
    📌 Model: 200 CC - 1 ilan
    📌 Model: Hector 450 - 6 ilan
    📌 Model: Hunter 300 - 7 ilan
    📌 Model: XY 500 - 1 ilan
  🔹 Marka: Asya Motor (https://www.arabam.com/ikinci-el/atv-utv/asya-motor)
    📌 Model: Discovery 150 - 1 ilan
  🔹 Marka: Can-Am (https://www.arabam.com/ikinci-el/atv-utv/can-am)
    📌 Model: Maverick X RS Turbo RR - 1 ilan
    📌 Model: Outlander Max XT 570 - 5 ilan
  🔹 Marka: CFMoto (https://www.arabam.com/ikinci-el/atv-utv/cfmoto)
    📌 Model: C Force 1000 - 1 ilan
    📌 Model: C Force 1000 ATR-EPS - 30 ilan
    📌 Model: C Force 1000 Overland - 15 ilan
    📌 Model: C Force 450 L EPS - 33 ilan
    📌 Model: C Force 550 ATR-EPS - 4 ilan
    📌 Model: C Force 625 ATR-EPS - 23 ilan
    📌 Model: C Force 625 Touring - 23 ilan
    📌 Model: C Force 800 ATR-EPS - 1 ilan
    📌 Model: CF 1000 ATR EPS - 2 ilan
    📌 Model: CF 450 ATR EPS - 3 ilan
    📌 Model: CF 625 - 1 ilan
    📌 Model: U Force 1000XL - 2 ilan
    📌 Model: Z Force 1000 Sport - 3 ilan
    📌 Model: Z Force 1000 Sport EPS - 9 ilan
    📌 Model: Z Force 1000 Sport R - 10 ilan
    📌 Model: Z Force 500 EX UTR - 1 ilan
    📌 Model: Z Force 550 EX-UTR - 1 ilan
    📌 Model: Z Force 950 Sport - 3 ilan
  🔹 Marka: Dorado (https://www.arabam.com/ikinci-el/atv-utv/dorado)
    📌 Model: 150 - 1 ilan
  🔹 Marka: Goes (https://www.arabam.com/ikinci-el/atv-utv/goes)
    📌 Model: CF500 ATR - 1 ilan
  🔹 Marka: Kanuni (https://www.arabam.com/ikinci-el/atv-utv/kanuni)
    📌 Model: ATV 150 - 1 ilan
    📌 Model: ATV 150 U Off Road - 2 ilan
  🔹 Marka: Kawasaki (https://www.arabam.com/ikinci-el/atv-utv/kawasaki)
    📌 Model: Brute Force 750 - 1 ilan
    📌 Model: Brute Force 750 Camo - 1 ilan
  🔹 Marka: Kral Motor (https://www.arabam.com/ikinci-el/atv-utv/kral-motor)
    📌 Model: KR 150 Argon - 1 ilan
  🔹 Marka: Kuba (https://www.arabam.com/ikinci-el/atv-utv/kuba)
    📌 Model: Alterra 350 - 1 ilan
    📌 Model: Eland 200 - 2 ilan
    📌 Model: GARDENTRACK 150 - 2 ilan
    📌 Model: Hussar 135 - 6 ilan
    📌 Model: HUSSAR 220 / T3 - 5 ilan
    📌 Model: Hussar 220 Pro - 3 ilan
    📌 Model: LH 200 - 2 ilan
    📌 Model: LH 500 - 1 ilan
    📌 Model: Promax 450 - 8 ilan
    📌 Model: Promax 570 - 1 ilan
    📌 Model: RACER 280 / T3 - 7 ilan
    📌 Model: TRV 350 - 12 ilan
    📌 Model: Vip Track - 13 ilan
    📌 Model: Viptrack 250 / T3 - 16 ilan
    📌 Model: XWolf 700 - 14 ilan
  🔹 Marka: Kymco (https://www.arabam.com/ikinci-el/atv-utv/kymco)
    📌 Model: MXU 300 - 2 ilan
    📌 Model: MXU 500 - 1 ilan
  🔹 Marka: Loncin (https://www.arabam.com/ikinci-el/atv-utv/loncin)
    📌 Model: XWolf 250 Pro - 5 ilan
    📌 Model: XWolf 700 - 8 ilan
  🔹 Marka: Mondial (https://www.arabam.com/ikinci-el/atv-utv/mondial)
    📌 Model: AU 200 (T3B) - 11 ilan
    📌 Model: BS 150 - 1 ilan
    📌 Model: Vulcan - 1 ilan
  🔹 Marka: Motolux (https://www.arabam.com/ikinci-el/atv-utv/motolux)
    📌 Model: M750 - 2 ilan
  🔹 Marka: Motoran (https://www.arabam.com/ikinci-el/atv-utv/motoran)
    📌 Model: BS 150S-2B - 1 ilan
    📌 Model: LX 200 - 1 ilan
  🔹 Marka: Polaris (https://www.arabam.com/ikinci-el/atv-utv/polaris)
    📌 Model: Phoenix 200 - 1 ilan
    📌 Model: RZR 170 - 1 ilan
    📌 Model: Sportsman 570 - 3 ilan
    📌 Model: Sportsman 570 Touring - 5 ilan
    📌 Model: Sportsman 800 EFI - 1 ilan
    📌 Model: Sportsman X2 - 1 ilan
    📌 Model: Sportsman XP 850 - 6 ilan
    📌 Model: UTV General 1000 - 1 ilan
    📌 Model: UTV Ranger XP 1000 - 2 ilan
    📌 Model: UTV RZR XP 1000 - 1 ilan
  🔹 Marka: Pumarex (https://www.arabam.com/ikinci-el/atv-utv/pumarex)
    📌 Model: Jaguar 500 - 1 ilan
    📌 Model: UTV Buggy XT150GK-9A - 1 ilan
  🔹 Marka: QJ Motor (https://www.arabam.com/ikinci-el/atv-utv/qj-motor)
    📌 Model: SFA 600 - 9 ilan
  🔹 Marka: Regal Raptor (https://www.arabam.com/ikinci-el/atv-utv/regal-raptor)
    📌 Model: F320 - 4 ilan
    📌 Model: M210 - 6 ilan
    📌 Model: Promax 650L - 3 ilan
  🔹 Marka: Revolt (https://www.arabam.com/ikinci-el/atv-utv/revolt)
    📌 Model: RA5 - 9 ilan
  🔹 Marka: Segway (https://www.arabam.com/ikinci-el/atv-utv/segway)
    📌 Model: Fugleman UT10 - 1 ilan
    📌 Model: Snarler 500 - 12 ilan
    📌 Model: Snarler 570 - 2 ilan
    📌 Model: Snarler AT6L X 570 - 32 ilan
    📌 Model: Villain SX10 - 1 ilan
    📌 Model: Villian - 4 ilan
  🔹 Marka: Skyjet (https://www.arabam.com/ikinci-el/atv-utv/skyjet)
    📌 Model: Braves 110 - 10 ilan
    📌 Model: M135 - 4 ilan
  🔹 Marka: SMC (https://www.arabam.com/ikinci-el/atv-utv/smc)
    📌 Model: Jumbo 700 - 1 ilan
  🔹 Marka: SYM (https://www.arabam.com/ikinci-el/atv-utv/sym)
    📌 Model: QuadLander - 3 ilan
  🔹 Marka: TGB (https://www.arabam.com/ikinci-el/atv-utv/tgb)
    📌 Model: QUAD 425 - 1 ilan
  🔹 Marka: Yamaha (https://www.arabam.com/ikinci-el/atv-utv/yamaha)
    📌 Model: Kodiak 700 EPS SE - 2 ilan
  🔹 Marka: Yuki (https://www.arabam.com/ikinci-el/atv-utv/yuki)
    📌 Model: 70 CC Afacan - 1 ilan
    📌 Model: CZD180Y12 Cazador - 1 ilan
    📌 Model: HS 400ATV - 1 ilan
    📌 Model: HS 600ATV - 2 ilan
    📌 Model: HS 700 Puma - 1 ilan
    📌 Model: Tirex 125 - 3 ilan
    📌 Model: UTV 150 - 2 ilan
    📌 Model: UTV HS 800 Zebra - 1 ilan
    📌 Model: UTV Thor 250 - 1 ilan
    📌 Model: UTV Thor 450 - 2 ilan
    📌 Model: YK150ST-3 - 1 ilan
    📌 Model: YK200-T3 Tract - 22 ilan
    📌 Model: YK250ST-2 - 11 ilan
"""

# Araç türü eşleşme sözlüğü
arac_tur_eslestirme = {
    "otomobil": "Otomobil",
    "arazi-suv-pick-up": "Arazi, SUV & Pickup",
    "elektrik_li-araclar": "Elektrikli Araçlar",
    "motosiklet": "Motosiklet",
    "minivan-van_panelvan": "Minivan & Panelvan",
    "ticari-arac": "Ticari Araçlar",
    "karavan_": "Karavan",
    "atv-utv": "ATV & UTV"
}

arac_turleri = []
arac_markalari = defaultdict(set)
arac_modelleri = defaultdict(lambda: defaultdict(list))

lines = veri.strip().splitlines()

current_tur = None
current_marka = None

for line in lines:
    line = line.strip()

    if line.startswith("🚗 Araç Türü:"):
        url = line.split("https://www.arabam.com/ikinci-el/")[-1].strip()
        tur_key = url.split("/")[0].strip("/")
        current_tur = arac_tur_eslestirme.get(tur_key, tur_key)
        if current_tur not in arac_turleri:
            arac_turleri.append(current_tur)

    elif line.startswith("🔹 Marka:"):
        match = re.match(r"🔹 Marka: (.+?) \(", line)
        if match:
            current_marka = match.group(1)
            arac_markalari[current_tur].add(current_marka)

    elif line.startswith("📌 Model:"):
        match = re.match(r"📌 Model: (.+?) - \d+ ilan", line)
        if match and current_tur and current_marka:
            model_adi = match.group(1)
            arac_modelleri[current_tur][current_marka].append(model_adi)

# Set'leri sıralı listeye çevir
arac_markalari = {k: sorted(list(v)) for k, v in arac_markalari.items()}

# C# formatında yazdırma
print("public static List<string> AracTurleri = new List<string>")
print("{")
for tur in arac_turleri:
    print(f'    "{tur}",')
print("};\n")

print("public static Dictionary<string, List<string>> AracMarkalari = new Dictionary<string, List<string>>")
print("{")
for tur, markalar in arac_markalari.items():
    marka_str = ", ".join(f'"{m}"' for m in markalar)
    print(f'    {{ "{tur}", new List<string> {{ {marka_str} }} }},')
print("};\n")

print("public static Dictionary<string, Dictionary<string, List<string>>> AracModelleri =")
print("    new Dictionary<string, Dictionary<string, List<string>>>")
print("{")
for tur, markalar in arac_modelleri.items():
    print(f'    {{ "{tur}", new Dictionary<string, List<string>>')
    print("        {")
    for marka, modeller in markalar.items():
        model_str = ", ".join(f'"{m}"' for m in modeller)
        print(f'            {{ "{marka}", new List<string> {{ {model_str} }} }},')
    print("        }")
    print("    },")
print("};")
