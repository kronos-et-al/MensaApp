# MensaApp-Frontend

Frontend application for viewing and interacting with meal plan data of the canteens of the
Studierendenwerk Karlsruhe [^1].

[^1]: https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/

## Building

### GraphQL

To generate the dart wrappers from `*.graphql` files run `dart run build_runner build`.

### Tests

### Graphql

To run graphql test, a api endpoint must be specified in an `secret.json` file, an example of which
can be found in `secret.example.env`.
| ⚠️ **Important** | These secrets must AT NO POINT be check in to version control! |
| -- | -- |

Then, you need to specify the files location when running
tests: `flutter test --dart-define-from-file=.\secret.json`