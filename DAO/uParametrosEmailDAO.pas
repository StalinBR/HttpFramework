unit uParametrosEmailDAO;

interface

uses
 SysUtils ,
 uDAO, SqlExpr;

type TParametrosEmailDAO = class(TDAO)
private

protected

public
  FusuarioEmail :String;
  FsenhaEmail :String;
  Femail_remetente :String;
  Fremetente :String;
  //FparamEmpresa :Integer;
  FqryParametros: TSQLQuery;

  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

{ TParametrosEmailDAO }

constructor TParametrosEmailDAO.Create;
begin
  AbreBanco;
  FqryParametros := TSQLQuery.Create(nil);
  FqryParametros.SQLConnection := FSQLConnection;

  //FparamEmpresa := empresa;

  FqryParametros.SQL.Clear;
  FqryParametros.SQL.Add(' SELECT P.USUARIO_SMTP, P.SENHA_SMTP, P.EMAIL_REMETENTE, P.REMETENTE ');
  FqryParametros.SQL.Add(' FROM PARAMETROS_EMAIL P ');
  FqryParametros.SQL.Add(' WHERE P.CODIGO_EMPRESA = ' + IntToStr( Fempresa_padrao ) );

  FqryParametros.Open;

  FusuarioEmail     := FqryParametros.FieldByName('USUARIO_SMTP').Value;
  FsenhaEmail       := FqryParametros.FieldByName('SENHA_SMTP').Value;
  Femail_remetente  := FqryParametros.FieldByName('EMAIL_REMETENTE').Value;
  Fremetente        := FqryParametros.FieldByName('REMETENTE').Value;
end;

destructor TParametrosEmailDAO.Destroy;
begin

  inherited;
end;

end.
 