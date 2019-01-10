program passgen;

uses crt;


const
	alphaRange = 25;
	digitRange = 10;
	specialRange = 21;

type
	passRecord = record
		password : string;
		beenSet : array of boolean;
	end;

var
	totalLength, numOfCaps, numOfDigits, numOfSpecial, i : integer;
	uppercase : array[0..25] of char = ('A','B','C', 'D', 'E', 'F', 'G',
																			'H', 'I', 'J' , 'K' , 'L', 'M',
																			'N', 'O', 'P', 'Q', 'R', 'S', 'T',
																			'U', 'V', 'W', 'X', 'Y', 'Z');
	digits : array[0..9] of char = ('0', '1', '2', '3', '4', '5', '6', '7',
																	'8', '9');
	special : array[0..21] of char = ('@', '%', '+', '\', '/', '!', '#', '$',
																		'^', '?', ':', '.', '(' , ')' , '{', '}',
																		'[', ']', '~', '`', '-', '_');
	passRec : passRecord;

procedure getInput;
begin
	repeat
		writeln('Enter length of password (must be greater than 7): ');
		writeln('Enter -1 to exit');
		readln(totalLength);
	until (totalLength >= 8) or (totalLength < 1);
end;

procedure setNum;
begin
	numOfCaps := random(totalLength div 4) + 1;
	numOfDigits := random(totalLength div 4) + 1;
	numOfSpecial := random(totalLength div 4) + 1;
	writeln('Number of caps: ', numOfCaps);
	writeln('Number of digits: ', numOfDigits);
	writeln('Number of special: ', numOfSpecial);
end;

procedure generate;
var
	pos : integer;
begin
	//create the inital password
	for i := 1 to totalLength do
		passRec.password := passRec.password + chr(random(alphaRange) + 97);

	//create an array of the length of the password and initialise to false
	setLength(passRec.beenSet, length(passRec.password));
	for i := 0 to length(passRec.password) do
		passRec.beenSet[i] := false;

	for i := 0 to numOfCaps - 1 do
	begin
		//generate a random position
		pos := random(totalLength) + 1;
		//if the character at the posions has not been editied already
		if passRec.beenSet[pos] = false then
		begin
			//set character
			passRec.beenSet[pos] := true;
			passRec.password[pos] := uppercase[random(alphaRange)];
		end
		else
		begin
			//while the position has already been set. Regenerate the position
			while passRec.beenSet[pos] = true do
				pos := random(totalLength) + 1;
			//set character
			passRec.beenSet[pos] := true;
			passRec.password[pos] := uppercase[random(alphaRange)];
			//repeat for all criteria
		end;
	end;

	for i := 0 to numOfDigits - 1 do
	begin
		pos := random(totalLength) + 1;
		if passRec.beenSet[pos] = false then
		begin
			passRec.beenSet[pos] := true;
			passRec.password[pos] := digits[random(digitRange)];
		end
		else
		begin
			while passRec.beenSet[pos] = true do
				pos := random(totalLength) + 1;
			passRec.password[pos] := digits[random(digitRange)];
			passRec.beenSet[pos] := true;
		end;
	end;

	for i := 0 to numOfSpecial - 1 do
	begin
		pos := random(totalLength) + 1;
		if passRec.beenSet[pos] = false then
		begin
			passRec.beenSet[pos] := true;
			passRec.password[pos] := special[random(specialRange)];
		end
		else
		begin
			while passRec.beenSet[pos] = true do
				pos := random(totalLength) + 1;
			passRec.beenSet[pos] := true;
			passRec.password[pos] := special[random(specialRange)];
		end;
	end;
end;

procedure output;
begin
	writeln('Your randomly generated password is: ');
	textColor(lightgreen);
	writeln(passRec.password);
	textColor(white);
end;

begin
	repeat
		passRec.password := '';
		randomize;
		getInput;
		//only runs the generation if the length requirement is met
		if totalLength >= 8 then
		begin
			setNum;
			generate;
			output;
		end;
	until totalLength = -1;
end.