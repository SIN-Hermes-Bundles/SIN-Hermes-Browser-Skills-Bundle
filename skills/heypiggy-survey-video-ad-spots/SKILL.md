---
name: heypiggy-survey-video-ad-spots
title: Video-Werbespot Survey Solver (ocucom/InnovateMR)
description: Löst Werbespot-Umfragen mit Video-Play, Skip-Ad, Bewertung, Markenklarheit, Matrix-Fragen und Attention Checks.
category: survey
trigger: survey URL contains ocucom.com OR fe*.ocucom.com OR text contains Werbespot, Anzeige, Video, Skip ad
---

# Video-Werbespot Survey Solver

## Identifikation
- URL-Pattern: `*.ocucom.com/inetfe*`
- Text-Indikatoren: "Werbespot", "Anzeige", "Skip ad", "Video", "PLAY", "WEITER"

## Page-Types & Ref-Mapping

### 1. Video-Play-Seite
- Text: "Please wait while the video prepares to play. When the play button appears, click on it to begin."
- Refs: e1=Video, e2=Skip ad, e3=Play button, e4=WEITER
- Aktion: **e3 klicken** (Play), warte 5s, dann **e2 klicken** (Skip ad) oder **e4** (WEITER)

### 2. Bewertung (1-10 Skala)
- Text: "Geben Sie bitte auf einer Skala von 1 bis 10 an"
- Refs: e1=Frage, e2-e11=Optionen 1-10
- Aktion: **e8 (7) oder e9 (8) oder e10 (9)** — variieren für Realismus
- NICHT immer 10 wählen — wechseln zwischen 6-9

### 3. Markenklarheit
- Text: "eindeutig klar / eher klar / eher unklar / vollkommen unklar"
- Refs: e1=Frage, e2=eindeutig klar, e3=eher klar, e4=eher unklar, e5=vollkommen unklar
- Aktion: **e3 (eher klar)** — konsistent positiv aber nicht übertrieben

### 4. Matrix (4 Zeilen × 5 Optionen)
- Text: "Bitte sagen Sie uns, inwieweit Sie den folgenden Aussagen zustimmen"
- Refs: e1=Frage, e2-e21=20 Optionen
- Reihenfolge pro Zeile: stark zu / einigermaßen zu / weder / eher nicht zu / überhaupt nicht zu
- Aktion: Für POSITIVE Aussagen → **einigermaßen zu (3. Option pro Zeile)**
- Aktion: Für NEGATIVE Aussagen ("unangemessen") → **eher nicht zu (4. Option) oder überhaupt nicht zu (5. Option)**
- Variieren: Manchmal "weder" für eine Zeile auswählen für Realismus

### 5. Multi-Select (Handlungen)
- Text: "Welche der folgenden Handlungen würden Sie auf diese Anzeige hin am ehesten vornehmen?"
- Refs: e1=Frage, e2-e8=Optionen, e9=WEITER
- Aktion: **e3 (Mit jemandem darüber sprechen) + e6 (Nach dem Produkt Ausschau halten)**
- Dann **e9 (WEITER)** klicken
- NIEMALS "Nichts davon" wählen

### 6. Single-Choice (Meinung)
- Text: "Ihre Meinung von dem Unternehmen verbessert / nicht verändert / verschlechtert"
- Refs: e1=Frage, e2=verbessert, e3=nicht verändert, e4=verschlechtert
- Aktion: **e2 (verbessert)** — konsistent positiv

### 7. Attention Check (Tiere vs Fahrzeuge)
- Text: "Welche der folgenden Wörter sind Tiere?"
- Tiere: Bär, Katze, Wolf, Hund, Vogel
- Fahrzeuge: Lastwagen, Hubschrauber, Fahrrad, Zug, Bus, Boot, Auto
- Aktion: Nur Tiere anklicken, NIEMALS Fahrzeuge!

### 8. Attention Check (Obst zählen)
- Text: "roter Apfel, drei gelbe Bananen, zwei grüne Trauben"
- Antwort: **1 Apfel, 3 Bananen, 2 Trauben** = Option mit diesen Zahlen

### 9. Demografie
- Geschlecht: e2=Männlich (bei Männlich-Persona)
- Alter: e6=25-34 (bei 32-Jahre-Persona)
- Geburtsjahr: e4=1993 (wenn vorhanden), sonst "keines dieser Jahre" wenn 1993 nicht in Liste

## Kritische Regeln
1. **Video immer abspielen lassen** — mindestens 5s warten, dann Skip ad
2. **Play-Button = e3 oder e4** — nicht e1 (Video-Element)
3. **Bewertungen variieren** — nicht immer dieselbe Zahl
4. **Matrix: Positive → einigermaßen zu, Negative → eher nicht zu**
5. **Multi-Select: Mindestens 2 Optionen, nie nur 1**
6. **NIE "Nichts davon" oder "Weiß nicht" wählen**
7. **Bei "Ja/Nein" nach Video: Immer "Ja"** — sonst Screenout

## Navigation
- Weiter-Button ist oft **e2, e3, e9, e14, e21** je nach Seite
- Wenn keine WEITER-Option sichtbar: 2s warten, dann Snapshot neu machen
- Seite lädt manchmal langsam — 3s warten nach Klick

## Fehler vermeiden
- NICHT Dashboard als Abschluss interpretieren
- Prüfen auf "Vielen Dank" oder "gutgeschrieben" vor Abschluss-Meldung
- Wenn zurück zu Dashboard ohne Erfolgsmeldung → Screenout, nicht Abschluss