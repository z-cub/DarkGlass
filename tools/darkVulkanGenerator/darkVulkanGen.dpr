program darkVulkanGen;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  darkUnicode,
  darkLog,
  darkLog.logtarget.console,
  darkLog.logtarget.logfile,
  System.SysUtils,
  darkvulkangen.xml.standard in 'implementation\darkvulkangen.xml.standard.pas',
  darkvulkangen.ast in 'interface\darkvulkangen.ast.pas',
  darkvulkangen.xml in 'interface\darkvulkangen.xml.pas',
  darkvulkangen.generator in 'interface\darkvulkangen.generator.pas',
  darkvulkangen.generator.standard in 'implementation\darkvulkangen.generator.standard.pas',
  darkvulkangen.ast.node.standard in 'implementation\darkvulkangen.ast.node.standard.pas',
  darkvulkangen.ast.rootnode.standard in 'implementation\darkvulkangen.ast.rootnode.standard.pas',
  darkvulkangen.ast.unitnode.standard in 'implementation\darkvulkangen.ast.unitnode.standard.pas',
  darkvulkangen.ast.comment.standard in 'implementation\darkvulkangen.ast.comment.standard.pas',
  darkvulkangen.ast.unitsection.standard in 'implementation\darkvulkangen.ast.unitsection.standard.pas',
  darkvulkangen.ast.ifdef.standard in 'implementation\darkvulkangen.ast.ifdef.standard.pas',
  darkvulkangen.ast.define.standard in 'implementation\darkvulkangen.ast.define.standard.pas',
  darkvulkangen.ast.ifndef.standard in 'implementation\darkvulkangen.ast.ifndef.standard.pas',
  darkvulkangen.ast.useslist.standard in 'implementation\darkvulkangen.ast.useslist.standard.pas',
  darkvulkangen.ast.astlabel.standard in 'implementation\darkvulkangen.ast.astlabel.standard.pas',
  darkvulkangen.ast.typedsymbol.standard in 'implementation\darkvulkangen.ast.typedsymbol.standard.pas',
  darkvulkangen.ast.parameter.standard in 'implementation\darkvulkangen.ast.parameter.standard.pas',
  darkvulkangen.ast.functionheader.standard in 'implementation\darkvulkangen.ast.functionheader.standard.pas',
  darkvulkangen.ast.compoundstatement.standard in 'implementation\darkvulkangen.ast.compoundstatement.standard.pas',
  darkvulkangen.ast._function.standard in 'implementation\darkvulkangen.ast._function.standard.pas',
  darkvulkangen.ast.constant.standard in 'implementation\darkvulkangen.ast.constant.standard.pas',
  darkvulkangen.ast.constants.standard in 'implementation\darkvulkangen.ast.constants.standard.pas',
  darkvulkangen.ast.typedefs.standard in 'implementation\darkvulkangen.ast.typedefs.standard.pas',
  darkvulkangen.ast.typedef.standard in 'implementation\darkvulkangen.ast.typedef.standard.pas',
  darkvulkangen.ast.variable.standard in 'implementation\darkvulkangen.ast.variable.standard.pas',
  darkvulkangen.ast.variables.standard in 'implementation\darkvulkangen.ast.variables.standard.pas';

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
