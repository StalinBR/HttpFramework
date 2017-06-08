program Testes;

uses
  Forms,
  TestFrameWork,
  GuiTestRunner,
  uLkJSON in '..\Classes\Terceiros\uLkJSON.pas',
  HttpClient in '..\Classes\Http\HttpClient.pas',
  Response in '..\Classes\Http\Response.pas',
  URL in '..\Classes\Http\URL.pas',
  TestHttpCodes in 'TestHttpCodes.pas',
  TrasancaoGoPague in '..\..\..\Delphi 7\Teles Cabeleireiros\Aplicação\SVIP\Classes\TrasancaoGoPague.pas',
  uTransacoesDAO in '..\Classes\DAO\uTransacoesDAO.pas',
  uDAO in '..\Classes\DAO\uDAO.pas',
  TestTransacoes in 'TestTransacoes.pas',
  IURL in '..\Interfaces\IURL.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
