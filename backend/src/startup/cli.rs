use colored::Colorize;

pub const HELP: &[&str] = &["--help", "-h", "-?"];
pub const MIGRATE: &str = "--migrate";

pub fn print_help() {
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!("{}", "   MensaApp Backend v0.1 🥘  ".green());
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!("This binary runs the backend to for the mensa app,");
    println!("including a graphql server.");
    println!("For more information, ");
    println!("see https://github.com/kronos-et-al/MensaApp");
    println!();
    println!("{}", "Licensed under the MIT license.".italic());
    println!();
    println!();
    println!("{}", "Available commands:".blue());
    println!(
        "{}      {}",
        "help".bold(),
        HELP.join(" ").as_str().bright_black()
    );
    println!("          shows this page");
    println!();
    println!("{}   {}", "migrate".bold(), MIGRATE.bright_black());
    println!("          runs the database migrations");
    println!("          before continuing like normal");
    println!();
}
