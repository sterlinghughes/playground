mod service;

use tonic::transport::Server;

use hello::greeter_server::GreeterServer;
use service::GreeterService;

pub mod hello {
    tonic::include_proto!("hello");
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let port = std::env::var("PORT").unwrap_or_else(|_| "50051".to_string());
    let addr = format!("0.0.0.0:{port}").parse()?;

    println!("GreeterServer listening on {addr}");

    Server::builder()
        .add_service(GreeterServer::new(GreeterService))
        .serve(addr)
        .await?;

    Ok(())
}
