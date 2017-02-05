unit SalaoVipServico;

interface

uses Classes, SalaoVIP, uServico;

type TSalaoVipServico = class(TSalaoVIP)
  private
  protected
  public
    function postServico(servico :TServico) :String;
end;


implementation

uses SysUtils, ConvUtils, Variants, uLkJSON;

{ TSalaoVipCliente }


{ TSalaoVipComanda }

function TSalaoVipServico.postServico(servico: TServico): String;
var
  Str :String;
  jsLista, jsData :TlkJSONobject;
  tipo :String;
begin
  lparams.Clear;
  if servico.FID > 0 then
    Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/servico/' + IntToStr(servico.FID)
  else
    Furl := Fnamespace + 'salao/' + IntToStr(FsalaoID) + '/servico';

  lhttp.Request.ContentType := 'application/json';
  lhttp.Request.CustomHeaders.Values['Authorization'] := Ftoken;

  case servico.FTipoValor of
    0 : tipo := 'fixo';
    1 : tipo := 'apartirde';
    2 : tipo := 'sobconsulta';
  end;

  js := TlkJSONobject.Create;
  js.Add('categoria_id',    servico.FServiceTypeID);
  js.Add('servico', servico.FName);
  js.Add('valor', servico.FPrice);
  js.Add('tempo', servico.FTempo);
  js.Add('tipo_valor', tipo);
  lparams.Add(TlkJSON.GenerateText(js));

  RequestBody := TStringStream.Create( TlkJSON.GenerateText(js) );

  if servico.FID > 0 then
    lhttp.Put(Furl, RequestBody)
  else
    lhttp.Post( Furl, RequestBody, lresponse );
  lresponse.Position := 0;

  try
    Str := '{"Lista": '+ lresponse.DataString + '}';
    js := TlkJSON.ParseText( Str ) as TlkJSONobject;

    if servico.FID = 0 then
    begin
      jsLista := js.Field['Lista'] as TlkJSONobject;
      Fcode := jsLista.Field['code'].value;
      if Fcode = 200 then
      begin
        jsData  := jsLista.Field['data'] as TlkJSONobject;
        Result := jsData.Field['id'].Value;
      end
      else
        Result := '';
    end
    else
      Result := IntToStr(servico.FID);    
    RequestBody.Free;
  except
    Result := '';
  end;
end;

end.
