
%name stuff

name_category([
	pattern(['My',name,is,star(A)]),
	template([think(set_var(name,A)),'Hello',A,',',what,can,'I',do,for,'you?'])
]).

name_category([
	pattern(['I',am,star(A)]),
	template([srai(['My',name,is,A])])
]).

name_category([
	pattern(['I''m',star(A)]),
	template([srai(['My',name,is,A])])
]).

name_category([
	pattern(['Who',am,'I',one_or_zero([?])]),
	template(think(get_var(name,A)),
	positive([random([['You',said,you,are,A],['Your',name,is,A],['You''re',called,A]])]),
	negative(
	[
		random([['I','don''t',know,who,you,'are.','Who',are,'you?'],
			['I','don''t',know,who,you,'are.','What',is,your,'name?'],
			['I','don''t',know,who,you,'are.','Can',you,tell,me,your,'name?']])
	]))
]).

name_category([
	pattern(['What',is,my,name,one_or_zero([?])]),
	template([srai(['Who',am,'I',?])])
]).