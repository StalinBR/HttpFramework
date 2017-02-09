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

const TOKEN =  'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImp0aSI6IjRmMWcyM2ExMmFhIn0.'
              +'eyJpc3MiOiJodHRwOlwvXC9zYWxhb3ZpcC5jb20uYnIiLCJhdWQiOiJodHRwOlwvX'
              +'C9zYWxhb3ZpcC50ZXJjZWlyby5iciIsImp0aSI6IjRmMWcyM2ExMmFhIiwiaWF0Ij'
              +'oxNDgxNTU1NDM0LCJuYmYiOjE0ODE1NTU0MzQsImV4cCI6MTQ4MTU1OTAzNCwidWl'
              +'kIjo4MjA0LCJqd3RjbGllbnQiOiJTQGxhb1YxUCJ9.1Fp_lfHVxRZzCiBAiisz7KFTvCypIDGWW9r0Pv4XbjM';



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
  comanda := TComanda.Create(Now, 4, 824075);
  httpclient := THttpClient.Create( TURL.Create(8204, 'comanda'), TOKEN, TStringStream.Create( comanda.ToJson ) );
  response := httpclient.Send();
  response.ProcessarResposta;
  CheckEquals('200', response.code);
end;

initialization
  TestFramework.RegisterTest('Api-SVIP', TApiTeste.Suite);


end.
