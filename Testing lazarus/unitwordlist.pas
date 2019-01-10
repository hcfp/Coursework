unit unitWordList;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  EditBtn, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    ButtonTest: TButton;
    FileNameEditGetPass: TFileNameEdit;
    EditGetPass: TLabeledEdit;
    procedure ButtonTestClick(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

procedure TForm2.ButtonTestClick(Sender: TObject);
var
  searchArray: array of string;
  i, high, low, mid, maxLength: integer;
  found, exists: boolean;
  temp, searchItem, currentSearchItem: string;
  passwords: TextFile;
begin
  AssignFile(passwords, FileNameEditGetPass.FileName);
  reset(passwords);

  //increments i for each line in the file
  i := 1;
  while not EOF(passwords) do
  begin
    readln(passwords, temp);
    //increases the size of the search array
    setLength(searchArray, i);
    //populates the array
    searchArray[i - 1] := temp;
    i := i + 1;
  end;
  //corrects changes required for counting length and array indexing
  maxLength := i - 2;
  //closes passwords file to minimise memory use
  closeFile(passwords);

  searchItem := EditGetPass.Text;
  //converts to lowercase to lead to more matches
  searchItem := lowercase(searchItem);
  {also simplifies search since ord('a') > ord('A')
  which causes problems with binary search}
  high := maxLength;
  low := 0;
  found := False;
  //initially assume that the item exists
  exists := True;
  //the loop will only terminate if the item is found or does not exist
  while not (found) and exists do
  begin
    //Item has been searched for and could not be found
    if high < low then
    begin
      ShowMessage(searchItem + ' Not found');
      exists := False;
    end;
    //jump to middle
    mid := low + (high - low) div 2;
    currentSearchItem := lowercase(searchArray[mid]);
    //when the guess is less than the required, the search is moved down
    if currentSearchItem < searchItem then
      low := mid + 1;
    //when greater, search is moved up
    if currentSearchItem > searchItem then
      high := mid - 1;
    if currentSearchItem = searchItem then
    begin
      ShowMessage('Found ' + searchItem);
      found := True;
    end;
  end;
end;

end.