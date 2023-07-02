# MensaApp-Backend
Backend application for providing and synchronizing meal plan data of the canteens of the Studierendenwerk Karlsruhe [^1].

[^1]: https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/

## Building
- Run `cargo fmt` to format all code files.
- Run `cargo clippy` to check for errors and recommendations.
- Run `cargo run` to build and run the backend.

### Graphql mock server
To run a mock version of the graphql server, run `cargo run --bin graphql_mock`.

### Documentation
The documentation can be accessed with `cargo doc --open`.

## Logging
Whenever an action of importance happens or a silent error occurs (which does not get transported to the next upper layer) a logging message shall get produced.
The following log levels are available:
| level | syntax         | usecase                                                                                                                    |
| ----- | -------------- | -------------------------------------------------------------------------------------------------------------------------- |
| TRACE | `trace!(...);` | Information useful for troubleshooting for developers.                                                                     |
| DEBUG | `debug!(...);` | Information useful for sys admins when troubleshooting.                                                                    |
| INFO  | `info!(...);`  | Information which an administrator might want to see but does not mark something going wrong.                              |
| WARN  | `warn!(...);`  | An error is allowed to occur now and then on some edge cases but has t obe looked after if occurring too often.            |
| ERROR | `error!(...);` | A fatal error which does _may not_ lead to program termination but is so severe that it should never happen in production. |

## First Setup
To compile the backend, you need cargo, you can install it here: https://www.rust-lang.org/tools/install.

For writing rust code, VSCode with the `rust-analyzer` extension is recommended.
It is also recommended to set the `rust-analyzer.check.command` setting to `clippy`
