package service

type HealthcheckResponse struct {
	Service string `json:"service"`
	Status  string `json:"status"`
}

func Healthcheck(serviceName string) HealthcheckResponse {
	if serviceName == "" {
		serviceName = "go-service"
	}

	return HealthcheckResponse{
		Service: serviceName,
		Status:  "ok",
	}
}
