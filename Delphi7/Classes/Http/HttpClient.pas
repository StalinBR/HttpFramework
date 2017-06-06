unit HttpClient;

interface

uses
  Classes, uLkJSON, SysUtils,
  URL, IdHTTP, Response;

type TMethod = ( mtGet, mtPost, mtPut, mtDelete );

type THttpClient = class(TObject)
private
  Furl :TURL;
  Fmethod :TMethod;
  Frequest :TStringStream;
  Fresponse :TStringStream;
  Fhttp :TIdHTTP;
  Ftoken :String;
  function Get :TResponse;
  function Delete :TResponse;
  function Post  :TResponse;
  function Put  :TResponse;
  procedure GravaLog(log :String);
protected

public
  function Execute :Tresponse;
  function ToString :String;
  constructor Create( Url :TURL; method :TMethod; token :String; request :TStringStream);
  destructor Destroy; override;
published

end;


implementation

uses Math;

{ THttpClient }

constructor THttpClient.Create(Url: TURL; method :TMethod; token: String;
  request: TStringStream);
begin
  Furl := Url;
  Fmethod := method;
  Ftoken := token;
  Frequest := request;
  Fresponse := TStringStream.Create('');
  Fhttp := TIdHTTP.Create(nil);
  Fhttp.Request.ContentType := 'application/json';
  Fhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
end;

function THttpClient.Delete: TResponse;
var
  url :String;
  ljson :TlkJSONobject;
begin
  ljson := TlkJSONobject.Create;
  url := Furl.getURL;
  try
    Fhttp.Delete(url,Fresponse);
    ljson := TlkJSON.ParseText( Fresponse.DataString ) as TlkJSONobject;
    Result := TResponse.Create( Fhttp.ResponseCode, ljson );
  except on E :Exception do
   begin
     ljson.Add('code', 500);
     ljson.Add('Exception', E.Message);
     Fresponse := TStringStream.Create( TlkJSON.GenerateText(ljson) );
     Result := TResponse.Create( 500,  ljson );
   end;
  end;
end;

destructor THttpClient.Destroy;
begin
  Fhttp.Free;
  Frequest.Free;
  Fresponse.Free;
  Furl.Free;
  inherited;
end;

function THttpClient.Execute: Tresponse;
begin
  case Fmethod of
    mtGet    : Result := Get;
    mtPost   : Result := Post;
    mtPut    : Result := Put;
    mtDelete : Result := Delete;
  end;
  GravaLog( ToString );
end;

function THttpClient.Get: TResponse;
var
  url :String;
  ljson :TlkJSONobject;
begin
  ljson := TlkJSONobject.Create;
  url := Furl.getURL;
  try
    Fhttp.Get(url,Fresponse);
    ljson := TlkJSON.ParseText( Fresponse.DataString ) as TlkJSONobject;
    Result := TResponse.Create( Fhttp.ResponseCode, ljson );
  except on E :Exception do
   begin
     ljson.Add('code', 500);
     ljson.Add('message', 'Exception: ' + E.Message);
     Result := TResponse.Create( 500,  ljson );
   end;
  end;
end;

procedure THttpClient.GravaLog(log: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := ExtractFileDir(ParamStr(0)) +'\HTTPCLIENT' + '.txt';
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

function THttpClient.Post( ) : TResponse;
var
  url :String;
  lresponse :TStringStream;
  ljson :TlkJSONobject;
begin
  ljson := TlkJSONobject.Create;
  lresponse := TStringStream.Create('');
  url := Furl.getURL;
  try
    //Frequest.Create( TlkJSON.GenerateText(Frequest) );
    Fhttp.Post(url, Frequest, Fresponse);
    ljson :=  TlkJSON.ParseText( '{"Lista": '+ lresponse.DataString + '}' ) as TlkJSONobject;
    Result := TResponse.Create( Fhttp.ResponseCode, ljson );
  except on E :Exception do
   begin
    ljson.Add('Exception', E.Message);
    Result := TResponse.Create( 500, ljson );
   end;
  end;
end;

function THttpClient.Put : TResponse;
var
  url :String;
  lresponse :TStringStream;
  ljson :TlkJSONObject;
begin
  ljson := TlkJSONObject.Create;
  lresponse := TStringStream.Create('');
  url := Furl.getURL;
  try
    
    Fhttp.Post(url, Frequest, lresponse);
    ljson := TlkJSON.ParseText( '{"Lista": '+ lresponse.DataString + '}' ) as TlkJSONobject;
    Result := TResponse.Create( Fhttp.ResponseCode, ljson );
  except on E :Exception do
   begin
    ljson.Add('Exception', E.Message);
    Result := TResponse.Create( 500, ljson );
   end;
  end;
end;

function THttpClient.ToString: String;
var
  metodo :String;
begin
  case Fmethod of
    mtGet    : metodo := 'GET';
    mtPost   : metodo := 'POST';
    mtPut    : metodo := 'PUT';
    mtDelete : metodo := 'DELETE';
  end;


  Result := #13#10 + 'Method: '        + metodo +
            #13#10 + 'URL: '           + Furl.getURL +
            #13#10 + 'Authorization: ' + Ftoken +
            #13#10 + 'ContentType: '   + Fhttp.Request.ContentType +
            #13#10 + 'Request: '       + Frequest.DataString +
                     'Resposta:'       + Fresponse.DataString +
            #13#10;

end;

end.
