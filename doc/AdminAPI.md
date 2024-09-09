# Admin API
Separate from the main GraphQL API to access data like meal plans, there exists a (minimal) admin REST API for managing image reports (and maybe more in the future).


The API can be accesses by sending requests to `/admin/...`.

## Authetication
The admin API requires HTTP basic auth with the following parameters:

**Username** `admin` \
**Password** set in `ADMIN_KEY` environment variable of backend

## Available Requests

| Type | Path                                   | Request Content | Response                | Description                                                                             |
| ---- | -------------------------------------- | --------------- | ----------------------- | --------------------------------------------------------------------------------------- |
| GET  | `/admin/version`                       | no data         | 200 with version string | Returns the backend version. Can act as a health check.                                 |
| GET  | `/admin/report/delete_image/:image_id` | no data         | 200 on success          | Deletes the image with id `:image_id`                                                   |
| GET  | `/admin/report/verify_image/:image_id` | no data         | 200 on success          | Verifies the image with id `:image_id`. Future image reports will no longer be handled. |
