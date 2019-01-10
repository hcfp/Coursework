program binaySearch;

{$mode delphi}

uses
  SysUtils;
const
  fileLocation = 'pass.txt';

var
  searchArray : array of string;
  //numberFound for testing
  i, high, low, mid, maxLength{, numberFound} : integer;
  found, exists : boolean;
  temp, searchItem, currentSearchItem : string;
  passwords : TextFile;

begin
  AssignFile(passwords, fileLocation);
  reset(passwords);
  i := 1;

  while not eof(passwords) do
  begin
    readln(passwords, temp);
    setLength(searchArray, i);
    searchArray[i - 1] := temp;
    i := i + 1;
  end;

  maxLength := i - 2;
  writeln('Enter a search item for: ' , fileLocation);
  writeln('Type "quit" to exit');
	searchItem := '';

  //for testing
  //numberFound := 0;
  reset(passwords);
  while searchItem <> 'quit' do
  //for testing
  //for i := 0 to maxLength do
  begin
    //for testing
    //readln(passwords, searchItem);
    readln(searchItem);
    searchItem := lowercase(searchItem);
    high := maxLength;
    low := 0;
    found := false;
    exists := true;
    while not(found) and exists do
    begin
      if high < low then
      begin
        writeln(searchItem, ' Not found');
        exists := false
      end;
      mid := low + (high - low) div 2;
      currentSearchItem := lowercase(searchArray[mid]);
      if currentSearchItem < searchItem then
        low := mid + 1;
      if currentSearchItem > searchItem then
        high := mid - 1;
      if currentSearchItem = searchItem then
      begin
        writeln('Found ' , searchItem);
        found := true;
        //for testing
        //numberFound := numberFound + 1;
      end;
    end;
  end;
  //for testing
  //writeln(numberFound);
end.