# MensaApp-Backend
Backend application for providing and synchronizing meal plan data of the canteens of the Studierendenwerk Karlsruhe [^1].

[^1]: https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/

## Building
- Run `cargo fmt` to format all code files.
- Run `cargo clippy` to check for errors and recommendations.
- Run `cargo run` to build and run the backend.

### Documentation
The documentation can be accessed with `cargo doc --open`.


## First Setup
To compile the backend, you need cargo, you can install it here: https://www.rust-lang.org/tools/install.

For writing rust code, VSCode with the `rust-analyzer` extension is recommended.
It is also recommended to set the `rust-analyzer.check.command` setting to `clippy`
