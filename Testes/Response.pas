unit Response;

interface

uses uLkJSON;

type TResponse = class(TObject)
private
  Fresponse :TlkJSONobject;
  function CheckNodeExists( js :TlkJSONobject; name :String) :Boolean;
protected

public
  message :String;
  code :String;
  id :String;
  status :String;
  procedure ProcessarResposta;
  constructor Create( response :String );
  destructor Destroy; override;
published

end;


implementation



function TResponse.CheckNodeExists(js: TlkJSONobject;
  name: String): Boolean;
var
  leitura :String;
begin
  try
    leitura := js.Field[name].Value;
    Result := True;
  except
    Result := False;
  end;
end;

constructor TResponse.Create( response :String );
var
  Str :String;
begin
  Str := '{"Lista": '+ response + '}';
  Fresponse := TlkJSON.ParseText( Str ) as TlkJSONobject
end;

destructor TResponse.Destroy;
begin
  Fresponse.Free;
  inherited;
end;

procedure TResponse.ProcessarResposta;
var
  jsLista, jsData, jsPayment : TlkJSONobject;
begin
  jsLista := Fresponse.Field['Lista'] as TlkJSONobject;
  code := jsLista.Field['code'].value;
  if code = '200' then
  begin
    jsData  := jsLista.Field['data'] as TlkJSONobject;
    id      := jsData.Field['id'].Value;
    jsPayment := jsData.Field['paymentRequest'] as TlkJSONobject;
    if CheckNodeExists(jsPayment, 'id') then
      id      := jsPayment.Field['id'].Value;
    if CheckNodeExists(jsPayment, 'status') then
      status := jsPayment.Field['status'].Value;
  end
  else
    message := jsLista.Field['message'].value;
end;

end.
