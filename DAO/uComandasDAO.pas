unit uComandasDAO;

interface

uses
 Classes, SysUtils , SqlExpr,
 uDAO, uComanda ;

type TComandasDAO = class(TDAO)
private

protected


public
  function InserirComanda( comanda :TComanda) :Boolean;
  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

{ TParametrosEmailDAO }

constructor TComandasDAO.Create;
begin
  AbreBanco;
end;

destructor TComandasDAO.Destroy;
begin
  inherited;
end;

function TComandasDAO.InserirComanda(comanda: TComanda): Boolean;
var
  Str :TStringList;
begin
  Str := TStringList.Create;

  Str.Add('  insert into movimentos_comanda ( nr_movimento        ');
  Str.Add('                                 , codigo_empresa      ');
  Str.Add('                                 , nr_comanda          ');
  Str.Add('                                 , codigo_cliente      ');
  Str.Add('                                 , emp_cliente         ');
  Str.Add('                                 , data                ');
  Str.Add('                                 , hora_abertura )     ');
  Str.Add('    values ( gen_id(gen_nr_movimento_comanda,1)        ');
  Str.Add('          , ' + IntToStr( comanda.Fcodigo_empresa )  );
  Str.Add('          , ' + IntToStr( comanda.Fnumero )          );
  Str.Add('          , ' + IntToStr( comanda.Fcodigo_cliente )  );
  Str.Add('          , ' + IntToStr( comanda.Fcodigo_cliente )  );
  Str.Add('          , current_date '     );
  Str.Add('          , current_time ) '   );

end;

end.
 