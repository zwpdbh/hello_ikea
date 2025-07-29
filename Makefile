# stop_containers: docker stop $(docker ps -q)
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
	export XLA_TARGET="cuda12" && iex --erl "-kernel shell_history enabled" --name hello@127.0.0.1 --cookie some_token -S mix phx.server 

# livebook could be installed using escripts
# after erlang and elixir is installed, just run: 
# mix escript.install hex livebook
run_livebook:
	export LIVEBOOK_HOME=~/code/elixir_programming/hello/documents/livebook && ~/.asdf/installs/elixir/1.18.4-otp-27/.mix/escripts/livebook server

# For cleanup running dockers 
cleanup_pods:
	docker stop $(docker ps -q)

remove_pods:
	docker rm -f $(docker ps -aq)