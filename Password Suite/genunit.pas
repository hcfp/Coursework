unit GenUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Spin, ExtCtrls, EditBtn;

type

  { TFormGen }

  TFormGen = class(TForm)
    ButtonGenWords: TButton;
    ButtonGenRandom: TButton;
    FileNameEditWordList: TFileNameEdit;
    LabelDefaultDelimiter: TLabel;
    EditDelimiter: TLabeledEdit;
    LabelLength: TLabel;
    LabelRandom: TLabel;
    LabelWords: TLabel;
    LabelDigits: TLabel;
    LabelCaps: TLabel;
    EditOutput: TLabeledEdit;
    EditOutputWords: TLabeledEdit;
    LabelSpecial: TLabel;
    PageControl1: TPageControl;
    SpinEditNumOfWords: TSpinEdit;
    SpinEditLength: TSpinEdit;
    SpinEditDigits: TSpinEdit;
    SpinEditSpecial: TSpinEdit;
    SpinEditCaps: TSpinEdit;
    TabSheetWordGen: TTabSheet;
    TabSheetRandGen: TTabSheet;
    procedure ButtonGenRandomClick(Sender: TObject);
    procedure ButtonGenWordsClick(Sender: TObject);
    procedure FormClose(Sender: TObject);
  private

  public

  end;

type
  passRecord = record
    password: string;
    beenSet: array of boolean;
  end;

var
  FormGen: TFormGen;
  passRec: passRecord;
  NumOfCaps, numOfDigits, numOfSpecial, totalLength: integer;

implementation

{$R *.lfm}

const
  alphaRange = 25;
  digitRange = 10;
  specialRange = 21;

procedure TFormGen.FormClose(Sender: TObject);
begin
  EditOutput.Text := '';
  SpinEditNumOfWords.Value := 0;
  FileNameEditWordList.FileName := '';
  FileNameEditWordList.Text := '';
  EditDelimiter.Text := '';
  SpinEditLength.Value := 0;
  SpinEditDigits.Value := 0;
  SpinEditSpecial.Value := 0;
  SpinEditCaps.Value := 0;
end;

function initialise: integer;
var
  i: integer;
begin
  totalLength := FormGen.SpinEditLength.Value;
  passRec.password := '';
  //create the inital password consisting of random lowercase letters
  for i := 1 to totalLength do
    //+97 brings the output of random(alpharange) into the range fo ascii lowercase letter
    passRec.password := passRec.password + chr(random(alphaRange) + 97);
  //create the beenSet array for each char in the password and initialise to false
  setLength(passRec.beenSet, length(passRec.password));
  for i := 0 to length(passRec.password) do
    passRec.beenSet[i] := False;
  Result := totalLength;
end;

procedure setCaps(totalLength: integer);
var
  uppercase: array[0..25] of char = ('A', 'B', 'C', 'D', 'E', 'F',
    'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S',
    'T', 'U', 'V', 'W', 'X', 'Y', 'Z');
  i, pos: integer;
begin
  for i := 0 to numOfCaps - 1 do
  begin
    // Generate a random position
    //+1 is required due to string indexing
    pos := random(totalLength) + 1;
    // If the character at the position has not been editied already then
    if passRec.beenSet[pos] = False then
    begin
      // Set character
      passRec.beenSet[pos] := True;
      passRec.password[pos] := uppercase[random(alphaRange)];
    end
    // If the character has already been set
    else
    begin
      // While the position has already been set. Regenerate the position
      while passRec.beenSet[pos] = True do
        pos := random(totalLength) + 1;
      // Set character
      passRec.beenSet[pos] := True;
      passRec.password[pos] := uppercase[random(alphaRange)];
    end;
  end;
end;

// Similar to setCaps
procedure setDigits(totalLength: integer);
var
  digits: array[0..9] of char = ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
  i, pos: integer;
begin
  for i := 0 to numOfDigits - 1 do
  begin
    pos := random(totalLength) + 1;
    if passRec.beenSet[pos] = False then
    begin
      passRec.beenSet[pos] := True;
      passRec.password[pos] := digits[random(digitRange)];
    end
    else
    begin
      while passRec.beenSet[pos] = True do
        pos := random(totalLength) + 1;
      passRec.password[pos] := digits[random(digitRange)];
      passRec.beenSet[pos] := True;
    end;
  end;
end;

// Similar to setCaps
procedure setSpecial(totalLength: integer);
var
  special: array[0..21] of char = ('@', '%', '+', '\', '/', '!', '#',
    '$', '^', '?', ':', '.', '(', ')', '{', '}', '[', ']', '~', '`', '-', '_');
  i, pos: integer;
begin
  for i := 0 to numOfSpecial - 1 do
  begin
    pos := random(totalLength) + 1;
    if passRec.beenSet[pos] = False then
    begin
      passRec.beenSet[pos] := True;
      passRec.password[pos] := special[random(specialRange)];
    end
    else
    begin
      while passRec.beenSet[pos] = True do
        pos := random(totalLength) + 1;
      passRec.beenSet[pos] := True;
      passRec.password[pos] := special[random(specialRange)];
    end;
  end;
end;

procedure generate;
var
  totalLength: integer;
begin
  totalLength := initialise;
  //changing the order of execution has no noticable impact
  setCaps(totalLength);
  setDigits(totalLength);
  setSpecial(totalLength);
  FormGen.EditOutput.Text := passRec.Password;
end;

{ TFormGen }

procedure TFormGen.ButtonGenRandomClick(Sender: TObject);
begin
  //generate a random number of caps,digits and special
  if (SpinEditCaps.Value = 0) and (SpinEditDigits.Value = 0) and
    (SpinEditSpecial.Value = 0) then
  begin
    //ensures that they will not combine to be greater than the maxlength
    numOfCaps := random(totalLength div 4) + 1;
    numOfDigits := random(totalLength div 4) + 1;
    numOfSpecial := random(totalLength div 4) + 1;
  end
  else
  begin
    //if the user did not set all to 0, take their input
    numOfCaps := SpinEditCaps.Value;
    numOfDigits := SpinEditDigits.Value;
    numOfSpecial := SpinEditSpecial.Value;

    {If the number caps,digits and special is greater than the total
      length, the program will attempt to replace characters that have
      already been set, leading to a freeze on the following code.
      it will be stuck in an infinite loop since all positions would
      have already been set
      while passRec.beenSet[pos] = True do
        pos := random(totalLength) + 1;}

    if numOfCaps + numOfDigits + numOfSpecial > totalLength then
    begin
      //this is prevented by generating a random number in this case
      numOfCaps := random(totalLength div 4) + 1;
      numOfDigits := random(totalLength div 4) + 1;
      numOfSpecial := random(totalLength div 4) + 1;
    end;
  end;
  generate;
end;

function GetLines: integer;
var
  i: integer;
  words: TextFile;
  temp: string;
begin
  // Go through the file incrementing the counter while there are lines
  // Remianing in the file
  try
    AssignFile(words, FormGen.FileNameEditWordList.FileName);
    reset(words);
  except
    ShowMessage('Could not assign word list');
  end;
  i := 0;
  while not EOF(words) do
  begin
    readln(words, temp);
    i := i + 1;
  end;
  CloseFile(Words);
  Result := i;
end;

function getDelimiter: string;
var
  delimiter: string;
begin
  delimiter := FormGen.EditDelimiter.Text;
  Result := delimiter;
end;

procedure TFormGen.ButtonGenWordsClick(Sender: TObject);
var
  words: TextFile;
  temp, password, delimiter : string;
  i, pos, numOfWords, j, lengthOfFile: integer;
begin
  // Initializes the random number generator
  // by giving a value to Randseed, calculated with the system clock
  randomize;
  try
    AssignFile(words, FileNameEditWordList.FileName);
  except
    ShowMessage('Could not assign word list');
  end;
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
    delimiter := getDelimiter;
    if i <> numOfWords then
      password := password + temp + delimiter
    else
      password := password + temp;
  end;
  EditOutputWords.Text := password;
end;

end.

