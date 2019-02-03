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
  UserID, LastTimeLockedString: string;
  attempts: integer;
  TimeFirstLocked: TDateTime;

implementation

{$R *.lfm}

{ TFormManagerLogin }

function ELFHash(password: string): string;
var
  //cardinal cannot be negative unlike integer
  i, x, hashNum: cardinal;
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
  Result := IntToHex(hashNum, 8);
end;

function generateSalt: string;
var
  i: integer;
  salt: string;
begin
  salt := '';
  //generates a 5-10 length string consisting of ascii characters in a range
  for i := 0 to (random(5) + 5) do
    salt := salt + chr(random(93) + 33);
  Result := salt;
end;

//Clears login details for when login screen is accessed again
procedure resetConnection;
begin
  //Close connection in the login form
  FormManagerLogin.Conn.Close;
  FormManagerLogin.Trans.EndTransaction;
  FormManagerLogin.Query.Close;
  //clear edits for next user
  FormManagerLogin.EditUsername.Text := '';
  FormManagerLogin.EditPassword.Text := '';
  FormManager.EditCiphertext.Text := '';
  FormManager.EditOutputCiphertext.Text := '';
  FormManager.EditPlaintext.Text := '';
  FormManager.EditOutputPlaintext.Text := '';
  //Hides the login form
  FormManagerLogin.Hide;
  //shows the manager
  FormManager.ShowModal;
  //Shows the login form when the manager is exited
  FormManagerLogin.Show;
  //ensures all connections are close
  try
    FormManager.Conn.Close;
    FormManager.Trans.EndTransaction;
    FormManager.Query.Close;
  except
    ShowMessage('Could not close manager table');
  end;
end;

procedure TFormManagerLogin.FormCreate(Sender: TObject);
begin
  randomize;
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
          '"Password" VARCHAR(50) , "Salt" VARCHAR(10));');
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
  username, password, generatedSalt: string;
begin
  username := EditUsername.Text;
  password := EditPassword.Text;
  if length(password) >= 8 then
  begin
    Query.Close;
    Query.SQL.Text := 'SELECT Username FROM LoginInformation WHERE Username = ' +
      '"' + username + '"';
    Query.Open;
    if Query.FieldByName('Username').AsString = '' then
    begin
      generatedSalt := generateSalt;
      //appends salt to password string
      password := password + generatedSalt;
      //hash password
      password := ELFHash(password);
      // formats strings to fit in the sql query string
      username := '"' + username + '"';
      password := '"' + password + '"';
      generatedSalt := '"' + generatedSalt + '"';
      //UserID value is null since it is an auto-incremented field
      try
        conn.ExecuteDirect(
          'INSERT INTO LoginInformation (UserID, Username, Password, Salt) VALUES (NULL,' +
          username + ',' + password + ',' + generatedSalt + ');');
        trans.Commit;
        Conn.Close;
        ShowMessage('User created');
        EditUsername.Text := '';
        EditPassword.Text := '';
      except
        ShowMessage('Unable to add user to the database')
      end;
    end
    else
      ShowMessage('Username not available');
  end
  else
    ShowMessage('Password must be 8 characters or longer. Use the password words generator to create a strong password');
end;

procedure TFormManagerLogin.ButtonLoginClick(Sender: TObject);
var
  EnteredUsername, EnteredPassword, Password, SaltFromDB: string;
  log: TextFile;
begin
  query.Close;
  EnteredUsername := EditUsername.Text;
  EnteredPassword := EditPassword.Text;
  try
    AssignFile(Log, 'log.txt');
    reset(log);
  except
    ShowMessage('Unable to open log file.');
  end;
  try
    while not EOF(log) do
    begin
      readln(log, LastTimeLockedString);
    end;
  except
    ShowMessage('Unable to read from file');
  end;
  CloseFile(Log);
  //if it has been more than 30 seconds since the file was last locked
  if MilliSecondsBetween(StrToTime(LastTimeLockedString), Time) > 30000 then
  begin
    attempts := attempts + 1;
    if attempts < 3 then
    begin
      try
        Query.SQL.Clear;
        //gets the password associated with the inputted username
        Query.SQL.Text :=
          'SELECT UserId, Password, Salt FROM LoginInformation WHERE Username = ' +
          '"' + EnteredUsername + '"';
        Query.Open;
        //extracts the password from the query
        Password := Query.FieldByName('Password').AsString;
        UserID := Query.FieldByName('UserID').AsString;
        SaltFromDB := Query.FieldByName('Salt').AsString;
        EnteredPassword := ELFHash(EnteredPassword + SaltFromDB);
        //if the password entered by the user is the same as the password fetched
        //from the databased corresponding to the username, the login is successful
      except
        ShowMessage('Unable to get username and password');
      end;
      if Password = EnteredPassword then
      begin
        resetConnection;
        attempts := 0;
        EnteredUsername := '';
        EnteredPassword := '';
      end
      else
        ShowMessage('Login Failed');
    end
    else
    begin
      //if it is the first time that the user has exceeded the max attemps
      if attempts = 3 then
      begin
        //add the current time to the log file
        TimeFirstLocked := Time;
        try
          AssignFile(Log, 'log.txt');
          append(log);
          writeln(log, TimeToStr(TimeFirstLocked));
          CloseFile(Log);
        except
          ShowMessage('Unable to read log');
        end;
        ShowMessage('Too many attempts. Locked for 30 seconds');
      end;
      //if the user has already failed, check if the time has been exceeded
      if attempts > 3 then
      begin
        try
        AssignFile(Log, 'log.txt');
        reset(log);
        while not EOF(log) do
        begin
          readln(log, LastTimeLockedString);
        end;
        CloseFile(Log);
        except
          ShowMessage('Unable to read from log');
        end;
        if MilliSecondsBetween(StrToTime(LastTimeLockedString), Time) > 30000 then
        begin
          ShowMessage('Login has been unlocked. Try again');
          attempts := 0;
        end;
      end;
    end;
  end
  else
    ShowMessage('Too many attempts. Locked for 30 seconds');
end;

end.
