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
    procedure queryAfterDelete();
    procedure queryAfterPost();
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.queryAfterDelete();
begin
  try
    //apply deletions made using dbgrid
    query.ApplyUpdates;
    Trans.Commit;
  except
    on E: Exception do
      ShowMessage('Error');
  end;
end;

procedure TForm1.queryAfterPost();
begin
  try
  //applys edits and inserts made using dbgrid
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
  //UserID value is null since it is an auto-incremented field
  conn.ExecuteDirect('INSERT INTO LoginInformation (UserID,Username, Password) VALUES (NULL,' + username + ',' + password + ');');
  trans.Commit;
  ShowMessage('Added to DB');
end;

procedure TForm1.ButtonConnectClick(Sender: TObject);
var
  i : integer;
begin
  conn.open;
  query.close;
  //the sql query displayed in dbgrid
  query.sql.text := ('SELECT * FROM Manager');
  query.open;
  query.active := true;
  //makes the collums smaller than the defualt
  for i := 0 to grid.Columns.Count - 1 do
    grid.Columns.Items[i].Width := 90;
end;

end.

