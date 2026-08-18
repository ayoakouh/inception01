# User Documentation
This document explains how to start, stop, and use the Inception
infrastructure as an end user or administrator. For technical/development
details, see `DEV_DOC.md`.

## 1. Starting the stack
From the root of the repository:
    ## make ##

This builds the Docker images (if needed) and starts all containers
(NGINX, WordPress, MariaDB) in the background.

Wait a few seconds for MariaDB and WordPress to finish initializing before
opening the site.

## 2. Stopping the stack

To stop the containers without deleting data:
    ## make down ##

Your database and WordPress files remain untouched — they live in Docker
volumes on the host, not inside the containers.

To stop the containers **and** remove images/volumes (full reset, data
loss):    ## make clean ##

## 3. Accessing the website
1. Add an entry to `/etc/hosts` mapping your login's domain to `127.0.0.1`:
        ##  echo  "127.0.0.1  ayoakouh.42.fr" >> /etc/hosts  ##
2. Open a browser and go to :  "https://ayoakouh.42.fr"
3. Your browser will warn you about the certificate — this is expected,
   since it's a self-signed TLS certificate, not one issued by a public
   Certificate Authority. Accept the warning to continue ("Advanced" →
   "Proceed anyway", wording depends on your browser).
4. Note: the site is **only** reachable over HTTPS (port 443).
   `http://ayoakouh.42.fr` will not work — this is intentional.

## 4. Accessing the WordPress admin panel

1. Go to:  https://ayoakouh.42.fr/wp-admin
2. Log in with the administrator account.
   - **Username:** `<admin-username>` (see note below)
   - **Password:** stored in your local `.env` file / secrets — not
     published in this repository.
> **Note:** The admin username intentionally does **not** contain "admin"
> (e.g. it is not `admin`, `administrator`, `Admin-<login>`, etc.), per
> the project's security requirements.
From the admin dashboard you can:
- Edit pages and posts.
- Manage a second, non-administrator WordPress user (able to comment/publish
  as a regular author).
- Update site settings.

## 5. Managing credentials
All credentials (database name/user/password, WordPress admin
credentials) are defined in a local `.env` file at `srcs/.env`, which is
**not** committed to Git.

To change a credential:
1. Edit the value in `srcs/.env`.
2. Rebuild the stack so the change takes effect:  "make re "
If you lose the admin password, you can reset it directly via the MariaDB
container (see `DEV_DOC.md` for database access instructions).

## 6. Basic health checks
Check that all three containers are running: "docker compose -f srcs/docker-compose.yml ps"
You should see three containers (`nginx`, `wordpress`, `mariadb`) with a
status of `Up`.
Check container logs if something looks wrong:
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb

Check that data persists after a reboot:
1. Reboot the VM.
2. Run `make` again.
3. Confirm the website still shows your previous changes (posts, pages,
   comments) — this proves data is stored in persistent volumes, not
   inside the (ephemeral) containers.

## 7. Common issues
| Symptom | Likely cause |
|---|---|
| Browser can't reach `https://<login>.42.fr` | `/etc/hosts` entry missing, or containers not running |
| Certificate warning | Expected — self-signed cert, not a bug |
| "Error establishing a database connection" | MariaDB container not ready yet, or wrong credentials in `.env` |
| Blank page / 502 error | WordPress (php-fpm) container not running or NGINX misconfigured |
