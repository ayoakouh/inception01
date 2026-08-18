# Developer Documentation

This document describes how the Inception infrastructure is built and how
to work on it. For end-user instructions (starting the stack, logging in,
etc.), see `USER_DOC.md`.

## 1. Prerequisites

- A Linux virtual machine (this project targets a Debian/Alpine-based
  environment).
- Docker Engine and the Docker Compose plugin installed.
- Basic familiarity with Docker Compose, Dockerfiles, and Linux networking.
- Git.

Verify your Docker installation:
docker --version
docker compose version


## 2. Repository structure

.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs/
├── docker-compose.yml
├── .env # not committed — see section 4
└── requirements/
├── mariadb/
│ ├── Dockerfile
│ ├── conf/
│ └── tools/
├── wordpress/
│ ├── Dockerfile
│ ├── conf/
│ └── tools/
└── nginx/
├── Dockerfile
├── conf/
└── tools/


Each service under `requirements/` is self-contained: its own Dockerfile,
its own configuration files, and its own entrypoint/setup script under
`tools/`.

## 3. Setup

1. Clone the repository.
2. Create `srcs/.env` (see section 4 for required variables).
3. Add a hosts entry for local testing:

127.0.0.1 ayoakouh.42.fr

4. Build and start everything:

make


## 4. Environment variables (`.env`)

`srcs/.env` is read by `docker-compose.yml` and injected into the
containers. It is excluded from Git via `.gitignore`. Required variables
(adapt names to what you actually used):

DOMAIN_NAME=<login>.42.fr

MYSQL_DATABASE=wordpress
MYSQL_USER=wp_user
MYSQL_PASSWORD=<password>
MYSQL_ROOT_PASSWORD=<password>

WP_TITLE=Inception
WP_ADMIN_USER=<non-admin-looking-username>
WP_ADMIN_PASSWORD=<password>
WP_ADMIN_EMAIL=<email>
WP_USER=<second-user>
WP_USER_PASSWORD=<password>
WP_USER_EMAIL=<email>


Sensitive values here should ideally be backed by Docker secrets rather
than plain environment variables for anything touching production;
`.env` is used here for local/evaluation convenience.

## 5. Makefile usage

| Target | Effect |
|---|---|
| `make` / `make up` | Builds images (if needed) and starts the stack (`docker compose up --build -d`) |
| `make down` | Stops and removes containers, keeps volumes/images |
| `make clean` | `down` + removes images and dangling build cache |
| `make fclean` | `clean` + removes named volumes (⚠️ deletes DB/WP data) |
| `make re` | `fclean` + `up` — full rebuild from scratch |
| `make logs` | Tails logs from all services |

Adjust this table to match your actual Makefile targets.

## 6. Docker Compose commands (manual, without Makefile)
Build and start in the background

docker compose -f srcs/docker-compose.yml up --build -d

View running containers

docker compose -f srcs/docker-compose.yml ps

Follow logs for a specific service

docker compose -f srcs/docker-compose.yml logs -f wordpress

Get a shell inside a running container

docker compose -f srcs/docker-compose.yml exec wordpress sh
docker compose -f srcs/docker-compose.yml exec mariadb sh

Stop everything

docker compose -f srcs/docker-compose.yml down

Stop and remove volumes too (data loss)

docker compose -f srcs/docker-compose.yml down -v


## 7. Architecture notes

- **Network:** all three containers share a single custom bridge network
  defined in `docker-compose.yml`. No container uses `network: host`, and
  no `--link` flags are used anywhere. Service discovery relies entirely
  on Docker's embedded DNS (containers resolve each other by service
  name, e.g. `wordpress` connects to MariaDB at `mariadb:3306`).
- **Exposed ports:** only NGINX publishes a port to the host (443).
  WordPress and MariaDB are reachable only from within the Docker network,
  not from the host or outside.
- **Base images:** each Dockerfile starts from a pinned, non-`latest` tag
  of the penultimate stable Alpine or Debian release. No images are pulled
  pre-built from Docker Hub for the three core services — each is built
  from its own Dockerfile.
- **Process model:** each container runs a single foreground process as
  PID 1 (e.g. `nginx -g "daemon off;"`, `php-fpm` in foreground mode,
  `mariadbd`). No background daemons, no `tail -f`, no infinite sleep
  hacks used to keep containers alive artificially — the main service
  process itself is what keeps the container running.
- **Entrypoints:** each service's `tools/` directory contains a setup
  script responsible for first-run initialization (e.g. WordPress's
  script waits for MariaDB to be reachable, then runs `wp core install`
  if not already installed; MariaDB's script initializes the database and
  users on first launch only).

## 8. Data persistence

Two named Docker volumes are declared in `docker-compose.yml`:

- `mariadb_data` → mounted at `/var/lib/mysql` inside the MariaDB
  container, bound on the host at `/home/<login>/data/mariadb`.
- `wordpress_data` → mounted at `/var/www/html` inside the WordPress
  container, bound on the host at `/home/<login>/data/wordpress`.

Verify volume paths:

docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data


The `Mountpoint` field should resolve back to
`/home/<login>/data/...` per the project's persistence requirement.

Because these are named volumes (not stored inside the container's
writable layer), data survives `docker compose down`, container
rebuilds, and VM reboots — as long as you don't run `down -v` or
`make fclean`.

## 9. Debugging tips

- If WordPress can't reach the database: check that the MariaDB
  container is fully initialized before WordPress's entrypoint tries to
  connect (`docker compose logs mariadb`), and confirm both containers
  are on the same custom network (`docker network inspect <network>`).
- If NGINX returns a connection refused/502: confirm php-fpm is listening
  on the port/socket NGINX's config expects (check NGINX's `fastcgi_pass`
  directive against WordPress's php-fpm listen configuration).
- If a rebuild doesn't pick up config changes: Docker layer caching may be
  serving a stale layer — try `docker compose build --no-cache <service>`.
- Inspect a container's environment/mounts directly:

docker inspect <container_name>