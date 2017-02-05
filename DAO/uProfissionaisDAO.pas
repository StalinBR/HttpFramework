unit uProfissionaisDAO;

interface

uses
 SysUtils, uCliente,
 uDAO, uProfissional,
 SqlExpr;

type TProfissionaisDAO = class(TDAO)
private

protected

public
  FqryParametros: TSQLQuery;

  function PesquisaProfissionaisById( id :Integer ) :TProfissional;
  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

{ TParametrosEmailDAO }

constructor TProfissionaisDAO.Create;
begin
  AbreBanco;
end;

destructor TProfissionaisDAO.Destroy;
begin
  inherited;
end;

function TProfissionaisDAO.PesquisaProfissionaisById( id :Integer ) :TProfissional;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT P.* ' );
    qr_Aux.SQL.Add(' FROM PROFISSIONAIS P ' );
    qr_Aux.SQL.Add(' WHERE P.ID_WEB = ' + IntToStr( id ) );
    qr_aux.Open;

    Result := TProfissional.Create;
    Result.FNome  := qr_aux.FieldByName('NOME').AsString;
    Result.Fcodigo_empresa := qr_aux.FieldByName('CODIGO_EMPRESA').Value;
    Result.Fcodigo_profissional := qr_aux.FieldByName('CODIGO_PROFISSIONAL').Value;
    Result.Fid_web := qr_aux.FieldByName('ID_WEB').Value;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
 