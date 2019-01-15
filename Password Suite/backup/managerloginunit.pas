unit ManagerLoginUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, FileUtil, Forms, Controls, Graphics,
  Dialogs, Menus, ExtCtrls, StdCtrls, DateUtils, Manager;

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
  UserID, LastTimeLockedString : string;
  attempts : integer;
  TimeFirstLocked : TDateTime;
  log : TextFile;

implementation

{$R *.lfm}

{ TFormManagerLogin }

function ELFHash(password: string): string;
var
  i, x, hashNum: cardinal; // cardinal cannot be negative unlike integer
begin
  hashNum := 0;
  for i := 1 to length(password) do
  begin
    //binary shift left by 4 and add the ascii value of the current string element
    hashNum := (hashNum shl 4) + Ord(password[i]);
    //and this value with a key
    x := hashNum and $F0000000;
    if x <> 0 then
      hashNum := hashNum xor (x shr 24);
    hashNum := hashNum and (not x);
  end;
  Result := IntToHex(hashNum,8);
end;

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
  attempts := 0;
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
    password := ELFHash(password);
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
  EnteredPassword := ELFHash(EnteredPassword);
  if attempts < 3 then
  begin
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
      attempts := 0;
    end
    else
    begin
      ShowMessage('Login Failed');
      attempts := attempts + 1;
    end;
  end
  else
  begin
    ShowMessage('Too many attempts. Locked for 30 seconds');
    if attempts = 3 then
    begin
      TimeFirstLocked := Time;
      AssignFile(Log, 'C:\Users\habib\Documents\Computing\Coursework\Password Suite\log.txt');
      append(log);
      writeln(log, TimeToStr(TimeFirstLocked));
      CloseFile(Log);
    end;
    AssignFile(Log, 'C:\Users\habib\Documents\Computing\Coursework\Password Suite\log.txt');
    reset(log);
    while not EOF(log) do
    begin
      readln(log, LastTimeLockedString);
    end;
    CloseFile(Log);
    if MilliSecondsBetween(StrToTime(LastTimeLockedString), Time) > 3000 then
        attempts := 0;
    attempts := attempts + 1;
  end;
end;

end.
