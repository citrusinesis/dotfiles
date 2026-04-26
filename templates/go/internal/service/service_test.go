package service

import "testing"

func TestHealthcheckUsesDefaultServiceName(t *testing.T) {
	response := Healthcheck("")

	if response.Service != "go-service" {
		t.Fatalf("unexpected service name: %s", response.Service)
	}

	if response.Status != "ok" {
		t.Fatalf("unexpected status: %s", response.Status)
	}
}
