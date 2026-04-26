mod error;
mod service;

use std::env;

use dotenvy::dotenv;
use service::ServiceClient;

#[tokio::main]
async fn main() -> Result<(), error::AppError> {
    let _ = dotenv();

    let base_url =
        env::var("SERVICE_BASE_URL").unwrap_or_else(|_| "https://example.com".to_owned());
    let client = ServiceClient::from_base_url(base_url)?;
    let request = client.healthcheck_request()?;
    let payload = serde_json::to_string(&client.example_response())?;

    println!("template ready for {}", request.url());
    println!("{payload}");

    Ok(())
}
