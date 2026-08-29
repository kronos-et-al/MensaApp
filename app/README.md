# MensaApp-Frontend

Frontend application for viewing and interacting with meal plan data of the canteens of the
Studierendenwerk Karlsruhe [^1].

[^1]: https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/

## Building

### GraphQL

To generate the dart wrappers from `*.graphql` files run `dart run build_runner build`.

## Tests

### GraphQL Code Generation

To generate the Dart wrappers from `*.graphql` files, run the following command:

```bash
flutter run build_runner build
```

This will create the necessary `*.graphql.dart` files in the `lib/model/api_server/requests/`
directory.

