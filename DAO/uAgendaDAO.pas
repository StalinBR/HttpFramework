unit uAgendaDAO;

interface
 uses Classes, uDAo, uAgenda, SqlExpr;

type ListaAgenda = array of TAgenda;

type TAgendaDAO = class(TDAO)
     private
       procedure Inclui_Auditoria( agenda :TAgenda );
     protected

     public
       FlistaAgenda :array of TAgenda;
       FqryAgenda: TSQLQuery;
       FparamEmpresa :Integer;
       constructor Create;
       destructor Destroy; override;
       function listaAgenda :ListaAgenda;
       procedure AtualizaStatus( controle, status :Integer; log :String );

       function PesquisaAgendaControle(controle :Integer) :Boolean;
       function PesquisaClienteID(controle :Integer): Integer;
       function PesquisaProfissionalID(Cod_Profissional,  Cod_Empresa: String): Integer;
       function PesquisaSalaoID(empresa: Integer): Integer;
       function PesquisaServicoAgenda(controle: Integer): String;
       function PesquisaDescricaoServico ( id_web :Integer ) :String;

       function PesquisaAgendaID(id: Integer): Integer;
       function ReservaDisponivel ( codigo_profissional, emp_profissional :Integer; data :TDateTime; inicio, fim :String) :Boolean;
       function IncluiAgendamento( data :TDateTime;
                                   id_profissional, emp_profissional :Integer;
                                   id_cliente, emp_cliente :Integer;
                                   horario, fim :Integer;
                                   status, servico :String;
                                   nome, app :String;
                                   id_web :Integer ) :Boolean;
       procedure UpdateIdWeb ( controle, id :Integer);
       procedure BaixaControle( controle :Integer; status :String );
       function ExcluiAgenda(controle :Integer) :Integer;
     published

     end;


implementation

uses SysUtils, DB;

{ TEmailsDAO }

procedure TAgendaDAO.AtualizaStatus(controle, status: Integer; log: String);
var
 qr_aux :TSQLQuery;
begin
  qr_aux := TSQLQuery.Create(nil);

  try
    try
      qr_aux.SQLConnection := FSqlConnection;

      qr_aux.SQL.Add ('UPDATE EMAILS E ');
      qr_aux.SQL.Add ('SET E.STATUS = ' + IntToStr( status ) );
      qr_aux.SQL.Add ('  , E.data_envio = current_date');
      qr_aux.SQL.Add ('  , E.hora_envio = current_time');
      qr_aux.SQL.Add ('  , E.log = ' + QuotedStr(log));
      qr_aux.SQL.Add ('WHERE E.controle = ' + IntToStr( controle ) );
      qr_aux.ExecSQL;

    except on E :Exception do
      //raise Exception.Create(E.Message);
    end;

  finally
    FreeAndNil(qr_aux);
  end;
end;

procedure TAgendaDAO.BaixaControle(controle: Integer; status: String);
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add( 'UPDATE SINCRONISMO_WEB ');
    qr_Aux.SQL.Add( 'SET STATUS =   ' + QuotedStr(status) );
    qr_Aux.SQL.Add( 'WHERE CONTROLE = '+ IntToStr(controle));
    qr_aux.ExecSQL;
  finally
    FreeAndNil(qr_aux);
  end;
end;

constructor TAgendaDAO.Create;
begin
  AbreBanco;
  FqryAgenda := TSQLQuery.Create(nil);
  FqryAgenda.SQLConnection := FSQLConnection;

  FqryAgenda.SQL.Add(' SELECT controle, tabela, acao, field1, field2, field3, field4, field5, field6, field7, field8, status, aplicativo, field9, ');
  FqryAgenda.SQL.Add('        (select count(a.controle)   ');
  FqryAgenda.SQL.Add('           from sincronismo_web a   ');
  FqryAgenda.SQL.Add('          WHERE A.APLICATIVO = 2    ');
  FqryAgenda.SQL.Add('            AND A.TABELA = 4        ');
  FqryAgenda.SQL.Add('            AND STATUS = ' + QuotedStr('ABE'));
  FqryAgenda.SQL.Add('            AND CONTROLE > 0        ');
  FqryAgenda.SQL.Add('        ) as RECORDCOUNT '           );      
  FqryAgenda.SQL.Add('   FROM SINCRONISMO_WEB S                                 ');
  FqryAgenda.SQL.Add('  WHERE S.APLICATIVO = 2                                  '); // Opcional.
  FqryAgenda.SQL.Add('    AND TABELA = 4                                        ');
  FqryAgenda.SQL.Add('   AND STATUS = ' + QuotedStr('ABE')                       );
  FqryAgenda.SQL.Add('   AND CONTROLE > 0                                       ');
  FqryAgenda.SQL.Add('ORDER BY CONTROLE                                         ');
end;

destructor TAgendaDAO.Destroy;
begin
  FreeAndNil(FqryAgenda);
  inherited;
end;

function TAgendaDAO.ExcluiAgenda(controle: Integer) :Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    try
    if controle > 0 then
    begin
      qr_Aux.SQL.Add('delete from agenda where id_web = ' + IntToStr(controle) );
      qr_aux.ExecSQL;
    end;
    Result := 0;
    except
      Result := 1; 
    end;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.IncluiAgendamento(data: TDateTime; id_profissional,
  emp_profissional, id_cliente, emp_cliente, horario, fim: Integer; status,
  servico, nome, app: String; id_web: Integer): Boolean;
var
  SqlText :TStringList;
  qr_aux :TSqlQuery;
begin
  Result := True;
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;

  SqlText := TStringList.Create;
  SqlText.Text := 'INSERT INTO AGENDA (CONTROLE '
                +'   , DATA '
                +'   , CODIGO_PROFISSIONAL '
                +'   , EMP_PROFISSIONAL '
                +'   , CODIGO_CLIENTE '
                +'   , EMP_CLIENTE '
                +'   , HORARIO '
                +'   , FIM '
                +'   , STATUS '
                +'   , SERVICOS '
                +'   , AVISO '
                +'   , AVISO_CONFIRMADO '
                +'   , CONTROLE_INTERNO '
                +'   , S '
                +'   , CONTROLE_CODIGO '
                +'   , CONTROLE_EMP_CODIGO '
                +'   , DATA_MARCACAO '
                +'   , HORA_MARCACAO '
                +'   , QTDE_MARCACOES '
                +'   , STATUS_ATUAL '
                +'   , CONTROLE_EXCLUSAO '
                +'   , CODIGO_FOLGA '
                +'   , EMP_FOLGA '
                +'   , FIXO '
                +'   , PREFERENCIA '
                +'   , CONFIRMADO '
                +'   , CONTROLE_CONF '
                +'   , EMP_CONTROLE_CONF '
                +'   , CONTROLE_FIXO '
                +'   , NOME_CLIENTE '
                +'   , RESPONSAVEL_CONTROLE '
                +'   , CODIGO_SALA '
                +'   , EMP_SALA '
                +'   , ID_WEB '
                +'   , APLICATIVO ) '
          +'    VALUES  (GEN_ID(GEN_CONTROLE_AGENDA,1) '
          +'         , :DATA '
          +'         , :CODIGO_PROFISSIONAL '
          +'         , :EMP_PROFISSIONAL '
          +'         , :CODIGO_CLIENTE '
          +'         , :EMP_CLIENTE '
          +'         , :HORARIO '
          +'         , :FIM '
          +'         , :STATUS '
          +'         , :SERVICOS '
          +'         , ''N'' '
          +'         , ''N'' '
          +'         , :CONTROLE_INTERNO '
          +'         , ''N'' '
          +'         , :CONTROLE_CODIGO '
          +'         , :CONTROLE_EMP_CODIGO '
          +'         , CURRENT_DATE '
          +'         , CURRENT_TIME '
          +'         , 1 '
          +'         , ''M'' '
          +'         , 0 '
          +'         , 0 '
          +'         , 0 '
          +'         , ''N'' '
          +'         , ''N'' '
          +'         , ''N'' '
          +'         , 0 '
          +'         , 0 '
          +'         , 0 '
          +'         , :NOME_CLIENTE '
          +'         , ''SALAOVIP'' '
          +'         , 0 '
          +'         , 0 '
          +'         , :ID_WEB '
          +'         , :APLICATIVO) ';

  qr_aux.SQL.Text := SqlText.Text;
  try
    qr_aux.Params[0].AsDate := data;
    qr_aux.Params[1].Value  := id_profissional;
    qr_aux.Params[2].Value  := emp_profissional;
    qr_aux.Params[3].Value  := id_cliente;
    qr_aux.Params[4].Value  := emp_cliente;
    qr_aux.Params[5].Value  := horario;
    qr_aux.Params[6].Value  := fim;
    qr_aux.Params[7].Value  := status;
    qr_aux.Params[8].Value  := Servico;
    qr_aux.Params[9].Value  := 0;
    qr_aux.Params[10].Value := '1';
    qr_aux.Params[11].Value := '1';
    qr_aux.Params[12].Value := nome;
    qr_aux.Params[13].Value := id_web;
    qr_aux.Params[14].Value := app;
    try
      qr_aux.ExecSql();
    except
      Result := False;
    end;
  finally
    FreeAndNil(qr_aux);
  end;
end;

procedure TAgendaDAO.Inclui_Auditoria( agenda :TAgenda );
var
  qr_aux :TSQLQuery;
begin
  qr_aux := TSQLQuery.Create(nil);

  try
    qr_aux.SQLConnection := FSqlConnection;

    qr_aux.SQL.Add ('        INSERT INTO AUDITORIA_AGENDA ( CONTROLE, DATA, HORA, CODIGO_OPERADOR, EMP_OPERADOR  ');
    qr_aux.SQL.Add ('                                     , ACAO                                                 ');
    qr_aux.SQL.Add ('                                     , CODIGO_PROFISSIONAL                                  ');
    qr_aux.SQL.Add ('                                     , EMP_PROFISSIONAL                                     ');
    qr_aux.SQL.Add ('                                     , DATA_HORARIO                                         ');
    qr_aux.SQL.Add ('                                     , INICIO                                               ');
    qr_aux.SQL.Add ('                                     , FIM                                                  ');
    qr_aux.SQL.Add ('                                     , CODIGO_CLIENTE                                       ');
    qr_aux.SQL.Add ('                                     , EMP_CLIENTE                                          ');
    qr_aux.SQL.Add ('                                     , SERVICO)                                             ');
    qr_aux.SQL.Add ('        VALUES ( GEN_ID(GEN_AUDITORIA_AGENDA,1), CURRENT_DATE, CURRENT_TIME, 0, 0           ');
    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.Facao)                                                  );
    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.Fcodigo_profissional)                                   );
    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.Femp_profissional)                                      );
    qr_aux.SQL.Add ('               , ' + QuotedStr(agenda.Fdata)                                                 );
    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.Fhora)                                                  );
    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.Ffim)                                                   );
//    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.FCODIGO_CLIENTE)                                        );
//    qr_aux.SQL.Add ('               , ' + IntToStr(agenda.FEMP_CLIENTE)                                           );
    qr_aux.SQL.Add ('               , ' + QuotedStr(agenda.Fservicos) + ');'                                      );
    qr_aux.ExecSQL;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.listaAgenda :ListaAgenda;
var
  i :Integer;
  agenda :TAgenda;
  lista :array of TAgenda;
begin
  try
    FqryAgenda.Open;


    if FqryAgenda.FieldByName('RECORDCOUNT').AsInteger > 0 then
    begin

    SetLength( Result, FqryAgenda.FieldByName('RECORDCOUNT').AsInteger );
    SetLength( lista,  FqryAgenda.FieldByName('RECORDCOUNT').AsInteger );
    agenda := TAgenda.Create;
    for i := 0 to FqryAgenda.FieldByName('RECORDCOUNT').AsInteger -1 do
    begin
      agenda := TAgenda.Create;
      agenda.Facao                 := FqryAgenda.FieldByName('ACAO').Value;
      agenda.Fcontrole             := FqryAgenda.FieldByName('FIELD1').Value;
      agenda.Fcodigo_profissional  := FqryAgenda.FieldByName('FIELD2').Value;
      agenda.Femp_profissional     := FqryAgenda.FieldByName('FIELD3').Value;
      agenda.Fhora                 := FqryAgenda.FieldByName('FIELD4').Value;
      agenda.Ffim                  := FqryAgenda.FieldByName('FIELD5').Value;
      agenda.Fdata                 := FqryAgenda.FieldByName('FIELD6').Value;
      agenda.Fid_Web               := FqryAgenda.FieldByName('FIELD7').Value;
      agenda.FstatusA              := FqryAgenda.FieldByName('FIELD9').Value;
      agenda.Fcontrole_web         := FqryAgenda.FieldByName('CONTROLE').Value;
      
      Result[i] := agenda;
      lista[i] := agenda;
      FqryAgenda.Next;
    end;  
  end;
  finally
    FqryAgenda.Close;
    //agenda.Free;
  end;
end;

function TAgendaDAO.PesquisaAgendaControle(controle: Integer): Boolean;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT CONTROLE ');
    qr_Aux.SQL.Add('FROM AGENDA ');
    qr_Aux.SQL.Add('WHERE CONTROLE = '+ IntToStr(controle));
    qr_aux.Open;

    if qr_aux.FieldByName('CONTROLE').AsInteger > 0 then
      Result := True
    else
      Result := False;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaAgendaID(id: Integer): Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT ID_WEB ');
    qr_Aux.SQL.Add('FROM AGENDA ');
    qr_Aux.SQL.Add('WHERE CONTROLE = '+ IntToStr(id));
    qr_aux.Open;

    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaClienteID(controle: Integer): Integer;
var
  SqlText :TStringList;
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;

  SqlText := TStringList.Create;
  SqlText.Text :=
    ' SELECT C.ID_WEB '
   +' FROM CLIENTES C '
   +' LEFT JOIN AGENDA A ON C.CODIGO_CLIENTE = A.CODIGO_CLIENTE AND C.CODIGO_EMPRESA = A.EMP_CLIENTE '
   +' WHERE A.CONTROLE = ' + IntToStr(controle);

  qr_aux.SQL.Text := SqlText.Text;
  try
    qr_aux.Open;
    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaDescricaoServico(id_web: Integer): String;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT DESCRICAO FROM SERVICOS ');
    qr_Aux.SQL.Add('WHERE ID_WEB = '+ IntToStr(id_web));
    qr_aux.Open;
    Result := qr_aux.FieldByName('DESCRICAO').AsString;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaProfissionalID(Cod_Profissional,
  Cod_Empresa: String): Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT ID_WEB ');
    qr_Aux.SQL.Add('FROM PROFISSIONAIS ');
    qr_Aux.SQL.Add('WHERE CODIGO_PROFISSIONAL = '+Cod_Profissional+' AND CODIGO_EMPRESA = '+ Cod_Empresa);
    qr_aux.Open;

    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaSalaoID(empresa: Integer): Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT ID_WEB ');
    qr_Aux.SQL.Add('FROM EMPRESAS ');
    qr_Aux.SQL.Add('WHERE CODIGO_EMPRESA = '+ IntToStr(empresa));
    qr_aux.Open;

    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.PesquisaServicoAgenda(controle: Integer): String;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('SELECT SERVICOS FROM AGENDA ');
    qr_Aux.SQL.Add('WHERE CONTROLE = '+ IntToStr(controle));
    qr_aux.Open;

    Result := qr_aux.FieldByName('SERVICOS').AsString;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TAgendaDAO.ReservaDisponivel(codigo_profissional,
  emp_profissional: Integer; data: TDateTime; inicio,
  fim: String): Boolean;
var
  qr_aux :TSqlQuery;
  Fformart :TFormatSettings;
begin
  Fformart.DateSeparator := '/';
  Fformart.ShortDateFormat := 'mm/dd/yyyy';
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add('SELECT CONTROLE FROM AGENDA                                ');
    qr_Aux.SQL.Add('WHERE DATA = '+ QuotedStr( DateToStr(data, Fformart) )      );
    qr_Aux.SQL.Add('AND CODIGO_PROFISSIONAL = '+ IntToStr(codigo_profissional)  );
    qr_Aux.SQL.Add('AND EMP_PROFISSIONAL = '+ IntToStr(emp_profissional)        );
    qr_Aux.SQL.Add('AND   (((HORARIO <= '+INICIO+') AND (FIM > '+INICIO+')) OR ');
    qr_Aux.SQL.Add('       ((HORARIO < '+FIM+') AND (FIM >= '+FIM+')) OR       ');
    qr_Aux.SQL.Add('       ((HORARIO >= '+INICIO+') AND (FIM <= '+FIM+')))     ');
    qr_aux.Open;

    if qr_aux.FieldByName('CONTROLE').AsInteger > 0 then
      Result := False
    else
      Result := True;
  finally
    FreeAndNil(qr_aux);
  end;
end;

procedure TAgendaDAO.UpdateIdWeb(controle, id: Integer);
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('UPDATE AGENDA ');
    qr_Aux.SQL.Add('SET ID_WEB =  ' + IntToStr(id));
    qr_Aux.SQL.Add('WHERE CONTROLE = '+ IntToStr(controle));
    qr_aux.ExecSQL;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
