program PasswordSuiteProject;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainMenu, ManagerLoginUnit, TesterUnit, GenUnit, Manager
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormPasswordSuite, FormPasswordSuite);
  Application.CreateForm(TFormManagerLogin, FormManagerLogin);
  Application.CreateForm(TFormTester, FormTester);
  Application.CreateForm(TFormGen, FormGen);
  Application.CreateForm(TFormManager, FormManager);
  Application.Run;
end.

