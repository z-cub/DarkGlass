program darkVulkanGen;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  darkUnicode,
  darkLog,
  darkLog.logtarget.console,
  darkLog.logtarget.logfile,
  System.SysUtils,
  darkvulkangen.ast in '..\..\units\interface\darkvulkangen.ast.pas',
  darkvulkangen.generator in '..\..\units\interface\darkvulkangen.generator.pas',
  darkvulkangen.xml in '..\..\units\interface\darkvulkangen.xml.pas',
  darkvulkangen.ast.functionheaderalias.standard in '..\..\units\implementation\darkvulkangen.ast.functionheaderalias.standard.pas',
  darkvulkangen.ast.ifdef.standard in '..\..\units\implementation\darkvulkangen.ast.ifdef.standard.pas',
  darkvulkangen.ast.ifndef.standard in '..\..\units\implementation\darkvulkangen.ast.ifndef.standard.pas',
  darkvulkangen.ast.node.standard in '..\..\units\implementation\darkvulkangen.ast.node.standard.pas',
  darkvulkangen.ast.parameter.standard in '..\..\units\implementation\darkvulkangen.ast.parameter.standard.pas',
  darkvulkangen.ast.plaintext.standard in '..\..\units\implementation\darkvulkangen.ast.plaintext.standard.pas',
  darkvulkangen.ast.rootnode.standard in '..\..\units\implementation\darkvulkangen.ast.rootnode.standard.pas',
  darkvulkangen.ast.typedef.standard in '..\..\units\implementation\darkvulkangen.ast.typedef.standard.pas',
  darkvulkangen.ast.typedefs.standard in '..\..\units\implementation\darkvulkangen.ast.typedefs.standard.pas',
  darkvulkangen.ast.typedsymbol.standard in '..\..\units\implementation\darkvulkangen.ast.typedsymbol.standard.pas',
  darkvulkangen.ast.unitnode.standard in '..\..\units\implementation\darkvulkangen.ast.unitnode.standard.pas',
  darkvulkangen.ast.unitsection.standard in '..\..\units\implementation\darkvulkangen.ast.unitsection.standard.pas',
  darkvulkangen.ast.useslist.standard in '..\..\units\implementation\darkvulkangen.ast.useslist.standard.pas',
  darkvulkangen.ast.variable.standard in '..\..\units\implementation\darkvulkangen.ast.variable.standard.pas',
  darkvulkangen.ast.variables.standard in '..\..\units\implementation\darkvulkangen.ast.variables.standard.pas',
  darkvulkangen.generator.standard in '..\..\units\implementation\darkvulkangen.generator.standard.pas',
  darkvulkangen.xml.standard in '..\..\units\implementation\darkvulkangen.xml.standard.pas',
  darkvulkangen.ast._function.standard in '..\..\units\implementation\darkvulkangen.ast._function.standard.pas',
  darkvulkangen.ast.astlabel.standard in '..\..\units\implementation\darkvulkangen.ast.astlabel.standard.pas',
  darkvulkangen.ast.comment.standard in '..\..\units\implementation\darkvulkangen.ast.comment.standard.pas',
  darkvulkangen.ast.compoundstatement.standard in '..\..\units\implementation\darkvulkangen.ast.compoundstatement.standard.pas',
  darkvulkangen.ast.constant.standard in '..\..\units\implementation\darkvulkangen.ast.constant.standard.pas',
  darkvulkangen.ast.constants.standard in '..\..\units\implementation\darkvulkangen.ast.constants.standard.pas',
  darkvulkangen.ast.define.standard in '..\..\units\implementation\darkvulkangen.ast.define.standard.pas',
  darkvulkangen.ast.functionheader.standard in '..\..\units\implementation\darkvulkangen.ast.functionheader.standard.pas';

var
  Generator: IdvHeaderGenerator;
const
  cLogFileName = 'darkVulkanGenerator.log';

begin
  try
    //- Setup log targets.
    Log.AddLogTarget( ConsoleLogTarget );
    if FileExists(cLogFileName) then begin
      DeleteFile(cLogFileName);
    end;
    Log.AddLogTarget( FileLogTarget(cLogFileName,TUnicodeFormat.utf8) );
    //- Create a vulkan generator
    Generator := TdvHeaderGenerator.Create;
    try
      if Generator.Generate('vk.xml',ExtractFilePath(ParamStr(0))) then begin
        Writeln('Vulkan Header Generated Successfully.');
      end else begin
        Writeln('Vulkan Header Generation Failed. Please review log file.');
      end;
      Readln;
    finally
      Generator := nil;
    end;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
