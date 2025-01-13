if (!FALSE) {
  # Quelle des Analyse-Skripts
  source("~/scripts/gemini_analysis.R")
  perform_analysis()
}

API_KEY = Sys.getenv("API_KEY")

cat("\n\nSTART TEST ANALYS\n\n")

# Quelle des Tools für Gemini
source("~/scripts/gemini_tools.R")

# Definiere das Prompt, das an das Modell übergeben wird
prompt <- "
Lies den Text in der Spalte Text und analysiere folgende Aspekte: 
1. **Gerichtstyp**: 
Unterscheide, ob es sich um einen Entscheid eines Oberlandesgerichts (OLG) oder eines Landgerichts (LG) handelt. 
Dies sollte im Text bei der Urteilsangabe erwähnt sein (z. B. OLG, LG). Hier sollen nur die Begriffe OLG und LG extrahiert werden, der Name der Stadt wird nicht benötigt.
2. **Geldbetrag oder Abweisung**: Überprüfe in der Spalte Text, ob im Abschnitt Tenor ein Geldbetrag genannt wird, den der Kläger als Schadensersatz erhält, oder ob die Klage abgewiesen wurde. 
Dies steht zu Beginn des Abschnitts Tenor und wird vor dem Abschnitt Gründe festgelegt. Der Betrag wird in der Regel in Euro ohne Zinsen angegeben (z. B. 25.900 EUR) und steht zu Beginn des Abschnitts Tenor. 
Gebe mir nur den Betrag in Euro aus (z.B. 23542,23 EUR). Falls kein Betrag vorhanden ist und die Klage abgewiesen wurde (hierbei wird im Text vermittelt, dass die Klage des 'Klägers/-in' oder der 'Klagepartei' abgelehnt wurde), 
soll dies als Klage abgewiesen angezeigt werden.
Sollte jedoch in dem Abschnitt Tenor nichts zu die Klage des Klägers bzw. der Klägerin wird abgewiesen oder der Kläger bzw. die Klägerin erhält Anspruch auf Schadensersatz stehen, 
sondern es wird ein anderes Verfahren betrachtet bzw. ein Ablehnungsgesuch der oder des Beklagten wird verworfen, es wird eine Streitwertfestsetzung betrachtet, 
es wird eine Gerichtsstandbestimmung erwähnt oder abgelehnt oder eine Entscheidung des Senats thematisiert, dann gebe dies als Sonstige aus. 
Achte dabei vor allem darauf, ob im Text Streitwertfestsetzung (einschließlich dessen Ablehnung), Ablehnungsgesuch oder Entscheid des Senats thematisiert und ausgeführt wird. 
Dies sind Indizien für die Kategorie 'Sonstige'. Handelt es sich um die Kategorie 'Sonstige', dann gib mit an, woran du dies festgemacht hast.

Gebe mir das Ergebnis im folgenden Format zurück:
[{'Datei': Dateiname; 'Gerichtstyp':'Bestimmung des Gerichtstyps'; 'Urteil':'Ergebnis der Bestimmung des Urteils'}]
"

# Liste für alle Ergebnisse
all_results <- list()

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
  
  # Füge das Ergebnis zur Liste hinzu
  all_results <- append(all_results, list(res))
  
  cat("\n\nFinished processing: ", file, "\n\n")
}

# Speichern der gesamten Ergebnismenge in einer JSON-Datei
output_json <- "/root/output/all_results.json"

# Versuche, alle Ergebnisse in eine einzelne JSON-Datei zu schreiben
try(writeLines(toJSON(all_results, pretty = TRUE), output_json))

cat("\n\nEND TEST ANALYS\n\n")

