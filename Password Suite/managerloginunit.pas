unit ManagerLoginUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, Menus, ExtCtrls, StdCtrls, Manager;

type

  { TFormManagerLogin }

  TFormManagerLogin = class(TForm)
    ButtonNewUser: TButton;
    ButtonLogin: TButton;
    CheckBoxPassword: TCheckBox;
    Conn: TSQLite3Connection;
    EditUsername: TLabeledEdit;
    EditPassword: TLabeledEdit;
    Query: TSQLQuery;
    Trans: TSQLTransaction;
    procedure ButtonLoginClick(Sender: TObject);
    procedure ButtonNewUserClick(Sender: TObject);
    procedure CheckBoxPasswordChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private

  public

  end;

var
  FormManagerLogin: TFormManagerLogin;
  UserID: string;

implementation

{$R *.lfm}

{ TFormManagerLogin }

procedure TFormManagerLogin.FormCreate(Sender: TObject);
begin
  conn.Close; // Ensure the connection is closed at start start
  try
    // Since we're making this database for the first time,
    // check whether the file already exists
    if not FileExists(conn.DatabaseName) then
    begin
      // Create the database and the tables
      try
        conn.Open;
        Trans.StartTransaction;
        //creates the LoginInformation table
        conn.ExecuteDirect('CREATE TABLE `LoginInformation` ( ' +
          '"UserID" INTEGER PRIMARY KEY ,' + '"Username" VARCHAR(50),' +
          '"Password" VARCHAR(50));');
        trans.Commit;
        //creates the Manager table
        conn.ExecuteDirect('CREATE TABLE "Manager" (' +
          '"EntryID" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "UserID" INT,' +
          '"Username" VARCHAR(50),' + '"Password" VARCHAR(50));');
        trans.Commit;
        //only shows when all columns etc are creates as defined
        ShowMessage('Succesfully created database.');
      except
        //shows when the file is not created or not created as defined
        ShowMessage('Unable to Create new Database');
      end;
    end;
  except
    ShowMessage('Unable to check if database file exists');
  end;
  conn.Close;
end;

procedure TFormManagerLogin.CheckBoxPasswordChange(Sender: TObject);
begin
  if CheckBoxPassword.Checked then
    //the characters in EditPassword can be seen in plaintext
    EditPassword.PasswordChar := #0
  else
    //chars replaced by *
    EditPassword.PasswordChar := '*';
end;

procedure TFormManagerLogin.ButtonNewUserClick(Sender: TObject);
var
  username, password: string;
begin
  username := EditUsername.Text;
  password := EditPassword.Text;
  Query.Close;
  Query.SQL.Text := 'SELECT Username FROM LoginInformation WHERE Username = ' +
    '"' + username + '"';
  Query.Open;
  if Query.FieldByName('Username').AsString = '' then
  begin
    // formats strings to fit in the sql query string
    username := '"' + username + '"';
    password := '"' + password + '"';
    //UserID value is null since it is an auto-incremented field
    conn.ExecuteDirect(
      'INSERT INTO LoginInformation (UserID,Username, Password) VALUES (NULL,' +
      username + ',' + password + ');');
    trans.Commit;
    Conn.Close;
    ShowMessage('Added to DB');
  end
  else
    ShowMessage('Username not available');
end;

procedure TFormManagerLogin.ButtonLoginClick(Sender: TObject);
var
  EnteredUsername, EnteredPassword, Password: string;
begin
  query.Close;
  EnteredUsername := EditUsername.Text;
  EnteredPassword := EditPassword.Text;
  Query.SQL.Clear;
  //gets the password associated with the inputted username
  Query.SQL.Text := 'SELECT UserId, Password FROM LoginInformation WHERE Username = ' +
    '"' + EnteredUsername + '"';
  Query.Open;
  //extracts the password from the query
  Password := Query.FieldByName('Password').AsString;
  UserID := Query.FieldByName('UserID').AsString;
  //if the password entered by the user is the same as the password fetched
  //from the databased corresponding to the username, the login is successful
  if Password = EnteredPassword then
  begin
    ShowMessage('Login  to User: ' + UserId + ' Successful');
    //Clears login details for when login screen is accessed again
    FormManagerLogin.Conn.Close;
    FormManagerLogin.Trans.EndTransaction;
    FormManagerLogin.Query.Close;
    EditUsername.Text := '';
    EditPassword.Text := '';
    EnteredUsername := '';
    EnteredPassword := '';
    FormManagerLogin.Hide;
    FormManager.ShowModal;
    FormManagerLogin.Show;
    FormManager.Conn.Close;
    FormManager.Trans.EndTransaction;
    FormManager.Query.Close;
  end
  else
  begin
    ShowMessage('Login Failed');
  end;
end;

end.
