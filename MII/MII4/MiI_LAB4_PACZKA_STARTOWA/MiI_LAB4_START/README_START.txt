MiI - LAB 4 - PACZKA STARTOWA
================================
Temat: Sterowanie rozmyte obiektem nieliniowym (silnik obcowzbudny DC).

01_INSTRUKCJA
  MiI_LAB_4.pdf - zadanie LAB 4 (T4).
  MiPI_LAB_4_Material_pomocniczy.pdf - tutorial starszego GUI Fuzzy.

02_MODEL_SILNIKA
  ModelSilnika_MiI2012.mdl - model Simulinka, na ktorym oparto laboratorium.
  silnik.gif - obraz pomocniczy silnika.
  ARCHIWUM/ - starsza wersja .mdl, gdyby potrzebna byla zgodnosc.

03_REGULATORY_FIS
  silnik_fis.fis - Mamdani, 2 wejscia: uchyb i pochodna uchybu, 9 regul.
  silnik_fis2.fis - Mamdani, 2 wejscia: uchyb i calka uchybu, 9 regul.
  Pliki pochodza z przykladu kolegi, nie sa rozwiazaniem referencyjnym prowadzacego.

04_DANE
  M.mat, Wzad.mat - dane zapisane w formacie Simulink SimulationData.Dataset.

05_WYKLADY
  MW6, MW7, MW8 - modelowanie rozmyte, wnioskowanie Mamdaniego i formalne.

06_MATERIALY_DODATKOWE
  Materialy o zmiennych lingwistycznych i wieloobszarowym regulatorze PID.

ZADANIE (wg instrukcji)
  - Zaprojektowac regulator rozmyty sledzacy predkosc katowa silnika.
  - Zmieniac moment oporowy w granicach +/-50%.
  - Uwzglednic ograniczenia amplitudy i szybkosci zmian sterowania.
  - Pokazac regulator i baze regul, zadana predkosc i zaklocenie,
    predkosc, prad wzbudzenia, prad twornika oraz sygnal regulatora.

UWAGI
  - Nie dolaczono katalogow slprj i plikow cache (*.slxc), bo sa generowane automatycznie.
  - Model .mdl i material GUI sa starsze; w nowszych wydaniach MATLAB/Simulink
    moze byc potrzebne dostosowanie blokow i Fuzzy Logic Toolbox.
  - Paczka oparta na archiwum kolegi, nie na nowej oficjalnej paczce LAB 4.
  - To materialy startowe, nie gotowy skrypt realizujacy zadanie.
