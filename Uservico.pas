unit Uservico;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  ExtCtrls, IniFiles, DBXpress, FMTBcd, DB, SqlExpr, Provider, DBClient,
  Registry, JvComponentBase,
  JvCipher;

type
  TsrvTelesServicos = class(TService)
    timerRelatorioSMS: TTimer;
    SQLConnectionEmails: TSQLConnection;
    qryControleSMS: TSQLQuery;
    qryControleSMSENVIADAS: TIntegerField;
    qryControleSMSRECEBIDAS: TIntegerField;
    dspControleSMS: TDataSetProvider;
    cdsControleSMS: TClientDataSet;
    cdsControleSMSQTDE: TFMTBCDField;
    cdsControleSMSENVIADAS: TIntegerField;
    cdsControleSMSRECEBIDAS: TIntegerField;
    qryNaoEnviados: TSQLQuery;
    qryNaoEnviadosCODIGO_EMPRESA: TIntegerField;
    qryNaoEnviadosCONTROLE: TIntegerField;
    qryNaoEnviadosDATA: TDateField;
    qryNaoEnviadosHORA: TTimeField;
    qryNaoEnviadosTIPO: TIntegerField;
    qryNaoEnviadosCAMPANHA: TIntegerField;
    qryNaoEnviadosEMP_CAMPANHA: TIntegerField;
    qryNaoEnviadosASSUNTO: TStringField;
    qryNaoEnviadosCODIGO_DESTINATARIO: TIntegerField;
    qryNaoEnviadosEMP_DESTINATARIO: TIntegerField;
    qryNaoEnviadosSTATUS: TIntegerField;
    qryNaoEnviadosDATA_ENVIO: TDateField;
    qryNaoEnviadosHORA_ENVIO: TTimeField;
    qryNaoEnviadosBODY: TMemoField;
    qryNaoEnviadosLOG: TMemoField;
    qryNaoEnviadosICS: TMemoField;
    qryNaoEnviadosRESPOSTA: TStringField;
    qryNaoEnviadosTELEFONE_CONFIRMACAO: TStringField;
    qryNaoEnviadosTELEFONE_LEMBRETE: TStringField;
    qryNaoEnviadosTELEFONE_CANCELAMENTO: TStringField;
    qryNaoEnviadosNOME: TStringField;
    dspNaoEnviados: TDataSetProvider;
    cdsNaoEnviados: TClientDataSet;
    cdsNaoEnviadosCODIGO_EMPRESA: TIntegerField;
    cdsNaoEnviadosCONTROLE: TIntegerField;
    cdsNaoEnviadosDATA: TDateField;
    cdsNaoEnviadosHORA: TTimeField;
    cdsNaoEnviadosTIPO: TIntegerField;
    cdsNaoEnviadosCAMPANHA: TIntegerField;
    cdsNaoEnviadosEMP_CAMPANHA: TIntegerField;
    cdsNaoEnviadosASSUNTO: TStringField;
    cdsNaoEnviadosCODIGO_DESTINATARIO: TIntegerField;
    cdsNaoEnviadosEMP_DESTINATARIO: TIntegerField;
    cdsNaoEnviadosSTATUS: TIntegerField;
    cdsNaoEnviadosDATA_ENVIO: TDateField;
    cdsNaoEnviadosHORA_ENVIO: TTimeField;
    cdsNaoEnviadosBODY: TMemoField;
    cdsNaoEnviadosLOG: TMemoField;
    cdsNaoEnviadosICS: TMemoField;
    cdsNaoEnviadosRESPOSTA: TStringField;
    cdsNaoEnviadosTELEFONE_CONFIRMACAO: TStringField;
    cdsNaoEnviadosTELEFONE_LEMBRETE: TStringField;
    cdsNaoEnviadosTELEFONE_CANCELAMENTO: TStringField;
    cdsNaoEnviadosNOME: TStringField;
    cdsConfiguracoes: TClientDataSet;
    cdsConfiguracoescodigo: TIntegerField;
    cdsConfiguracoesdescricao: TStringField;
    cdsConfiguracoesip_servidor: TStringField;
    cdsConfiguracoespath_sistema_local: TStringField;
    cdsConfiguracoespath_imagens: TStringField;
    cdsConfiguracoespath_relatorios: TStringField;
    cdsConfiguracoespath_backup: TStringField;
    cdsConfiguracoespath_banco_dados: TStringField;
    cdsConfiguracoesusuario: TStringField;
    cdsConfiguracoessenha: TStringField;
    cdsConfiguracoespadrao: TStringField;
    cdsConfiguracoessequencia: TAggregateField;
    JvVigenereCipher1: TJvVigenereCipher;
    sqlParamEmail: TSQLQuery;
    sqlParamEmailUSUARIO_SMTP: TStringField;
    sqlParamEmailSENHA_SMTP: TStringField;
    sqlParamEmailEMAIL_GESTOR: TStringField;
    procedure timerRelatorioSMSTimer(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
    procedure timerLimiteSMSTimer(Sender: TObject);
  private
    Aplicacao  : String;
    Banco      : String;
    Servidor   : String;
    BancoDados : String;
    Usuario    : String;
    Senha      : String;

    function LerIni(tipo :String) :String;
    procedure GravaIni(tipo :String);
    procedure GravaLog(erro :String);
    procedure GerarRelatorio(tipo :String);
    function Email_Gestor :String;
    function Limite_SMS :Integer;
    procedure Abre_Banco_Dados;
    procedure Conecta_DB;
    function ApelidoEmpresa :String;
    function EmpresaPadrao  :Integer;
    function ExtensoMes(n :Integer) :String;
    function Parametro_Web :String;
    function Id_Web :Integer;
  public
    function GetServiceController: TServiceController; override;
  end;

var
  srvTelesServicos: TsrvTelesServicos;

implementation

uses
  Uemail, DateUtils,
  IdHTTP, uLkJSON, Variants;

{$R *.DFM}

function TsrvTelesServicos.ExtensoMes(n: Integer): String;
const
  aMeses :array[0..11] of String = ( 'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                                     'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro' );
begin
 Result := aMeses[n-1];
end;

{Service Methods}
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  srvTelesServicos.Controller(CtrlCode);
end;

function TsrvTelesServicos.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TsrvTelesServicos.ServiceExecute(Sender: TService);
begin
  while not self.Terminated do
  begin
    ServiceThread.ProcessRequests(true);
    timerRelatorioSMS.Enabled := True;
  end;
end;

procedure TsrvTelesServicos.ServiceAfterInstall(Sender: TService);
var
  regEdit : TRegistry;
begin
  regEdit := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    regEdit.RootKey := HKEY_LOCAL_MACHINE;

    if regEdit.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name,False) then
    begin
      regEdit.WriteString('Description','Teles Hair Solution - Serviços Automáticos');
      regEdit.CloseKey;
    end;
  finally
    FreeAndNil(regEdit);
  end;
end;

{Timers}
procedure TsrvTelesServicos.timerRelatorioSMSTimer(Sender: TObject);
begin
  // Relatorio Gerencial SMS
  if Date > StrToDate(LerIni('Diario')) then
    GerarRelatorio('Diario');
  // Relatorio Mensal SMS  
  if ( (DayOf(Date) = StrToInt(LerIni('DiaRelatorio')) )
         and ( Date > StrToDate(LerIni('Mensal')) )) then // Se Primeiro Dia do Mês E Menor que data do INI
    GerarRelatorio('Mensal');
end;

procedure TsrvTelesServicos.timerLimiteSMSTimer(Sender: TObject);
begin

end;

{INI Files}
function TsrvTelesServicos.LerIni(tipo :String): String;
var
  ArqIni :TIniFile;
begin
  ArqIni := TIniFile.Create(ExtractFilePath(ParamStr(0))+'\Services.ini');
  try
    ArqIni.UpdateFile;
    if tipo = 'Diario' then
      Result := ArqIni.ReadString('Settings', 'DataRelDiario', '01/01/2015')
    else if tipo = 'Mensal' then
      Result := ArqIni.ReadString('Settings', 'DataRelMensal', '01/01/2015')
    else if tipo = 'DiaRelatorio' then
      Result := ArqIni.ReadString('Settings', 'DiaRelatorio', '1')
    else if tipo = 'LimiteMes' then
      Result := ArqIni.ReadString('Settings', 'LimiteMes', '1');
  finally
    ArqIni.Free;
  end;
end;

procedure TsrvTelesServicos.GravaIni(tipo :String);
var
  ArqIni :TIniFile;
begin
  ArqIni := TIniFile.Create(ExtractFilePath(ParamStr(0))+'\Services.ini');
  try
    ArqIni.UpdateFile;
    if tipo = 'Diario' then
      ArqIni.WriteString('Settings', 'DataRelDiario', DateToStr(Date) )
    else if tipo = 'Mensal' then
      ArqIni.WriteString('Settings', 'DataRelMensal', DateToStr(Date) )
    else if tipo = 'Limite' then
      ArqIni.WriteString('Settings', 'LimiteMes', IntToStr(MonthOf(Date)) );
  finally
    ArqIni.Free;
  end;
end;

procedure TsrvTelesServicos.GravaLog(erro: String);
var
  NomeDoLog: string;
  Arquivo: TextFile;
begin
  NomeDoLog := ExtractFileDir(ParamStr(0)) +'\LogServices.txt';
  AssignFile(Arquivo, NomeDoLog);
  if FileExists(NomeDoLog) then
    Append(Arquivo) { se existir, apenas adiciona linhas }
  else
    ReWrite(Arquivo); { cria um novo se não existir }
  try
    Writeln(arquivo, DateTimeToStr(Now) + ' - ' +   erro);
  finally
    CloseFile(arquivo)
  end;
end;

procedure TsrvTelesServicos.GerarRelatorio(tipo :String);
var
  Enviados, Recebidos, Total, Subject :String;
  EmailList :TStringList;
  lista :ListErros;
  i :Integer;
begin
  inherited;
  EmailList   := TStringList.Create;
  try
  try
    if not SQLConnectionEmails.Connected then
      Conecta_DB;

    if tipo = 'Diario' then
    begin
      Subject  := 'Relatório Gerencial de SMS';
      cdsControleSMS.Params.ParamByName('data_ini').AsDate := Yesterday;
      cdsControleSMS.Params.ParamByName('data_fim').AsDate := Yesterday;
    end
    else if tipo = 'Mensal' then
    begin
      Subject  := 'Relatório Mensal de SMS';
      EmailList.Add(Email_Gestor);
      EmailList.Add('telesinfo@telesinfo.com.br');
      cdsControleSMS.Params[0].AsDate := EncodeDate(YearOf(Date), MonthOf(Date)-1, 1);
      cdsControleSMS.Params[1].AsDate := EndOfTheMonth(EncodeDate(YearOf(Date), MonthOf(Date)-1, 1));
    end;

    cdsControleSMS.Close;
    cdsControleSMS.OPen;

    Enviados  := IntToStr( cdsControleSMSENVIADAS.AsInteger  );
    Recebidos := IntToStr( cdsControleSMSRECEBIDAS.AsInteger );
    Total     := IntToStr( cdsControleSMSQTDE.AsInteger      );

    sqlParamEmail.Close;
    sqlParamEmail.Params[0].Value := EmpresaPadrao;
    sqlParamEmail.Open;

    if tipo = 'Diario' then
    begin
      cdsNaoEnviados.Params.ParamByName('data_ini').AsDate := Yesterday;
      cdsNaoEnviados.Params.ParamByName('data_fim').AsDate := Yesterday;

      cdsNaoEnviados.Close;
      cdsNaoEnviados.Open;
      cdsNaoEnviados.First;

      SetLength(lista, cdsNaoEnviados.Recordcount);

      if Length(lista) > 0 then
      begin
        lista[0].data     := '-';
        lista[0].telefone := '-';
        lista[0].nome     := '-';
        lista[0].erro     := '-';

        for i := 1 to cdsNaoEnviados.Recordcount-1 do
        begin
          lista[i].data := DateTimeToStr(cdsNaoEnviadosDATA_ENVIO.AsDateTIme);
          lista[i].telefone := cdsNaoEnviadosTELEFONE_LEMBRETE.asString;
          lista[i].nome := cdsNaoEnviadosNOME.ASString;
          lista[i].erro := cdsNaoEnviadosLOG.AsString;
          cdsNaoEnviados.Next;
        end;
        EnviarEmail_SMS_Diario( sqlParamEmailUSUARIO_SMTP.ASString
                              , sqlParamEmailSENHA_SMTP.AsString
                              , 'reinaldo@telesinfo.com.br'
                              , 'Teles Informática'
                              , Subject
                              , '39822'
                              , sqlParamEmailEMAIL_GESTOR.AsString
                              , ApelidoEmpresa
                              , DateTimeToStr(Date-1)
                              , Recebidos
                              , Enviados
                              , Total
                              , lista );
      end;
    end
    else if tipo = 'Mensal' then
    begin
      EnviarEmail_SMS_Mensal( sqlParamEmailUSUARIO_SMTP.ASString
                            , sqlParamEmailSENHA_SMTP.AsString
                            , 'reinaldo@telesinfo.com.br'
                            , 'Teles Informática'
                            , Subject
                            , '40104'
                            , sqlParamEmailEMAIL_GESTOR.AsString
                            , ApelidoEmpresa
                            , ExtensoMes( MonthOf(Now)-1 )
                            , DateTimeToStr(Date-1)
                            , Recebidos
                            , Enviados
                            , Total
                            , EmailList );
    end;

    GravaIni(tipo);
  except on E :Exception do
    GravaLog(E.Message);
  end;
  finally
    cdsCOntroleSMS.Close;
    cdsNaoEnviados.Close;
    timerRelatorioSMS.Enabled := True;
  end;
end;

procedure TsrvTelesServicos.Conecta_DB;
begin
  if FileExists(ExtractFilePath(ParamStr(0)) + '\Config.XML') then
  begin
    cdsConfiguracoes.LoadFromFile(ExtractFilePath(ParamStr(0)) + '\Config.XML');
    cdsConfiguracoes.First;
    while not cdsConfiguracoes.Eof do
    begin
      if cdsConfiguracoespadrao.AsString = 'S' then
      begin
        // Pega Valores (Servidor)
        Aplicacao  := cdsConfiguracoespath_sistema_local.AsString;
        Servidor   := cdsConfiguracoesip_servidor.AsString;
        BancoDados := cdsConfiguracoespath_banco_dados.AsString + '\Teles Cabeleireiros.FDB';
        Usuario    := JvVigenereCipher1.DecodeString('Usuario',cdsConfiguracoesusuario.AsString);
        Senha      := JvVigenereCipher1.DecodeString('Senha',cdsConfiguracoessenha.AsString);
        Abre_Banco_Dados;
        Exit;
      end;
      cdsConfiguracoes.Next;
    end;
  end
  else
    GravaLog('Não foi possível abrir o banco de dados!');
end;

procedure TsrvTelesServicos.Abre_Banco_Dados;
begin
  if Servidor <> '0.0.0.0' then
  begin
    Banco := Servidor;
    Banco := Banco + ':' + BancoDados;
  end
  else
    Banco := BancoDados;
  with SQLConnectionEmails do
  begin
    try
      with Params do
      begin
        Clear;
        Add('DriverName=Interbase');
        Add('BlobSize=-1');
        Add('CommitRetain=False');
        Add('Database='  +Banco);
        Add('ErrorResourceFile=');
        Add('LocaleCode=0000');
        Add('RoleName=RoleName');
        Add('ServerCharSet=');
        Add('SQLDialect=3');
        Add('Interbase TransIsolation=ReadCommited');
        Add('WaitOnLocks=True');
        Add('User_Name=' + Usuario);
        Add('Password=' + Senha);
      end;
      try
        Connected := True;
      except on e:Exception do
        begin
          GravaLog(e.Message);
        end;
      end;
    finally
    end;
  end;
end;

{Propriedades}
function TsrvTelesServicos.EmpresaPadrao: Integer;
var
  Arquivo : TIniFile;
begin
  Arquivo := TIniFile.Create(ExtractFilePath(ParamStr(0))+'\Config.ini');
  try
    Result := StrToInt(Arquivo.ReadString('empresa_padrao_terminal','codigo',''));
  except
    Result := 1;
  end;
end;

function TsrvTelesServicos.ApelidoEmpresa: String;
var
  sqlEmpresas : TSQLQuery;
begin
  sqlEmpresas := TSQLQuery.Create(nil);
  with sqlEmpresas do
  begin
    try
      Close;
      sql.Clear;
      SQLConnection := TSQLConnection(SQLConnectionEmails);
      SQL.Add('select apelido from empresas where codigo_empresa = '+ IntToStr(EmpresaPadrao));
      Open;
    finally
      Result := FieldByName('apelido').AsString;
      FreeAndNil(sqlEmpresas);
    end;
  end;
end;

function TsrvTelesServicos.Email_Gestor: String;
var
  qr_aux : TSqlquery;
begin
  qr_aux := TSQLQuery.Create(nil);
  with qr_aux do
  begin
    try
      Close;
      SQL.Clear;
      SQLConnection := TSQLConnection(SQLConnectionEmails);
      SQL.Add('SELECT EMAIL_GESTOR FROM PARAMETROS_EMAIL  ');
      SQL.Add('WHERE CODIGO_EMPRESA = '+ IntToStr(EmpresaPadrao));       // Padrão
      Open;
      Result := FieldByName('EMAIL_GESTOR').AsString;
    finally
      FreeAndNil(qr_aux);
    end;
  end;
end;

function TsrvTelesServicos.Limite_SMS: Integer;
var
  sqlParametros : TSQLQuery;
begin
  sqlParametros := TSQLQuery.Create(nil);
  with sqlParametros do
  begin
    try
      Close;
      sql.Clear;
      SQLConnection := TSQLConnection(SQLConnectionEmails);
      SQL.Add('select qtde_limite_mensal from parametros_sms where codigo_empresa = '+ IntToStr(EmpresaPadrao));
      Open;
    finally
      Result := FieldByName('qtde_limite_mensal').AsInteger;
      FreeAndNil(sqlParametros);
    end;
  end;
end;

function TsrvTelesServicos.Parametro_Web  :String;
var
  sqlParametros : TSQLQuery;
begin
  sqlParametros := TSQLQuery.Create(nil);
  with sqlParametros do
  begin
    try
      Close;
      sql.Clear;
      SQLConnection := TSQLConnection(SQLConnectionEmails);
      SQL.Add('select web from parametros_sms where codigo_empresa = '+ IntToStr(EmpresaPadrao));
      Open;
    finally
      Result := FieldByName('web').AsString;
      FreeAndNil(sqlParametros);
    end;
  end;
end;

function TsrvTelesServicos.Id_Web  :Integer;
var
  sqlParametros : TSQLQuery;
begin
  sqlParametros := TSQLQuery.Create(nil);
  with sqlParametros do
  begin
    try
      Close;
      sql.Clear;
      SQLConnection := TSQLConnection(SQLConnectionEmails);
      SQL.Add('select id_web from empresas where web = '+ QuotedStr('S') );
      Open;
    finally
      Result := FieldByName('id_web').AsInteger;
      FreeAndNil(sqlParametros);
    end;
  end;
end;

end.

