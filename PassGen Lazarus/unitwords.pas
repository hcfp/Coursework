unit unitWords;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin, EditBtn;

type

  { TForm2 }

  TForm2 = class(TForm)
    ButtonGenWords: TButton;
    EditOutputWords: TEdit;
    FileNameEditWordList: TFileNameEdit;
    LabelOpen: TLabel;
    SpinEditNumOfWords: TSpinEdit;
    procedure ButtonGenWordsClick(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }

function GetLines: integer;
var
  i: integer;
  words: TextFile;
  temp: string;
begin
  // Go through the file incrementing the counter while there are lines
  // Remianing in the file
  AssignFile(words, Form2.FileNameEditWordList.FileName);
  reset(words);
  i := 0;
  while not EOF(words) do
  begin
    readln(words, temp);
    i := i + 1;
  end;
  CloseFile(Words);
  Result := i;
end;

procedure TForm2.ButtonGenWordsClick(Sender: TObject);
var
  words: TextFile;
  temp, password: string;
  i, pos, numOfWords, j, lengthOfFile: integer;
begin
  // Initializes the random number generator
  // by giving a value to Randseed, calculated with the system clock
  randomize;
  AssignFile(words, FileNameEditWordList.FileName);
  // Find the total number of lines in the file
  lengthOfFile := GetLines;
  reset(words);
  password := '';
  // Get user defined number of words
  numOfWords := SpinEditNumOfWords.Value;
  for i := 1 to numOfWords do
  begin
    reset(words);
    // Generates a random line in the file
    pos := random(lengthOfFile);
    // Moves to that line
    for j := 0 to pos do
    begin
      readln(words, temp);
    end;
    // Ensure there isn't a space if it is the last word
    // Stops all passwords ending with a space
    if i <> numOfWords then
      password := password + temp + ' '
    else
      password := password + temp;
  end;
  EditOutputWords.Text := password;
end;

end.

