use tonic::{Request, Response, Status};

use crate::hello::greeter_server::Greeter;
use crate::hello::{HelloReply, HelloRequest};

pub struct GreeterService;

pub fn format_greeting(name: &str) -> String {
    if name.is_empty() {
        "Hello, World!".to_string()
    } else {
        format!("Hello, {}!", name)
    }
}

#[tonic::async_trait]
impl Greeter for GreeterService {
    async fn say_hello(
        &self,
        request: Request<HelloRequest>,
    ) -> Result<Response<HelloReply>, Status> {
        let name = &request.into_inner().name;
        let message = format_greeting(name);
        Ok(Response::new(HelloReply { message }))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_greeting() {
        assert_eq!(format_greeting("Alice"), "Hello, Alice!");
    }

    #[test]
    fn test_format_greeting_empty() {
        assert_eq!(format_greeting(""), "Hello, World!");
    }

    #[tokio::test]
    async fn test_say_hello_rpc() {
        let service = GreeterService;
        let request = Request::new(HelloRequest {
            name: "Tonic".to_string(),
        });
        let response = service.say_hello(request).await.unwrap();
        assert_eq!(response.into_inner().message, "Hello, Tonic!");
    }
}
