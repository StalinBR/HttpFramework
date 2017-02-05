unit uClientesDAO;

interface

uses
 SysUtils, uCliente,
 uDAO, SqlExpr;

type TClientesDAO = class(TDAO)
private

protected

public
  FqryParametros: TSQLQuery;

  function PesquisaClienteByAgenda ( controle :Integer ) :TCliente;
  function PesquisaClienteById ( id :Integer ) :TCliente;
  procedure AtualizaIdWeb(id_web, codigo_empresa, codigo_cliente: Integer);
  function PesquisaCliente (idweb :Integer; Email, Phone :String ) :Integer;
  function PesquisaClienteWeb ( idweb :Integer; Email, Phone :String ) :Integer;
  function IncluiCliente(nome, cpf, telefone, email, facebook :String; DataNasc :TDateTime; Id_Web :Integer) :Integer;
  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

{ TParametrosEmailDAO }

procedure TClientesDAO.AtualizaIdWeb(id_web, codigo_empresa,
  codigo_cliente: Integer);
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add('UPDATE CLIENTES ');
    qr_Aux.SQL.Add(' SET ID_WEB  ='          + IntToStr(id_web));
    qr_Aux.SQL.Add(' WHERE CODIGO_CLIENTE = '+ QuotedStr( IntToStr(codigo_cliente)) );
    qr_Aux.SQL.Add('   AND CODIGO_EMPRESA = '+ IntToStr(codigo_empresa));
    qr_aux.ExecSQL;
  finally
    FreeAndNil(qr_aux);
  end;
end;

constructor TClientesDAO.Create;
begin
  AbreBanco;
end;

destructor TClientesDAO.Destroy;
begin
  inherited;
end;

function TClientesDAO.IncluiCliente(nome, cpf, telefone, email,
  facebook: String; DataNasc: TDateTime; Id_Web: Integer): Integer;
var
  SP_Importa_Cliente :TSQLStoredProc;
begin
  SP_Importa_Cliente := TSQLStoredProc.Create(nil);

  SP_Importa_Cliente.SQLConnection := FSQLConnection;
  SP_Importa_Cliente.StoredProcName := 'SP_IMPORTA_CLIENTE';

  SP_Importa_Cliente.ParamByName('EMPRESA').value          :=  Tabelas_Empresa( Fempresa_padrao, 'CLIENTES');
  SP_Importa_Cliente.ParamByName('ATUALIZA').value         := 'N';
  SP_Importa_Cliente.ParamByName('CODIGO_CLIENTEI').value  := 0;
  SP_Importa_Cliente.ParamByName('APELIDO').value          := Copy(nome,1,15);
  SP_Importa_Cliente.ParamByName('NOME').value             := nome;
  SP_Importa_Cliente.ParamByName('CPF').value              := cpf;
  SP_Importa_Cliente.ParamByName('RG').value               := '';
  SP_Importa_Cliente.ParamByName('ENDERECO').value         := '';
  SP_Importa_Cliente.ParamByName('NUMERO').value           := 0;
  SP_Importa_Cliente.ParamByName('COMPLEMENTO').value      := '';
  SP_Importa_Cliente.ParamByName('BAIRRO').value           := '';
  SP_Importa_Cliente.ParamByName('CEP').value              := '';
  SP_Importa_Cliente.ParamByName('CIDADE').value           := '';
  SP_Importa_Cliente.ParamByName('UF').value               := '';
  SP_Importa_Cliente.ParamByName('TELEFONE1').value        := telefone;
  SP_Importa_Cliente.ParamByName('TIPO_TELEFONE1').value   := '';
  SP_Importa_Cliente.ParamByName('TELEFONE2').value        := '';
  SP_Importa_Cliente.ParamByName('TIPO_TELEFONE2').value   := '';
  SP_Importa_Cliente.ParamByName('TELEFONE3').value        := '';
  SP_Importa_Cliente.ParamByName('TIPO_TELEFONE3').value   := '';
  SP_Importa_Cliente.ParamByName('EMAIL').value            := email;
  SP_Importa_Cliente.ParamByName('GRUPO').value            := 0;
  SP_Importa_Cliente.ParamByName('VEICULO').value          := 0;
  SP_Importa_Cliente.ParamByName('SEXO').value             := '';
  SP_Importa_Cliente.ParamByName('ESTADO_CIVIL').value     := '';
  SP_Importa_Cliente.ParamByName('TWITTER').value          := '';
  SP_Importa_Cliente.ParamByName('FACEBOOK').value         := facebook;
  SP_Importa_Cliente.ParamByName('DATA_NASCIMENTO').value  := DataNasc;
  SP_Importa_Cliente.ParamByName('DATA_CLIENTE').value     := Now;
  SP_Importa_Cliente.ParamByName('ID_WEB').Value           := Id_Web;

  SP_Importa_Cliente.ExecProc;

end;

function TClientesDAO.PesquisaCliente(idweb: Integer; Email,
  Phone: String): Integer;
var
  qr_aux, qr_aux2 :TSqlQuery;
  codigo_cliente, emp_cliente :Integer;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add(' SELECT CODIGO_CLIENTE, CODIGO_EMPRESA ');
    qr_Aux.SQL.Add(' FROM CLIENTES ');
    qr_Aux.SQL.Add(' WHERE CODIGO_EMPRESA = ' + IntToStr( Tabelas_Empresa( Fempresa_padrao, 'CLIENTES' ) ) );
    qr_Aux.SQL.Add('   AND STATUS = '+ QuotedStr('A') );
    qr_Aux.SQL.Add('   AND ID_WEB = 0' );
    qr_Aux.SQL.Add('   AND ( (EMAIL = '+ QuotedStr(email) +') OR (UDF_DIGITS(TELEFONE1) = '+ QuotedStr(Phone) + ') )' );
    qr_aux.Open;

    // Se Recordcount > 1 then Result := 0; Exit;
    if qr_aux.RecordCount > 1 then
      Result := 0
    else
    begin
      if qr_aux.FieldByName('CODIGO_CLIENTE').AsInteger > 0 then
      begin
        codigo_cliente := qr_aux.FieldByName('CODIGO_CLIENTE').AsInteger;
        emp_cliente    := qr_aux.FieldByName('CODIGO_EMPRESA').AsInteger;

        qr_aux2 := TSQLQuery.Create(nil);
        qr_aux2.SQLConnection := FSQLConnection;
        try
          qr_Aux2.SQL.Add(' UPDATE CLIENTES ');
          qr_Aux2.SQL.Add(' SET ID_WEB = ' + IntToStr(idweb) );
          qr_Aux2.SQL.Add(' WHERE CODIGO_CLIENTE = ' + IntToStr(codigo_cliente) );
          qr_Aux2.SQL.Add('   AND CODIGO_EMPRESA = ' + IntToStr(emp_cliente) );
          qr_aux2.ExecSQL;
          Result := codigo_cliente;
        finally
          qr_aux2.Free;
        end;
      end
      else
        Result := 0;
    end;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TClientesDAO.PesquisaClienteByAgenda(controle: Integer): TCliente;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT C.* ' );
    qr_Aux.SQL.Add(' FROM CLIENTES C ' );
    qr_Aux.SQL.Add(' LEFT JOIN AGENDA A ON C.CODIGO_CLIENTE = A.CODIGO_CLIENTE AND C.CODIGO_EMPRESA = A.EMP_CLIENTE ' );
    qr_Aux.SQL.Add(' WHERE A.CONTROLE = ' + IntToStr( controle ) );
    qr_aux.Open;

    Result := TCliente.Create;
    Result.FNome  := qr_aux.FieldByName('NOME').AsString;
    Result.FEmail := qr_aux.FieldByName('EMAIL').AsString;
    Result.FCpf   := qr_aux.FieldByName('CPF').AsString;
    Result.FPhone := qr_aux.FieldByName('TELEFONE1').AsString;
    Result.Fcodigo_empresa := qr_aux.FieldByName('CODIGO_EMPRESA').Value;
    Result.Fcodigo_cliente := qr_aux.FieldByName('CODIGO_CLIENTE').Value;
    Result.Fid_web := qr_aux.FieldByName('ID_WEB').Value;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TClientesDAO.PesquisaClienteById(id: Integer): TCliente;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT C.* ' );
    qr_Aux.SQL.Add(' FROM CLIENTES C ' );
    qr_Aux.SQL.Add(' WHERE C.ID_WEB = ' + IntToStr( id ) );
    qr_aux.Open;

    Result := TCliente.Create;
    Result.FNome  := qr_aux.FieldByName('NOME').AsString;
    Result.Fcodigo_empresa := qr_aux.FieldByName('CODIGO_EMPRESA').Value;
    Result.Fcodigo_cliente := qr_aux.FieldByName('CODIGO_CLIENTE').Value;
    Result.Fid_web := qr_aux.FieldByName('ID_WEB').Value;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TClientesDAO.PesquisaClienteWeb(idweb: Integer; Email,
  Phone: String): Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add(' SELECT ID_WEB ');
    qr_Aux.SQL.Add(' FROM CLIENTES ');
    qr_Aux.SQL.Add(' WHERE ID_WEB = ' + IntToStr(idweb));
//    qr_Aux.SQL.Add(' OR TELEFONE1 = ' + QuotedStr(Phone));
//    qr_Aux.SQL.Add(' OR EMAIL = ' + QuotedStr(Email));
    qr_aux.Open;

    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
 