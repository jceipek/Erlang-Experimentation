#!/usr/bin/env escript
%%! -smp disable +A1 +K true -pa ebin deps/cowboy/ebin -input
-module(cowboy_echo).
-mode(compile).

-export([main/1]).

%% Cowboy callbacks
-export([init/3, handle/2, terminate/2]).


main(_) ->
    Port = 8081,
    application:start(sockjs),
    application:start(cowboy),

    SockjsState = sockjs_handler:init_state(
                    <<"/echo">>, fun service_echo/3, state, []),

    VhostRoutes = [{[<<"echo">>, '...'], sockjs_cowboy_handler, SockjsState},
                   {'_', ?MODULE, []}],
    Routes = [{'_',  VhostRoutes}], % any vhost

    io:format(" [*] Running at http://localhost:~p~n", [Port]),
    cowboy:start_listener(http, 100,
                          cowboy_tcp_transport, [{port,     Port}],
                          cowboy_http_protocol, [{dispatch, Routes}]),
    receive
        _ -> ok
    end.

%% --------------------------------------------------------------------------

init({_Any, http}, Req, []) ->
    {ok, Req, []}.

handle(Req, State) ->
    {Path, Req1} = cowboy_http_req:path(Req),
    {ok, Req2} = case Path of
                     [<<"echo.js">>] ->
                         {ok, Data} = file:read_file("./sim/echo.js"),
                         cowboy_http_req:reply(200, [{<<"Content-Type">>, "application/javascript"}],
                                               Data, Req1);
                     [] ->
                         {ok, Data} = file:read_file("./sim/echo.html"),
                         cowboy_http_req:reply(200, [{<<"Content-Type">>, "text/html"}],
                                               Data, Req1);
                     _ ->
                         cowboy_http_req:reply(404, [],
                                               <<"404 - Nothing here\n">>, Req1)
                 end,
    {ok, Req2, State}.

terminate(_Req, _State) ->
    ok.

%% --------------------------------------------------------------------------


service_echo(_Conn, init, state)        -> {ok, state};
service_echo(Conn, {recv, Data}, state) ->
  io:format("HERE: ~p~n", [Data]),
  Conn:send(Data);
service_echo(_Conn, closed, state)      -> {ok, state}.
