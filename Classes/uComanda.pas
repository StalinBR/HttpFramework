(* ITENS
- salao_servicos
- salao_productos
- salao_pacotes
*)

unit uComanda;

interface
uses Classes, SysUtils;

type TComanda = class
private

protected

public
  Fid :Integer;
  Fdata :TDateTime;
  Fnumero :Integer;
  Fsalao_cliente_id :Integer;
  Fstatus :String;
  function ToJson :String; 
  constructor Create ( data :TDateTime; numero, salao_cliente_id :Integer );
published

end;


implementation

uses uLkJSON;

{ TComanda }

constructor TComanda.Create(data: TDateTime; numero,
  salao_cliente_id: Integer);
begin
  Fdata := data;
  Fnumero := numero;
  Fsalao_cliente_id := salao_cliente_id;
end;

function TComanda.ToJson: String;
var
  js :TlkJSONobject;
  formato :TFormatSettings;
begin
  formato.ShortDateFormat := 'yyyy-mm-dd';
  js := TlkJSONobject.Create;
  js.Add('data',             FormatDateTime( 'yyyy-mm-dd', Fdata, formato) );
  js.Add('numero',           Fnumero);
  js.Add('salao_cliente_id', Fsalao_cliente_id);
  result := Tlkjson.GenerateText(js);
end;

end.
