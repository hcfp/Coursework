unit MainMenu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ComCtrls, ManagerLoginUnit, TesterUnit, GenUnit;

type

  { TFormPasswordSuite }

  TFormPasswordSuite = class(TForm)
    ButtonGen: TButton;
    ButtonTester: TButton;
    ButtonManager: TButton;
    Panel1: TPanel;
    procedure ButtonGenClick(Sender: TObject);
    procedure ButtonManagerClick(Sender: TObject);
    procedure ButtonTesterClick(Sender: TObject);
  private

  public

  end;

var
  FormPasswordSuite: TFormPasswordSuite;

implementation

{$R *.lfm}

{ TFormPasswordSuite }

procedure TFormPasswordSuite.ButtonManagerClick(Sender: TObject);
begin
  //Hide main menu
  FormPasswordSuite.Hide;
  //show login form and disable control to other forms until close
  FormManagerLogin.ShowModal;
  //Shows the main menu once the login screen has been closed
  FormPasswordSuite.Show;
end;

procedure TFormPasswordSuite.ButtonGenClick(Sender: TObject);
begin
  FormPasswordSuite.Hide;
  FormGen.ShowModal;
  FormPasswordSuite.Show;
  FormGen.PageControl1.ActivePageIndex := 0;
end;

procedure TFormPasswordSuite.ButtonTesterClick(Sender: TObject);
begin
  FormPasswordSuite.Hide;
  FormTester.ShowModal;
  FormPasswordSuite.Show;
  FormTester.PageControl1.ActivePageIndex := 0;
end;

end.

