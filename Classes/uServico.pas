unit uServico;

interface
uses Classes;

type TServico = class
private

protected

public
  FID :Integer;
  FDuration :String;
  FName :String;
  FDescription :String;
  FPrice :Double;
  FSalonID :String;
  FServiceTypeID :Integer;
  FActive :Integer;
  FTempo :Integer;
  FTipoValor :Integer;

  constructor Create( categoriaID :Integer; nome :String; preco :Double; tempo, tipo_valor :Integer );
published

end;


implementation

{ TServico }

constructor TServico.Create( categoriaID :Integer; nome :String; preco :Double; tempo, tipo_valor :Integer );
begin
  FServiceTypeID := categoriaID;
  FName := nome;
  FPrice := preco;
  FTempo := tempo;
  FTipoValor := tipo_valor;
end;

end.
