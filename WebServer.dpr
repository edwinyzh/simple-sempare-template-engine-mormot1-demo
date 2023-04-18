program WebServer;

{$APPTYPE CONSOLE}

uses
  SysUtils, SynCommons, mORMot, mORMotHttpServer, Sempare.Template, Winapi.Windows, Winapi.ShellAPI;

type
  // Note: TSQLRestServerFullMemory has no database support
  TMyRestServer = class(TSQLRestServerFullMemory)
  published
    procedure Home(aContext: TSQLRestServerURIContext);
  end;

  TPageData = record
    UserAgent: string;
    TmplEngineName: string;
    WebServrName: string;
  end;

procedure TMyRestServer.Home(aContext: TSQLRestServerURIContext);
var
  htmlTmpl, htmlResult: string;
  pageData: TPageData;
begin
  // Populate the page data
  pageData.UserAgent := aContext.UserAgent;
  pageData.TmplEngineName := 'Sempare Template Engine for Delphi';
  pageData.WebServrName := 'mORMot v1';

  // Load html template from file
  htmlTmpl := StringFromFile(ExtractFilePath(ParamStr(0)) + 'Home-template.html');

  // Render it
  htmlResult := Template.Eval(htmlTmpl, pageData);

  // Return the html page to the web browser
  aContext.Returns(htmlResult, HTTP_SUCCESS, HTML_CONTENT_TYPE_HEADER);
end;

const
  cWebServerAddr = 'http://localhost/www/home';
var
  dbModel: TSQLModel;
  restSvr: TMyRestServer;
  httpSvr: TSQLHttpServer;
begin
  dbModel := TSQLModel.Create([],'www');
  restSvr := TMyRestServer.Create(dbModel);
  dbModel.Owner := restSvr;

  httpSvr := TSQLHttpServer.Create('80', [restSvr], '+', useHttpSocket, 8);
  httpSvr.AccessControlAllowOrigin := '*';

  WriteLn('');
  WriteLn('Demonstrating mORMot 1''s method-based service serving html page rendered by Sempare Template Engine.');
  WriteLn('');
  WriteLn('Please visit ' + cWebServerAddr);
  WriteLn('Press [Enter] to close the web server.');
  ShellExecute(0, 'open', PChar(cWebServerAddr), nil, nil, SW_SHOWNORMAL);
  ReadLn;

  httpSvr.Free;
  restSvr.Free;
end.
