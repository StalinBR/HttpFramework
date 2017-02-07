program Testes;

uses
  Forms,
  TestFrameWork,
  GuiTestRunner,
  uLkJSON in '..\uLkJSON.pas',
  URL in 'URL.pas',
  HttpClient in '..\Classes\HttpClient.pas',
  Response in 'Response.pas',
  uComanda in '..\Classes\uComanda.pas',
  uComandaItens in '..\Classes\uComandaItens.pas',
  TesteApiSVIP in 'TesteApiSVIP.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
