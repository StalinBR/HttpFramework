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
  response := THttpClient.Create( TURL.Create(8204, 'profissionais') , '', nil ).Get();
  CheckEquals(200, response.code);
end;

procedure TTestHttpCodes.Test500;
begin
  response := THttpClient.Create( TURL.Create(8204, 'url_invalida') , '', nil ).Get();
  CheckEquals(500, response.code);
end;

procedure TTestHttpCodes.TestDelete;
begin
  client := THttpClient.Create(TURL.Create(8204, 'url_invalida') , 'TOKEN_HOMOLOG', TStringStream.Create('') );
  response := client.Delete();
  CheckEquals(500, response.parseCode);
  GravaLog( client.ToString ); 
  //CheckEquals(500, response.code);
end;

initialization
  TestFramework.RegisterTest('Teste de Códigos HTTP', TTestHttpCodes.Suite);

end.
