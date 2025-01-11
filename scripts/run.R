if (!FALSE) {
  # Quelle des Analyse-Skripts
  source("~/scripts/gemini_analysis.R")
  perform_analysis()
}

if (!FALSE) {
  API_KEY = Sys.getenv("API_KEY")
  
  cat("\n\nSTART TEST ANALYS\n\n")
  
  # Quelle des Tools für Gemini
  source("~/scripts/gemini_tools.R")

  # Alle .txt-Dateien im Verzeichnis '/root/openjur_docs' einlesen
  files <- list.files(path = "/root/openjur_docs/", pattern = "*.txt", full.names = TRUE)

  # Schleife, um jede Datei zu verarbeiten
  for (file in files) {
    # Dateiinhalt lesen
    text <- paste(readLines(file), collapse = "\n")
    
    # Gemini-Prompt ausführen
    res <- run_gemini(text, API_KEY, json_mode = TRUE)
    
    # Ergebnis speichern
    output_json <- paste0("/root/output/", basename(file), "_result.json")
    output_rds <- paste0("/root/output/", basename(file), "_result.Rds")
    
    saveRDS(res, output_rds)
    try(writeLines(toJSON(res), output_json))
    
    cat("\n\nFinished processing: ", file, "\n\n")
  }

  cat("\n\nEND TEST ANALYS\n\n")
}
