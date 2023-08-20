use colored::Colorize;

pub const HELP: &[&str] = &["--help", "-h", "-?"];
pub const MIGRATE: &str = "--migrate";

/// Prints information about the binary and shows available commands.
pub fn print_help() {
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!(
        "{}",
        format!("   MensaApp Backend v{} 🥘  ", env!("CARGO_PKG_VERSION")).green()
    );
    println!(
        "{}",
        "==================================================".bright_black()
    );
    println!("This binary runs the backend to for the mensa app,");
    println!("including a graphql server.");
    println!("For more information, ");
    println!("see {}", env!("CARGO_PKG_REPOSITORY"));
    println!();
    println!("{}", format!("Licensed under the {} license.", env!("CARGO_PKG_LICENSE")).italic());
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

#[cfg(test)]
mod tests {
    use super::print_help;

    #[test]
    fn test_print_cli() {
        print_help();
    }
}
