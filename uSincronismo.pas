unit uSincronismo;

interface

uses
  Windows, Messages, SysUtils, Classes,
  uAgenda,
   uAgendaDAO, uClientesDAO, uProfissionaisDAO,
  Registry, ExtCtrls, FMTBcd, Controls, SvcMgr;

type
  TTelesSincronismoWeb = class(TService)
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
    procedure ServiceAfterInstall(Sender: TService);
  private
    function GetServiceController: TServiceController; override;
    procedure EnviaHorariosSalaoVIP;
    procedure ImportaAgendamentos;
    function ImportaHorario(Horario :TAgenda) :Integer;
    procedure ImportaCliente(id :Integer);
    procedure ExportaCliente(controle :Integer);
    function DesformataHora (data :Integer) :Integer;
    function ConverteData (data :String) :TDateTime;
    function FormataHora (data :Integer) :Integer;
    procedure GravaLog(log :String);
    procedure ReportBugByEmail( assunto, mensagem :String );
  public
    agendaDAO :TAgendaDAO;
    clienteDAO :TClientesDAO;
    profissionalDAO :TProfissionaisDAO;
  end;

var
  TelesSincronismoWeb: TTelesSincronismoWeb;

implementation

uses
  DateUtils, DB,
  uCliente, uProfissional, uDAO,
  Uemail,
  SalaoVipAgenda, SalaoVipCliente, Math;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  TelesSincronismoWeb.Controller(CtrlCode);
end;

function TTelesSincronismoWeb.ConverteData(data: String): TDateTime;
begin
  //Ex: Input: "2016-02-18" Output: "18/02/2016"
  Result := EncodeDate    ( StrToInt(Copy(data,0,4))
                          , StrToInt(Copy(data,6,2))
                          , StrToInt(Copy(data,9,2))
                          );
end;

function TTelesSincronismoWeb.DesformataHora(data: Integer): Integer;
var
 vHora :Double;
 vMin :Integer;
begin
  // TELES -> SVIP
  vHora := Trunc( data / 100 );
  vHora := ( vHora * 60 ) ;
  vMin :=  ( data mod 100 );
  Result := Trunc(vHora) + vMin;
end;

procedure TTelesSincronismoWeb.EnviaHorariosSalaoVIP;
var
 retorno :String;
 lista :ListaAgenda;
 i :Integer;
 svipAgenda :TSalaoVipAgenda;
begin
  svipAgenda := TSalaoVipAgenda.Create( agendaDAO.getSalaoID, agendaDAO.getToken );
  try
  try
    lista := agendaDAO.listaAgenda;
    if Length(lista) > 0 then
    begin
      svipAgenda.GravaLog('EnviaHorarios');
      for i := 0 to Length(lista)-1 do
      begin
        //
        try
          if lista[i].Facao = 1 then
          begin
            if   ( ( lista[i].FstatusA <> 'O') AND (lista[i].FstatusA <> 'R') ) then
              ExportaCliente( lista[i].Fcontrole );
          end;
        except
          svipAgenda.GravaLog('Erro ao ExportarCliente:');
        end;

        lista[i].FclienteIdWeb       := agendaDAO.PesquisaClienteID( lista[i].Fcontrole );
        lista[i].FprofissionalIdWeb  := agendaDAO.PesquisaProfissionalID( IntToStr(  lista[i].Fcodigo_profissional), IntToStr(lista[i].Femp_profissional) );
        lista[i].FsalaoIdWeb         := agendaDAO.PesquisaSalaoID( agendaDAO.Fempresa_padrao );
        lista[i].Fhora               := DesformataHora( lista[i].Fhora );
        lista[i].Ffim                := DesformataHora( lista[i].Ffim );
        lista[i].Fservicos           := agendaDAO.PesquisaServicoAgenda( lista[i].Fcontrole );

        (* No caso do registro tiver em cache e for excluido (e.g. BlinkMe 05/01/2017)
              eu não posso enviar mais esse registro. Então tenho uma verificação
              para saber se esse registro ainda existe na nossa agenda  *)

        if ( not agendaDAO.PesquisaAgendaControle(lista[i].Fcontrole) ) AND ( lista[i].Facao = 1 ) then
        begin
          svipAgenda.GravaLog('Reserva Excluida do Sincronismo por não existir mais no sistema: ' + IntToStr(lista[i].Fcontrole));
          agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
        end
        else if ( lista[i].Facao = 3 ) and ( lista[i].Fid_Web = 0 ) then
        begin
          svipAgenda.GravaLog('Reserva Excluida do Sincronismo por não existir mais no sistema: ' + IntToStr(lista[i].Fcontrole));
          agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
        end
        //
        else
        begin
          retorno := svipAgenda.Execute(lista[i]);
          svipAgenda.GravaLog('Reserva Enviada: ' + svipAgenda.ToString + 'Retorno: ' + retorno );
          if svipAgenda.Fcode = 200 then
          begin
            if lista[i].Facao = 1 then
              agendaDAO.UpdateIdWeb( lista[i].Fcontrole, StrToInt(retorno) );
            agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'BAX');
          end
          else if (svipAgenda.Fcode = 500) and (lista[i].Facao = 3) then
          begin
            svipAgenda.GravaLog('Cancelamento feito pelo Aplicativo: ' + IntToStr(lista[i].Fcontrole));
            agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
          end
          else
          begin
            agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
            ReportBugByEmail( 'ERRO SINCRONIZADOR ' + IntToStr(agendaDAO.getSalaoID),  ' Acao: ' + IntToStr(lista[i].Facao)
                                                                                     + ' Retorno: ' + retorno
                                                                                     + ' ControleWeb: ' + IntToStr(lista[i].Fcontrole_web)
                                                                                     + ' Importar Horário. ' + ' Log: ' + svipAgenda.ToString );
          end;
              // Não alterar para -> CAN
              // Aqui o Email deve ser disparado, pois o método POST já é protegido por Try/Except para não haver quebra no fluxo do programa.
              // agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
        end;
      end;
    end;
  except on E : Exception do
    begin
      svipAgenda.GravaLog(E.Message);
      //ReportBugByEmail( 'Erro ao Importar Horário. Exception: ' + E.Message + ' Log: ' + svipAgenda.ToString );
    end;
  end;
  finally
    FreeAndNil( svipAgenda );
  end;
end;

procedure TTelesSincronismoWeb.ExportaCliente(controle: Integer);
var
  cliente :TCliente;
  retorno :String;
  svipCliente :TSalaoVipCliente;
begin
  try
    cliente := clienteDAO.PesquisaClienteByAgenda(controle);
    svipCliente := TSalaoVipCliente.Create( clienteDAO.getSalaoID, clienteDAO.getToken);
    if (cliente.Fid_web = 0) then
      retorno := svipCliente.postCliente(cliente);
    if retorno <> '' then
    begin
      clienteDAO.AtualizaIdWeb( StrToInt(retorno), cliente.Fcodigo_empresa, cliente.Fcodigo_cliente);
    end;
  except
    svipCliente.GravaLog('ERROR CLIENTE: ' + svipCliente.ToString);
  end;
end;

function TTelesSincronismoWeb.FormataHora(data: Integer): Integer;
var
 vHora :Integer;
 vMin :Integer;
begin
  // SVIP -> TELES
  vHora := ( data div 60 ) * 100 ;
  vMin :=  ( data mod 60 );
  Result := vHora + vMin;
end;

function TTelesSincronismoWeb.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TTelesSincronismoWeb.GravaLog(log: String);
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
    Writeln( arquivo, DateTimeToStr(Now) + ' - ' + log );
  finally
    CloseFile(arquivo);
  end;
end;

procedure TTelesSincronismoWeb.ImportaAgendamentos;
var
  Horarios :Agendas;
  i :Integer;
  retorno, notificado :Integer;
  svipAgenda :TSalaoVipAgenda;
begin
  svipAgenda := TSalaoVipAgenda.Create( agendaDAO.getSalaoID, agendaDAO.getToken );
  try
    Horarios := svipAgenda.getListaReserva( agendaDAO.getSalaoID );
    if Length(Horarios) > 0 then
    begin
      svipAgenda.GravaLog( 'API_LISTA: ' + svipAgenda.ToString );
      for i:=0 to Length(Horarios)-1 do
      begin
        if ( (Horarios[i].FStatus = '0.0') or (Horarios[i].FStatus = '0')) then
        begin
          if Horarios[i].Fid_Web > 0 then // Não deixar fazer um Delete com ID_WEB = 0
            retorno := agendaDAO.ExcluiAgenda(Horarios[i].Fid_Web);
          notificado := 0;
        end
        else
        begin
          retorno := ImportaHorario(Horarios[i]);
          notificado := 1;
        end;
        svipAgenda.postSincronizado(retorno, notificado, Horarios[i].Fid_Web);
      end;
      svipAgenda.GravaLog(svipAgenda.ToString);
    end;
  finally
    FreeAndNil( svipAgenda );
  end;
end;

procedure TTelesSincronismoWeb.ImportaCliente(id: Integer);
var
  Cliente :TCliente;
  svipCliente :TSalaoVipCliente;
begin
  svipCliente := TSalaoVipCliente.Create( clienteDAO.getSalaoID, clienteDAO.getToken );
  try
    Cliente := svipCliente.getCliente(id);
    svipCliente.GravaLog( svipCliente.ToString  );
    if  clienteDAO.PesquisaClienteWeb(Cliente.Fid_web, Cliente.FEmail, Cliente.FPhone ) = 0 then
    begin
      if clienteDAO.PesquisaCliente(Cliente.Fid_web, Cliente.FEmail, Cliente.FPhone) = 0 then
        clienteDAO.IncluiCliente( Cliente.FNome, Cliente.Fcpf, Cliente.FPhone, Cliente.FEmail, Cliente.FFacebook, Cliente.FDataNasc, Cliente.Fid_web );
    end;
  finally
    FreeAndNil( svipCliente );
  end;
end;

function TTelesSincronismoWeb.ImportaHorario(Horario: TAgenda): Integer;
var
 profissional :TProfissional;
 cliente :TCliente;
 Servico, status :String;
 dataIni :TDateTime;
 Hora, Fim :Integer;
begin
  if Horario.FclienteIdWeb > 0 then
    ImportaCliente(Horario.FclienteIdWeb);


  profissional    := profissionalDAO.PesquisaProfissionaisById(Horario.FprofissionalIdWeb);
  cliente         := clienteDAO.PesquisaClienteById(Horario.FclienteIdWeb);
  Servico         := agendaDAO.PesquisaDescricaoServico(Horario.FservicoIdWeb);
  dataIni         :=  ConverteData(Horario.Fdata);
  Hora            :=  FormataHora(Horario.Fhora);
  Fim             :=  FormataHora(Horario.Ffim);
  status          := 'M';

  try
    if agendaDAO.ReservaDisponivel( profissional.Fcodigo_profissional, profissional.Fcodigo_empresa,
                                    dataIni, IntToStr(Hora), IntToStr(Fim) ) then
    begin
      agendaDAO.IncluiAgendamento( DateOf(dataIni),
                                     profissional.Fcodigo_profissional, profissional.Fcodigo_empresa,
                                     cliente.Fcodigo_cliente, cliente.Fcodigo_empresa,
                                     Hora, Fim,
                                     status, Servico, cliente.FNome,
                                     '2', Horario.Fid_Web);
      Result := 1;
    end
    else
    begin
      Result := 0;
    end;
  except on E :Exception do
    begin
      ReportBugByEmail( 'Insert', 'Erro ao Importar Agendamento: ' + E.Message );
      Result := 0;
    end;
  end;
end;

procedure TTelesSincronismoWeb.ReportBugByEmail(assunto, mensagem: String);
begin
  try
    EnviarEmailAPI( '9b561feee81132fc87be611ed5390da9'
                  , '17cc7bd82fd68afe9cc9edde6109f935'
                  , 'reinaldo@telesinfo.com.br'
                  , 'Reinaldo'
                  , assunto
                  , mensagem
                  , ''
                  , 'reinaldo@telesinfo.com.br'
                  , '0' );
  except on E :Exception do
    GravaLog( 'Exception no envio de email: ' +  E.Message );
  end;
end;

procedure TTelesSincronismoWeb.ServiceAfterInstall(Sender: TService);
var
  regEdit : TRegistry;
begin
  regEdit := TRegistry.Create(KEY_READ or KEY_WRITE);
  try
    regEdit.RootKey := HKEY_LOCAL_MACHINE;

    if regEdit.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name,False) then
    begin
      regEdit.WriteString('Description','Teles Hair Solution - Sincronismo Web');
      regEdit.CloseKey;
    end;
  finally
    FreeAndNil(regEdit);
  end;
end;

procedure TTelesSincronismoWeb.ServiceExecute(Sender: TService);
begin
  while not self.Terminated do
  begin
    try
      ServiceThread.ProcessRequests(true);
      Timer1.Enabled := True;
    except
    end;
  end;
end;

procedure TTelesSincronismoWeb.Timer1Timer(Sender: TObject);
begin
  inherited;

  if not Assigned(agendaDAO) then
    agendaDAO := TAgendaDAO.Create;
  if not Assigned(clienteDAo) then
    clienteDAo := TClientesDAO.Create;
  if not Assigned(profissionalDAO) then
    profissionalDAO := TProfissionaisDAO.Create;

  try
    ImportaAgendamentos;
    EnviaHorariosSalaoVIP;
  except on E :EDatabaseError do
    begin
      GravaLog( 'Erro ao Exportar: ' + E.Message  );
      //FreeAndNil(agendaDAO);
      //FreeAndNil(clienteDAo);
      //FreeAndNil(profissionalDAO);
    end;
  end;
end;


end.
