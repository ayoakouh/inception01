*This project has been created as part of the 42 curriculum by ayoub.*

# Inception

## Description
Inception is a project that sets up a complete web infrastructure using Docker. It runs three separate containers, each handling a specific service:

    NGINX – Acts as a secure entry point, handling all HTTPS traffic (TLSv1.2/1.3) on port 443.

    WordPress + php-fpm – Runs the WordPress application without its own web server, relying on NGINX for that.

    MariaDB – Stores and manages WordPress data.

All containers are built from Debian:bookworm (no latest tags) and run in their own isolated environment on a custom Docker network. The setup avoids shortcuts like tail -f or sleep infinity, and data is persisted using Docker volumes mounted on the host at /home/<ayoakouh>/data


# Instructions

### Requirements
- A Linux virtual machine with Docker and Docker Compose installed.
- A `.env` file at the root of `srcs/` (not committed to Git) containing the
  environment variables consumed by `docker-compose.yml` (domain name,
  database name/user/password, WordPress admin credentials, etc.).

### Setup
0. Clone the repository.
1. Add an entry to `/etc/hosts` mapping your login's domain to `127.0.0.1`:
        ##  echo  "127.0.0.1  ayoakouh.42.fr" >> /etc/hosts  ##
2. Create the `.env` file with the required variables (see `DEV_DOC.md`).
3. From the root of the repository, run:
        ##   make   ##
4. This builds all images and starts the stack via `docker compose up
--build -d`.

### Useful commands
- `make down` — stop and remove the containers.
- `make clean` — stop containers and remove images/volumes.
- `make re` — full rebuild from scratch.
- `docker compose -f srcs/docker-compose.yml ps` — check container status.

See `USER_DOC.md` for day-to-day usage and `DEV_DOC.md` for development details.

### Virtual Machines vs Docker
Virtual Machines (VMs) pretend to be a complete computer. Each VM has its own operating system, kernel, and everything. This means they use a lot of memory, storage, and take time to start up. However, they are very secure because they are completely isolated from each other.

Docker containers are different. They share the same operating system (kernel) as the host computer. They only isolate the application itself using special Linux tools. This makes containers:
    Much lighter (use less memory and storage)
    Much faster to start
    Easier to reproduce
The downside is that containers are slightly less secure than full VMs.

Inception uses Docker because each service (NGINX, WordPress, MariaDB) can run as a separate, lightweight container. All three containers run on the same virtual machine and share the same Linux kernel, but they are still isolated from each other.

### Secrets vs Environment Variables
Environment variables are visible in `docker inspect`, in the container's
process environment, and often end up logged or leaked. Docker secrets are
mounted as files inside the container's filesystem (typically under
`/run/secrets/`) and are not exposed through `docker inspect` or the
process environment, which makes them a safer mechanism for sensitive data
such as database passwords or WordPress admin credentials. In this
project, non-sensitive configuration (domain name, service names) is
passed as environment variables, while sensitive values are kept out of
the Git repository via a local `.env` file / Docker secrets

### Docker Network vs Host Network
With `network: host`, a container shares the host's network namespace
directly — no isolation, no per-container IP, and a high risk of port
conflicts. This is explicitly forbidden in this project. A custom Docker
bridge network instead gives every container its own network namespace, IP
address, and access to Docker's embedded DNS server, so containers can
resolve each other by service name (e.g. WordPress reaching MariaDB at
`mariadb:3306`) without publishing any unnecessary ports to the host. Only
NGINX exposes a port (443) to the outside world, which minimizes the
infrastructure's attack surface.

### Docker Volumes vs Bind Mounts
Both methods save data outside the container so it doesn't disappear when the container stops. But they work differently:

Bind Mounts – You link a specific folder on your computer directly into the container. It's simple to set up, but it ties your container to your computer's exact folder structure. If you move the project to another computer, it might break.

Named Volumes – These are managed by Docker itself. You give them a name instead of a path, and Docker stores them in its own special folder. They are:
    More portable (works on any computer)
    Easier to manage with Docker commands like docker volume ls and docker volume inspect

Inception uses named volumes for storing MariaDB and WordPress data. However, the project requires these volumes to be mounted on the host at:
    /home/<ayoakouh>/data/mariadb
    /home/<ayoakouh>/data/wordpress
This way, even if you stop or rebuild the containers, your website data, posts, and database remain safe

## Resources
- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/compose/compose-file/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress + php-fpm documentation](https://wordpress.org/documentation/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- *Docker Deep Dive*, Nigel Poulton
- AI usage: an AI assistant (Claude) was used as a **learning mentor**
  throughout this project — explaining Docker/Linux networking concepts,
  reviewing my understanding of namespaces, volumes, and the container
  lifecycle through Socratic questioning, and helping debug configuration
  issues I described (e.g. container networking, volume mount paths). No
  AI-generated code was copy-pasted directly into the project; all
  Dockerfiles, configuration files, and scripts were written by me based on
  that understanding.