unit uTestesDAO;

interface
 uses uDAo, uProfissional, uCliente, SqlExpr;

type TTesteDAO = class(TDAO)
     public
       FqryEmails: TSQLQuery;
       FparamEmpresa :Integer;
       function RandomProfisisonal :TProfissional;
       function RandomCliente :TCliente;
       constructor Create;
       destructor Destroy; override;
     end;

implementation

uses SysUtils, DB;

{ TEmailsDAO }


function TTesteDAO.RandomProfisisonal: TProfissional;
var
  profissional :TProfissional;
  qr_aux :TSqlQuery;
begin
  profissional := TProfissional.Create;

  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT * ');
    qr_Aux.SQL.Add(' FROM PROFISSIONAIS ');
    qr_Aux.SQL.Add(' WHERE ID_WEB > 0 ');
    qr_Aux.SQL.Add(' ORDER BY UDF_RAND() ');
    qr_aux.Open;

    profissional.Fcodigo_profissional := qr_aux.FieldByName('CODIGO_PROFISSIONAL').AsInteger;
    profissional.Fcodigo_empresa := qr_aux.FieldByName('CODIGO_EMPRESA').AsInteger;
    Result := profissional;
  finally
    FreeAndNil(qr_aux);
  end;
end;


constructor TTesteDAO.Create;
var
  i :Integer;
begin
  AbreBanco;
  FqryEmails := TSQLQuery.Create(nil);
  FqryEmails.SQLConnection := FSQLConnection;
end;

destructor TTesteDAO.Destroy;
begin
  inherited;
end;


function TTesteDAO.RandomCliente: TCliente;
var
  cliente :TCliente;
  qr_aux :TSqlQuery;
begin
  cliente := TCliente.Create;
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT * ');
    qr_Aux.SQL.Add(' FROM CLIENTES ');
    qr_Aux.SQL.Add(' WHERE ID_WEB = 0 ');
    qr_Aux.SQL.Add(' ORDER BY UDF_RAND() ');
    qr_aux.Open;

    cliente.Fcodigo_cliente := qr_aux.FieldByName('CODIGO_CLIENTE').AsInteger;
    cliente.Fcodigo_empresa := qr_aux.FieldByName('CODIGO_EMPRESA').AsInteger;
    Result := cliente;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
