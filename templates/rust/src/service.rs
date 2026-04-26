use std::time::Duration;

use reqwest::Client;
use serde::{Deserialize, Serialize};

use crate::error::AppError;

#[derive(Debug, Serialize, Deserialize)]
pub(crate) struct HealthcheckResponse {
    ok: bool,
}

pub(crate) struct ServiceClient {
    base_url: String,
    client: Client,
}

impl ServiceClient {
    pub(crate) fn from_base_url(base_url: String) -> Result<Self, AppError> {
        let client = Client::builder()
            .use_rustls_tls()
            .timeout(Duration::from_secs(10))
            .build()?;

        Ok(Self { base_url, client })
    }

    pub(crate) fn healthcheck_request(&self) -> Result<reqwest::Request, AppError> {
        let url = format!("{}/health", self.base_url.trim_end_matches('/'));
        Ok(self.client.get(url).build()?)
    }

    pub(crate) fn example_response(&self) -> HealthcheckResponse {
        let _ = self;
        HealthcheckResponse { ok: true }
    }
}

#[cfg(test)]
mod tests {
    use super::{HealthcheckResponse, ServiceClient};

    #[test]
    fn builds_healthcheck_request() {
        let client = match ServiceClient::from_base_url("https://example.com".to_owned()) {
            Ok(client) => client,
            Err(error) => panic!("{error}"),
        };

        let request = match client.healthcheck_request() {
            Ok(request) => request,
            Err(error) => panic!("{error}"),
        };

        assert_eq!(request.url().as_str(), "https://example.com/health");
    }

    #[test]
    fn deserializes_healthcheck_response() {
        let response = match serde_json::from_str::<HealthcheckResponse>(r#"{"ok":true}"#) {
            Ok(response) => response,
            Err(error) => panic!("{error}"),
        };

        assert!(response.ok);
    }
}
