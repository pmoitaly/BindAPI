program BindAPITest;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}

uses
  System.SysUtils,
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
{$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  CoreBinderTest in 'CoreBinderTest.pas',
  BindElementDataTest in 'BindElementDataTest.pas',
  ClassDataTest in 'ClassDataTest.pas',
  ClassManagerTest in 'ClassManagerTest.pas',
  DeferredBindTest in 'DeferredBindTest.pas',
  RTTIUtilsTest in 'RTTIUtilsTest.pas',
  BindListTest in 'BindListTest.pas',
  AttributesTest in 'AttributesTest.pas',
  BindManagerTest in 'BindManagerTest.pas',
  AutoBinderTest in 'AutoBinderTest.pas',
  BindAPITestClasses in 'BindAPITestClasses.pas';

var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger: ITestLogger;

begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  Exit;
{$ENDIF}
  System.ReportMemoryLeaksOnShutdown := True;

  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(True);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create
      (TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := False;
    //When true, assertions must be made during tests;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

{$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
      begin
        System.Write('Done.. press <Enter> key to quit.');
        System.Readln;
      end;
{$ENDIF}
  except
    on E: Exception do
      begin
        System.Writeln(E.ClassName, ': ', E.Message);
        System.Readln;
      end;
  end;

end.
