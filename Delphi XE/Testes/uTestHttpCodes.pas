unit uTestHttpCodes;

interface
uses
  URL, HttpClient, Response,
  DUnitX.TestFramework;
type

  [TestFixture]
  TMyTestObject = class(TObject)
  private
    client :THttpClient;
    response :TResponse;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure Test200;
    [Test]
    procedure Test500;
  end;

implementation

procedure TMyTestObject.Setup;
begin
  //client := THttpClient.Create( TURL.Create(8204, 'profissionais') , '', nil );
  //response := client.Send();
end;

procedure TMyTestObject.TearDown;
begin
  response.Free;
  client.Free;
end;

procedure TMyTestObject.Test200;
begin
  response := THttpClient.Create( TURL.Create(8204, 'profissionais') , '', nil ).Get();
  Assert.AreEqual(200, response.code);
end;

procedure TMyTestObject.Test500;
begin
  response := THttpClient.Create( TURL.Create(8204, 'url_invalida') , '', nil ).Get();
  Assert.AreEqual(500, response.code);
end;

initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);
end.
