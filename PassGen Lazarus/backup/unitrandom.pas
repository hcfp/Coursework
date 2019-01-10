unit unitRandom;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Spin;

type

  { TForm3 }

  TForm3 = class(TForm)
    ButtonGenRandom: TButton;
    EditOutput: TEdit;
    LabelGenerated: TLabel;
    LabelCaps: TLabel;
    LabelDigit: TLabel;
    LabelSpecial: TLabel;
    LabelRandom: TLabel;
    LabelLength: TLabel;
    SpinEditCaps: TSpinEdit;
    SpinEditDigits: TSpinEdit;
    SpinEditSpecial: TSpinEdit;
    SpinEditLength: TSpinEdit;
    procedure ButtonGenRandomClick(Sender: TObject);
  private

  public

  end;

type
  passRecord = record
    password: string;
    beenSet: array of boolean;
  end;

var
  Form3: TForm3;
  passRec: passRecord;
  NumOfCaps, numOfDigits, numOfSpecial, totalLength: integer;

implementation

{$R *.lfm}

const
  alphaRange = 25;
  digitRange = 10;
  specialRange = 21;

function initialise: integer;
var
  i: integer;
begin
  totalLength := Form3.SpinEditLength.Value;
  passRec.password := '';
  //create the inital password consisting of random lowercase letters
  for i := 1 to totalLength do
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
    pos := random(totalLength) + 1;
    // If the character at the posions has not been editied already then
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
  setCaps(totalLength);
  setDigits(totalLength);
  setSpecial(totalLength);
  Form3.EditOutput.Text := passRec.Password;
end;

{ TForm3 }

procedure TForm3.ButtonGenRandomClick(Sender: TObject);
begin
  if (SpinEditCaps.Value = 0) and (SpinEditDigits.Value = 0) and
    (SpinEditSpecial.Value = 0) then
  begin
    numOfCaps := random(totalLength div 4) + 1;
    numOfDigits := random(totalLength div 4) + 1;
    numOfSpecial := random(totalLength div 4) + 1;
  end
  else
  begin
    numOfCaps := SpinEditCaps.Value;
    numOfDigits := SpinEditDigits.Value;
    numOfSpecial := SpinEditSpecial.Value;
    if numOfCaps + numOfDigits + numOfSpecial > totalLength then
    begin
      numOfCaps := random(totalLength div 4) + 1;
      numOfDigits := random(totalLength div 4) + 1;
      numOfSpecial := random(totalLength div 4) + 1;
    end;
  end;
  generate;
end;

end.
