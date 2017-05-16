% windowsfuntions.pl

:- use_module(library(swicli)).
:- cli_load_assembly('ChatBotWindowsFunctions').

% questions

win_functions([
	pattern([star(_),'Set',star(_),volume,to,star(A)]),
	template(think(set_volume(A,R)),
	positive(['I''ve',set,the,volume,to,R]),
	negative(['I','can''t',set,the,volume]))
]).

win_functions([
	pattern([star(_),'Increase',star(_),volume,by,star(A)]),
	template(think(increase_volume(A,R)),
	positive(['I',increased,the,volume,to,R]),
	negative(['I','can''t',increase,the,volume]))
]).

win_functions([
	pattern([star(_),'Decrease',star(_),volume,by,star(A)]),
	template(think(decrease_volume(A,R)),
	positive(['I',decreased,the,volume,to,R]),
	negative(['I','can''t',decrease,the,volume]))
]).

win_functions([
	pattern([star(_),'Mute',star(_),one_or_zero([volume])]),
	template(think(mute_volume()),
	positive(['I',muted,the,volume]),
	negative(['I','can''t',mute,the,volume]))
]).

win_functions([
	pattern([star(_),'Unmute',star(_),one_or_zero([volume])]),
	template(think(unmute_volume()),
	positive(['I',unmuted,the,volume]),
	negative(['I','can''t',unmute,the,volume]))
]).

win_functions([
	pattern([star(_),volume,star(_)]),
	template(['I',can,'set,','increase,','decrease,',mute,and,unmute,the,volume,of,your,computer])
]).

win_functions([
	pattern([star(_),'Get',star(_),upcoming,appointments]),
	template(['This',are,your,upcoming,'appointments:\n',think(write_upcoming_events)])
]).

win_functions([
	pattern([star(_),'Show',star(A),upcoming,appointments]),
	template([srai(['Get',A,upcoming,appointments])])
]).

win_functions([
	pattern([star(_),'Show',star(A),upcoming,appointments,for,star(B)]),
	template([srai(['Get',A,upcoming,appointments,for,B])])
]).

win_functions([
	pattern([star(_),'Show',star(_),appointments,for,a,specific,calendar]),
	template([think(write_events_for_calendar)])
]).

win_functions([
	pattern([star(_),'Show',star(_),appointments,for,star(B)]),
	template(['This',are,your,appointments,for,B,':\n',think(write_events(B,['']))])
]).

win_functions([
	pattern(['Show',star(_),calendars]),
	template(['This',are,your,'calendars:\n',think(get_and_write_calendars)])
]).

win_functions([
	pattern(['Get',star(A),calendars]),
	template([srai(['Show',A,calendars])])
]).

win_functions([
	pattern([star(_),create,a,new,appointment]),
	template([think(create_event())])
]).

win_functions([
	pattern([star(_),show,star(_),unread,mail]),
	template([here,is,your,'mail: \n',think(get_and_write_mail(@true))])
]).

win_functions([
	pattern([star(A),get,star(B),unread,mail]),
	template([srai([A,show,B,unread,mail])])
]).

win_functions([
	pattern([star(_),show,star(_),mail]),
	template([here,is,your,'mail: \n',think(get_and_write_mail(@false))])
]).

win_functions([
	pattern([star(A),get,star(B),mail]),
	template([srai([A,show,B,mail])])
]).

win_functions([
	pattern([star(_),reply,star(_)]),
	that([here,is,your,'mail: \n']),
	template([think(reply)])
]).

win_functions([
	pattern([star(_),create,star(_),mail]),
	template([think(create_mail())])
]).

win_functions([
	pattern([star(A),compose,star(B),mail]),
	template([srai([A,create,B,mail])])
]).

win_functions([
	pattern([star(A),make,star(B),mail]),
	template([srai([A,create,B,mail])])
]).

win_functions([
	pattern([star(A),write,star(B),mail]),
	template([srai([A,create,B,mail])])
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
get_and_write_calendars(X) :- get_calendars() , write_calendars(X).

write_calendars() :- not(current_predicate(calendar/4)), writeln('No calendars found').
write_calendars() :- foreach(calendar(_,Summary,_,_), write_calendar(Summary)).

write_calendars(_) :- not(current_predicate(calendar/4)), writeln('No calendars found').
write_calendars(X) :- foreach(calendar(_,Summary,_,X), write_calendar(Summary)).

write_calendar(Summary) :- write('| ') , write(Summary) , write(' |'), nl.

get_calendars() :- current_predicate(calendar/4).
get_calendars() :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetCalendars',List) , add_calendars($List).

add_calendars($List) :- cli_get($List,'Count',0).
add_calendars($List) :- foreach(cli_col($List,I), add_calendar($I)).

add_calendar($Cal) :- cli_get($Cal,'Summary',Summary) , cli_get($Cal,'Id',Id) , cli_get($Cal,'ReadOnly',ReadOnly) ,
					  atom_string(SummaryAtom,Summary) , atom_string(IdAtom,Id), downcase_atom(SummaryAtom,DSum), asserta(calendar(DSum,SummaryAtom,IdAtom,ReadOnly)).
					  
write_upcoming_events() :- get_upcoming_events('primary',$List) , write_events($List).
write_upcoming_events(X) :- get_calendars(), atomic_list_concat(X, ' ', XAtom), calendar(XAtom,_,Y,_) , get_upcoming_events(Y,$List) , write_events($List).

write_events_for_calendar() :- writeln('Ofcourse, which calendar would you like to see?') , read_from_input(Cal),
								   writeln('Which date? (dd-mm-yyyy)') , read_from_input(Date) , writeln('This are your appointment') ,
								   write_events(Cal,[Date],['']).

write_events(Date,End) :- atomic_list_concat(Date,'',XDate) ,atomic_list_concat(End,'',XEnd) , get_events('primary',XDate,XEnd,$List) , write_events($List).
write_events([Date],_) :- write('No appointments found for ') , write(Date) , nl.

write_events(X,Date,End) :- get_calendars(), atomic_list_concat(Date,'',XDate) , atomic_list_concat(End,'',XEnd), atom_string(XAtom,X) , calendar(XAtom,_,Y,_) , get_events(Y,XDate,XEnd,$List) , write_events($List).
write_events(_,[Date],_) :- write('No appointments found for ') , write(Date) , nl.

get_upcoming_events(X,$List) :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetUpcomingEvents'(X),List).

get_events(X,Date,End,$List) :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetEvents'(Date,End,X),List).

write_events($Obj) :- cli_get($Obj,'Count',0) , writeln('No appointments found for today').
write_events($Obj) :- foreach(cli_col($Obj,I), write_c_hekje($I)).

write_event_with_date($E) :- cli_call($E,'ToStringWithDate',String), write(String).

create_event() :- get_event_details(ID,BeginDate, Begin, EndDate, End, Title, Description, Location) , cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','AddEventToCalendar'(ID,Title,Description,Location,BeginDate,Begin,EndDate,End,'Europe/Amsterdam'),Event) ,
					writeln('Added the following event:') , write_event_with_date($Event).

get_event_details(ID,BeginDate, Begin, EndDate, End, Title, Description, Location) :- get_calendar_id(ID) , get_title(Title) , get_description(Description) ,
					get_times(BeginDate,Begin,EndDate,End) , get_location(Location).

get_times(BeginDate,Begin,EndDate,End) :- writeln('Which date does the appointment start? (dd-mm-yyyy)') , read_from_input(BeginDate) ,
										  writeln('Alright, How late does the appointment start? (HH:mm)') , read_from_input(Begin) ,
										  writeln('Okay, Which date does the appointment end? (dd-mm-yyyy)') , read_from_input(EndDate) ,
										  writeln('Understood, How late does the appointment end? (HH:mm)') , read_from_input(End), writeln('Okay.').
											
get_title(Title) :- writeln('How should the appointment be called?'), read_from_input(Title) , writeln('Okay.').

get_description(Description) :- writeln('What is the description of the appointment?'), read_from_input(Description) , writeln('Okay.').

get_location(Location) :- writeln('What is the location of the appointment?'), read_from_input(Location) , writeln('Okay.').

get_calendar_id(ID) :- writeln('Which of the following calendar would you like to add your appointment to?') , get_and_write_calendars(@false) , read_from_input(Input) ,
						atom_string(XAtom,Input), calendar(XAtom,_,ID,_).	
get_calendar_id(ID) :- writeln('That calendar is unknown') , get_calendar_id(ID).

get_and_write_mail(UnRead) :- get_mail(List, UnRead) , write_mails($List).

get_mail(List,UnRead) :- cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','GetMails'(UnRead),List) , retractall(mail(_,_)).

write_mails($Obj) :- cli_get($Obj,'Count',0) , writeln('No mails found').
write_mails($Obj) :- foreach(cli_col($Obj,I), write_mail($I)).

write_mail($Obj) :- write_c_hekje($Obj,@false) , cli_get($Obj,'ID',ID), cli_get($Obj,'Subject',Subject) , 
					atom_string(AID,ID), atom_string(ASubject,Subject) , asserta(mail(AID,ASubject)).

reply() :- writeln('To which mail would you like to reply?') , read_from_input(Mail) , atom_string(AMail,Mail) , reply(AMail).

reply([Mail]) :- reply(Mail).
reply(Mail) :- mail(ID,Mail) , writeln('What would you like to send?') , read_from_input(Body) , cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','Reply'(ID,Body),Message) ,
			 writeln('The following mail is send:') ,write_c_hekje($Message,@true).
			 
create_mail() :- writeln('To whom needs the mail to be send? (seperated with '','')') , read_from_input(TO) , writeln('What is the subject?') , read_from_input(Subject) ,
				writeln('What would you like to send?') , read_from_input(Body) , cli_call('ChatBotWindowsFunctions.GoogleApiFunctions','WriteMail'(TO,Subject,Body),Message) ,
			 writeln('The following mail is send:') ,write_c_hekje($Message,@true).
											
read_from_input(Text) :- current_input(Stream) , read_string(Stream,  "\n", "\r", _ , Text).

write_c_hekje($E,Bool) :- cli_call($E,'ToString'(Bool),String), write(String).
write_c_hekje(_,_).

write_c_hekje($E) :- cli_call($E,'ToString',String), write(String).
write_c_hekje(_).


