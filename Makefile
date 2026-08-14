COMPOSE = docker compose -f srcs/docker-compose.yml

DATA_DIRS = /home/ayoakouh/data/mariadb /home/ayoakouh/data/wordpress

all: 
	@echo "🔧 Building and 🚀 Starting containers..."
	@sudo mkdir -p /home/ayoakouh/data/mariadb /home/ayoakouh/data/wordpress 
	$(COMPOSE) up --build -d

down:
	@echo "🛑 Stopping containers..."
	$(COMPOSE) down -v

clean: down

fclean: clean
	@echo "🗑  Deleting data directories ..."
	@sudo rm -rf $(DATA_DIRS)

re: fclean all

.PHONY: all build up down clean fclean re