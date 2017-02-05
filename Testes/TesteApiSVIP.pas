unit TesteApiSVIP;

interface

uses TestFramework, Classes,
     uComanda,
     HttpClient, URL,
     SalaoVipAgenda, SalaoVipCliente, SalaoVipComanda, SalaoVipResponse;

type
  TApiTeste = class(TTestCase)
  private
    FsalaoVIP :TSalaoVipAgenda;
  protected

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TesteComanda;
    procedure TesteNew;
  end;
implementation

uses SysUtils,
     uProfissional, uCliente, Math;

procedure TApiTeste.SetUp;
begin
  inherited;
  FsalaoVIP := TSalaoVipAgenda.Create( 8204, '' );
end;

procedure TApiTeste.TearDown;
begin
  inherited;
  FsalaoVIP.Free;
end;


procedure TApiTeste.TesteComanda;
var
  svip :TSalaoVipComanda;
  response :TSalaoVipResponse;
  comanda :TComanda;
begin
  svip := TSalaoVipComanda.Create(8204, '');
  comanda := TComanda.Create(Now, 1, 824075);
  response := svip.postComanda(comanda);
  response.ProcessarResposta;
  CheckEquals('401', response.code);
end;

procedure TApiTeste.TesteNew;
var
  httpclient :THttpClient;
  comanda :TComanda;
begin
  comanda := TComanda.Create(Now, 1, 824075);
  httpclient := THttpClient.Create( TURL.Create(8204, 'comanda'), '', TStringStream.Create( comanda.ToJson ) );
end;

initialization
  TestFramework.RegisterTest('Api-SVIP', TApiTeste.Suite);


end.
