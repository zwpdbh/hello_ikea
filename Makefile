stop_containers:
	docker stop $(docker ps -q)
# FOR DEV LOCALLY
# This will run livebook with db from docker-compose
run_db:
	UID=$(id -u) GID=$(id -g) docker compose -f docker-compose-for-dev.yaml up
	
reset_db:
	mix ecto.reset && MIX_ENV=test mix ecto.reset

kill_erlang_node:
	ps aux | grep "name hello@127.0.0.1" | grep -v grep | awk '{print $$2}' | xargs -r kill -9

run_app:
	make kill_erlang_node
	iex --erl "-kernel shell_history enabled" --name hello@127.0.0.1 --cookie some_token -S mix phx.server 

# This will run a simple livebook and set the working directory inside the container.
# `make run_db` could also be used to start a livebook with a db.
run_livebook:
	docker run \
		-p 8007:8007 \
		-p 8008:8008 \
		-e RELEASE_NODE=hello_livebook \
		-e LIVEBOOK_DISTRIBUTION=name \
		-e LIVEBOOK_COOKIE=some_token \
		-e LIVEBOOK_NODE=livebook@127.0.0.1 \
		-e LIVEBOOK_PORT=8007 \
		-e LIVEBOOK_IFRAME_PORT=8008 \
		-u $(shell id -u):$(shell id -g) \
		-v $(shell pwd)/documents/livebook:/data \
		-w /data \
		ghcr.io/livebook-dev/livebook

# For cleanup running dockers 
cleanup_pods:
	docker stop $(docker ps -q)

remove_pods:
	docker rm -f $(docker ps -aq)