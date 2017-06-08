unit URL;

interface

uses IURL;

type TEndpoint = ( epConsultaTransacoes, epTransacao,
                   epConsultaProfissionais, epProfissional  );

type TURL = class(TInterfacedObject, IUrls)
private
  Furl :String;
  Fnamespace :String;
  Fambiente :Integer;
  FsalaoID :Integer;
  Fmetodo :TEndpoint;
  FmetodoID :String;
  procedure SetAmbiente(const Value: Integer);
  function getEndpoint( Fmetodo :TEndpoint ) :String;
protected

public
  function getURL :String;
  constructor Create(salaoID :Integer; metodo :TEndpoint; metodoID :String = '' );
  destructor Destroy; override;
published

end;


implementation

uses SysUtils;

  const NAMESPACE_HOMOLOGACAO = 'http://apidev.salaovip.com.br/';
  const NAMESPACE_PRODUCAO    = 'http://api.salaovip.com.br/';


{ TURL }

constructor TURL.Create(salaoID: Integer; metodo: TEndpoint; metodoID :String  = '');
var
  lambiente :Integer;
begin
  inherited Create;
  if salaoID = 7083 then lambiente := 0 else lambiente := 1;
  SetAmbiente(lambiente);
  FsalaoID  := salaoID;
  Fmetodo := metodo;
  FmetodoID := metodoID;
end;

destructor TURL.Destroy;
begin

  inherited;
end;

function TURL.getEndpoint(Fmetodo: TEndpoint): String;
begin
  case Fmetodo of

    epConsultaTransacoes    : Result := '/gopague/transacoes';
    epTransacao             : Result := '/gopague/transacao/';
    epConsultaProfissionais : Result := '/profissionais';
    epProfissional          : Result := '/profissional/';

  end;

end;

function TURL.getURL: String;
begin
  Result := Fnamespace + 'salao/' + IntToStr(FsalaoID) + getEndpoint(Fmetodo) + FmetodoID ;
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
