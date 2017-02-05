unit TesteExportar;

interface

uses TestFramework,
     SalaoVipAgenda, SalaoVipCliente,
     uTestesDAO, uAgendaDAO, uClientesDAO;

type
  TExportarTeste = class(TTestCase)
  private
    FDao : TTesteDAO;
    FAgendaDao :TAgendaDAO;
    FsalaoVIP :TSalaoVipAgenda;
    Flista :ListaAgenda;
    function DesformataHora (data :Integer) :Integer;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDao;
    procedure PesquisaCliente;
    procedure ExportaCliente;
    procedure ExportarAgenda;
  end;
implementation

uses SysUtils, 
     uProfissional, uCliente, Math;

function TExportarTeste.DesformataHora(data: Integer): Integer;
var
 vHora :Double;
 vMin :Integer;
begin
  // TELES -> SVIP
  vHora := Trunc( data / 100 );
  vHora := ( vHora * 60 ) ;
  vMin :=  ( data mod 100 );
  Result := Trunc(vHora) + vMin;
end;

procedure TExportarTeste.ExportaCliente;
var
  cliente :TCliente;
  retorno :String;
  clienteDAO :TClientesDAO;
  svipCliente :TSalaoVipCliente;
begin
  clienteDAO := TClientesDAO.Create;
  try
    cliente := clienteDAO.PesquisaClienteByAgenda( Flista[0].Fcontrole );
    svipCliente := TSalaoVipCliente.Create( clienteDAO.getSalaoID, clienteDAO.getToken);
    if Cliente.Fid_web > 0 then
      retorno := ''
    else
      retorno := svipCliente.postCliente(cliente);
    svipCliente.GravaLog(svipCliente.ToString);
    clienteDAO.AtualizaIdWeb( StrToInt(retorno), cliente.Fcodigo_empresa, cliente.Fcodigo_cliente );
     CheckNotEquals('', retorno);
  finally
    FreeAndNil( clienteDAO );
  end;
end;

procedure TExportarTeste.ExportarAgenda;
var
 retorno : String;
begin
  Flista[0].FclienteIdWeb       := FagendaDAO.PesquisaClienteID( Flista[0].Fcontrole );
  Flista[0].FprofissionalIdWeb  := FagendaDAO.PesquisaProfissionalID( IntToStr(  Flista[0].Fcodigo_profissional), IntToStr(Flista[0].Femp_profissional) );
  Flista[0].FsalaoIdWeb         := FagendaDAO.PesquisaSalaoID( FagendaDAO.Fempresa_padrao );
  Flista[0].Fhora               := DesformataHora( Flista[0].Fhora );
  Flista[0].Ffim                := DesformataHora( Flista[0].Ffim );
  Flista[0].Fservicos           := FagendaDAO.PesquisaServicoAgenda( Flista[0].Fcontrole );
  retorno := FsalaoVIP.Execute( Flista[0] );
  FsalaoVIP.GravaLog(FsalaoVIP.ToString);
  FAgendaDao.UpdateIdWeb( Flista[0].Fcontrole, StrToInt(retorno)   );
  FAgendaDao.BaixaControle( Flista[0].Fcontrole_web, 'BAX' );
  CheckNotEquals('', retorno);
end;

procedure TExportarTeste.PesquisaCliente;
var
  cliente :TCliente;
  retorno :String;
  clienteDAO :TClientesDAO;
  svipCliente :TSalaoVipCliente;
begin
  clienteDAO := TClientesDAO.Create;
  try
    cliente := clienteDAO.PesquisaClienteByAgenda(Flista[0].Fcontrole);
    svipCliente := TSalaoVipCliente.Create( clienteDAO.getSalaoID, clienteDAO.getToken );
    CheckEquals(0, cliente.Fid_web);
  finally
    FreeAndNil( clienteDAO );
  end;
end;

procedure TExportarTeste.SetUp;
begin
  inherited;
  FDao := TTesteDAO.Create;
  FAgendaDao := TAgendaDAO.Create;
  FsalaoVIP := TSalaoVipAgenda.Create( FDao.getSalaoID, FDao.getToken );
  Flista := FAgendaDao.listaAgenda;
end;

procedure TExportarTeste.TearDown;
begin
  inherited;
  FDao.Free;
  FAgendaDao.Free;
  FsalaoVIP.Free;
end;

procedure TExportarTeste.TestDao;
begin
//  Flista := FAgendaDao.listaAgenda;
  CheckNotEquals(0, Length(Flista));
end;


initialization
  TestFramework.RegisterTest('ExportarAgendamento', TExportarTeste.Suite);


end.
