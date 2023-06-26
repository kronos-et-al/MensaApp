#![forbid(unsafe_code)]
#![warn(clippy::pedantic, clippy::nursery, clippy::unwrap_used)]

mod interface;
mod layer;
mod startup;
mod util;


pub fn run_backend() {
    println!("Hello MensaApp!");
}