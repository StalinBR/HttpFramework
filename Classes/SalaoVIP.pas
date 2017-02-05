unit SalaoVIP;

interface

uses
 Classes, Variants, SysUtils,
 Dialogs, 
 IdHTTP, uLkJSON;


type TSalaoVIP = class(TObject)
private
  procedure SetAmbiente(const Value: Integer);

protected
  Furl :String;
  Fnamespace :String;
  Ftoken :String;
  Fambiente :Integer;
  Fmetodo :String;
  FsalaoID :Integer;
  Fformart :TFormatSettings;
  lhttp :TIdHTTP;
  lparams :TStringList;
  RequestBody :TStringStream;
  lresponse :TStringStream;
  js: TlkJSONobject;
  ja: TlkJSONlist;  
public
  Fcode :Integer;

  constructor Create(salaoID :Integer; token :String);
  destructor Destroy; override;
  function ToString :String;
  procedure GravaLog(log :String);

published
  property token    :String read Ftoken write Ftoken;
  property ambiente :Integer read Fambiente write SetAmbiente;
  property metodo :String read Fmetodo write Fmetodo;
end;

implementation

uses DateUtils;
  const NAMESPACE_HOMOLOGACAO = 'http://apidev.salaovip.com.br/';
  const NAMESPACE_PRODUCAO    = 'http://api.salaovip.com.br/';

constructor TSalaoVIP.Create(salaoID :Integer; token :String);
var
  lambiente :Integer;
begin
  inherited Create;
  if salaoID = 8204 then lambiente := 0 else lambiente := 1;
  SetAmbiente(lambiente);
  FsalaoID  := salaoID;
  Ftoken    := token;
  lhttp := TIdHTTP.Create(nil);
  lparams := TStringList.Create;
  lresponse := TStringStream.Create('');
  Fformart.ShortDateFormat := 'yyyy-mm-dd';
end;

procedure TSalaoVIP.SetAmbiente(const Value: Integer);
begin
  Fambiente := Value;
  if Fambiente = 0 then
    Fnamespace := NAMESPACE_HOMOLOGACAO
  else
    Fnamespace := NAMESPACE_PRODUCAO;
end;

function TSalaoVIP.ToString: String;
begin
  Result := #13#10 + 'URL: '           + Furl +
            #13#10 + 'Authorization: ' + Ftoken +
            #13#10 + 'ContentType: '   + lhttp.Request.ContentType +
            #13#10 + 'Request: '       + lparams.Text +
                     'Resposta:'       + lresponse.DataString +
            #13#10;
end;

destructor TSalaoVIP.Destroy;
begin
  lhttp.Free;
  //RequestBody.Free;
  lparams.Free;
  lresponse.Free;
  inherited;
end;

procedure TSalaoVIP.GravaLog(log :String);
var
  data, NomeDoLog: string;
  Arquivo: TextFile;
begin
  data := IntToStr(DayOf(Now)) + IntToStr(MonthOf(Now)) + IntToStr(YearOf(Now));
  NomeDoLog := ExtractFileDir(ParamStr(0)) +'\LogSalaoVIP' + data + '.txt';
  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo) { se existir, apenas adiciona linhas }
  else
    ReWrite(Arquivo); { cria um novo se não existir }
  try
    Writeln( arquivo, DateTimeToStr(Now) + ' - ' + log );
  finally
    CloseFile(arquivo)
  end;
end;

end.