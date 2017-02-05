unit uParametrosDAO;

interface

uses
 SysUtils ,
 uDAO, SqlExpr;

type TParametrosDAO = class(TDAO)
private

protected


public
  FutilizaSalaoVIP :String;
  FsalaoVipToken :String;
  FqryParametros: TSQLQuery;

  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

{ TParametrosEmailDAO }

constructor TParametrosDAO.Create;
begin
  AbreBanco;
  FqryParametros := TSQLQuery.Create(nil);
  FqryParametros.SQLConnection := FSQLConnection;

  FqryParametros.SQL.Clear;
  FqryParametros.SQL.Add(' SELECT P.APP_SALAOVIP, P.APP_SALAOVIP_TOKEN ');
  FqryParametros.SQL.Add(' FROM PARAMETROS_SISTEMA P ');
  FqryParametros.SQL.Add(' WHERE P.CODIGO_EMPRESA = ' + IntToStr( Fempresa_padrao ) );

  FqryParametros.Open;

  FutilizaSalaoVIP  := FqryParametros.FieldByName('APP_SALAOVIP').Value;
  FsalaoVipToken    := FqryParametros.FieldByName('APP_SALAOVIP_TOKEN').Value;
end;

destructor TParametrosDAO.Destroy;
begin
  FreeAndNil( FqryParametros );
  inherited;
end;

end.
 