program prjSincronismoWeb;

uses
  SvcMgr,
  uSincronismo in 'uSincronismo.pas' {TelesSincronismoWeb: TService},
  uLkJSON in 'uLkJSON.pas',
  uDAO in 'DAO\uDAO.pas',
  uAgendaDAO in 'DAO\uAgendaDAO.pas',
  uAgenda in 'Classes\uAgenda.pas',
  SalaoVIP in 'Classes\SalaoVIP.pas',
  SalaoVipAgenda in 'Classes\SalaoVipAgenda.pas',
  uParametrosDAO in 'DAO\uParametrosDAO.pas',
  uClientesDAO in 'DAO\uClientesDAO.pas',
  uCliente in 'Classes\uCliente.pas',
  SalaoVipCliente in 'Classes\SalaoVipCliente.pas',
  uProfissional in 'Classes\uProfissional.pas',
  uProfissionaisDAO in 'DAO\uProfissionaisDAO.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TTelesSincronismoWeb, TelesSincronismoWeb);
  Application.Run;
end.
