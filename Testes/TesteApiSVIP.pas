unit TesteApiSVIP;

interface

uses TestFramework, Classes,
     uComanda,
     HttpClient, URL,
     Response;

type
  TApiTeste = class(TTestCase)
  private
  protected

    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TesteNew;
  end;
implementation

uses SysUtils,
     Math;

procedure TApiTeste.SetUp;
begin
  inherited;
end;

procedure TApiTeste.TearDown;
begin
  inherited;
end;

procedure TApiTeste.TesteNew;
var
  httpclient :THttpClient;
  comanda :TComanda;
  response :TResponse;
begin
  comanda := TComanda.Create(Now, 1, 824075);
  httpclient := THttpClient.Create( TURL.Create(8204, 'comanda'), '', TStringStream.Create( comanda.ToJson ) );
  response := httpclient.Send();
  response.ProcessarResposta;
  CheckEquals('400', response.code);
end;

initialization
  TestFramework.RegisterTest('Api-SVIP', TApiTeste.Suite);


end.
