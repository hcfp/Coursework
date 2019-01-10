unit LoginUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, sqlite3conn, FileUtil, Forms, Controls, Graphics,
  Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonLogin: TButton;
    CheckBoxPassword: TCheckBox;
    EditUsername: TEdit;
    EditPassword: TEdit;
    LabelLoginStatus: TLabel;
    LabelUsername: TLabel;
    LabelPassword: TLabel;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    procedure ButtonLoginClick(Sender: TObject);
    procedure CheckBoxPasswordChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

//allows user to see password
procedure TForm1.CheckBoxPasswordChange(Sender: TObject);
begin
  if CheckBoxPassword.Checked then
    //the characters in EditPassword can be seen as inputted
    EditPassword.PasswordChar := #0
  else
    //chars replaced by *
    EditPassword.PasswordChar := '*';
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Form1.ActiveControl := EditUsername;
end;

procedure TForm1.ButtonLoginClick(Sender: TObject);
var
  EnteredUsername, EnteredPassword, Password : string;
begin
  EnteredUsername := EditUsername.Text;
  EnteredPassword := EditPassword.Text;
  SQLQuery1.SQL.Clear;
  //gets the password associated with the inputted username
  SQLQuery1.SQL.Text := 'SELECT Password FROM LoginInformation WHERE Username = ' + '"' + EnteredUsername + '"';
  SQLQuery1.Open;
  //extracts the password from the query
  Password := SQLQuery1.FieldByName('Password').AsString;
  //if the password entered by the user is the same as the password fetched
  //from the databased corresponding to the username, the login is successful
  if Password = EnteredPassword then
  begin
    LabelLoginStatus.Font.Color := clLime;
    LabelLoginStatus.Caption := 'Login Successful'
  end
  else
  begin
    LabelLoginStatus.Font.Color := clRed;
    LabelLoginStatus.Caption := 'Login Failed'
  end;
end;

end.

