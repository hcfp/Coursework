program hash;

uses sysutils;

var
	i, x, hashNum : cardinal; // cardinal cannot be negative unlike integer
	str : string;

begin
	readln(str);
	hashNum := 0;
	for i := 1 to length(str) do
	begin
		//binary shift left by 4 and add the ascii value of the current string element
		hashNum := (hashNum shl 4) + ord(str[i]);
		//and this value with a key
		x := hashNum and $F0000000;
		if x <> 0 then
			hashNum := hashNum xor (x shr 24);
		hashNum := hashNum and (not x)
	end;
	writeln(hashNum);
	//hashnum is an int, hex allow a more fixed length value
	writeln(IntToHex(hashNum, 8));
end.