.PHONY: run compile

name ?= dc@127.0.0.1

rebar: rebar3

compile: rebar
	./rebar3 compile

run: compile
	erl -pa _build/default/lib/*/ebin \
	-config sys \
	-setcookie dobby_allinone \
	-name ${name} \
	-eval "application:ensure_all_started(dobby_subs)"

rebar3:
	wget -O rebar3 https://s3.amazonaws.com/rebar3/rebar3
	chmod u+x rebar3
