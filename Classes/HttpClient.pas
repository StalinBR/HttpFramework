unit HttpClient;

interface

uses
  Classes,
  URL, IdHTTP, Response;

type THttpClient = class(TObject)
private
  Furl :TURL;
  // Teste...Fmethod  :TIdHTTPMethod;
  Frequest :TStringStream;
  Fhttp :TIdHTTP;
  Ftoken :String;
protected

public
  function Send () :TResponse;
  constructor Create( Url :TURL; token :String; request :TStringStream);
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
  Fhttp := TIdHTTP.Create;
  Fhttp.Request.ContentType := 'application/json';
  Fhttp.Request.CustomHeaders.Values['Authorization'] := token;
end;

function THttpClient.Send: TResponse;
var
  url :String;
  lresponse :TStringStream;
begin
  lresponse := TStringStream.Create('');
  url := Furl.getURL;
  Fhttp.Post(url, Frequest, lresponse);
  Result := TResponse.Create( lresponse.DataString );
end;

end.
