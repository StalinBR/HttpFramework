unit uThreadSalaoVIP;

interface

uses
 Classes, SysUtils, Windows, Controls, uAgenda;

type
  ThreadSalaoVIP = class(TThread)
  private
    function ConverteData (data :String) :TDateTime;
    function FormataHora (data :Integer) :Integer;
    function DesformataHora (data :Integer) :Integer;
    procedure ExportaCliente(controle :Integer);
    procedure GravaLog(log :String);    
  protected
    procedure Execute; override;
    procedure EnviaHorariosSalaoVIP;
    procedure ImportaAgendamentos;
    function ImportaHorario(Horario :TAgenda) :Integer;
    procedure ImportaCliente(id :Integer);
  end;

implementation

uses
  DateUtils, DB,
  uAgendaDAO, uParametrosDAO, uClientesDAO, uProfissionaisDAO,
  uCliente, uProfissional, uDAO,
  SalaoVipAgenda, SalaoVipCliente, Math;

function ThreadSalaoVIP.ConverteData(data: String): TDateTime;
begin
  //Ex: Input: "2016-02-18" Output: "18/02/2016"
  Result := EncodeDate    ( StrToInt(Copy(data,0,4))
                          , StrToInt(Copy(data,6,2))
                          , StrToInt(Copy(data,9,2))
                          );
end;

procedure ThreadSalaoVIP.EnviaHorariosSalaoVIP;
var
 retorno :String;
 agendaDAO :TAgendaDAO;
 lista :ListaAgenda;
 i :Integer;
 svipAgenda :TSalaoVipAgenda;
begin
  agendaDAO  := TAgendaDAO.Create;
  svipAgenda := TSalaoVipAgenda.Create( 1, agendaDAO.getSalaoID, agendaDAO.getToken );
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

        try
        lista[i].FclienteIdWeb       := agendaDAO.PesquisaClienteID( lista[i].Fcontrole );
        lista[i].FprofissionalIdWeb  := agendaDAO.PesquisaProfissionalID( IntToStr(  lista[i].Fcodigo_profissional), IntToStr(lista[i].Femp_profissional) );
        lista[i].FsalaoIdWeb         := agendaDAO.PesquisaSalaoID( agendaDAO.Fempresa_padrao );
        lista[i].Fhora               := DesformataHora( lista[i].Fhora );
        lista[i].Ffim                := DesformataHora( lista[i].Ffim );
        lista[i].Fservicos           := agendaDAO.PesquisaServicoAgenda( lista[i].Fcontrole );

        retorno := svipAgenda.Execute(lista[i]);
        except
          svipAgenda.GravaLog('Erro ao ExportarAgenda');
        end;


        svipAgenda.GravaLog('Reserva Enviada: ' + svipAgenda.ToString );
        if svipAgenda.Fcode = 200 then
        begin
          if lista[i].Facao = 1 then
            agendaDAO.UpdateIdWeb( lista[i].Fcontrole, StrToInt(retorno) );
          agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'BAX');
        end
        else
          agendaDAO.BaixaControle( lista[i].Fcontrole_web, 'CAN');
      end;
    end;
  except on E : Exception do
    svipAgenda.GravaLog(E.Message);
  end;
  finally
    agendaDAO.Free;
    svipAgenda.Free;
  end;
end;

procedure ThreadSalaoVIP.Execute;
var
  paramDAO :TParametrosDAO;
begin
  inherited;
  paramDAO := TParametrosDAO.Create;
  try
    if paramDAO.FutilizaSalaoVIP = 'S' then
    begin
      try
        ImportaAgendamentos;
      except on E :Exception do
        GravaLog( 'Erro na Importacao: ' + E.Message  );
      end;
      try
        EnviaHorariosSalaoVIP;
      except on E :Exception do
        GravaLog( 'Erro ao Exportar: ' + E.Message  );
      end;
    end;
  finally
   FreeAndNil( paramDAO );
   Terminate;
  end;
end;

procedure ThreadSalaoVIP.ExportaCliente(controle :Integer);
var
  cliente :TCliente;
  retorno :String;
  clienteDAO :TClientesDAO;
  svipCliente :TSalaoVipCliente;
begin
  clienteDAO := TClientesDAO.Create;
  try
    cliente := clienteDAO.PesquisaClienteByAgenda(controle);
    svipCliente := TSalaoVipCliente.Create( 1, clienteDAO.getSalaoID, clienteDAO.getToken);
    if (cliente.Fid_web = 0) then
      retorno := svipCliente.postCliente(cliente);
    if retorno <> '' then
    begin
      clienteDAO.AtualizaIdWeb( StrToInt(retorno), cliente.Fcodigo_empresa, cliente.Fcodigo_cliente);
    end;
  finally
    FreeAndNil( clienteDAO );
  end;
end;

function ThreadSalaoVIP.FormataHora(data: Integer): Integer;
var
 vHora :Integer;
 vMin :Integer;
begin
  // SVIP -> TELES
  vHora := ( data div 60 ) * 100 ;
  vMin :=  ( data mod 60 );
  Result := vHora + vMin;
end;

function ThreadSalaoVIP.ImportaHorario(Horario: TAgenda) :Integer;
var
 profissionalDAO :TProfissionaisDAO;
 profissional :TProfissional;
 clienteDAO :TClientesDAO;
 cliente :TCliente;
 agendaDAO :TAgendaDAO;

 Servico, status :String;
 dataIni :TDateTime;
 Hora, Fim :Integer;
 //
begin
  if Horario.FclienteIdWeb > 0 then
    ImportaCliente(Horario.FclienteIdWeb);

  profissionalDAO := TProfissionaisDAO.Create;
  profissional    := profissionalDAO.PesquisaProfissionaisById(Horario.FprofissionalIdWeb);

  clienteDAO := TClientesDAO.Create;
  cliente := clienteDAO.PesquisaClienteById(Horario.FclienteIdWeb);

  agendaDAO := TAgendaDAO.Create;
  Servico := agendaDAO.PesquisaDescricaoServico(Horario.FservicoIdWeb);

  dataIni :=  ConverteData(Horario.Fdata);
  Hora    :=  FormataHora(Horario.Fhora);
  Fim     :=  FormataHora(Horario.Ffim);

  status := 'M';

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
      //salaoVIP.GravaLog( 'Reserva confirmada: ' + IntToStr( Horario.ID));
      Result := 1;
    end
    else
    begin
      //salaoVIP.GravaLog( 'Reserva cancelada pelo sistema: ' + IntToStr( Horario.ID));
      Result := 0;
    end;
  except on E :Exception do
    begin
        //salaoVIP.GravaLog( 'Reserva cancelada pela Exception: ' + E.Message + IntToStr( Horario.ID));
      Result := 0;
    end;
  end;
end;

procedure ThreadSalaoVIP.ImportaAgendamentos;
var
  Horarios :Agendas;
  i :Integer;
  retorno, notificado :Integer;
  agendaDAO :TAgendaDAO;
  svipAgenda :TSalaoVipAgenda;
begin
  agendaDAO := TAgendaDAO.Create;
  svipAgenda := TSalaoVipAgenda.Create( 1, agendaDAO.getSalaoID, agendaDAO.getToken );
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
    FreeAndNil( agendaDAO );
    FreeAndNil( svipAgenda );
  end;
end;

procedure ThreadSalaoVIP.ImportaCliente(id: Integer);
var
  Cliente :TCliente;
  clienteDAO :TClientesDAO;
  svipCliente :TSalaoVipCliente;
begin
  clienteDAO := TClientesDAO.Create;
  svipCliente := TSalaoVipCliente.Create( 1, clienteDAO.getSalaoID, clienteDAO.getToken );
  try
    Cliente := svipCliente.getCliente(id);
    svipCliente.GravaLog( svipCliente.ToString  );
    if  clienteDAO.PesquisaClienteWeb(Cliente.Fid_web, Cliente.FEmail, Cliente.FPhone ) = 0 then
    begin
      if clienteDAO.PesquisaCliente(Cliente.Fid_web, Cliente.FEmail, Cliente.FPhone) = 0 then
        clienteDAO.IncluiCliente( Cliente.FNome, Cliente.Fcpf, Cliente.FPhone, Cliente.FEmail, Cliente.FFacebook, Cliente.FDataNasc, Cliente.Fid_web );
    end;
  finally
    FreeAndNil( clienteDAO );
    FreeAndNil( svipCliente );
  end;
end;

function ThreadSalaoVIP.DesformataHora(data: Integer): Integer;
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

procedure ThreadSalaoVIP.GravaLog(log: String);
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
    CloseFile(arquivo)
  end;
end;

end.
