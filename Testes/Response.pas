unit Response;

interface

uses uLkJSON;

type TResponse = class(TObject)
private
  Fresponse :TlkJSONobject;
protected

public
  message :String;
  code :String;
  id :String;
  procedure ProcessarResposta;
  constructor Create( response :String );
  destructor Destroy; override;
published

end;


implementation



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
  jsLista, jsData : TlkJSONobject;
begin
  jsLista := Fresponse.Field['Lista'] as TlkJSONobject;
  code := jsLista.Field['code'].value;
  if code = '200' then
  begin
    jsData  := jsLista.Field['data'] as TlkJSONobject;
    id      := jsData.Field['id'].Value;
  end
  else
    message := jsLista.Field['message'].value;
end;

end.
