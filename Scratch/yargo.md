# yargo scratch file

## Ideen

### make

- Quelltext into SauberText
- SauberText into SendeText (Bitmorse)

### MIDI

- [midi1]( http://www.sonicspot.com/guide/midifiles.html )
- [midi2]( http://cs.fit.edu/~ryan/cse4051/projects/midi/midi.html )
- [midi3]( http://faydoc.tripod.com/formats/mid.htm )

---

## Bitmorse (binaer, byteorientiert)

Bit 7 muss gesetzt sein fuer Morsedaten, geloescht fuer Steuerdaten

### Morsedaten

- Bit 7 wird geloescht, dann hoechstes gesetztes Bit gleich Stopbit (erzeugt kein Signal)
- nachfolgende Bits in aufsteigender Folge (dh Beginn beim LSB, Ende beim Stopbit): 0=dit 1=dah, jeweils implizit eine Dit-Pause danach, sowie zusaetzlich zwei Dit-Pausen am Ende
- Verarbeitung durch Rightshift, Ende wenn 1 vom Stopbit erreicht

#### Spezialfaelle (mit Bit 7 bereits geloescht)

- 0 = Zeichen-Pause (drei Dit-Pausen)
- 1 = Wort-Pause (sieben Dit-Pausen)
- 127 (0x7f) = Irrung, dh wird wie 0x100 gesendet (8 dits, Bedeutung waere eigentlich 6 dahs)

### Steuerdaten

- Werte kleiner als 128 (0x80) sind Steuerbefehle, werden stets von Start-Byte (beliebiger Wert) gefolgt und von Stop-Byte abgeschlossen, welches gleichen Wert wie Start-Byte haben muss; dazwischen Argument des Steuerbefehles
- unbekannte Steuerzeichen oder -befehle werden still ignoriert
- 0 = reserviert
- 1 = Tempo in WPM mit 1 Byte Argument, minimal Tempo 1WPM, maximal Tempo 255WPM; "Tempo 0" wird ignoriert, folglich am einfachsten 0 fuer Start-&Stopbyte; *muss* vor ersten Morsedaten gegeben sein, sonst Default-Tempo; Tempo-Basis ist PARIS
- 0x20 .. 0x2F = Kommentar (inkl Argument komplett ignoriert)

---

## Systemkomponenten (Programme)

_Def: URLs fuer Textquellen, Rezepte (RegExp, externe Skripts etc) und Prio fuer Verarbeitung_

### Planer(Def:GlobalKonfig)

- startet und ueberwacht je Kanal einen `Schneider` und einen `Sendechef`
- startet und ueberwacht `Abfuhr`

### Bereiter(Def:Rezepte,Def:Prio,Def:URLs)

- gestartet von `Schneider`
- holt Rohdaten mit `Sauger` und wandelt sie mittels Rezepten in `SauberTexte` um (mit PBL fuer Quellenangaben u Prioritaeten)

### Sauger(Def:URLs)

- gestartet von `Bereiter`
- holt Rohdaten von Net/Mail/File mit Quellenangabe auf erster Zeile, Erstellungszeit auf zweiter Zeile

### Schneider(Filestatus,SauberTexte)

- erstellt `SendeTexte` (formatierte Texte) via Filesystem fuer `Sendechef`, basierend auf aktuellem Status und _Durchsatzoptimierung_
- erzeugt Filenamen aufsteigend je Kanalprefix
- je Kanalprefix nur eine Instanz

### Sendechef(SendeTexte,XXX)

- erzeugt Textstrom fuer `Sender`, meldet Filestatus zurueck an `Schneider`
- unterbricht allenfalls bei Eintreffen von XXX (via Filesystem ueber Datei mit _Index_ `000000` im Namen)
- nimmt je Kanalprefix ersten `SendeText`, loescht ihn nach erfolgreicher Uebergabe an `Sender`
- je Kanalprefix nur eine Instanz

### Sender(Textstrom)

- erzeugt A1A-Signal aus Textstrom-Zeichen
- je Kanalprefix nur eine Instanz

## Prioritaeten

_0 ist reserviert fuer SendeText, siehe unten_

1. XXX
2. XXX2
3. PPP
4. PPP2
5. TTT
6. TTT2
7. ROUTINE
8. ROUTINE2
9. FILLER

## Dateien

### GlobalKonfig

#### Verzeichnisse:

- kanalweise: Konfig, Status, Rezepte, `SendeText`
- quellweise: `SauberText`

### SauberText

Dateien enthalten zuerst PBL-Zeilen, eine oder mehrere Leerzeilen, anschliessend Textzeilen.
PBL-Zeilen mit anderem als Buchstaben an erster Stelle werden ignoriert (Kommentar).

#### Namen: PrefixPrioIndex[Suffix]

- _Prefix_ `a..z` (Kanalselektor falls mehrere Sendekanaele)
- _Prio_ Ziffer `1..9`
- _Index_ Ganzzahl (`0[0*]` ist reserviert fuer XXX)
- _Suffix_ `.txt`
- normalerweise im 8.3-Schema: _PNMMMMMM.YYY_, dh Index mindestens bis zu 1E6-1, zB `a7000123.txt`

#### PBL-Zeilen (Bezeichner gross- oder kleingeschrieben)

- `PRI` Prioritaet (1..9)
- `EXP` Zerfallszeit [sec] fuer abnehmende Sendewahrscheinlichkeit
- `DUR` Dauer [sec], rein informativ (fuer Sendeplanerstellung)
- `TMP` Tempo [WPM], minimal 1, maximal 255
- `GEN` Erstellungszeit [sec]
- `SRC` Quelle (http/file/mail)

#### Beispiel

ROUTINE von info@example.com, erhalten 2010-12-30,12:34, 48 sec lang, Tempo 20 WPM, gueltig (zu senden) bis 2011-2-3,04:05

    PRI 7
    EXP 201102030405
    DUR 48
    TMP 20 wpm
    GEN 201012301234
    SRC mail:info@example.com
    
    == mail: info at example.com = this is a first test for mail input = 73 de example.com +

### SendeText

Bitmorse-Format, dh keine PBL; Tempoinformation muss jedoch enthalten sein

#### Namen: PrefixPrioIndex[Suffix]

- _Prefix_ `a..z` (Kanalselektor falls mehrere Sendekanaele)
- _Prio_ `0` __fix__ zur Abgrenzung gegen SauberTexte
- _Index_ Ganzzahl (`[0*]0` ist reserviert fuer XXX)
- _Suffix_ `.a1a` fuer Bitmorse-Format oder `.dat`

---

# [sourceforge]

Eine unbediente Funkstation sammelt via Web oder PR oder andere Verfahren
(gespeicherte Texte) Texte und Daten, bereitet sie auf und sendet sie in
Morse aus. Sie besteht aus einer Sendestation, einem Rechner mit einem
Skript, Zusatzprogrammen zum Morsen sowie evtl Kommunikationsverbindungen
(Web, PR, lokale Wetterstation).

### Skript

* lÃ¤dt regelmÃ¤ssig bestimmte Webseiten (URLs) und vergleicht sie mit den gepufferten Versionen
* fÃ¼r eine bestimmte Zeitdauer (z.B. 15min oder 30min) wird aus den Webseiten Text zusammengestellt, der nicht lÃ¤nger zum Morsen benÃ¶tigt
* jeder Seite wird eine ID und Versionsnummer ("QTC-Nummer") zugeteilt, die in regelmÃ¤ssigen AbstÃ¤nden in den Text eingebaut (mitgesendet) wird
* evtl werden Stationskennungen und andere Angaben in den Text eingebaut
* zu den vorgegebenen Zeitpunkten wird die Zeit und Stationskennung gesendet
* wenn keine neuen Versionen vorliegen, kÃ¶nnen weniger aktuelle Nachrichten (Hintergrundinfos) gesendet werden
* zu jeder bestimmten Webseite gehÃ¶rt ein Verarbeitungsmuster, das bestimmt, welche Informationen zum Morsen herausgefiltert werden, welche PrioritÃ¤t die Seite aufweist, wie lang ihr Beitrag hÃ¶chstens sein darf und wie hÃ¤ufig sie gesendet werden soll (cfg-Dateien)
* evtl werden vor dem EinfÃ¼gen in den Morsestrom weitere PrÃ¼fungen angewendet: nur plausible Zeichen? sinnvoller Text? "verbotene WÃ¶rter"?
* zur Bestimmung der Morsezeit und zum Morsen dienen separate Programme; Morsen erfolgt bevorzugt Ã¼ber ein System wie lpr

### Konfigurationsdateien

* Quelle (URL, Datei, ...), AbrufhÃ¤ufigkeit oder -zeit (crontab?)
* Programm (lynx, wvText, ...) zum PrÃ¤prozessing
* Programm/Skript zum Postprozessing (Umlaute, verbotene WÃ¶rter, ...)
  (optional)
* TextblÃ¶cke: Name; Anfangs-&Ende-Regexp als s///-Pattern, mehrzeilig = eine oder mehrere Regexp, die alle erfÃ¼llt sein mÃ¼ssen;
  Abbruchanweisungen, wenn Regexp misslingen: ignorieren des Blockes (warn) oder ignorieren des ganzen Textes (fatal)
  oder (wenn Ende-Regexp misslingt) Rest Ã¼bernehmen
* Minimal-&MaximallÃ¤nge, wenn unter/Ã¼berschritten, ganzer Text ignoriert (fatal) oder abgeschnitten (warn)
  (optional)
* SendehÃ¤ufigkeit (absolut/sofort wenn neu) und PrioritÃ¤t
  (optional)
* Ausgabeformular: Textblocknamen, verbatim-Text, Programm-Variablen (QTR, QTC, ...)
* Fehlermelde-Methode: e-mail, Sendung, Log; inkl Regexp/Textblock fÃ¼r Zusatzinfo
  (optional)


---

# mailwork/plan.txt

Morsebroadcast - Plan
=====================
($Id: plan.txt,v 1.1.1.1 2004/05/23 20:14:54 yargo Exp $)

1. System
---------

Eine unbediente Funkstation sammelt via Web oder PR oder andere Verfahren
(gespeicherte Texte) Texte und Daten, bereitet sie auf und sendet sie in
Morse aus. Sie besteht aus einer Sendestation, einem Rechner mit einem
Skript, Zusatzprogrammen zum Morsen sowie evtl Kommunikationsverbindungen
(Web, PR, lokale Wetterstation).

1.1 Skript:

* lädt regelmässig bestimmte Webseiten (URLs) und vergleicht sie mit
den gepufferten Versionen
* für eine bestimmte Zeitscheibe (z.B. 15min oder 30min) wird aus den
Webseiten Text zusammengestellt, der nicht länger zum Morsen benötigt
* jeder Seite wird eine ID und Versionsnummer ("QTC-Nummer") zugeteilt,
die in regelmässigen Abständen in den Text eingebaut (mitgesendet) wird
* evtl werden Stationskennungen und andere Angaben in den Text eingebaut
* zu den vorgegebenen Zeitpunkten wird die Zeit und Stationskennung gesendet
* wenn keine neuen Versionen vorliegen, können weniger aktuelle
Nachrichten (Hintergrundinfos) gesendet werden
* zu jeder bestimmten Webseite gehört ein Verarbeitungsmuster, das
bestimmt, welche Informationen zum Morsen herausgefiltert werden, welche
Priorität die Seite aufweist, wie lang ihr Beitrag höchstens sein darf
und wie häufig sie gesendet werden soll (cfg-Dateien)
* evtl werden vor dem Einfügen in den Morsestrom weitere Prüfungen
angewendet: nur plausible Zeichen? sinnvoller Text? "verbotene Wörter"?
* zur Bestimmung der Morsezeit und zum Morsen dienen separate Programme;
Morsen erfolgt bevorzugt über ein System wie lpr

1.2 Zusatzprogramme:

* Morseprogramm (asynchron)
* Morsezeitprogramm (Bestimmung der Zeit zum Morsen eines Textes)
* Textladeprogramme (lynx, cat, XML-Interpreter...)

2. ToDo
-------

2.1 Quellen:

Copyrights? Kontaktpersonen?

* SG Tagblatt: Reto
* Slashdot
* SWISSTXT
* www.uska.ch
* SMA
* www.spaceweather.com
* stratfor.com

3. Entwurf Konfigurationsdateien
--------------------------------

3.1 allgemein:

* Zeitscheibenlänge
* Anzahl vorauszuberechnender Zeitscheiben

3.2 textspezifisch:

* Priorität P: 1=max, 3=min
* Def. Quelle (URL, Datei, ...), Abrufhäufigkeit oder -zeit (crontab?)
* Def. Programm (lynx, wvText, ...) zum Präprozessing
* Def. Programm/Skript zum Postprozessing (Umlaute, verbotene Wörter, ...)
  (optional)
* Def. Textblöcke: Name; Anfangs-&Ende-Regexp als s///-Pattern, mehrzeilig =
  eine oder mehrere Regexp, die alle erfüllt sein müssen;
  Abbruchanweisungen, wenn Regexp misslingen: ignorieren des Blockes (warn)
  oder ignorieren des ganzen Textes (fatal)
  oder (wenn Ende-Regexp misslingt) Rest übernehmen
* Minimal-&Maximallänge, wenn unter/überschritten, ganzer Text ignoriert
  (fatal) oder abgeschnitten (warn)
  (optional)
* Sendefreq (0= sofort wenn neu)
* Ausgabeformular: Textblocknamen, verbatim-Text, Programm-Variablen (QTR,
  QTC, ...)
* Fehlermelde-Methode: e-mail, Sendung, Log;
  inkl Regexp/Textblock für Zusatzinfo
  (optional)

4. Programm-Erstellung
----------------------

erfolgt über Minimierung einer Kostenfunktion

4.1 allgemeine Kosten:

* Leerzeit in Zeitscheibe: q_j=Leerzeit/Zeitscheibenlänge

4.2 Einzelkosten:

* Priorität: P_j=2/(2^Prio)
* Zerreissen eines Textes: p_j1=Stückzahl-1
* Unterdrücken eines Textes: p_j2=(unterdrückt?1:0)
* Kürzen eines Textes: p_j3=Kürzung/Textlänge
* Alter relativ zu Sendefrequenz: p_j4=(freq*Alter)^2

4.3 Kostenfunktion:

für einzelne Zeitscheibe:
S= sum_j(g_j*q_j) + sum_j(P_j*[1+sum_k(f_k*p_jk)])

Gesamtkosten= sum_n(S_n/n)
n="Unsicherheitsfaktor Zukunft"

Ziel: Gesamtkosten minimieren

