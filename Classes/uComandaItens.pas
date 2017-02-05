(* ITENS
- salao_servicos
- salao_productos
- salao_pacotes
*)

unit uComandaItens;

interface
uses Classes;

type Ttipo = ( salao_servicos, salao_productos, salao_pacotes );

type TComandaItem = class
private
protected
public
  Fid :Integer;
  Fcomanda_id: Integer;
  Fsalao_id : Integer;
  Ftipo: String;
  Ftipo_id: Integer;
  Fitem : String;
  Fquantidade :Integer;
  Fcusto : Integer;
  Fvalor : Double;
  Fdesconto: Integer;
  Fcomissao: Integer;
  Fcomissao1: Integer;
  Fcomissao2: Integer;
  Fstatus: Integer;

  constructor Create ( comanda_id, salao_id :Integer; tipo :String; tipo_id, quantidade : Integer; valor :Double; status :Integer; item :String );
end;

type ListaComandasItens = array of TComandaItem;

implementation

constructor TComandaItem.Create(comanda_id, salao_id :Integer; tipo :String; tipo_id, quantidade : Integer; valor :Double; status :Integer; item :String);
begin
  Fcomanda_id := comanda_id;
  Fsalao_id := salao_id;
  Ftipo := tipo;
  Ftipo_id := tipo_id;
  Fquantidade := quantidade;
  Fvalor := valor;
  Fstatus := status;
  Fitem := item;
end;

end.
