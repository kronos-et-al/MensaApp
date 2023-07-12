# Graphql API authentication

Each **mutation** query must be authenticated to take affect.

Although **querys**  do NOT need authentication, 
some may need a `client_identifier` to return the wished data.
In these cases `<api key indetifier>` and `<hash>` can just be left _empty_.


## Authentication format
Authentication is done using the [HTTP `Authorization` header](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization).
It must be set to the following:

```
Mensa <base64 of auth info>
```

where `<base64 of auth info>` is a [base 64](https://en.wikipedia.org/wiki/Base64) encoding according to _RFC 3548_ using _padding_ of:

```
<client_id>:<api key identifier>:<hash>
```
This string consists of three parts separated by `:`.
| placeholder            | description                                                                                                   |
| ---------------------- | ------------------------------------------------------------------------------------------------------------- |
| `<client_id>`          | Randomly generated [uuid](https://en.wikipedia.org/wiki/Universally_unique_identifier) identifying the client |
| `<api key indetifier>` | First `10` symbols of an api key. It can be requested from TODO.                                              |
| `<hash>`               | Hash over TODO                                                                                                |