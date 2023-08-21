# MensaApp-Backend
Backend application for providing and synchronizing meal plan data of the canteens of the Studierendenwerk Karlsruhe [^1].

[^1]: https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/

If you just want to use the (Android, iOS) App, the following is not necessary.

## Running the backend yourself

### Deploy using docker-compose
The easiest way to run the backend is by using [docker compose](https://docs.docker.com/compose/). 
1. Install docker
2. Download the [compose.yaml](compose.yaml?raw=true) file
3. Modify the environment variables and other configurations inside the file accordingly
   1. For the first start you may want to uncomment the `command: --migrate` line to crate the database schema automatically
4. run `docker compose up -d` next to the file

### Deploy using Docker
If you only want to run the backend and want to provide a database by other means, you can run the backend container using:
(Is you use docker compose, this is not necessary!) 
```
docker run -d --name mens-app-backend \
    -p 80:80
    -e DATABASE_URL=postgres://<db user>:<db password>@<db host>/<db port>/<db name>
    -e SMTP_SERVER=<domain of mail server> \
    -e SMTP_PORT=<port of mail server> \
    -e SMTP_USERNAME=<username of mail server> \
    -e SMTP_PASSWORD=<password of mail server> \
    -e ADMIN_EMAIL=<email address admin notofocations should be send to> \
    -e FLICKR_API_KEY=<flickr public api key> \
    ghcr.io/kronos-et-al/mensa-app
```

Running the container requires a postgres database, connection to a mail server and a flickr api key.

### Run the binary
Alternatively, you can also just build yourself and run the binary. See [below](#building-the-backend) for building the backend yourself.

### Environment variables
To pass configuration options to the backend application environment variables are used.
The following options are available:
| Name                    | Description                                                                                                                                                                                                                                                                                    | Default / Required                                                                                                           |
| ----------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------- |
| `LOG_CONFIG`            | Configure which messages are logged. Fore more information on the used syntax, see [here](https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html#directives). You may want to set this to `warn,mensa_app_backend=trace` to enable all messages we produce. | `warn,mensa_app_backend=info`                                                                                                |
| `DATABASE_URL`          | Connection information to for the datebase. Format: `postgres://[<username>[:<password>]@]<host>[:<port>]/<database>`. Must be a [postgresql](https://www.postgresql.org/) database.                                                                                                           | required                                                                                                                     |
| `ADMIN_EMAIL`           | Email address to send notifications to (when images are reported)                                                                                                                                                                                                                              | required                                                                                                                     |
| `SMTP_SERVER`           | Name of SMTP server used for sending emails                                                                                                                                                                                                                                                    | required                                                                                                                     |
| `SMTP_PORT`             | Port of SMTP server                                                                                                                                                                                                                                                                            | `465`                                                                                                                        |
| `SMTP_USERNAME`         | Username to access the SMTP server. Often, this is the email address of the sender.                                                                                                                                                                                                            | required                                                                                                                     |
| `SMTP_PASSWORD`         | Password to access the SMTP server.                                                                                                                                                                                                                                                            | required                                                                                                                     |
| `FULL_PARSE_SCHEDULE`   | [Cron](https://cron.help/)-**like** schedule for when to run a full parsing to get the meal plans for the next three weeks. **A sixth, first _digit_ specifying the seconds is neccessary!**                                                                                                   | `0 0 2 * * *`                                                                                                                |
| `UPDATE_PARSE_SCHEDULE` | Schedule for when to update the melplan for the current day. Same format as `FULL_PARSE_SCHEDULE`                                                                                                                                                                                              | `0 */15 10-15 * * *`                                                                                                         |
| `IMAGE_REVIEW_SCHEDULE` | Schedule for when to check if images still exists at flickr. Same format as `FULL_PARSE_SCHEDULE`                                                                                                                                                                                              | `0 0 2 * * *`                                                                                                                |
| `FLICKR_API_KEY`        | API key from [flickr](https://www.flickr.com/), you can request one [here](https://www.flickr.com/services/api/misc.api_keys.html). Sometimes called public key.                                                                                                                               | required                                                                                                                     |
| `CLIENT_TIMEOUT`        | Timeout in ms for requesting the webpage containing the meal plan.                                                                                                                                                                                                                             | `6000`                                                                                                                       |
| `MENSA_BASE_URL`        | Base URL where meal plans are requested. It excludes the canteens name, which will be appended later on.                                                                                                                                                                                       | `https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/`                                                                   |
| `CANTEENS`              | Comma (`,`) separated list of canteens which should be requested and parsed. These are appended on the `MENSA_BASE_URL`.                                                                                                                                                                       | `mensa_adenauerring,mensa_gottesaue,mensa_moltke,mensa_x1moltkestrasse,mensa_erzberger,mensa_tiefenbronner,mensa_holzgarten` |
| `USER_AGENT`            | [User agent](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent) used for requesting meal plan data. Fore some reason, this can not be empty.                                                                                                                                | `MensaKa <version>`, where `<version>` is the current version of the application (as specified in the rust crate)            |
| `HTTP_PORT`             | Port to listen on for API requests                                                                                                                                                                                                                                                             | `80`                                                                                                                         |



## Building the backend

### Run the backend
You need to install rust and cargo.

- Run `cargo run --bin mensa-app-backend` to build and run the backend.

#### Command line arguments
```
==================================================
   MensaApp Backend v0.1 🥘
==================================================
This binary runs the backend to for the mensa app,
including a graphql server.
For more information,
see https://github.com/kronos-et-al/MensaApp

Licensed under the MIT license.


Available commands:
help      --help -h -?
          shows this page

migrate   --migrate
          runs the database migrations
          before continuing like normal

```

### Graphql mock server
To run a mock version of the graphql server, run `cargo run --bin graphql_mock`.

### Documentation
The documentation can be accessed with `cargo doc --open`.



## Contribution

### First Setup
To compile the backend, you need cargo, you can install it here: https://www.rust-lang.org/tools/install.

For writing rust code, VSCode with the `rust-analyzer` extension is recommended.
It is also recommended to set the `rust-analyzer.check.command` setting to `clippy`

#### Environment Variables
For deployment of the server, initial settings like API tokens and other access information are passed as environment variables.
To make development easier, these can also be defined textually in a `.env` file. A preset with all available options is provided as `.env.default`. The `.env` file is the **only place you can put credentials safely** so that they get not published in the _public_ git repository.

#### Database
If you work on database parts, you need to setup a local dev database first:
1. Setup your environment variable for the database in the `.env` file. The default should be ok when you use the command below for your database.

2. Install docker and run to spun up a database:
    ```bash
    docker run -itd -e POSTGRES_USER=postgres_user -e POSTGRES_PASSWORD=secret_password -e POSTGRES_HOST_AUTH_METHOD=trust -e POSTGRES_DB=mensa_app -p 5432:5432 -v data:/var/lib/postgresql/data --name postgresql postgres
    ```
    This runs a postgres database as a docker container.
    To setup all relations install `cargo install sqlx-cli` and run `cargo sqlx mig run`.

3. If you want to reset the database (because you changed the migrations) run `sqlx database reset`

### Pre-submission checklist

Before submitting changes to the code, you should run
- `cargo fmt` to format all code files.
- `cargo clippy` to check for errors and recommendations.
- `cargo sqlx prepare` if you have changed database queries or migrations. This is to prepare information on these queries so that others can still compile the backend without having a local dev database. See also [sqlx-cli/README.md](https://github.com/launchbadge/sqlx/blob/main/sqlx-cli/README.md#enable-building-in-offline-mode-with-query).
- `cargo test` to make sure all test are ok

### Logging
Whenever an action of importance happens or a silent error occurs (which does not get transported to the next upper layer) a logging message shall get produced.
The following log levels are available:
| level | syntax         | usecase                                                                                                                                                                               |
| ----- | -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| TRACE | `trace!(...);` | Information about things happening in the background like API-Requests or web requests. Enabeling all TRACE messages may result in much noise.                                        |
| DEBUG | `debug!(...);` | More important information than trace but still not always noteworthy. For example, this includes failed api request.                                                                 |
| INFO  | `info!(...);`  | Noteworthy information about the state of the system. This is where the server communicates events like successful startup or mealplan parsing.                                       |
| WARN  | `warn!(...);`  | An error occurred but execution can continue. This includes situations like when a meal could not be resolved and added to the meal plan, but other meals are and will be added fine. |
| ERROR | `error!(...);` | A fatal error which does _may not_ lead to program termination but marks a serious malcondition. This includes failed sending of an email.                                            |


### Testing Coverage

To show test coverage, you need to install `cargo install cargo-tarpaulin`. Then you can run `cargo tarpaulin --out Lcov` to generate coverage info.
to view these information, you can install the VSCode plugin "Coverage Gutters". It should work out of the box with the installed files.



### Build Docker
1. To build the docker container, run `docker build . -t ghcr.io/kronos-et-al/mensa-app:<verion>` where `<version>` is of format `x.y` or `pre_x.y` for pre-releases.
2. To deploy to ghc login using `docker login ghcr.io -u <username> --password-stdin` and provide access token with necessary permission.
3. Publish using `docker push ghcr.io/kronos-et-al/mensa-app:<version>`