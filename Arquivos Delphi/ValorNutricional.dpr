program ValorNutricional;

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Android.JNI.Toast in 'C:\Program Files (x86)\Embarcadero\Studio\15.0\source\rtl\android\Android.JNI.Toast.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
