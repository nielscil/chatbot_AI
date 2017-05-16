% chatbot.pl

:- use_module(library('http/http_client')).
:- use_module(library('http/http_json')).
:- use_module(library('http/json')).

:- consult([alice]).
:- consult([windowsfunctions]).
:- consult([name_categories]).

category([
	pattern([can,you,star(A),'?']),
	template(['I', 'don''t', really, know, if,'I','can', A,
		but,'I''m', very, good, at, swimming])
]).

category([
	pattern([who,is,alan,turing,'?']),
	template(['Alan Mathison Turing',was,a,'British',mathematician,',',logician,',',cryptanalyst,',',philosopher,',',computer,scientist,',',mathematical,biologist,',',and,marathon,and,ultra,distance,runner,'.'])
]).

category([
	pattern([do,you,know,who,star(A),is,'?']),
	template([srai([who,is,A,'?'])])
]).

category([
	pattern([yes]),
	that([do, you, like, movies,'?']),
	template(['What', is, your, favourite, movie, '?'])
]).

category([
	pattern([star(_),always,star(_)]),
	template(['Can',you,think,of,a,specific,example,'?'])
]).

category([
	pattern([how,much,is,star([A]),plus,star([B]),'?']),
	template([think((C is A + B)),A,plus,B,is,C])
]).

category([
	pattern([star(_),temperature,star(_),in,star([City]),'?']),
	template([think(temperature(City,Temp)),
	    'The',temperature,in,City,is,Temp,degrees,celcius,'.'])
]).

category([
	pattern([star(_),joke,star(_)]),
	template([think(chuckNorrisJoke(Joke)),Joke])
]).

category([
	pattern([is,star([Person]),female,'?']),
	template(think(female(Person)),
	positive(['Yes, ',she,is,'!']),
	negative(['No, ',Person,is,a,male]))
]).

category([
	pattern([is,star([Person]),male,'?']),
	template(think(not(female(Person))),
	positive(['Yes, ',he,is,'!']),
	negative(['No, ',Person,is,a,female]))
]).

category([
	pattern([who,is,the,father,of,star([Person]),'?']),
	template(think(father_of(Father,Person)),
	positive([Father,is,the,father,of,Person]),
	negative(['The',father,of,Person,'isn''t',known]))
]).

category([
	pattern([star(_),sound,star(_)]),
	template(['Okay!',
		think(process_create(path(play), ['emergency.mp3'], [stderr(null)]))])
]). 

category([
	pattern([are,you,afraid,of,syntax(np,NP),'?']),
	template(['Why',would,'I',be,afraid,of,NP,'?!'])
]).

category([
	pattern([star(_),goodbye,star(_)]),
	template([think(halt)])
]).

category([
	pattern([hello]),
	template(think(get_var(name,Name)),
	positive(['Hello',Name,',what',can,'I',do,for,'you?']),
	negative(['Hello,',what,is,your,'name?']))
]).

category([
	pattern([what,is,your,name]),
	template([my,name,is,alice])
]).

category(X) :- name_category(X).
category(X) :- win_functions(X).

category([
	pattern([star(_)]),
	template(['Huh??!'])
]).

% Family tree
female(helen).
female(ruth).
female(petunia).
female(lili).

male(paul).
male(albert).
male(vernon).
male(james).
male(dudley).
male(harry).

parent_of(paul,petunia).
parent_of(helen,petunia).
parent_of(paul,lili).
parent_of(helen,lili).
parent_of(albert,james).
parent_of(ruth,james).
parent_of(petunia,dudley).
parent_of(vernon,dudley).
parent_of(lili,harry).
parent_of(james,harry).

% Fathers are male parent and mothers are female parents.
father_of(X,Y) :- male(X),
                  parent_of(X,Y).
mother_of(X,Y) :- female(X),
                  parent_of(X,Y).
				  
% save_data(A,B,C,D) :- atomic_list_concat(A, '_', AAtom) , atomic_list_concat(B, '_', BAtom), atomic_list_concat(C, '_', CAtom),
%					  atomic_list_concat(D, '_', DAtom) , If=..[BAtom,AAtom] , Then=..[DAtom,CAtom].

% http://openweathermap.org/
temperature(City,Temp) :-
	First = 'http://api.openweathermap.org/data/2.5/find?q=',
	Second = City,
	Third = '&mode=json&appid=b4cf58a66894a114580988cc65d8bdcb',
	atomic_concat(First,Second,Buffer),
	atomic_concat(Buffer,Third,HREF),
	http_get(HREF,json(R),[]),
	member(list=L,R), 
	member(json(M),L), 
	member(main=json(Main),M), 
	member(temp=T,Main), 
	Temp is round(T - 273.15).

chuckNorrisJoke(Joke) :-
	http_get('http://api.icndb.com/jokes/random?escape=javascript&exclude=[nerdy,explicit]',json(Json),[]),
	member(value=json(W),Json),
	member(joke=Joke,W).
	
%poetry(Title,Autor) :- atomic_list_concat(Title,' ',ATitle) , atomic_list_concat(Autor,' ',AAutor), atomic_concat(AAutor,';',B1) , atomic_concat(B1,';',B2),
%						atomic_concat(B2,ATitle,B3) , atomic_concat('http://poetrydb.org/author,title/',B3,Final) , http_get(Final,json(R),[]).
						

np --> art, noun.

art --> [the];[a];[an].

noun --> [cat];[dog];[mouse];[rat];[table].

:- write('\33\[2J') , loop.