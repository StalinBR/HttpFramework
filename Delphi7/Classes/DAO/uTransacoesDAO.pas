unit uTransacoesDAO;

interface

uses
 SysUtils, SqlExpr,
 uDAO, TrasancaoGoPague;

type TransacaoDAO = class(TDAO)
private

protected

public
  procedure Salvar( transacao :TransacaoGoPague );

  constructor Create;
  destructor Destroy; override;
published

end;


implementation

uses DB;

constructor TransacaoDAO.Create;
begin
  AbreBanco;
end;

destructor TransacaoDAO.Destroy;
begin
  inherited;
end;



procedure TransacaoDAO.Salvar(transacao: TransacaoGoPague);
var
  qr_aux :TSqlQuery;
begin
  DecimalSeparator := '.';
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add('insert into transacoes_gopague ( transacao_id, autorizacao, nsu, numero_pos, metodo_pagamento ');
    qr_Aux.SQL.Add(                               ' , valor, parcelas, documento, fornecedor, data) ');

    qr_Aux.SQL.Add(                        'values ( '   + QuotedStr( transacao.gopague_id ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.codigo_autorizacao ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.codigo_nsu ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.numero_pos ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.metodo_pagamento ) );
    qr_Aux.SQL.Add(                                ' , ' + FloatToStr(transacao.valor) );
    qr_Aux.SQL.Add(                                ' , ' + IntToStr(transacao.parcelas)  );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.documento ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr( transacao.fornecedor ) );
    qr_Aux.SQL.Add(                                ' , ' + QuotedStr(DateToStr( transacao.datacad )) + ')' );

    qr_aux.ExecSQL;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
 