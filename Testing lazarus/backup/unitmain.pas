unit unitMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls, unitWordList, unitSimple;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonWordList: TButton;
    ButtonSimple: TButton;
    procedure ButtonSimpleClick(Sender: TObject);
    procedure ButtonWordListClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonWordListClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.ButtonSimpleClick(Sender: TObject);
begin
  Form3.ShowModal;
end;

end.

