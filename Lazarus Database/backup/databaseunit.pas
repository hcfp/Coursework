unit DatabaseUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqlite3conn, sqldb, db, FileUtil, Forms, Controls,
  Graphics, Dialogs, StdCtrls, DBGrids, DbCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonConnect: TButton;
    ButtonSubmit: TButton;
    conn: TSQLite3Connection;
    DBEditUsername: TDBEdit;
    DBEditPassword: TDBEdit;
    DBNavigator1: TDBNavigator;
    LabelEditPassword: TLabel;
    LabelEditUsername: TLabel;
    source: TDataSource;
    grid: TDBGrid;
    EditPassword: TEdit;
    EditUsername: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    query: TSQLQuery;
    trans: TSQLTransaction;
    procedure ButtonConnectClick(Sender: TObject);
    procedure ButtonSubmitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure queryAfterDelete(;
    procedure queryAfterPost();
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.FormCreate(Sender: TObject);
var
  newFile : Boolean;
begin

  conn.Close; // Ensure the connection is closed when we start

  try
    // Since we're making this database for the first time,
    // check whether the file already exists
    newFile := not FileExists(conn.DatabaseName);

    if newFile then
    begin
      // Create the database and the tables
      try
        conn.Open;
        trans.Active := true;
        conn.ExecuteDirect('CREATE TABLE "LoginInformation" (' +
                           '"UserID" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,'+
                           '"Username" VARCHAR(50),'+
                           '"Password" VARCHAR(50));');
        trans.Commit;
        ShowMessage('Succesfully created database.');
      except
        ShowMessage('Unable to Create new Database');
      end;
    end;
  except
    ShowMessage('Unable to check if database file exists');
  end;
 end;

procedure TForm1.queryAfterDelete();
begin
  query.ApplyUpdates;
  trans.commit;
end;

procedure TForm1.queryAfterPost();
begin
   try
    query.ApplyUpdates;
    Trans.Commit;
  except
    on E: Exception do
      ShowMessage('Error');
  end;
end;

procedure TForm1.ButtonSubmitClick(Sender: TObject);
var
  username, password : string;
begin
  username := EditUsername.Text;
  password := EditPassword.Text;
  // formats strings to fit in the sql query string
  username := '"' + username + '"';
  password := '"' + password + '"';
  conn.ExecuteDirect('INSERT INTO LoginInformation (UserID,Username, Password) VALUES (NULL,' + username + ',' + password + ');');
  trans.Commit;
  ShowMessage('Added to DB');
end;

procedure TForm1.ButtonConnectClick(Sender: TObject);
var
  i : integer;
begin
  query.close;
  query.sql.text := ('SELECT * FROM LoginInformation');
  query.open;
  query.active := true;
  for i := 0 to grid.Columns.Count - 1 do
  grid.Columns.Items[i].Width := 90;
end;

end.

