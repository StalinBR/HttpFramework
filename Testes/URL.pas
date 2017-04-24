unit URL;

interface

type TURL = class(TObject)
private
  Furl :String;
  Fnamespace :String;
  Fambiente :Integer;
  FsalaoID :Integer;
  Fmetodo :String;
  procedure SetAmbiente(const Value: Integer);
protected

public
  function getURL :String;
  constructor Create(salaoID :Integer; metodo :String);
  destructor Destroy; override;
published

end;


implementation

uses SysUtils;

  const NAMESPACE_HOMOLOGACAO = 'http://apidev.salaovip.com.br/';
  const NAMESPACE_PRODUCAO    = 'http://api.salaovip.com.br/';


{ TURL }

constructor TURL.Create(salaoID: Integer; metodo: String);
var
  lambiente :Integer;
begin
  inherited Create;
  if salaoID = 8204 then lambiente := 0 else lambiente := 1;
  SetAmbiente(lambiente);
  FsalaoID  := salaoID;
  Fmetodo := metodo;
end;

destructor TURL.Destroy;
begin

  inherited;
end;

function TURL.getURL: String;
begin
  Result := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/'+ Fmetodo ;
end;

procedure TURL.SetAmbiente(const Value: Integer);
begin
  Fambiente := Value;
  if Fambiente = 0 then
    Fnamespace := NAMESPACE_HOMOLOGACAO
  else
    Fnamespace := NAMESPACE_PRODUCAO;
end;

end.
