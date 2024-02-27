# Graphql API authentication

Each **mutation** query must be authenticated to take affect.

Although **querys**  do NOT need authentication, 
some may need a `client_identifier` to return the wished data.
In these cases `<api key indetifier>` and `<hash>` can just be left _empty_ or set anyways.


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
| `<client_id>`          | Randomly generated [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) identifying the client |
| `<api key indetifier>` | First `10` symbols of an api key. It can be requested from TODO.                                              |
| `<hash>`               | Base64 of Hash see below                                                                                                |


## Generating the hash
The hash is calculated as an _Sha512_ [HMAC](https://en.wikipedia.org/wiki/HMAC) over the HTTP request body (for normal - non-multipart - requests). 
As key an UTF8 encoding of the api key is used.

### Multipart Requests
For Multipart Requests arising from file Uploads (for `addImage`) the HMAC is only calculated of the body of the request JSON part (with name `operations`). 
For more details on the GraphQL multipart standart see the [spec](https://github.com/jaydenseric/graphql-multipart-request-spec).