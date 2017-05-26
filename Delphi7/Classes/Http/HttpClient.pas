unit HttpClient;

interface

uses
  Classes, uLkJSON, SysUtils,
  URL, IdHTTP, Response;

type THttpClient = class(TObject)
private
  Furl :TURL;
  Frequest :TStringStream;
  Fresponse :TStringStream;
  Fhttp :TIdHTTP;
  Ftoken :String;
protected

public
  function ToString :String;
  function Get() :TResponse;
  function Delete() :TResponse;
  function Post () :TResponse;
  function Put ( request :TlkJSONobject ) :TResponse;
  constructor Create( Url :TURL; token :String; request :TStringStream);
  destructor Destroy; override;
published

end;


implementation

uses Math;

{ THttpClient }

constructor THttpClient.Create(Url: TURL; token: String;
  request: TStringStream);
begin
  Furl := Url;
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
     ljson.Add('Exception', E.Message);
     Result := TResponse.Create( 500,  ljson );
   end;
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

function THttpClient.Put( request :TlkJSONobject ) : TResponse;
var
  url :String;
  lresponse :TStringStream;
  ljson :TlkJSONObject;
begin
  ljson := TlkJSONObject.Create;
  lresponse := TStringStream.Create('');
  url := Furl.getURL;
  try
    Frequest.Create( TlkJSON.GenerateText(request) );
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
begin
    Result := #13#10 + 'URL: '           + Furl.getURL +
              #13#10 + 'Authorization: ' + Ftoken +
              #13#10 + 'ContentType: '   + Fhttp.Request.ContentType +
              #13#10 + 'Request: '       + Frequest.DataString +
                       'Resposta:'       + Fresponse.DataString +
              #13#10;

end;

end.
