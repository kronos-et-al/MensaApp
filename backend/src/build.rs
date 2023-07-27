fn main() {
    /// necessary for sqlx migrations
    println!("cargo:rerun-if-changed=migrations");
}