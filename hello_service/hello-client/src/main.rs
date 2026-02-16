use clap::Parser;

pub mod hello {
    tonic::include_proto!("hello");
}

use hello::greeter_client::GreeterClient;
use hello::HelloRequest;

#[derive(Parser)]
#[command(name = "hello-client", about = "gRPC greeter client")]
struct Cli {
    /// Server address
    #[arg(long, default_value = "http://127.0.0.1:50051")]
    addr: String,

    /// Name to greet
    #[arg(long, default_value = "World")]
    name: String,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let cli = Cli::parse();

    let mut client = GreeterClient::connect(cli.addr).await?;

    let request = tonic::Request::new(HelloRequest { name: cli.name });
    let response = client.say_hello(request).await?;

    println!("{}", response.into_inner().message);

    Ok(())
}
