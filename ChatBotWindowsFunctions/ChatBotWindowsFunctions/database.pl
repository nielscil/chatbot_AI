:- module(database,
			[add_user_fact/2,
			 update_user_fact/2,
			 get_user_fact/2
			]).
			
:- use_module(library(persistency)).

:- initialization(init).

init:- absolute_file_name('customfacts.db', File, [access(write)]), db_attach(File, [gc]).

:- persistent user_facts(varname:atom, value:list).

add_user_fact(Name,Value) :- assert_user_facts(Name,Value).

update_user_fact(Name, Value) :- retractall_user_facts(Name,_) ,
						assert_user_facts(Name, Value).

get_user_fact(Name, Value) :- user_facts(Name,Value).