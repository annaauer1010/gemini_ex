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
[...]  
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


