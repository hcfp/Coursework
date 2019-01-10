program passgen;

{$mode delphi}

uses
	sysutils;

var
	words : TextFile;
	temp, password : string;
	i, pos, numOfWords, j : integer;

begin
	randomize;
	AssignFile(words, 'words.txt');
	reset(words);
	password := '';
	numOfWords := random(2) + 2;
	for i := 1 to numOfWords do
	begin
		reset(words);
		pos := random(2046);
		for j := 0 to pos do
		begin
			readln(words, temp);
		end;
		if i <> numOfWords then
			password := password + temp + ' '
		else
			password := password + temp;
	end;
	writeln(password);
end.