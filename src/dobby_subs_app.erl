%%%-------------------------------------------------------------------
%% @doc dobby_subs public API
%% @end
%%%-------------------------------------------------------------------

-module('dobby_subs_app').

-behaviour(application).

%% Application callbacks
-export([start/2
        ,stop/1]).

-define(DEFAULT_DOBBY_NODE, 'dobby@127.0.0.1').

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    try
        connect_to_dobby()
    catch
        throw:Reason ->
            {error, Reason}
    end,
    dobby_subs:start(),
    'dobby_subs_sup':start_link().

stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================

connect_to_dobby() ->
    DobbyNode = application:get_env(dobby_subs, dobby_node,
                                    ?DEFAULT_DOBBY_NODE),
    case net_adm:ping(DobbyNode) of
        pong ->
            lager:info("Connected to dobby node: ~p", [DobbyNode]);
        pang ->
            lager:error("Failed to connect to dobby node: ~p", [DobbyNode]),
            throw({connecting_to_dobby_failed, DobbyNode})
    end.
