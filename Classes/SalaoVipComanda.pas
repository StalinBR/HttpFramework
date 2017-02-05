unit SalaoVipComanda;

interface

uses Classes, SalaoVipResponse, SalaoVIP, uComanda, uComandaItens;



type TSalaoVipComanda = class(TSalaoVIP)
private
  function postServico( servico :TComandaItem ) :String;
  function postProduto( produto :TComandaItem ) :String;
protected

public
  function postComanda(comanda: TComanda) : TSalaoVipResponse;
  function postComandaItens( comanda_itens :ListaComandasItens ) :String;
  function postItem ( item :TComandaItem ) :String;
  procedure deleteComandaItens ( comanda :Integer );
  function postSolicitarPagamento( comanda :Integer ) :String;
  function postVerificarPagamento( transacao :Integer ) :String;
published

end;



implementation

uses SysUtils, ConvUtils, Variants, uLkJSON;

{ TSalaoVipCliente }

procedure TSalaoVipComanda.deleteComandaItens(comanda: Integer);
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/comanda/' + IntToStr(comanda) + '/itens';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  try
    lhttp.Delete(Furl,lresponse);
  except
    //
  end;
end;

function TSalaoVipComanda.postComanda(comanda: TComanda): TSalaoVipResponse;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/comanda/';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  js.Add('data',             FormatDateTime( 'yyyy-mm-dd', comanda.Fdata, Fformart) );
  js.Add('numero',           comanda.Fnumero);
  js.Add('salao_cliente_id', comanda.Fsalao_cliente_id);
  lparams.Add(Tlkjson.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );
  try
    lhttp.Post(Furl, RequestBody, lresponse);
    Result := TSalaoVipResponse.Create( lresponse.DataString );

  except on E :Exception do
    Result := TSalaoVipResponse.Create('');
  end;
  RequestBody.Free;
end;

function TSalaoVipComanda.postComandaItens(
  comanda_itens: ListaComandasItens): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
  i :Integer;
  jsitem : TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/comanda/' + IntToStr(comanda_itens[0].Fcomanda_id) + '/itens';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;
  ja := TlkJSONlist.Create;

  for i := 0 to Length(comanda_itens)-1  do
  begin
    jsitem := TlkJSONobject.Create;
    jsitem.Add('comanda_id', comanda_itens[i].Fcomanda_id);
    jsitem.Add('salao_id',   comanda_itens[i].Fsalao_id);
    jsitem.Add('tipo',       comanda_itens[i].Ftipo);
    jsitem.Add('tipo_id',    comanda_itens[i].Ftipo_id);
    jsitem.Add('item',       comanda_itens[i].Fitem);
    jsitem.Add('quantidade', comanda_itens[i].Fquantidade);
    jsitem.Add('valor',      comanda_itens[i].Fvalor);
    jsitem.Add('status',     comanda_itens[i].Fstatus);
    ja.Add(jsitem);
  end;
  js.Add('itens', ja);
  lparams.Add(Tlkjson.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  try
    lhttp.Post(Furl, RequestBody, lresponse);
    lresponse.Position := 0;
    Str := '{"Lista": '+ lresponse.DataString + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;
    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if lhttp.ResponseCode = 200 then
    begin
      Result := '';
    end
    else
      Result := '0';
  except on E :Exception do
    Result := '';
  end;
  RequestBody.Free;
end;

function TSalaoVipComanda.postItem(item: TComandaItem): String;
begin
  if item.Ftipo = 'salao_servicos' then
    Result := postServico(item)
  else if item.Ftipo = 'salao_productos' then
    Result := postProduto(item);
end;

function TSalaoVipComanda.postProduto(produto: TComandaItem): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
  tipo :String;
begin
  lparams.Clear;
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/produto';

  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  js := TlkJSONobject.Create;
  js.Add('nome', produto.Fitem);
  js.Add('valor', produto.Fvalor);
  lparams.Add(TlkJSON.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  lhttp.Post( Furl, RequestBody, lresponse );
  lresponse.Position := 0;

  try
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
    RequestBody.Free;
  except
    Result := '';
  end;
end;

function TSalaoVipComanda.postServico(servico: TComandaItem): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
  tipo :String;
begin
  lparams.Clear;
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/servico';

  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  js := TlkJSONobject.Create;
  js.Add('categoria_id', 1); // Defalt...
  js.Add('servico', servico.Fitem);
  js.Add('valor', servico.Fvalor);
  js.Add('agendamento_online', false);    // Preciso que esse serviço não seja habilitado para Agendamento Online
  lparams.Add(TlkJSON.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  lhttp.Post( Furl, RequestBody, lresponse );
  lresponse.Position := 0;

  try
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
    RequestBody.Free;
  except
    Result := '';
  end;
end;

function TSalaoVipComanda.postSolicitarPagamento(  comanda: Integer): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/pagamento/solicitar';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  js.Add('tipo', 'comandas' );
  js.Add('tipo_id', comanda);
  lparams.Add(Tlkjson.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  try
    lhttp.Post(Furl, RequestBody, lresponse);

    lresponse.Position := 0;
    Str := '{"Lista": '+ lresponse.DataString + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;
    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if lhttp.ResponseCode = 200 then
    begin
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      Result := jsData.Field['id'].Value;
    end
    else
      Result := '0';
  except on E :Exception do
    Result := '';
  end;
  RequestBody.Free;
end;

function TSalaoVipComanda.postVerificarPagamento(
  transacao: Integer): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/pagamento/verificar/' + IntToStr(transacao);
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  js.Add('tipo', 'comandas' );
  js.Add('tipo_id', transacao);
  lparams.Add(Tlkjson.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  try
    lhttp.Post(Furl, RequestBody, lresponse);

    lresponse.Position := 0;
    Str := '{"Lista": '+ lresponse.DataString + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;
    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if lhttp.ResponseCode = 200 then
    begin
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      Result := jsData.Field['id'].Value;
    end
    else
      Result := '0';
  except on E :Exception do
    Result := '';
  end;
  RequestBody.Free;
end;

end.
