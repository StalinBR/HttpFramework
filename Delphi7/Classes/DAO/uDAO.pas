unit uDAO;

interface

uses SqlExpr, DBClient, IniFiles,
     JvComponentBase, JvCipher;

type TDao = class
private
  FcdsConfiguracoes: TClientDataSet;
  FJvVigenereCipher: TJvVigenereCipher;
protected
    function Tabelas_Empresa ( empresa :Integer; tabela :String ) :Integer;
    function Generators(Generator : String) : Integer;
public
  FSQLConnection: TSQLConnection;
  Fempresa_padrao :Integer;
  function getSalaoID :Integer;
  constructor Create;
  destructor Destroy; override;
  procedure AbreBanco;
  procedure FechaBanco;
  function getToken : String;
published

end;


implementation

uses SysUtils, DB;

{ TDao }

procedure TDao.AbreBanco;
var
 lServidor, lBAnco, lBancoDados :String;
 lUsuario, lSenha :String;
 lArquivo : TIniFile;
begin
  if not FileExists(ExtractFilePath( ParamStr(0) ) + '\Config.XML') then
    raise Exception.Create('Arquivo de Configuração não encontrado.');


  FSQLConnection     := TSQLConnection.Create(nil);
  FcdsConfiguracoes  := TClientDataSet.Create(nil);
  FJvVigenereCipher  := TJvVigenereCipher.Create(nil);

  try
  FcdsConfiguracoes.LoadFromFile(ExtractFilePath( ParamStr(0) ) + '\Config.XML');
  FcdsConfiguracoes.First;
  while not FcdsConfiguracoes.Eof do
  begin
    if FcdsConfiguracoes.FieldByName('padrao').AsString = 'S' then
    begin
      lServidor   := FcdsConfiguracoes.FieldByName('ip_servidor').Value;
      lBancoDados := FcdsConfiguracoes.FieldByName('path_banco_dados').Value +  '\Teles Cabeleireiros.FDB';

      if lServidor <> '0.0.0.0' then
      begin
        lBanco := lServidor;
        lBanco := lBanco + ':' + lBancoDados;
      end
      else
        lBanco := lBancoDados;

      lUsuario := FJvVigenereCipher.DecodeString('Usuario', FcdsConfiguracoes.FieldByName('usuario').Value );
      lSenha   := FJvVigenereCipher.DecodeString('Senha'  , FcdsConfiguracoes.FieldByName('senha').Value);

      FSQLConnection.DriverName          := 'Interbase';
      FSQLConnection.LibraryName         := 'dbexpint.dll';
      FSQLConnection.LoadParamsOnConnect := false;
      FSQLConnection.ConnectionName      := 'TelesCabeleireiros';
      FSQLConnection.VendorLib           := 'GDS32.DLL';
      FSQLConnection.GetDriverFunc       := 'getSQLDriverINTERBASE';
      FSQLConnection.LoginPrompt         := false;
      FSQLConnection.Params.Add('DriverName=Interbase');
      FSQLConnection.Params.Add('BlobSize=-1');
      FSQLConnection.Params.Add('CommitRetain=False');
      FSQLConnection.Params.Add('Database=' + lBanco);
      FSQLConnection.Params.Add('ErrorResourceFile=');
      FSQLConnection.Params.Add('LocaleCode=0000');
      FSQLConnection.Params.Add('RoleName=RoleName');
      FSQLConnection.Params.Add('ServerCharSet=');
      FSQLConnection.Params.Add('SQLDialect=3');
      FSQLConnection.Params.Add('Interbase TransIsolation=ReadCommited');
      FSQLConnection.Params.Add('WaitOnLocks=True');
      FSQLConnection.Params.Add('User_Name=' + lUsuario);
      FSQLConnection.Params.Add('Password=' + lSenha);
    end;
    FcdsConfiguracoes.Next;
  end;
  finally
    FreeAndNil( FJvVigenereCipher );
    FreeAndNil( FcdsConfiguracoes );
  end;

  if FileExists(ExtractFilePath( ParamStr(0) ) +  '\Config.ini') then
  begin
    lArquivo := TIniFile.Create(ExtractFilePath( ParamStr(0) ) +  '\Config.ini');
    try
      Fempresa_padrao  := StrToInt(lArquivo.ReadString('empresa_padrao_terminal','codigo',''));
    finally
      FreeAndNil(lArquivo);
    end;
  end;

  try
    FSQLConnection.Connected := True;
  except on E :EDatabaseError do
    raise EDatabaseError.Create('Não foi possível se conectar ao Banco de Dados.');
  end;
end;

constructor TDao.Create;
begin
  inherited;
  AbreBanco;
end;

destructor TDao.Destroy;
begin
  FechaBanco;
  FreeAndNil( FSQLConnection );
  inherited;
end;


procedure TDao.FechaBanco;
begin
  FSQLConnection.Connected := False;
end;

function TDao.Generators(Generator: String): Integer;
var
sqlGenerators : TSQLQuery;
begin
  sqlGenerators := TSQLQuery.Create(nil);
  with sqlGenerators do
  begin
    try
      sqlGenerators.Close;
      sqlGenerators.sql.Clear;
      sqlGenerators.SQLConnection := TSQLConnection( FSQLConnection );
      sqlGenerators.SQL.Add('select gen_id(' + Generator + ', 1) as SEQUENCIA from rdb$database');
      sqlGenerators.Open;
      Result := sqlGenerators.FieldByName('SEQUENCIA').AsInteger;
    finally
      FreeAndNil(sqlGenerators);
    end;
  end;
end;

function TDao.getSalaoID: Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add('SELECT ID_WEB ');
    qr_Aux.SQL.Add('FROM EMPRESAS ');
    qr_Aux.SQL.Add('WHERE CODIGO_EMPRESA = '+ IntToStr(Fempresa_padrao));
    qr_aux.Open;

    if qr_aux.FieldByName('ID_WEB').AsInteger > 0 then
      Result := qr_aux.FieldByName('ID_WEB').AsInteger
    else
      Result := 0;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TDao.getToken: String;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSqlConnection;
  try
    qr_Aux.SQL.Add( ' SELECT P.APP_SALAOVIP_TOKEN ');
    qr_Aux.SQL.Add( 'FROM PARAMETROS_SISTEMA P ');
    qr_Aux.SQL.Add( ' WHERE P.CODIGO_EMPRESA = ' + IntToStr( Fempresa_padrao ) );
    qr_aux.Open;
    Result := qr_aux.FieldByName('APP_SALAOVIP_TOKEN').AsString;
  finally
    FreeAndNil(qr_aux);
  end;
end;

function TDao.Tabelas_Empresa(empresa: Integer; tabela: String): Integer;
var
  qr_aux :TSqlQuery;
begin
  qr_aux := TSQLQuery.Create(nil);
  qr_aux.SQLConnection := FSQLConnection;
  try
    qr_Aux.SQL.Add('SELECT CODIGO_EMPRESA_TABELA ');
    qr_Aux.SQL.Add('FROM TABELAS_EMPRESA ');
    qr_Aux.SQL.Add('WHERE CODIGO_EMPRESA = '+ IntToStr(empresa) + ' AND TABELA = '+ QuotedStr(tabela));
    qr_aux.Open;

    if qr_aux.FieldByName('CODIGO_EMPRESA_TABELA').AsInteger > 0 then
      Result := qr_aux.FieldByName('CODIGO_EMPRESA_TABELA').AsInteger
    else
      Result := 1;
  finally
    FreeAndNil(qr_aux);
  end;
end;

end.
