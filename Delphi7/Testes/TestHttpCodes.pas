unit TestHttpCodes;

interface

uses TestFramework, SysUtils, DateUtils, Classes,
     URL, HttpClient, Response;

type
  TTestHttpCodes = class(TTestCase)
  private
    client :THttpClient;
    response :TResponse;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test200;
    procedure Test500;
  end;


implementation

{ TTestHttpCodes }

procedure TTestHttpCodes.SetUp;
begin
  inherited;

end;

procedure TTestHttpCodes.TearDown;
begin
  inherited;
  response.Free;
  client.Free;
end;

procedure TTestHttpCodes.Test200;
begin
  response := THttpClient.Create( TURL.Create(8204, epConsultaProfissionais ) , mtGet, '', TStringStream.Create('') ).Execute;
  CheckEquals(200, response.code);
end;

procedure TTestHttpCodes.Test500;
begin
  response := THttpClient.Create(TURL.Create(8204, epConsultaTransacoes) , mtDelete, 'TOKEN_HOMOLOG', TStringStream.Create('')).Execute ;
  CheckEquals(500, response.code);
end;

initialization
  TestFramework.RegisterTest('Teste de Códigos HTTP', TTestHttpCodes.Suite);

end.
