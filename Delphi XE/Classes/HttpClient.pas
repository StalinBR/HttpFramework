unit HttpClient;

interface

uses
  Classes,  System.JSON, System.SysUtils,
  URL, IdHTTP, Response;

type THttpClient = class(TObject)
private
  Furl :TURL;
  Fjson :TJSONObject;
  Fresponse :TStringStream;
  Frequest :TStringStream;
  Fhttp :TIdHTTP;
  Ftoken :String;
protected

public
  function Get () :TResponse;
  function Post ( request :TJSONObject ) :TResponse;
  function Put ( request :TJSONObject ) :TResponse;
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
  Fjson := TJSONObject.Create;
  Fresponse := TStringStream.Create('');
  Frequest := request;
  Fhttp := TIdHTTP.Create(nil);
  Fhttp.Request.ContentType := 'application/json';
  Fhttp.Request.CustomHeaders.Values['Authorization'] := token;
end;

destructor THttpClient.Destroy;
begin
  Fhttp.Free;
  Fjson.Free;
  Fresponse.Free;
  Frequest.Free;
  Furl.Free;
  inherited;
end;

function THttpClient.Get: TResponse;
var
  url :String;
begin
  url := Furl.getURL;
  try
    Fhttp.Get(url,Fresponse);
    Fjson.Parse(BytesOf(Fresponse.DataString), 0);
    Result := TResponse.Create( Fhttp.ResponseCode, Fjson );
  except on E :Exception do
    Result := TResponse.Create( 500, Fjson.AddPair(TJSONPair.Create(TJSONString.Create('Exception'),
                                                              TJSONString.Create(E.Message))));
  end;
end;

function THttpClient.Post( request :TJSONObject ) : TResponse;
var
  url :String;
begin
  url := Furl.getURL;
  try
    Fhttp.Post(url,request.ToString, Fresponse);
    Fjson.Parse(BytesOf(Fresponse.DataString), 0);
    Result := TResponse.Create( Fhttp.ResponseCode, Fjson );
  except on E :Exception do
    Result := TResponse.Create( 500, Fjson.AddPair(TJSONPair.Create(TJSONString.Create('Exception'),
                                                              TJSONString.Create(E.Message))));
  end;
end;

function THttpClient.Put( request :TJSONObject ) : TResponse;
var
  url :String;
begin
  url := Furl.getURL;
  try
    Fhttp.Post(url,request.ToString, Fresponse);
    Fjson.Parse(BytesOf(Fresponse.DataString), 0);
    Result := TResponse.Create( Fhttp.ResponseCode, Fjson );
  except on E :Exception do
    Result := TResponse.Create( 500, Fjson.AddPair(TJSONPair.Create(TJSONString.Create('Exception'),
                                                              TJSONString.Create(E.Message))));
  end;
end;

end.
