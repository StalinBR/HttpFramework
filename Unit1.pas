unit Unit1;

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
    // Sample Methods
    // Simple single Test
    [Test]
    procedure Test1;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA','1,2')]
    [TestCase('TestB','3,4')]
    procedure Test2(const AValue1 : Integer;const AValue2 : Integer);
  end;

implementation

procedure TMyTestObject.Setup;
begin
  client := THttpClient.Create( TURL.Create(8204, 'profissionais') , '', nil );
  response := client.Send();
end;

procedure TMyTestObject.TearDown;
begin
  response.Free;
  client.Free;
end;

procedure TMyTestObject.Test1;
begin
  Assert.AreEqual('', '');
end;

procedure TMyTestObject.Test2(const AValue1 : Integer;const AValue2 : Integer);
begin
end;

initialization
  TDUnitX.RegisterTestFixture(TMyTestObject);
end.
