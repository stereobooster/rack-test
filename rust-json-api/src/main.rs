#[macro_use] extern crate nickel;
extern crate rustc_serialize;

use std::collections::BTreeMap;
use nickel::status::StatusCode;
use nickel::{Nickel, JsonBody, HttpRouter, MediaType};
use rustc_serialize::json::{Json, ToJson};

#[derive(RustcDecodable, RustcEncodable)]
struct BlaResponse {
  results: Vec<i32>
}

impl ToJson for BlaResponse {
  fn to_json(&self) -> Json {
      let mut map = BTreeMap::new();
      map.insert("results".to_string(), self.results.to_json());
      Json::Object(map)
  }
}

#[derive(RustcDecodable, RustcEncodable)]
struct BlaRequest {
  name: String
}

impl ToJson for BlaRequest {
  fn to_json(&self) -> Json {
      let mut map = BTreeMap::new();
      map.insert("name".to_string(), self.name.to_json());
      Json::Object(map)
  }
}

fn main() {
    let mut server = Nickel::new();

    server.get("/bla", middleware! { |_, mut response|
        response.set(MediaType::Json);

        let bla = BlaResponse {
            results: vec![1, 2, 3]
        };

        bla.to_json()
    });

    server.post("/bla", middleware! { |request, mut response|
        response.set(MediaType::Json);

        let bla = try_with!(response, {
            request.json_as::<BlaRequest>().map_err(|e| (StatusCode::BadRequest, e))
        });

        bla.to_json()
    });

    server.listen("127.0.0.1:3000").unwrap();
}

