program Testes;

uses
  Forms,
  TestFrameWork,
  GuiTestRunner,
  uLkJSON in '..\Classes\Terceiros\uLkJSON.pas',
  HttpClient in '..\Classes\Http\HttpClient.pas',
  Response in '..\Classes\Http\Response.pas',
  URL in '..\Classes\Http\URL.pas',
  TestHttpCodes in 'TestHttpCodes.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
