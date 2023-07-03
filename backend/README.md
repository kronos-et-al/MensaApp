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

### Environment Variables
For deployment of the server, initial settings like API tokens and other access information are passed as environment variables.
To make development easier, these can also be defined textually in a `.env` file. A preset with all available options is provided as `.env.default`. The `.env` file is the **only place you can put credentials safely** so that they get not published in the _public_ git repository.

### Databse
Install docker and run:
```bash
docker run -itd -e POSTGRES_USER=postgres_user -e POSTGRES_PASSWORD=secret_password -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=mensa_app -p 5432:5432 -v data:/var/lib/postgresql/data --name postgresql postgres
```
This runs a postgres database as a docker container.
To setup all relations install `cargo install sqlx-cli` and run `cargo sqlx mig run`.