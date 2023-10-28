%%%-------------------------------------------------------------------
%% @doc supdls public API
%% @end
%%%-------------------------------------------------------------------

-module(supdls_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    supdls_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
