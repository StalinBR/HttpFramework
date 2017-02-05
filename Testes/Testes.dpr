program Testes;

uses
  Forms,
  TestFrameWork,
  GuiTestRunner,
  SalaoVIP in '..\Classes\SalaoVIP.pas',
  SalaoVipAgenda in '..\Classes\SalaoVipAgenda.pas',
  SalaoVipCliente in '..\Classes\SalaoVipCliente.pas',
  uAgenda in '..\Classes\uAgenda.pas',
  uCliente in '..\Classes\uCliente.pas',
  uProfissional in '..\Classes\uProfissional.pas',
  uLkJSON in '..\uLkJSON.pas',
  uComanda in '..\Classes\uComanda.pas',
  SalaoVipComanda in '..\Classes\SalaoVipComanda.pas',
  uServico in '..\Classes\uServico.pas',
  SalaoVipServico in '..\Classes\SalaoVipServico.pas',
  uComandaItens in '..\Classes\uComandaItens.pas',
  SalaoVipResponse in '..\Classes\SalaoVipResponse.pas',
  TesteApiSVIP in 'TesteApiSVIP.pas',
  URL in 'URL.pas',
  HttpClient in '..\Classes\HttpClient.pas';

{$R *.res}

begin
  Application.Initialize;
  GUITestRunner.RunRegisteredTests;
end.
