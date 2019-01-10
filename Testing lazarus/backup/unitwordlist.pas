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
  i := 1;

  while not EOF(passwords) do
  begin
    readln(passwords, temp);
    setLength(searchArray, i);
    searchArray[i - 1] := temp;
    i := i + 1;
  end;

  maxLength := i - 2;

  searchItem := EditGetPass.Text;
  reset(passwords);
  searchItem := lowercase(searchItem);
  high := maxLength;
  low := 0;
  found := False;
  exists := True;
  while not (found) and exists do
  begin
    if high < low then
    begin
      ShowMessage(searchItem + ' Not found');
      exists := False;
    end;
    mid := low + (high - low) div 2;
    currentSearchItem := lowercase(searchArray[mid]);
    if currentSearchItem < searchItem then
      low := mid + 1;
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

