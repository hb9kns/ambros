# yargo scratch file for AMBroS

## Konfiguration

Kontrollskript `ambros.sh` muss in Verzeichnis gestartet werden,
das Kanalverzeichnisse enthaelt, und globale Konfigurationsdatei
als Argument erhalten.

Jeder Kanal hat ein eigenes Verzeichnis mit Konfigurationsdatei und
aktuellem Status sowie den SendeTexten. Die benoetigten Quellen sind
implizit dort definiert.

Alle Quellen sind in einem separaten Verzeichnis `textsources` abgelegt.
Jede Quelle hat ein eigenes Verzeichnis mit abgelegten SauberTexten,
benannt nach ihrer Kurzbezeichnung `IDENTIFICATION`.

Verzeichnisstruktur:

- Kanal1
- Kanal2
- KanalN
- textsources
  - Quelle1
  - Quelle2
  - QuelleN

### Kanal

#### Konstanten

- SLICETIME: Zeitscheibenlaenge
- SLICEDEPTH: Anzahl vorauszuberechnender Zeitscheiben
- TOCLENGTH: maximale Laenge [sec] des Inhaltsverzeichnisses
- TOCSLICES: Anzahl Zeitscheiben zwischen Inhaltsverzeichnis-Sendungen
- POSTPROCESSOR: Skript zum Postprozessing: Umlaute, verbotene Woerter, ...
- WPM: Tastgeschwindigkeit (kann durch Rezept oder Prio veraendert werden)
- SOURCES: Liste von IDENTIFICATIONs (Quellen), welche gesendet werden sollen
- PREFIX: Prefix fuer Quelltexte

#### Variablen

- XXXSTATUS: oberste aktuell laufende XXX-Prioritaet (20=PPP, falls keine)

### Quelle

#### Konstanten

- IDENTIFICATION: eindeutiges "Wort" (nur Buchstaben), so kurz wie moeglich,
  wird durch Verzeichnisname definiert
- PRIORITY: Prioritaet P: 10=max, 99=min (kann durch Rezept veraendert werden)
- SOURCE: Quelle (URL, Datei, ...); bei mehreren Quellen erste erfolgreich
  abgerufene, IDENTIFICATION wird dann mit Sub-ID (1,2,...) versehen
- POLLING: Abrufintervall oder -zeit
- RECIPE: Skript zur Verarbeitung
- PERIOD: Sendeperiode (in sec, 0= sofort sobald neue Version)
- MININDEX: minimaler INDEX-Wert (zB 100)
- MAXINDEX: maximaler INDEX-Wert (zB 999, danach wieder MININDEX)
- ERRORRECIPIENT: Fehlermelde-Methode: e-mail, Sendung, Log; optional
  mit Regexp/Textblock fuer Zusatzinfo

#### Variablen

- LASTHASH: Hash oder sonstiger Schluessel auf letzte/aktuelle Version
  (zur Filterung gleicher Quelltexte trotz unterschiedlichem Zeitstempel)
- INDEX: laufende Nummer

## Komponenten

### Zeitmesser

_ok, shellscript_ `src/morse/sniptime`

- Eingabetext auf stdin
- wenn `Laenge>0`: stdout erhaelt in Worte getrennten Text (stdin),
  wobei nach Laenge[sec] (gemaess WpM) Leerzeile eingefuegt wird
- sonst erhaelt stdout Textlaenge[sec] (gemaess WpM) von stdin
- Zeichenlaenge einmalig aus Textdatei ermittelt:

    a .-
    b -...
    ...

### Kontroller (zentrales Skript)

_ok, shellscript_ `src/ambros`

- startet und ueberwacht je Kanal einen `Schneider` und einen `Sendechef`
- ruft Quellen regelmaessig ab mittels `Bereiter`
- Argument: Konfigurationsdatei im Kanalverzeichnis

### Bereiter

_ok, shellscript_ `src/extractor`

- gestartet von `Kontroller`
- holt Rohdaten mit `Sauger` und wandelt sie mittels Rezepten
  in `SauberTexte` um (mit PBL fuer Quellenangaben u Prioritaeten)
- Argumente: Prefix, Reportdatei (feedback), Quellenverzeichnisliste

### Sauger

_ok, shellscript_ `src/fetcher`

- gestartet von `Bereiter`
- holt Rohdaten von Net/Mail/File mit Quellenangabe auf erster Zeile und
  Erstellungszeit auf zweiter Zeile
- Argument: PROTO://SOURCE

### Planer

_shellscript_ `src/planner`

- erstellt `SendeTexte` (formatierte Texte) via Filesystem fuer `Sendechef`,
  basierend auf aktuellem Status und Durchsatzoptimierung
- erzeugt Filenamen aufsteigend je Kanalprefix
- erzeugt Sendeplan zur Uebertragung zu vordefinierten Zeiten
- eine Instanz je Kanalprefix

### Durchsatz-Optimierer

_shellscript_ `src/optimize`

- berechnet beste Anordnung der `SendeTexte` (aus stdin) und gibt sie
  umgestellt wieder aus (stdout)
- stdin&stdout: Liste der Textdateinamen und ihrer jeweiligen Kosten
- Argumente: Dateien mit Kostenfunktions-Parametern und Kanalkonfiguration

### Sendechef

_shellscript_ `scr/sender`

- erzeugt Textstrom fuer `Morser`, meldet Filestatus zurueck an `Planer`
- unterbricht allenfalls bei Eintreffen von XXX (via Filesystem ueber Datei
  mit _Index_ `10..19` im Namen, falls kleiner als aktuell laufendes XXX)
- nimmt je Kanalprefix ersten `SendeText`, verschiebt ihn nach erfolgreicher
  Uebergabe an `Morser` in Papierkorb/Log
- eine Instanz je Kanalprefix

### Morser

- erzeugt A1A-Signal aus Textstrom-Zeichen
- je Kanalprefix nur eine Instanz

## Signale

### SIGDAEMONTERMINATE

- Abbruchsignal
- von ambros.sh
- fuer alle Daemons und Subroutinen

### INT,TERM,STOP

- Abbruchsignal
- von extern
- fuer ambros.sh

### SIGDAEMONRESTART

- Signal zum Neulesen der Konfiguration und Neustart
- von ambros.sh
- fuer alle Daemons und Subroutinen

## Prioritaeten

_0 ist reserviert fuer SendeText, siehe unten_

10..19: XXX (EMERGENCY)
20..29: PPP (URGENT)
30..39: TTT (IMPORTANT)
40..49: RRR (ROUTINE)
50..59: VVV (FILLER)

## Dateiformate

### SauberText

Dateien enthalten zuerst PBL-Zeilen, eine oder mehrere Leerzeilen, anschliessend Textzeilen.
PBL-Zeilen mit anderem als Buchstaben an erster Stelle werden ignoriert (Kommentar).

#### Name: PrefixPrioIndex[Suffix]

- _Prefix_ `_a..z` (Kanalselektor falls mehrere Sendekanaele, `_` fuer alle)
- _Prio_ Zahl `10..99` (`0..9` reserviert)
- _Index_ Ganzzahl (`0[0*]` ist reserviert fuer XXX)
- _Suffix_ `.txt`
- normalerweise im 8.3-Schema PNNMMMMM.YYY, dh Index mindestens bis zu 1E5-1;
  zB `a4000123.txt` (Kanal a, Prio 40, Nr.123)
  oder `_123.txt` (alle Kanaele, Prio 12, Nr.3)

#### PBL-Zeilen (Bezeichner grossgeschrieben)

- `PRIORITY` Prioritaet (10..99, normalerweise nur 10..59)
- `INDEX` Index (Ganzzahl)
- `DECAY` Zerfallszeit [sec] fuer abnehmende Sendewahrscheinlichkeit
- `GENESIS` Erstellungszeit [sec]
- `SOURCE` Quelle (URL)
- `IDENTIFICATION` Kurzbezeichnung (Wort, optional da durch Quelle gegeben)
- `DURATION` Sendedauer [sec] bei angegebener Geschwindigkeit in WPM
- `WPM` Speed [WpM]

`PRIORITY,INDEX` sind identisch zu entsprechenden Teilen des Dateinamens
und deshalb optional; bei Widerspruechen haben sie jedoch Vorrang.
`DURATION,WPM` sind optional, sollten aber vorhanden sein, damit Planung
rascher berechnet werden kann.

#### Beispiel

STANDARD (ROUTINE) von info@example.com, erhalten 2010-12-30,12:34, Zerfallszeit 43200 sec

    PRIORITY	44
    INDEX	123
    DECAY	43200
    GENESIS	201012301234
    SOURCE	mail:info@example.com
    
    == mail: info at example.com = this is a first test for mail input = 73 de example.com +

### SendeText

Format wie SauberText, allenfalls whitespace umformatiert

#### Namen: PrefixPrioIndex[Suffix]

- _Prefix_ `_a..z` (Kanalselektor falls mehrere Sendekanaele, `_` fuer alle)
- _Prio_ `00` __fix__ zur Abgrenzung gegen SauberTexte
- _Index_ Ganzzahl (`[0*]0` ist reserviert fuer XXX)
- _Suffix_ `.txt` oder `.dat`

#### PBL-Zeilen (Bezeichner grossgeschrieben)

wie oben, jedoch _alle optional ausser:_

- `DURATION` Sendedauer [sec]
- `WPM` Speed [WpM]

---

## Morsebroadcast - Plan

(basierend auf plan.txt, 2004/05/23)

Eine unbediente Funkstation sammelt via Web oder PR oder andere Verfahren
(gespeicherte Texte) Texte und Daten, bereitet sie auf und sendet sie in
Morse aus. Sie besteht aus einer Sendestation, einem Rechner mit einem
Skript, Zusatzprogrammen zum Morsen sowie evtl Kommunikationsverbindungen
(Web, PR, lokale Wetterstation).

### Skript:

- laedt regelmaessig bestimmte Webseiten (URLs) und vergleicht sie mit den gepufferten Versionen
- fuer eine bestimmte Zeitscheibe (z.B. 15min oder 30min) wird aus den Webseiten Text zusammengestellt, der nicht laenger zum Morsen benoetigt
- jeder Seite wird eine ID und Versionsnummer ("QTC-Nummer") zugeteilt, die in regelmaessigen Abstaenden in den Text eingebaut (mitgesendet) wird
- evtl werden Stationskennungen und andere Angaben in den Text eingebaut
- zu den vorgegebenen Zeitpunkten wird die Zeit und Stationskennung gesendet
- wenn keine neuen Versionen vorliegen, koennen weniger aktuelle Nachrichten (Hintergrundinfos) gesendet werden
- zu jeder bestimmten Webseite gehoert ein Verarbeitungsmuster, das bestimmt, welche Informationen zum Morsen herausgefiltert werden, welche Prioritaet die Seite aufweist, wie lang ihr Beitrag hoechstens sein darf und wie haeufig sie gesendet werden soll (cfg-Dateien)
- evtl werden vor dem Einfuegen in den Morsestrom weitere Pruefungen angewendet: nur plausible Zeichen? sinnvoller Text? "verbotene Woerter"?
- zur Bestimmung der Morsezeit und zum Morsen dienen separate Programme; Morsen erfolgt bevorzugt ueber ein System wie lpr

### Programm-Erstellung ueber Minimierung einer Kostenfunktion

#### allgemeine Kosten:

- Leerzeit in Zeitscheibe: `q.n=Zeit([Prio.10-59]/Zeitscheibenlaenge)`
- Konstanten in Kostenfunktion: `k.A, k.P, g.(), f.()`

#### Einzelkosten:

- Prioritaet: `P.j=Prio^k.P` mit zB `k.P=2`
- Zerreissen eines Textes: `p.j1=Stueckzahl-1`
- Unterdruecken eines Textes: `p.j2=(unterdrueckt?1:0)`
- Kuerzen eines Textes: `p.j3=100*Kuerzung/Textlaenge`
- Alter relativ zu Sendeintervall: `p.j4=(Alter/Intervall)^k.A` mit zB `k.A=2`

#### Kostenfunktion:

fuer einzelne Zeitscheibe:
`S.n= g.n*q.n + sum.j(P.j*[1+sum.k(f.k*p.jk)])`

mit Gewichtungsfaktoren `g.n` und `f.k`

Total:
`T= sum.n(S.n/n)` mit
n="Unsicherheitsfaktor Zukunft"

#### Ablauf:

- Ziel: Gesamtkosten minimieren
- Startwert: Texte nach Prio aufsteigend und Laenge absteigend angeordnet
- Verfahren: von vorne beginnend umstellen
- Abbruchbedingungen:
  - neuer Text eingetroffen mit hoeherer Prio als vorhanden
  - keine Zeit mehr vor Sendebeginn

---

---

# Archiv / Abfall

## Ideen

### make

- vom Quelltext zum SauberText
- vom SauberText zum SendeText

### MIDI

- [midi1]( http://www.sonicspot.com/guide/midifiles.html )
- [midi2]( http://cs.fit.edu/~ryan/cse4051/projects/midi/midi.html )
- [midi3]( http://faydoc.tripod.com/formats/mid.htm )

---

## Bitmorse (binaer, byteorientiert)

_eventuell unnoetig: direkt normale ASCII-Text waehrend Senden konvertieren_

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

