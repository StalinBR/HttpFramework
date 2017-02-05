object srvTelesServicos: TsrvTelesServicos
  OldCreateOrder = False
  DisplayName = 'Teles Hair Solution - Servi'#231'os'
  AfterInstall = ServiceAfterInstall
  OnExecute = ServiceExecute
  Left = 764
  Top = 26
  Height = 765
  Width = 324
  object timerRelatorioSMS: TTimer
    Interval = 10000
    OnTimer = timerRelatorioSMSTimer
    Left = 40
    Top = 16
  end
  object SQLConnectionEmails: TSQLConnection
    ConnectionName = 'TelesCabeleireiros'
    DriverName = 'Interbase'
    GetDriverFunc = 'getSQLDriverINTERBASE'
    LibraryName = 'dbexpint.dll'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=Interbase'
      'BlobSize=-1'
      'CommitRetain=False'
      
        'Database=localhost:d:\projetos\delphi 7\teles cabeleireiros\banc' +
        'o de dados\teles cabeleireiros.fdb'
      'ErrorResourceFile='
      'LocaleCode=0000'
      'Password=manager'
      'RoleName=RoleName'
      'ServerCharSet='
      'SQLDialect=3'
      'Interbase TransIsolation=ReadCommited'
      'User_Name=SYSDBA'
      'WaitOnLocks=True')
    VendorLib = 'GDS32.DLL'
    Left = 32
    Top = 80
  end
  object qryControleSMS: TSQLQuery
    MaxBlobSize = -1
    Params = <
      item
        DataType = ftUnknown
        Name = 'data_ini'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'data_fim'
        ParamType = ptUnknown
      end>
    SQL.Strings = (
      'SELECT COUNT(CONTROLE) + COUNT(RESPOSTA) AS QTDE'
      '             , COUNT(CONTROLE) AS ENVIADAS'
      '             , COUNT(RESPOSTA) AS RECEBIDAS'
      'FROM SMS'
      'WHERE CODIGO_EMPRESA = 1'
      'AND   STATUS = 1'
      'AND   DATA_ENVIO between :data_ini and :data_fim')
    SQLConnection = SQLConnectionEmails
    Left = 40
    Top = 144
    object qryControleSMSQTDE: TFMTBCDField
      FieldName = 'QTDE'
      Required = True
      Precision = 15
      Size = 0
    end
    object qryControleSMSENVIADAS: TIntegerField
      FieldName = 'ENVIADAS'
      Required = True
    end
    object qryControleSMSRECEBIDAS: TIntegerField
      FieldName = 'RECEBIDAS'
      Required = True
    end
  end
  object dspControleSMS: TDataSetProvider
    DataSet = qryControleSMS
    Options = [poAllowCommandText]
    Left = 128
    Top = 144
  end
  object cdsControleSMS: TClientDataSet
    Aggregates = <>
    Params = <
      item
        DataType = ftUnknown
        Name = 'data_ini'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'data_fim'
        ParamType = ptUnknown
      end>
    ProviderName = 'dspControleSMS'
    Left = 228
    Top = 144
    object cdsControleSMSQTDE: TFMTBCDField
      FieldName = 'QTDE'
      Required = True
      Precision = 15
      Size = 0
    end
    object cdsControleSMSENVIADAS: TIntegerField
      FieldName = 'ENVIADAS'
      Required = True
    end
    object cdsControleSMSRECEBIDAS: TIntegerField
      FieldName = 'RECEBIDAS'
      Required = True
    end
  end
  object qryNaoEnviados: TSQLQuery
    MaxBlobSize = -1
    Params = <
      item
        DataType = ftUnknown
        Name = 'data_ini'
        ParamType = ptInput
      end
      item
        DataType = ftUnknown
        Name = 'data_fim'
        ParamType = ptUnknown
      end>
    SQL.Strings = (
      'SELECT SMS.CODIGO_EMPRESA                                '
      '     , SMS.CONTROLE                                      '
      '     , SMS.DATA                                          '
      '     , SMS.HORA                                          '
      '     , SMS.TIPO                                          '
      '     , SMS.CAMPANHA                                      '
      '     , SMS.EMP_CAMPANHA                                  '
      '     , SMS.ASSUNTO                                       '
      '     , SMS.CODIGO_DESTINATARIO                           '
      '     , SMS.EMP_DESTINATARIO                              '
      '     , SMS.STATUS                                        '
      '     , SMS.DATA_ENVIO                                    '
      '     , SMS.HORA_ENVIO                                    '
      '     , SMS.BODY                                          '
      '     , SMS.LOG                                           '
      '     , SMS.ICS                                           '
      '     , SMS.RESPOSTA                                      '
      '     , CASE CLIENTES.AVISO_CONFIRMACAO                   '
      '       WHEN '#39'1'#39' THEN CLIENTES.TELEFONE1                '
      '       WHEN '#39'2'#39' THEN CLIENTES.TELEFONE2                '
      '       WHEN '#39'3'#39' THEN CLIENTES.TELEFONE3                '
      '       END AS TELEFONE_CONFIRMACAO                       '
      '     , CASE CLIENTES.AVISO_LEMBRETE                      '
      '       WHEN '#39'1'#39' THEN CLIENTES.TELEFONE1                '
      '       WHEN '#39'2'#39' THEN CLIENTES.TELEFONE2                '
      '       WHEN '#39'3'#39' THEN CLIENTES.TELEFONE3                '
      '       END AS TELEFONE_LEMBRETE                          '
      '     , CASE CLIENTES.AVISO_CANCELAMENTO                  '
      '       WHEN '#39'1'#39' THEN CLIENTES.TELEFONE1                '
      '       WHEN '#39'2'#39' THEN CLIENTES.TELEFONE2                '
      '       WHEN '#39'3'#39' THEN CLIENTES.TELEFONE3                '
      '       END AS TELEFONE_CANCELAMENTO                      '
      '     , CLIENTES.NOME                                     '
      '  FROM SMS                                               '
      ' INNER JOIN CLIENTES                                     '
      'ON  (CLIENTES.CODIGO_CLIENTE = SMS.CODIGO_DESTINATARIO)  '
      'AND (CLIENTES.CODIGO_EMPRESA = SMS.EMP_DESTINATARIO)     '
      'WHERE SMS.CODIGO_EMPRESA = 1                             '
      '  AND SMS.STATUS = 2'
      '  AND SMS.data_envio between :data_ini and :data_fim'
      '                           '
      '                          ')
    SQLConnection = SQLConnectionEmails
    Left = 40
    Top = 200
    object qryNaoEnviadosCODIGO_EMPRESA: TIntegerField
      FieldName = 'CODIGO_EMPRESA'
      Required = True
    end
    object qryNaoEnviadosCONTROLE: TIntegerField
      FieldName = 'CONTROLE'
      Required = True
    end
    object qryNaoEnviadosDATA: TDateField
      FieldName = 'DATA'
      Required = True
    end
    object qryNaoEnviadosHORA: TTimeField
      FieldName = 'HORA'
      Required = True
    end
    object qryNaoEnviadosTIPO: TIntegerField
      FieldName = 'TIPO'
      Required = True
    end
    object qryNaoEnviadosCAMPANHA: TIntegerField
      FieldName = 'CAMPANHA'
    end
    object qryNaoEnviadosEMP_CAMPANHA: TIntegerField
      FieldName = 'EMP_CAMPANHA'
    end
    object qryNaoEnviadosASSUNTO: TStringField
      FieldName = 'ASSUNTO'
      Size = 150
    end
    object qryNaoEnviadosCODIGO_DESTINATARIO: TIntegerField
      FieldName = 'CODIGO_DESTINATARIO'
    end
    object qryNaoEnviadosEMP_DESTINATARIO: TIntegerField
      FieldName = 'EMP_DESTINATARIO'
    end
    object qryNaoEnviadosSTATUS: TIntegerField
      FieldName = 'STATUS'
      Required = True
    end
    object qryNaoEnviadosDATA_ENVIO: TDateField
      FieldName = 'DATA_ENVIO'
    end
    object qryNaoEnviadosHORA_ENVIO: TTimeField
      FieldName = 'HORA_ENVIO'
    end
    object qryNaoEnviadosBODY: TMemoField
      FieldName = 'BODY'
      BlobType = ftMemo
      Size = 1
    end
    object qryNaoEnviadosLOG: TMemoField
      FieldName = 'LOG'
      BlobType = ftMemo
      Size = 1
    end
    object qryNaoEnviadosICS: TMemoField
      FieldName = 'ICS'
      BlobType = ftMemo
      Size = 1
    end
    object qryNaoEnviadosRESPOSTA: TStringField
      FieldName = 'RESPOSTA'
      Size = 15
    end
    object qryNaoEnviadosTELEFONE_CONFIRMACAO: TStringField
      FieldName = 'TELEFONE_CONFIRMACAO'
      Size = 15
    end
    object qryNaoEnviadosTELEFONE_LEMBRETE: TStringField
      FieldName = 'TELEFONE_LEMBRETE'
      Size = 15
    end
    object qryNaoEnviadosTELEFONE_CANCELAMENTO: TStringField
      FieldName = 'TELEFONE_CANCELAMENTO'
      Size = 15
    end
    object qryNaoEnviadosNOME: TStringField
      FieldName = 'NOME'
      Required = True
      Size = 40
    end
  end
  object dspNaoEnviados: TDataSetProvider
    DataSet = qryNaoEnviados
    Options = [poAllowCommandText]
    Left = 128
    Top = 200
  end
  object cdsNaoEnviados: TClientDataSet
    Aggregates = <>
    Params = <
      item
        DataType = ftUnknown
        Name = 'data_ini'
        ParamType = ptUnknown
      end
      item
        DataType = ftUnknown
        Name = 'data_fim'
        ParamType = ptUnknown
      end>
    ProviderName = 'dspNaoEnviados'
    Left = 232
    Top = 200
    object cdsNaoEnviadosCODIGO_EMPRESA: TIntegerField
      FieldName = 'CODIGO_EMPRESA'
      Required = True
    end
    object cdsNaoEnviadosCONTROLE: TIntegerField
      FieldName = 'CONTROLE'
      Required = True
    end
    object cdsNaoEnviadosDATA: TDateField
      FieldName = 'DATA'
      Required = True
    end
    object cdsNaoEnviadosHORA: TTimeField
      FieldName = 'HORA'
      Required = True
    end
    object cdsNaoEnviadosTIPO: TIntegerField
      FieldName = 'TIPO'
      Required = True
    end
    object cdsNaoEnviadosCAMPANHA: TIntegerField
      FieldName = 'CAMPANHA'
    end
    object cdsNaoEnviadosEMP_CAMPANHA: TIntegerField
      FieldName = 'EMP_CAMPANHA'
    end
    object cdsNaoEnviadosASSUNTO: TStringField
      FieldName = 'ASSUNTO'
      Size = 150
    end
    object cdsNaoEnviadosCODIGO_DESTINATARIO: TIntegerField
      FieldName = 'CODIGO_DESTINATARIO'
    end
    object cdsNaoEnviadosEMP_DESTINATARIO: TIntegerField
      FieldName = 'EMP_DESTINATARIO'
    end
    object cdsNaoEnviadosSTATUS: TIntegerField
      FieldName = 'STATUS'
      Required = True
    end
    object cdsNaoEnviadosDATA_ENVIO: TDateField
      FieldName = 'DATA_ENVIO'
    end
    object cdsNaoEnviadosHORA_ENVIO: TTimeField
      FieldName = 'HORA_ENVIO'
    end
    object cdsNaoEnviadosBODY: TMemoField
      FieldName = 'BODY'
      BlobType = ftMemo
      Size = 1
    end
    object cdsNaoEnviadosLOG: TMemoField
      FieldName = 'LOG'
      BlobType = ftMemo
      Size = 1
    end
    object cdsNaoEnviadosICS: TMemoField
      FieldName = 'ICS'
      BlobType = ftMemo
      Size = 1
    end
    object cdsNaoEnviadosRESPOSTA: TStringField
      FieldName = 'RESPOSTA'
      Size = 15
    end
    object cdsNaoEnviadosTELEFONE_CONFIRMACAO: TStringField
      FieldName = 'TELEFONE_CONFIRMACAO'
      Size = 15
    end
    object cdsNaoEnviadosTELEFONE_LEMBRETE: TStringField
      FieldName = 'TELEFONE_LEMBRETE'
      Size = 15
    end
    object cdsNaoEnviadosTELEFONE_CANCELAMENTO: TStringField
      FieldName = 'TELEFONE_CANCELAMENTO'
      Size = 15
    end
    object cdsNaoEnviadosNOME: TStringField
      FieldName = 'NOME'
      Required = True
      Size = 40
    end
  end
  object cdsConfiguracoes: TClientDataSet
    Aggregates = <>
    AggregatesActive = True
    Filter = 'padrao = '#39'S'#39
    FieldDefs = <
      item
        Name = 'codigo'
        DataType = ftInteger
      end
      item
        Name = 'descricao'
        DataType = ftString
        Size = 35
      end
      item
        Name = 'ip_servidor'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'path_sistema_local'
        DataType = ftString
        Size = 150
      end
      item
        Name = 'path_imagens'
        DataType = ftString
        Size = 150
      end
      item
        Name = 'path_relatorios'
        DataType = ftString
        Size = 150
      end
      item
        Name = 'path_backup'
        DataType = ftString
        Size = 150
      end
      item
        Name = 'path_banco_dados'
        DataType = ftString
        Size = 150
      end
      item
        Name = 'usuario'
        DataType = ftString
        Size = 15
      end
      item
        Name = 'senha'
        DataType = ftString
        Size = 15
      end>
    IndexDefs = <
      item
        Name = 'cdsConfiguracoesIndex1'
        Fields = 'codigo'
      end>
    IndexName = 'cdsConfiguracoesIndex1'
    Params = <>
    StoreDefs = True
    Left = 227
    Top = 79
    object cdsConfiguracoescodigo: TIntegerField
      DisplayWidth = 10
      FieldName = 'codigo'
      Visible = False
    end
    object cdsConfiguracoesdescricao: TStringField
      DisplayLabel = 'Descri'#231#227'o'
      DisplayWidth = 35
      FieldName = 'descricao'
      Size = 35
    end
    object cdsConfiguracoesip_servidor: TStringField
      DisplayWidth = 15
      FieldName = 'ip_servidor'
      Visible = False
      Size = 15
    end
    object cdsConfiguracoespath_sistema_local: TStringField
      DisplayWidth = 150
      FieldName = 'path_sistema_local'
      Visible = False
      Size = 150
    end
    object cdsConfiguracoespath_imagens: TStringField
      DisplayWidth = 150
      FieldName = 'path_imagens'
      Visible = False
      Size = 150
    end
    object cdsConfiguracoespath_relatorios: TStringField
      DisplayWidth = 150
      FieldName = 'path_relatorios'
      Visible = False
      Size = 150
    end
    object cdsConfiguracoespath_backup: TStringField
      DisplayWidth = 150
      FieldName = 'path_backup'
      Visible = False
      Size = 150
    end
    object cdsConfiguracoespath_banco_dados: TStringField
      DisplayWidth = 150
      FieldName = 'path_banco_dados'
      Visible = False
      Size = 150
    end
    object cdsConfiguracoesusuario: TStringField
      DisplayWidth = 15
      FieldName = 'usuario'
      Visible = False
      Size = 15
    end
    object cdsConfiguracoessenha: TStringField
      DisplayWidth = 15
      FieldName = 'senha'
      Visible = False
      Size = 15
    end
    object cdsConfiguracoespadrao: TStringField
      DefaultExpression = #39'N'#39
      FieldName = 'padrao'
      Size = 1
    end
    object cdsConfiguracoessequencia: TAggregateField
      FieldName = 'sequencia'
      Active = True
      Expression = 'max(codigo)'
    end
  end
  object JvVigenereCipher1: TJvVigenereCipher
    Left = 136
    Top = 79
  end
  object sqlParamEmail: TSQLQuery
    MaxBlobSize = -1
    Params = <
      item
        DataType = ftInteger
        Name = 'CODIGO'
        ParamType = ptInput
      end>
    SQL.Strings = (
      ' SELECT P.USUARIO_SMTP, P.SENHA_SMTP, P.EMAIL_GESTOR'
      '  FROM PARAMETROS_EMAIL P'
      '  WHERE P.CODIGO_EMPRESA = :CODIGO')
    SQLConnection = SQLConnectionEmails
    Left = 40
    Top = 256
    object sqlParamEmailUSUARIO_SMTP: TStringField
      FieldName = 'USUARIO_SMTP'
      Size = 150
    end
    object sqlParamEmailSENHA_SMTP: TStringField
      FieldName = 'SENHA_SMTP'
      Size = 150
    end
    object sqlParamEmailEMAIL_GESTOR: TStringField
      FieldName = 'EMAIL_GESTOR'
      Size = 150
    end
  end
end
