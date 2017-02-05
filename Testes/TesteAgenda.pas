unit TesteAgenda;

interface

uses TestFramework, uDAO, uTestesDAO, uAgendaDAO;

type
  TAgendaTeste = class(TTestCase)
  private
    FDao : TTesteDAO;
    FAgendaDao :TAgendaDAO;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestConexao;
    procedure TestInsertAgendamento;
    procedure TestIntertFolga;
  end;
implementation

uses SysUtils, 
     uProfissional, uCliente, Math;

procedure TAgendaTeste.SetUp;
begin
  inherited;
  FDao := TTesteDAO.Create;
  FAgendaDao := TAgendaDAO.Create;
end;

procedure TAgendaTeste.TearDown;
begin
  inherited;
  FDao.Free;
  FAgendaDao.Free;
end;

procedure TAgendaTeste.TestConexao;
begin
  CheckTrue(FDao.FSQLConnection.Connected);
end;


procedure TAgendaTeste.TestInsertAgendamento;
var
  data: TDateTime;
  profissional :TProfissional;
  cliente :TCliente;
  r, horario, fim: Integer;
  status, servico, nome, app: String;
  id_web: Integer;
begin
  data := Now;
  profissional := FDao.RandomProfisisonal;
  cliente := FDao.RandomCliente;
  Randomize;
  r := RandomRange(10,19);
  horario := r *100;
  //status  := 'O';
  //fim     := horario + 200;
  status := 'M';
  fim     := horario + 30;
  servico := 'TESTE_TELES';
  nome    := 'Reinaldo';
  app     := '2';
  id_web  := 0;
  CheckTrue( FAgendaDao.IncluiAgendamento( data, profissional.Fcodigo_profissional, profissional.Fcodigo_empresa,
                                           cliente.Fcodigo_cliente, cliente.Fcodigo_empresa,
                                           horario, fim, status, servico, nome, app, id_web)     );

end;

procedure TAgendaTeste.TestIntertFolga;
var
  data: TDateTime;
  profissional :TProfissional;
  cliente :TCliente;
  r, horario, fim: Integer;
  status, servico, nome, app: String;
  id_web: Integer;
begin
  data := Now;
  profissional := FDao.RandomProfisisonal;
  cliente := FDao.RandomCliente;
  Randomize;
  r := RandomRange(10,19);
  horario := r *100;
  status  := 'O';
  fim     := horario + 100;
  servico := 'TESTE_TELES';
  nome    := 'Reinaldo';
  app     := '2';
  id_web  := 0;
  CheckTrue( FAgendaDao.IncluiAgendamento( data, profissional.Fcodigo_profissional, profissional.Fcodigo_empresa,
                                           cliente.Fcodigo_cliente, cliente.Fcodigo_empresa,
                                           horario, fim, status, servico, nome, app, id_web)     );

end;

initialization
  TestFramework.RegisterTest('NovoAgendamento', TAgendaTeste.Suite);


end.
