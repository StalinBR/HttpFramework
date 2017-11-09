# HttpFramework

Dependencias: 
  uLkJSON


Exemplo de uso: 

uses
  uLkJSON,
  URL, HttpClient, Response;

var
  response :TResponse;

try
  response := THttpClient.Create( TURLSendGrid.Create( '/fcm/send' )
                                     , mtPost
                                     , 'Bearer ' + Ftoken
                                     , TStringStream.Create( TlkJSON.GenerateText( email.parseToJson ) ) ).Execute;
finally
  response.Free;
end;
