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
	pattern(['Increase',star(_),volume,by,star(A)]),
	template(think(increase_volume(A,R)),
	positive(['I',increased,the,volume,to,R]),
	negative(['I','can''t',increase,the,volume]))
]).

win_functions([
	pattern(['Decrease',star(_),volume,by,star(A)]),
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

win_functions([
	pattern(['Get',star(_),upcoming,appointments]),
	template(['This',are,you,upcoming,'events:\n',think(write_upcoming_events)])
]).

win_functions([
	pattern(['Get',star(_),upcoming,appointments,for,star(A)]),
	template(['This',are,you,upcoming,'events:\n',think(write_upcoming_events(A))])
]).

win_functions([
	pattern(['Show',star(A),upcoming,appointments]),
	template([srai(['Get',A,upcoming,appointments])])
]).

win_functions([
	pattern(['Show',star(A),upcoming,appointments,for,star(B)]),
	template([srai(['Get',A,upcoming,appointments,for,B])])
]).

win_functions([
	pattern(['Show',star(_),calendars]),
	template(['This',are,your,'calendars:\n',think(get_and_write_calendars)])
]).

% functions

set_volume([H|_],Return) :- set_volume(H,Return).
set_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.WindowsFunctions','SetVolume'(X),Return).

increase_volume([H|_],Return) :- increase_volume(H,Return).
increase_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.WindowsFunctions','IncreaseVolume'(X),Return).

decrease_volume([H|_],Return) :- decrease_volume(H,Return).
decrease_volume(X,Return) :- cli_call('ChatBotWindowsFunctions.WindowsFunctions','DecreaseVolume'(X),Return).

mute_volume() :- cli_call('ChatBotWindowsFunctions.WindowsFunctions','Mute'(@true),Return) , Return = @true,!.
unmute_volume() :- cli_call('ChatBotWindowsFunctions.WindowsFunctions','Mute'(@false),Return), Return = @false,!.

get_and_write_calendars() :- get_calendars() , write_calendars().

write_calendars() :- not(current_predicate(calendar/3)), writeln('No calendars found').
write_calendars() :- foreach(calendar(_,Summary,_), write_calendar(Summary)).

write_calendar(Summary) :- write('| ') , write(Summary) , write(' |'), nl.

get_calendars() :- current_predicate(calendar/3).
get_calendars() :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetCalendars',List) , add_calendars($List).

add_calendars($List) :- cli_get($List,'Count',0).
add_calendars($List) :- foreach(cli_col($List,I), add_calendar($I)).

add_calendar($Cal) :- cli_get($Cal,'Summary',Summary) , cli_get($Cal,'Id',Id) , 
					  atom_string(SummaryAtom,Summary) , atom_string(IdAtom,Id) , downcase_atom(SummaryAtom,DSum), asserta(calendar(DSum,SummaryAtom,IdAtom)).
					  
write_upcoming_events() :- get_upcoming_events('primary',List) , write_events($List).
write_upcoming_events(X) :- get_calendars(), atomic_list_concat(X, ' ', XAtom), calendar(XAtom,_,Y) , get_upcoming_events(Y,$List) , write_events($List).

get_upcoming_events(X,$List) :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetUpcomingEvents'(X),List).

write_events($Obj) :- cli_get($Obj,'Count',0) , writeln('No appointments found for today').
write_events($Obj) :- foreach(cli_col($Obj,I), write_event($I)).

write_event($E) :- cli_call($E,'ToString',String), write(String).
write_event(_).

