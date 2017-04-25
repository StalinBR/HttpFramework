unit Response;

interface

uses  System.JSON;

type TResponse = class(TObject)
private
  Fcode :Integer;
  Fmensagem :TJSONObject;
protected

public
  message :String;
  id :String;
  status :String;
  procedure ProcessarResposta;
  constructor Create( code :Integer; mensagem :TJSONObject );
  destructor Destroy; override;
published
  property code :Integer read Fcode write Fcode;
end;


implementation


constructor TResponse.Create( code :Integer; mensagem :TJSONObject );
begin
  Fcode := code;
  Fmensagem := mensagem;
  //Str := '{"Lista": '+ response + '}';
end;

destructor TResponse.Destroy;
begin
  inherited;
end;

procedure TResponse.ProcessarResposta;
begin

end;

end.
