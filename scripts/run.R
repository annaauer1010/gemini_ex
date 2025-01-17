if (!FALSE) {
  # Quelle des Analyse-Skripts
  source("~/scripts/gemini_analysis.R")
  perform_analysis()
}

API_KEY = Sys.getenv("API_KEY")

cat("\n\nSTART TEST ANALYSIS\n\n")

# Quelle des Tools für Gemini
source("~/scripts/gemini_tools.R")

# Definiere das Prompt, das an das Modell übergeben wird
prompt = "
Lies den Text in der Spalte **Text** und analysiere folgende Aspekte:  

1. **Gerichtstyp**:  
Unterscheide, ob es sich um einen Entscheid eines Oberlandesgerichts (OLG) oder eines Landgerichts (LG) handelt.  
Dies sollte im Text bei der Urteilsangabe erwähnt sein (z. B. OLG, LG). Hier sollen nur die Begriffe OLG und LG extrahiert werden, der Name der Stadt wird nicht benötigt.  

2. **Urteil**:  
Überprüfe in der Spalte **Text**, ob im Abschnitt **Tenor** ein Geldbetrag genannt wird, den der Kläger als Schadensersatz erhält, oder ob die Klage abgewiesen wurde.  
- Der Betrag wird in der Regel in Euro ohne Zinsen angegeben (z. B. 25.900 EUR) und steht zu Beginn des Abschnitts **Tenor**.  
- Gib nur den Betrag in Euro aus (z. B. 23542,23 EUR).  
- Falls kein Betrag vorhanden ist und die Klage abgewiesen wurde (z. B. der Text erwähnt, dass die Klage des 'Klägers/-in' oder der 'Klagepartei' abgelehnt wurde), gib dies als **Klage abgewiesen** an.  
- Sollte jedoch im Abschnitt **Tenor** nichts zur Klageentscheidung stehen, sondern z. B. eine Streitwertfestsetzung, ein Ablehnungsgesuch, eine Gerichtsstandbestimmung oder eine Entscheidung des Senats thematisiert werden, gib dies als **Sonstige** aus.  
  - Gib bei **Sonstige** zusätzlich an, woran dies festgemacht wurde (z. B. 'Streitwertfestsetzung erwähnt').  

3. **Zusätzliche Features**:  
Extrahiere außerdem folgende zusätzliche Informationen aus dem Text, falls verfügbar:  
   - **Fahrzeugmodell**: Das Modell des im Fall genannten Fahrzeugs (z. B. VW Golf, BMW 3er).  
   - **Streitwert bzw. Klageforderung**: Der im Verfahren genannte Streitwert oder die geforderte Summe.  
   - **Kaufdatum**: Das Datum, an dem das Fahrzeug gekauft wurde (z. B. 15.07.2019).  
   - **Gericht**: Das genaue Gericht, das den Fall behandelt (z. B. Landgericht Stuttgart, Oberlandesgericht München).  
   - **Bundesland**: Das Bundesland, in dem das Gericht liegt (z. B. Baden-Württemberg, Bayern).  
   - **Baujahr**: Suche gezielt nach Hinweisen auf das Baujahr des Fahrzeugs. Das Baujahr wird oft in Form einer Jahreszahl (z. B. 2015) angegeben, die sich auf das Fahrzeug bezieht. Ignoriere Jahreszahlen, die keinen Bezug zum Fahrzeug haben.  
   - **Wiederverkaufswert bzw. Verlust dabei**: Suche nach Hinweisen auf den Wiederverkaufswert oder den Verlust im Zusammenhang mit dem Fahrzeug. Diese Informationen könnten explizit als 'Wiederverkaufswert', 'Restwert' oder als Differenz zwischen Kaufpreis und Verkaufspreis angegeben sein. Wenn der Text nur auf einen Wert hinweist, gib ihn direkt aus. Wenn kein Wert gefunden wird, gib 'Nicht angegeben' zurück.  

Gib das Ergebnis im folgenden Format zurück:  

[
  {
    'Gerichtstyp': 'Bestimmung des Gerichtstyps',
    'Urteil': 'Ergebnis der Bestimmung des Urteils',
    'Fahrzeugmodell': 'Modell des Fahrzeugs',
    'Streitwert/Klageforderung': 'Streitwert oder Klageforderung in EUR',
    'Kaufdatum': 'Datum des Kaufs (TT.MM.JJJJ)',
    'Gericht': 'Name des Gerichts',
    'Bundesland': 'Bundesland des Gerichts',
    'Baujahr': 'Baujahr des Fahrzeugs (z. B. 2015 oder Nicht angegeben)',
    'Wiederverkaufswert/Verlust': 'Wiederverkaufswert oder Verlust in EUR (z. B. 12.500 EUR oder Nicht angegeben)'
  }
]
"

# Alle .txt-Dateien im Verzeichnis '/root/openjur_docs' einlesen
files <- list.files(path = "/root/openjur_docs/", pattern = "*.txt", full.names = TRUE)

# Schleife, um jede Datei zu verarbeiten
for (file in files) {
  # Dateiinhalt lesen
  text <- paste(readLines(file), collapse = "\n")
  
  # Kombiniere das Prompt und den Text
  full_input <- paste(prompt, text)
  
  # Gemini-Prompt ausführen
  res <- run_gemini(full_input, API_KEY, json_mode = TRUE)
  
  # Ergebnis als Liste speichern
  result_entry <- list(
    filename = basename(file), # Nur den Dateinamen
    result = res
  )
  
  # Speichere die Ergebnisse der aktuellen Datei als .Rds
  output_rds <- file.path("/root/output", paste0(tools::file_path_sans_ext(basename(file)), ".Rds"))
  saveRDS(result_entry, output_rds)
  
  cat("\n\nFinished processing and saved to: ", output_rds, "\n\n")
}

cat("\n\nEND TEST ANALYSIS\n\n")


