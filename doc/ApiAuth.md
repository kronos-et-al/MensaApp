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
| `<client_id>`          | Randomly generated [UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier) identifying the client |
| `<api key indetifier>` | First `10` symbols of an api key. It can be requested from TODO.                                              |
| `<hash>`               | Hash see below                                                                                                |


## Generating the hash
A [SHA-512](https://en.wikipedia.org/wiki/SHA-2) hash has to be generated over the following parameters (in that order):

1. Name of mutation query as used in GraphQL (eg. `addUpvote`) as [UTF-8](https://en.wikipedia.org/wiki/UTF-8)
1. Client identifier as the the representation of the uuid (not string)
1. Complete API key as UTF-8
1. Remaining mutation parameters, see below

The resulting hash then gets again encoded as base 64 and can be inserted in the `<hash>` field.

### Mutation parameters
After the api key, (_almost_*) all parameters have to get inserted in the order of their appearance in the graphql schema so that a mutation can not be changed in a meaningful way while keeping the same hash.

Data format:
- **UUIDs** are encoded as their byte representation
- **strings** are encoded as UTF-8
- **integers** are encoded as 32 bit unsigned integer in [_little endian_](https://en.wikipedia.org/wiki/Endianness) byte orderin
- **enums** are encoded as as UTF-8 String as they are named in the graphql schema (eg. `OFFENSIVE`)

The following table gives a overview over the parameters which have to be included:

| mutation         | parameters                                                                                  |
| ---------------- | ------------------------------------------------------------------------------------------- |
| `addUpvote`      | `imageId` as UUID                                                                           |
| `addDownvote`    | `imageId` as UUID                                                                           |
| `removeUpvote`   | `imageId` as UUID                                                                           |
| `removeDownvote` | `imageId` as UUID                                                                           |
| `addImage`       | `mealId` as UUID, `imageUrl` as UTF-8                                                       |
| `setRating`      | `mealId` as UUID, `rating` as 32 bit little endian unsigned integer                         |
| `reportImage`    | `imageId` as UUID, `reason` as UTF-8 string, named like in graphql schema (eg. `OFFENSIVE`) |



| ❗Note                                                                                                     |
| :-------------------------------------------------------------------------------------------------------- |
| As a result, only one mutation can be made in a single graphql query as each mutation needs its own hash. |