# 🥘 MensaApp

[![Build-Android](https://github.com/kronos-et-al/MensaApp/actions/workflows/main.yml/badge.svg)](https://github.com/kronos-et-al/MensaApp/actions/workflows/main.yml) [![Build-Rust](https://github.com/kronos-et-al/MensaApp/actions/workflows/rust.yml/badge.svg)](https://github.com/kronos-et-al/MensaApp/actions/workflows/rust.yml) ![License](https://badgen.net/github/license/kronos-et-al/MensaApp) ![version](https://badgen.net/github/release/kronos-et-al/MensaApp) ![stars](https://badgen.net/github/stars/kronos-et-al/MensaApp)

**Application for communication and collective exchange of
menu information in university catering facilities.**

| 🚧        | This project is still in a very early state and WIP!       |
|------------|:-----------------------------------------------------------|


The goal of this application is to provide easy access to the meal plans of the canteens of the [Studierendenwerk Karlsruhe](https://www.sw-ka.de/de/hochschulgastronomie/speiseplan) providing an android (iOS also planned) app and also a GraphQL API. Additionaly, users should be able to rate meals and add images to get a better idea about the meals at hand.


This application consists of a [Flutter](https://flutter.dev/) app (see [app](app/README.md)) and a [Rust](https://www.rust-lang.org/) server (see [backend](backend/README.md)).
They communicate using a [GraphQL](https://graphql.org/) API and the backend stores its data in a [PostgreSQL](https://www.postgresql.org/) database.


## Licence
This application is available under the MIT license, see [LICENSE](LICENSE).

## Contribution
TBD.
