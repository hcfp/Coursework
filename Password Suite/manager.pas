unit Manager;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, DB, sqlite3conn, FileUtil, Forms, Controls,
  Graphics, Dialogs, ComCtrls, DBGrids, DBCtrls, StdCtrls, Menus;

type

  { TFormManager }

  TFormManager = class(TForm)
    ButtonConnect: TButton;
    DBEditPassword1: TDBEdit;
    DBEditUsername: TDBEdit;
    DBEditPassword: TDBEdit;
    LabelAddEdit: TLabel;
    LabelEditUsername: TLabel;
    LabelEditPassword: TLabel;
    LabelEditUserID: TLabel;
    Source: TDataSource;
    Grid: TDBGrid;
    DBNavigator1: TDBNavigator;
    PageControl1: TPageControl;
    Conn: TSQLite3Connection;
    Query: TSQLQuery;
    Trans: TSQLTransaction;
    TabSheetManager: TTabSheet;
    procedure ButtonConnectClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure QueryAfterDelete();
    procedure QueryAfterPost();
  private

  public

  end;

var
  FormManager: TFormManager;

implementation

{$R *.lfm}

uses ManagerLoginUnit;

{ TFormManager }

procedure TFormManager.ButtonConnectClick(Sender: TObject);
var
  i: integer;
begin
  conn.Open;
  query.Close;
  //the sql query displayed in dbgrid
  query.sql.Text := ('SELECT UserID, Username, Password FROM Manager WHERE UserID = '
    + UserID);
  query.Open;
  query.active := True;
  //makes the collums smaller than the defualt
  for i := 0 to grid.Columns.Count - 1 do
    grid.Columns.Items[i].Width := 90;
end;

procedure TFormManager.FormCreate(Sender: TObject);
begin
  Grid.AllowOutboundEvents:=false;
end;

//applys edits, edits and deletions made using dbgrid
procedure TFormManager.QueryAfterDelete();
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

procedure TFormManager.QueryAfterPost();
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

end.
