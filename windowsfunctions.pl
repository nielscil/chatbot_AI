% windowsfuntions.pl

:- use_module(library(swicli)).
:- cli_load_assembly('ChatBotWindowsFunctions').

% questions

win_functions([
	pattern(['Set',star(_),volume,to,star(A)]),
	template(think(set_volume(A,R)),
	positive(['I',set,the,volume,to,R]),
	negative(['I','can''t',set,the,volume]))
]).

win_functions([
	pattern(['Increase',star(_),volume,to,star(A)]),
	template(think(increase_volume(A,R)),
	positive(['I',increased,the,volume,to,R]),
	negative(['I','can''t',increase,the,volume]))
]).

win_functions([
	pattern(['Decrease',star(_),volume,to,star(A)]),
	template(think(decrease_volume(A,R)),
	positive(['I',decreased,the,volume,to,R]),
	negative(['I','can''t',decrease,the,volume]))
]).

win_functions([
	pattern(['Mute',star(_),one_or_zero([volume])]),
	template(think(mute_volume()),
	positive(['I',muted,the,volume]),
	negative(['I','can''t',mute,the,volume]))
]).

win_functions([
	pattern(['Unmute',star(_),one_or_zero([volume])]),
	template(think(unmute_volume()),
	positive(['I',unmuted,the,volume]),
	negative(['I','can''t',unmute,the,volume]))
]).

win_functions([
	pattern([star(_),volume,star(_)]),
	template(['I',can,'set,','increase,','decrease,',mute,and,unmute,the,volume,of,your,computer])
]).


% functions

set_volume([H|_],Return) :- set_volume(H,Return).
set_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.Functions','SetVolume'(X),Return).

increase_volume([H|_],Return) :- increase_volume(H,Return).
increase_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.Functions','IncreaseVolume'(X),Return).

decrease_volume([H|_],Return) :- decrease_volume(H,Return).
decrease_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.Functions','DecreaseVolume'(X),Return).

mute_volume() :- cli_call('ChatBotWindowsFunctions.Functions','Mute'(@true),Return) , Return = @true,!.
unmute_volume() :- cli_call('ChatBotWindowsFunctions.Functions','Mute'(@false),Return), Return = @false,!.