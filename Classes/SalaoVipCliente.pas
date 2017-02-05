unit SalaoVipCliente;

interface

uses Classes, SalaoVIP, uCliente;

type TSalaoVipCliente = class(TSalaoVIP)
private

protected

public
  function postCliente (cliente :TCliente) :String;
  function getCliente  ( clienteID :Integer ) :TCliente;  
published

end;



implementation

uses SysUtils, ConvUtils, Variants, uLkJSON;

{ TSalaoVipAgenda }

{ TSalaoVipCliente }

function TSalaoVipCliente.getCliente(clienteID: Integer): TCliente;
var
  Str :String;
  jsLista, jsData, jsProfissional: TlkJSONobject;
  ok :Boolean;
  tt :Integer;
  cliente :TCliente;
begin
  cliente := TCliente.Create;
  Furl    := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/cliente/' + IntToStr(clienteID);
  Fmetodo := 'GET_CLIENTE';
  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  try
    Str := lhttp.Get( Furl );
    Str := '{"Lista": '+ Str + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;

    jsLista := js.Field['Lista'] as TlkJSONobject;
    Fcode := jsLista.Field['code'].value;

    if Fcode = 200 then
    begin
      jsData  := jsLista.Field['data'] as TlkJSONobject;
      jsProfissional := jsData.Field['salonClient'] as TlkJSONobject;
      tt := jsProfissional.Field['id'].Value;
      cliente.Fid_web  := tt;
      cliente.FNome    := jsProfissional.Field['nome'].Value;
      try
        cliente.FEmail :=  jsProfissional.Field['email'].Value;
        cliente.FPhone := jsProfissional.Field['celular'].Value;
      except
        cliente.FEmail := '';
        cliente.FPhone := '';
      end;
      cliente.FCpf   := VarToStr(jsProfissional.Field['cpf'].Value);
      if not TryStrToDate( VarToStr(jsProfissional.Field['datanasc'].Value), cliente.FDataNasc, Fformart ) then
        cliente.FDataNasc := Now;
      Result := cliente;  
    end;
  finally
    js.Free;
    //cliente.Free;
  end;
end;

function TSalaoVipCliente.postCliente(cliente: TCliente): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
begin
  lparams.Clear;
  Furl    := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/cliente';

  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;
  js := TlkJSONobject.Create;

  js.Add('nome',    cliente.FNome);
  js.Add('celular', cliente.FPhone);
  lparams.Add(TlkJSON.GenerateText(js));
  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

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
  RequestBody.Free;    
end;

end.
