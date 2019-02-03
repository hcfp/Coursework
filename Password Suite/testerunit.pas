unit TesterUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, ExtCtrls, EditBtn, Menus, RegExpr;

type

  { TFormTester }

  TFormTester = class(TForm)
    Button1: TButton;
    ButtonTestWords: TButton;
    EditPassword: TLabeledEdit;
    FileNameEditGetPass: TFileNameEdit;
    LabelWordList: TLabel;
    EditGetPass: TLabeledEdit;
    PageControl1: TPageControl;
    TextPassLength: TStaticText;
    TextPassLower: TStaticText;
    TextPassUpper: TStaticText;
    TextPassDigits: TStaticText;
    TextPassSpecial: TStaticText;
    TextPassFail: TStaticText;
    TabSheetWordList: TTabSheet;
    TabSheetRequirements: TTabSheet;
    procedure Button1Click(Sender: TObject);
    procedure ButtonTestWordsClick(Sender: TObject);
    procedure EditPasswordChange(Sender: TObject);
  private

  public

  end;

var
  FormTester: TFormTester;

implementation

{$R *.lfm}

{ TFormTester }

procedure getTips;
var
  password: string;
  re: TRegExpr;
  meetsLength, hasDigits, hasLower, hasUpper, hasSpecial: boolean;
begin
  re := TRegExpr.Create;
  meetsLength := false;
  hasDigits := false;
  hasLower := false;
  hasUpper := false;
  hasSpecial := false;
  
  if length(password) >= 8 then
    meetsLength := True;
  
  re.expression := '\d+';
  if re.exec(password) then
    hasDigits := True;
  
  re.expression := '[a-z]+';
  if re.exec(password) then
    hasLower := True;
  
  re.expression := '[A-Z]+';
  if re.exec(password) then
    hasUpper := True;
  
  re.expression := '[~`!@#\$%\^&*\(\)\+=_\-\{\}\[\]\\|:;\?\/<>,\.]+';
  if re.exec(password) then
    hasSpecial := True;

  if not(meetsLength) then
    ShowMessage('It is recomended that passwords are at least 8 characters long. This makes it more difficult to brute force passwords.');
  if not(hasDigits) then
    ShowMessage('Passwords shoud have digits to increase the number of possible passwords in a fixed length');
  if not(hasLower) then
    ShowMessage('All passwords should include lowercase letters');
  if not(hasUpper) then
    ShowMessage('Passwords should have uppercase letters to increase the number of possible passwords in a fixed length');
  if not(hasSpecial) then
    ShowMessage('Following are the usually accepted special characters ~ ` ! @ # $ % ^ & * ( ) + = _ - { } [ ] \ / | : ; ? < > , .' + 
    ' This vastly increases the number of passwords that have to be brute forced');
end;

procedure TFormTester.Button1Click(Sender: TObject);
begin
  getTips;
end; 

procedure TFormTester.EditPasswordChange(Sender: TObject);
var
  password: string;
  re: TRegExpr;
  meetsLength, hasDigits, hasLower, hasUpper, hasSpecial: boolean;
  Count: integer;
begin
  meetsLength := False;
  re := TRegExpr.Create;
  Count := 0;
  password := EditPassword.Text;

  //Test for password length
  if length(password) >= 8 then
  begin
    TextPassLength.Font.Color := clGreen;
    meetsLength := True;
  end
  else
  begin
    TextPassLength.Font.Color := clRed;
    meetsLength := False;
  end;

  //Test for digits
  re.expression := '\d+';
  if re.exec(password) then
  begin
    TextPassDigits.Font.Color := clGreen;
    hasDigits := True;
  end
  else
  begin
    TextPassDigits.Font.Color := clRed;
    hasDigits := False;
  end;

  //Test for lowercase letter
  re.expression := '[a-z]+';
  if re.exec(password) then
  begin
    TextPassLower.Font.Color := clGreen;
    hasLower := True;
  end
  else
  begin
    TextPassLower.Font.Color := clRed;
    hasLower := False;
  end;

  //Test for uppercase letters
  re.expression := '[A-Z]+';
  if re.exec(password) then
  begin
    TextPassUpper.Font.Color := clGreen;
    hasUpper := True;
  end
  else
  begin
    TextPassUpper.Font.Color := clRed;
    hasUpper := False;
  end;

  //Test for special characters
  // \ required to escape characters used in regex
  re.expression := '[~`!@#\$%\^&*\(\)\+=_\-\{\}\[\]\\|:;\?\/<>,\.]+';
  if re.exec(password) then
  begin
    TextPassSpecial.Font.Color := clGreen;
    hasSpecial := True;
  end
  else
  begin
    hasSpecial := False;
    TextPassSpecial.Font.Color := clRed;
  end;

  //allows dynmaic updates. Recalculated based on each change
  if hasDigits then
    Count := Count + 1;
  if hasLower then
    Count := Count + 1;
  if hasUpper then
    Count := Count + 1;
  if hasSpecial then
    Count := Count + 1;

  //Has to be greater than 7 characters and pass 3 or more of the tests
  if (meetsLength) and (Count >= 3) then
  begin
    TextPassFail.Caption := 'Pass';
    TextPassFail.Font.Color := clLime;
  end
  else
  begin
    TextPassFail.Caption := 'Fail';
    TextPassFail.Font.Color := clRed;
  end;
  //reset to allow recalulation based on changes
  Count := 0;
end;

procedure TFormTester.ButtonTestWordsClick(Sender: TObject);
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

