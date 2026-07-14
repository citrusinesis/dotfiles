package main

import (
	"encoding/json"
	"log"
	"os"

	"example.com/go-service/internal/service"
)

//nolint:unused // Populated through ldflags for future version reporting.
var version = "unknown"

func main() {
	response := service.Healthcheck(os.Getenv("SERVICE_NAME"))

	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")

	if err := encoder.Encode(response); err != nil {
		log.Fatal(err)
	}
}
