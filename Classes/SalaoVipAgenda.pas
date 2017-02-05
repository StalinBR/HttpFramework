unit SalaoVipAgenda;

interface

uses Classes,  SalaoVIP, uAgenda;

type TSalaoVipAgenda = class(TSalaoVIP)
private
  function postReserva(horario :TAgenda ): String;
  function postAgenda(horario: TAgenda): String;
  function deleteAgenda(reservaID: Integer): String;

protected

public
  function Execute ( horario :TAgenda ) :String;
  function getListaReserva (idSalao :Integer) :Agendas;
  function postSincronizado( status, notificado, reservaID :Integer) :String;    
published 

end;



implementation

uses SysUtils, ConvUtils, Variants, uLkJSON;

{ TSalaoVipAgenda }

function TSalaoVipAgenda.deleteAgenda(reservaID: Integer): String;
var
  Str :String;
  jsLista :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/' + Fmetodo + '/' + IntToStr(reservaID);
  lparams.Clear;
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  lhttp.Delete( Furl, lresponse );
  lresponse.Position := 0;

  Str := '{"Lista": '+ lresponse.DataString + '}';
  js := TlkJSON.ParseText( Str ) as TlkJSONobject;
  jsLista := js.Field['Lista'] as TlkJSONobject;
  Fcode := jsLista.Field['code'].value;
  if Fcode = 200 then
  begin
    Result := jsLista.Field['code'].value;
  end
  else
    Result := '';
end;

function TSalaoVipAgenda.Execute(horario: TAgenda): String;
begin
  if   ( ( horario.FstatusA <> 'O') AND (horario.FstatusA <> 'R') ) then
    Fmetodo := 'reserva'
  else
    Fmetodo := 'agenda';

  if horario.Facao = 3 then
    Result := deleteAgenda( horario.Fid_Web )
  else if (horario.FstatusA <> 'O') AND (horario.FstatusA <> 'R') then
    Result := postReserva(horario)
  else
    Result := postAgenda(horario);
end;

function TSalaoVipAgenda.getListaReserva(idSalao: Integer): Agendas;
var
  Str :String;
  aSchedule :Agendas;
  tSchedule :TAgenda;
  i :Integer;
  jsLista, jsData :TlkJSONobject;
begin
  lparams.Clear;
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/reservas/sincronizado' ;
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;
  try
    Str := lhttp.Get( Furl );
    Str := '{"Lista": '+ Str + '}';
    lparams.add(Str);
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;

    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if Fcode = 200 then
    begin
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      ja := jsData.Field['bookings'] as TlkJSONlist;
      SetLength(aSchedule, ja.count);

      tSchedule := TAgenda.Create;
      for i:=0 to ja.Count-1 do
      begin
        tSchedule.FclienteIdWeb       := StrToInt( VarToStr(ja.Child[i].Field['salao_cliente_id'].Value) );

        if not TryStrToInt( VarToStr(ja.Child[i].Field['servico_id'].Value), tSchedule.FservicoIdWeb  ) then
        tSchedule.FservicoIdWeb        := 0;

        tSchedule.FsalaoIdWeb          := StrToInt( VarToStr(ja.Child[i].Field['salao_id'].Value) );
        tSchedule.FprofissionalIdWeb   := StrToInt( VarToStr(ja.Child[i].Field['profissional_id'].Value) );
        tSchedule.Fdata                := VarToStr(ja.Child[i].Field['data'].Value);
        tSchedule.Fhora                := StrToInt( VarToStr(ja.Child[i].Field['hora_ini'].Value) );
        tSchedule.Ffim                 := StrToInt( VarToStr(ja.Child[i].Field['hora_fim'].Value) );
        tSchedule.Fid_Web              := StrToInt( VarToStr(ja.Child[i].Field['id'].Value) );
        tSchedule.FStatus              := VarToStr(ja.Child[i].Field['status'].Value);

        aSchedule[i] := tSchedule;
      end;
      Result := aSchedule;
    end
  finally
    js.Free;
  end;
end;

function TSalaoVipAgenda.postAgenda(horario: TAgenda): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  lparams.Clear;
  if horario.Fid_Web > 0 then
    Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/agenda/' + IntToStr(horario.Fid_Web)
  else
    Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/agenda';

  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  //js.Add('servico_id'        , horario.ServiceId);
  js.Add('profissional_id'   , horario.FprofissionalIdWeb);
  js.Add('data_inicio'       , horario.Fdata);
  js.Add('data_fim'          , horario.Fdata);
  js.Add('hora_inicio'       , horario.Fhora);
  js.Add('hora_fim'          , horario.Ffim);
  lparams.Add( TlkJSON.GenerateText(js) );
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  try
    if horario.Fid_Web > 0 then
    begin
      Str := lhttp.Put(Furl, RequestBody);
    end
    else
      lhttp.Post(Furl, RequestBody, lresponse);

    Fcode := lhttp.ResponseCode;
    lresponse.Position := 0;
    if Str = '' then
      Str := '{"Lista": '+ lresponse.DataString + '}';
    if (lhttp.ResponseCode = 200) and (lresponse.DataString <> '') then
    begin
      js := TlkJSON.ParseText( Str ) as TlkJSONobject;
      jsLista := js.Field['Lista'] as TlkJSONobject;  
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      Result := jsData.Field['id'].Value;
    end
    else
      Result := Str;
  except on E :Exception do
    Result := E.Message;
  end;
  RequestBody.Free;
end;

function TSalaoVipAgenda.postReserva(horario: TAgenda): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/reserva';
  lparams.Clear;
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  js.Add('servicos'          , horario.Fservicos);
  js.Add('profissional_id'   , horario.FprofissionalIdWeb);
  js.Add('salao_cliente_id'  , horario.FclienteIdWeb);
  js.Add('cliente_nome'      , '');
  js.Add('cliente_tel'       , '');
  js.Add('data'              , horario.Fdata);
  js.Add('hora_ini'          , horario.Fhora);
  js.Add('hora_fim'          , horario.Ffim);
  //
  js.Add('status', 1);
  js.Add('encaixe'           , 1);
  lparams.Add(TlkJSON.GenerateText(js));

  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  try
  lhttp.Post(Furl, RequestBody, lresponse);
  lresponse.Position := 0;

  Str := '{"Lista": '+ lresponse.DataString + '}';
  js := TlkJSON.ParseText( Str ) as TlkJSONobject;
  jsLista := js.Field['Lista'] as TlkJSONobject;
  Fcode := jsLista.Field['code'].value;
  if Fcode = 200 then
  begin
    jsData  := jsLista.Field['data'] as TlkJSONobject;
    Result := jsData.Field['id'].Value;
  end
  else
    Result := '';
  except
     // Pensar numa exception adequada
  end;
  RequestBody.Free;
end;

function TSalaoVipAgenda.postSincronizado(status, notificado,
  reservaID: Integer): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/reservas/sincronizar/' + IntToStr(reservaID);
  lparams.Clear;
  lhttp.Request.Accept :=  'application/json';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  js := TlkJSONobject.Create;
  js.Add('status', status);
  js.Add('notificar', notificado);
  lparams.Add(TlkJSON.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );
  try
    lhttp.Post(Furl, RequestBody, lresponse);
    lresponse.Position := 0;
    Str := '{"Lista": '+ lresponse.DataString + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;
    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if Fcode = 200 then
    begin
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      Result := jsData.Field['id'].Value;
    end
    else
      Result := '';
  finally
    js.Free;
    RequestBody.Free;
  end;
end;

end.
