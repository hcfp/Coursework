unit unitSimple;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, Buttons, regexpr;

type

  { TForm3 }

  TForm3 = class(TForm)
    EditPassword: TLabeledEdit;
    TextPassFail: TStaticText;
    TextPassLower: TStaticText;
    TextPassUpper: TStaticText;
    TextPassDigits: TStaticText;
    TextPassSpecial: TStaticText;
    TextPassLength: TStaticText;
    procedure EditPasswordChange(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;
  re: TRegExpr;
  count: integer;
  password: string;
  meetsLength, hasDigits, hasLower, hasUpper, hasSpecial: boolean;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.EditPasswordChange(Sender: TObject);
begin
  meetsLength := False;
  re := TRegExpr.Create;
  count := 0;
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
    count := count + 1;
  if hasLower then
    count := count + 1;
  if hasUpper then
    count := count + 1;
  if hasSpecial then
    count := count + 1;

  //Has to be greater than 7 characters and pass 3 or more of the tests
  if (meetsLength) and (count >= 3) then
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
  count := 0;
end;

end.
