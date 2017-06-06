unit Response;

interface

uses  uLkJSON;

type TResponse = class(TObject)
private
protected

public
  Fcode :Integer;
  Fmensagem :TlkJSONobject;
  function parseCode :Integer;
  function parseMessage :String;
  constructor Create( code :Integer; mensagem :TlkJSONobject );
  destructor Destroy; override;
published
  property code :Integer read Fcode write Fcode;
end;


implementation

uses SysUtils;


constructor TResponse.Create( code :Integer; mensagem :TlkJSONobject );
begin
  Fcode := code;
  Fmensagem := mensagem;
end;

destructor TResponse.Destroy;
begin
  inherited;
end;

function TResponse.parseCode: Integer;
var
  code :Integer;
begin
  TryStrToInt( Fmensagem.Field['code'].Value, code );
  Result := code;
end;

function TResponse.parseMessage: String;
var
 mensagem :String;
begin
  try
    mensagem := Fmensagem.Field['message'].Value;
  except
    mensagem := 'Erro não identificado';
  end;
  Result := mensagem;
end;

end.
