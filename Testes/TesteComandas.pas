unit TesteComandas;

interface

uses TestFramework,
     SalaoVipAgenda, SalaoVipComanda, SalaoVipServico,
     uTestesDAO, uAgendaDAO, uClientesDAO;

type
  TExportarComanda = class(TTestCase)
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
    procedure ExportaComanda;
    procedure ExportaServico;
    procedure ExportaItem;
  end;
implementation

uses SysUtils, Math,
     uComanda, uServico;

function TExportarComanda.DesformataHora(data: Integer): Integer;
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

procedure TExportarComanda.ExportaComanda;
var
  comanda :TComanda;
  retorno :String;
  clienteDAO :TClientesDAO;
  svipComanda :TSalaoVipComanda;
  numero :Integer;
begin
  Randomize;
  numero := RandomRange(1,100);

  comanda := TComanda.Create( Now, numero, 987008 );
  clienteDAO := TClientesDAO.Create;
  try
    svipComanda := TSalaoVipComanda.Create( clienteDAO.getSalaoID, clienteDAO.getToken );
    retorno := svipComanda.postComanda(comanda);
    svipComanda.GravaLog(svipComanda.ToString);
    //clienteDAO.AtualizaIdWeb( StrToInt(retorno), cliente.Fcodigo_empresa, cliente.Fcodigo_cliente );
    CheckNotEquals('', retorno);
  finally
    FreeAndNil( clienteDAO );
  end;
end;

procedure TExportarComanda.ExportaItem;
begin

end;

procedure TExportarComanda.ExportaServico;
var
  servico :TServico;
  retorno :String;
  svipServico :TSalaoVipServico;
  clienteDAO :TClientesDAO;
begin
  servico     := TServico.Create( 1, '01-TESTE', 0, 30, 0 );
  clienteDAO  := TClientesDAO.Create;
  svipServico := TSalaoVipServico.Create( clienteDAO.getSalaoID, clienteDAO.getToken );
  try
    retorno := svipServico.postServico( servico );
    svipServico.GravaLog(svipServico.ToString);
    CheckNotEquals('', retorno);
  finally
    FreeAndNil( servico );
    FreeAndNil( clienteDAO );
  end;
end;

procedure TExportarComanda.SetUp;
begin
  inherited;
  FDao := TTesteDAO.Create;
end;

procedure TExportarComanda.TearDown;
begin
  inherited;
  FDao.Free;
end;

procedure TExportarComanda.TestDao;
begin
  CheckTrue(Fdao.FSQLConnection.Connected);
end;


initialization
  TestFramework.RegisterTest('ExportarComandas', TExportarComanda.Suite);


end.
