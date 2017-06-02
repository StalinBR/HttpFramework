unit TestHttpCodes;

interface

uses TestFramework, SysUtils, DateUtils, Classes,
     URL, HttpClient, Response;

type
  TTestHttpCodes = class(TTestCase)
  private
    client :THttpClient;
    response :TResponse;
    procedure GravaLog(log :String);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test200;
    procedure Test500;
    procedure TestDelete;
  end;


implementation

{ TTestHttpCodes }

procedure TTestHttpCodes.GravaLog(log: String);
var
  data, NomeDoLog: string;
  Arquivo: TextFile;
begin
  data := IntToStr(DayOf(Now)) + IntToStr(MonthOf(Now)) + IntToStr(YearOf(Now));
  NomeDoLog := ExtractFileDir(ParamStr(0)) +'\LogSalaoVIP' + data + '.txt';
  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo)
  else
    ReWrite(Arquivo); 
  try
    Writeln( arquivo, DateTimeToStr(Now) + ' - ' + log );
  finally
    CloseFile(arquivo)
  end;
end;

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
  response := THttpClient.Create( TURL.Create(8204, 'profissionais') , mtGet, '', TStringStream.Create('') ).Execute;
  CheckEquals(200, response.code);
end;

procedure TTestHttpCodes.Test500;
begin
  response := THttpClient.Create( TURL.Create(8204, 'url_invalida') , mtGet, '', TStringStream.Create('') ).Execute;
  CheckEquals(500, response.code);
end;

procedure TTestHttpCodes.TestDelete;
begin
  response := THttpClient.Create(TURL.Create(8204, 'url_invalida') , mtDelete, 'TOKEN_HOMOLOG', TStringStream.Create('')).Execute ;
  CheckEquals(500, response.parseCode);
  //CheckEquals(500, response.code);
end;

initialization
  TestFramework.RegisterTest('Teste de Códigos HTTP', TTestHttpCodes.Suite);

end.
