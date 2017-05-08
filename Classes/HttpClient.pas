unit HttpClient;

interface

uses
  Classes,  System.JSON, System.SysUtils,
  URL, IdHTTP, Response;

type THttpClient = class(TObject)
private
  Furl :TURL;
  Frequest :TStringStream;
  Fhttp :TIdHTTP;
  Ftoken :String;
protected

public
  function Send () :TResponse;
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
  Frequest := request;
  Fhttp := TIdHTTP.Create(nil);
  Fhttp.Request.ContentType := 'application/json';
  Fhttp.Request.CustomHeaders.Values['Authorization'] := token;
end;

destructor THttpClient.Destroy;
begin
  Fhttp.Free;
  Frequest.Free;
  Furl.Free;
  inherited;
end;

function THttpClient.Send: TResponse;
var
  url :String;
  lresponse :TStringStream;
  ljson :TJSONObject;
begin
  ljson := TJSONObject.Create;
  lresponse := TStringStream.Create('');
  url := Furl.getURL;
  try
  Fhttp.Get(url,lresponse);
  ljson.Parse(BytesOf(lresponse.DataString), 0);
  Result := TResponse.Create( Fhttp.ResponseCode, ljson );
  except on E :Exception do
    Result := TResponse.Create( 500, ljson.AddPair(TJSONPair.Create(TJSONString.Create('Exception'),
                                                              TJSONString.Create(E.Message))));
  end;
end;

end.
