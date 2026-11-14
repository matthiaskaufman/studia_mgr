CEM + NES (projekt 15) - PAKIET WYODREBNIONY Z DYSKU KOLEGI
============================================================

ZAKRES:
Cross-Entropy Method (CEM) i Natural Evolution Strategies (NES).
Projekt nr 15 z instrukcji "2026_Optymalizacja_projekt.pdf".

ZAWARTOSC:
01_INSTRUKCJA/
  2026_Optymalizacja_projekt.pdf
  - instrukcja przekazana przez uzytkownika w tej rozmowie (nie pochodzi z dysku kolegi).

02_KOD_ZRODLOWY/
  01_Z_OGRANICZENIAMI/
    - kompletna wersja z galezi Git 'main', obejmuje funkcje kary i ograniczenia.
    - kod CEM i NES, funkcje testowe, kryteria stopu, pseudokody, README,
      wymagania oraz 18 zachowanych wykresow z eksperymentow.
  02_BEZ_OGRANICZEN/
    - kompletna wersja z galezi Git 'Bez-kary'.
    - kod CEM i NES, funkcje testowe, kryteria stopu, pseudokody,
      wymagania oraz 36 zachowanych wykresow (w tym z galezi main).

03_RAPORT/
  Raport_CEM_NES_metody_optymalizacji.docx

04_PREZENTACJA/
  Prezentacja_CEM_NES_v2.pptx

05_ORIGINALNE_ARCHIWUM/ [TYLKO W WERSJI PELNEJ]
  Projekt-Metody-Optymalizacji.rar
  - oryginalne archiwum z dysku kolegi, bez zmian. Zawiera historie Git,
    obie galezie oraz jego wirtualne srodowisko .venv.

ZRODLO:
  Dysk kolegi: drive-download-20261108T073302Z-1-001.zip
  (wybrane: .rar + .docx + .pptx).
  Zadania projektu: PDF przeslany w tej rozmowie.

JAK URUCHOMIC:
  1. Zainstaluj Python z pakietami numpy i matplotlib.
  2. Wejdz do folderu wybranego wariantu w 02_KOD_ZRODLOWY.
  3. W terminalu uruchom: python main.py
  4. Wykresy sa zapisywane w folderze 'raport_wykresy' lub
     'raport_wykresy_bez_kar' zalezne od wybranej wersji.

UWAGI:
  - Nie zmieniono kodu kolegi. Obie wersje odtworzono z historii Git
    zawartej w oryginalnym RAR.
  - requirements.txt pochodzi ze srodowiska kolegi; zapisano go
    w oryginalnym kodowaniu UTF-16. Do uruchomienia skryptow
    z importow wynikaja zaleznosci numpy i matplotlib.
  - Statycznie sprawdzono skladnie .py, NIE wykonywano pełnych eksperymentow.
  - Raport i prezentacja moga opisywac wersje z innego terminu; aktualna
    instrukcje traktuj jako nadrzedna, a projekt kolegi jako przyklad.
  - Nie kopiuj katalogu .venv do nowego systemu jako gotowego srodowiska;
    lepiej utworzyc swoje virtualenv i zainstalowac pakiety.

WERSJE PACZKI:
  CEM_NES_PROJEKT_15_PELNA.zip  - wszystko powyzej wraz z oryginalnym RAR.
  CEM_NES_PROJEKT_15_LEKKA.zip  - bez RAR, z kodem obu wersji i wykresami.
