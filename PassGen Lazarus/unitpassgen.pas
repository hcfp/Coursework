unit unitPassgen;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, unitWords, unitRandom;

type

  { TForm1 }

  TForm1 = class(TForm)
    ButtonWords: TButton;
    ButtonRandom: TButton;
    procedure ButtonRandomClick(Sender: TObject);
    procedure ButtonWordsClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.ButtonWordsClick(Sender: TObject);
begin
  Form2.ShowModal;
end;

procedure TForm1.ButtonRandomClick(Sender: TObject);
begin
  Form3.ShowModal;
end;

end.
