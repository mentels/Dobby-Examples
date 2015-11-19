%%%-------------------------------------------------------------------
%% @doc dobby_subs public API
%% @end
%%%-------------------------------------------------------------------

-module(dobby_subs).

%% Application callbacks
-export([start/0,
         subcribe_for_message_via_id/1,
         unsubscribe/1,
         send_message_via_id/2]).

%%====================================================================
%% API
%%====================================================================

start() ->
    global:sync(),
    dby:install(?MODULE).

subcribe_for_message_via_id(Id) ->
    Opts = [breadth,
            {max_depth, 0},
            message,
            {delivery, delivery_fn(self())}],
    dby:subscribe(search_fn(), [], Id, Opts).

unsubscribe(SubId) ->
    dby:unsubscribe(SubId).

send_message_via_id(Id, Msg) when is_binary(Msg) ->
    dby:publish(<<"PUB">>, {Id, [{<<"msg">>, Msg}]}, []).

%%====================================================================
%% Internal functions
%%====================================================================

search_fn() ->
    fun(_Id, #{<<"msg">> := #{value := Msg}}, [], _) ->
            {continue, Msg};
       (_, _, _, Acc) ->
            {continue, Acc}
    end.

delivery_fn(Pid) ->
    fun(Msg) ->
            Pid ! {subs_msg, Msg},
            ok
    end.
