program Testes;

uses
  Forms,
  TestFrameWork in 'D:\dunit-9.3.0\src\TestFrameWork.pas',
  GuiTestRunner in 'D:\dunit-9.3.0\src\GuiTestRunner.pas',
  uLkJSON in '..\uLkJSON.pas',
  URL in 'URL.pas',
  HttpClient in 'D:\Projetos\SVIP\Classes\HttpClient.pas',
  Response in '..\Testes\Response.pas',
  uComanda in 'D:\Projetos\SVIP\Classes\uComanda.pas',
  uComandaItens in 'D:\Projetos\SVIP\Classes\uComandaItens.pas',
  TesteApiSVIP in 'TesteApiSVIP.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
