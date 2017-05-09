:- module(customquestiondatabase,
			[add_question/1,
			 clear_questions/0,
			 link_questions/1]).
			
:- use_module(library(persistency)).
:- initialization(init).
:- dynamic question_list/1.
question_list([]).

init:- absolute_file_name('custom_questions.db', File, [access(write)]), db_attach(File, []).

:- persistent custom_category(category:list).

% functions

add_question(Q) :- question_list(List) , retractall(question_list(_)) , 
					append(List,[Q],NewList) , asserta(question_list(NewList)).
				
clear_questions() :- retractall(question_list(_)) , asserta(question_list([])).

link_questions(Q) :- 

write_to_db(Q,[]).
write_to_db(Q,[H|T]) :- assert_custom_category([pattern(H),template([srai(Q)])]) , write_to_db(Q,T).

convert_questions([],[]).
convert_questions([H|T1],[Hnew,T2]) :- convert_question(H,Hnew) , convert_questions(T1,T2).

convert_question(In,Out). %:- do stuff.