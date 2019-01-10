unit unitSimple;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls, ActnList, Buttons, regexpr;

type

  { TForm3 }

  TForm3 = class(TForm)
    ButtonTest: TButton;
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
  Count: integer;
  password: string;
  meetsLength, hasDigits, hasLower, hasUpper, hasSpecial: boolean;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.EditPasswordChange(Sender: TObject);
begin
  meetsLength := False;
  re := TRegExpr.Create;
  Count := 0;
  password := EditPassword.Text;
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

  if hasDigits then
    Count := Count + 1;
  if hasLower then
    Count := Count + 1;
  if hasUpper then
    Count := Count + 1;
  if hasSpecial then
    Count := Count + 1;

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
  Count := 0;
end;

end.
