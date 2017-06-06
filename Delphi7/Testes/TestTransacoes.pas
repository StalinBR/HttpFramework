unit TestTransacoes;


interface

uses TestFramework, Classes, ulkjson,
     URL, HttpClient, Response, TrasancaoGoPague, uTransacoesDAO;


type TTestTransacoes = class(TtestCase)
  private
    client :THttpClient;
    response :TResponse;
    token :String;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestMessage;
    procedure TestParse;
    procedure TestSalvar;
  end;

{ TestTransacoes }
implementation

procedure TTestTransacoes.SetUp;
begin
  inherited;

  token := 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiIsImp0aSI6IjRmMWcyM2ExMmFhIn0.eyJpc3MiOiJo' +
           'dHRwOlwvXC9zYWxhb3ZpcC5jb20uYnIiLCJhdWQiOiJodHRwOlwvXC9zYWxhb3ZpcC50ZXJjZWly' +
           'by5iciIsImp0aSI6IjRmMWcyM2ExMmFhIiwiaWF0IjoxNDg4OTg0NDU1LCJuYmYiOjE0ODg5ODQ0' +
           'NTUsImV4cCI6MCwidWlkIjo3MDgzLCJqd3RjbGllbnQiOiJMQGMzUzN4VCJ9.fOggbdnA5xHZ6IKjsaP-DXVMC0GM-KmjUDMwRGi5Y1w';

end;

procedure TTestTransacoes.TearDown;
begin
  inherited;

end;

procedure TTestTransacoes.TestMessage;
begin
  response := THttpClient.Create( TURL.Create(7083, epTransacao, '0' ) , mtGet, token, TStringStream.Create('') ).Execute;
  CheckEquals( 'Recurso não encontrado', response.parseMessage );
end;

procedure TTestTransacoes.TestParse;
var
  transacao :TransacaoGoPague;
begin
  response := THttpClient.Create( TURL.Create(7083, epTransacao, '2611238' ) , mtGet, token, TStringStream.Create('') ).Execute;
  transacao := TransacaoGoPague.parseFromJson( response.Fmensagem.Field['data'].Field['transaction'] as TlkJSONobject );
  CheckNotEquals( '0', transacao.gopague_id );
end;

procedure TTestTransacoes.TestSalvar;
var
  transacao :TransacaoGoPague;
  tt :TransacaoDAO;
  data :TlkJSONobject;
  lista :TlkJSONlist;
  i :Integer;
begin
  tt := TransacaoDAO.Create;

  response := THttpClient.Create( TURL.Create(7083, epConsultaTransacoes ) , mtGet, token, TStringStream.Create('') ).Execute;

  data  := response.Fmensagem.Field['data'] as TlkJSONobject;
  lista := data.Field['transactions'] as TlkJSONlist;

  for i := 0 to lista.Count-1 do
  begin

    transacao := TransacaoGoPague.parseFromJson( lista.Child[i] as TlkjsonObject );

    tt.Salvar( transacao );
  end;
end;

initialization
  TestFramework.RegisterTest('Teste - TRANSACOES', TTestTransacoes.Suite);


end.
