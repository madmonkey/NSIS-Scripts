; NSIS (Damn small install)
; Mutilated script from dozens of developers
; Mobile One - because installations shouldn't suck!

; Maximum compression
SetCompressor /SOLID lzma
;--------------------------------
;Include(s) 

	!include "Shared\MUI2.nsh"
	!include "Shared\UninstallLog.nsh"
	!include "Shared\WinVer.nsh"
	!include "Shared\x64.nsh"
	!include "Shared\DotNetSearch.nsh"
	!include "Shared\DotNetVer.nsh"
	!include "Shared\LogicLib.nsh"
	!include "Shared\TextReplace.nsh"
	!include "Shared\EnumIni.nsh"

/* NOTES ABOUT UNINSTALL FUNCTIONS
Instead of using 
AddItem, File, CreateShortcut, CopyFiles, Rename, CreateDirectory, SetOutPath, 
WriteUninstaller, WriteRegStr and WriteRegDWORD instructions in your sections,
use; 
${AddItem}, ${File}, ${CreateShortcut}, ${CopyFiles}, ${Rename}, ${CreateDirectory}, ${SetOutPath}, 
${WriteUninstaller}, ${WriteRegStr} and ${WriteRegDWORD} instead.
*/
;--------------------------------
; Configure UnInstall log to only remove what is installed
;-------------------------------- 
	;Set the name of the uninstall log
    !define UninstLog "uninstall.log"
	!define setupini "orchestrationsetup.ini"
	;--------------------------------
	;Interface Settings
	  !define MUI_ABORTWARNING
	  ;!define MUI_FINISHPAGE_REBOOTLATER_DEFAULT 1
	;--------------------------------
	;Pages
		!insertmacro MUI_PAGE_WELCOME
		!insertmacro MUI_PAGE_DIRECTORY
		!insertmacro MUI_PAGE_INSTFILES
		;!insertmacro MUI_PAGE_FINISH - not adding this as we would lose "detail" of installation.
		;!insertmacro MUI_PAGE_FINISH 
		!insertmacro MUI_UNPAGE_CONFIRM
		!insertmacro MUI_UNPAGE_INSTFILES
	  
	;--------------------------------
	;Languages
	 
	  !insertmacro MUI_LANGUAGE "English"

	;--------------------------------
	!define backupfile "sungardbackup[${productversion}]"
	;!define exec "Web.config"
	!define CheckAndRestoreIfFails "!insertmacro CheckAndRestoreIfFails"
	!define appcmd "$SYSDIR\inetsrv\appcmd"
	;AddItem macro
    !define AddItem "!insertmacro AddItem"
	;File macro
    !define File "!insertmacro File"
	;File macro
    !define SharedFile "!insertmacro SharedFile"
	;CreateShortcut macro
    !define CreateShortcut "!insertmacro CreateShortcut"
	;Copy files macro
    !define CopyFiles "!insertmacro CopyFiles"
	;Rename macro
    !define Rename "!insertmacro Rename"
	;CreateDirectory macro
    !define CreateDirectory "!insertmacro CreateDirectory"
	;SetOutPath macro
    !define SetOutPath "!insertmacro SetOutPath"
	;WriteUninstaller macro
    !define WriteUninstaller "!insertmacro WriteUninstaller"
	;WriteRegStr macro
    !define WriteRegStr "!insertmacro WriteRegStr"
	;WriteRegDWORD macro
    !define WriteRegDWORD "!insertmacro WriteRegDWORD" 
	;ReplaceToken macro
	!define ReplaceToken "!insertmacro ReplaceToken"
	;Check return codes fro MSOLEDB plugin
	!define SqlExecutionCheck "!insertmacro SqlExecutionCheck"
	;General
	!define setup "orchestrationsetup.exe"
	!define releasedir "server\release\"
	; change this to wherever the files to be packaged reside
	; This is effectively our release branch - the precompiled web. From Studio -> Build Website and Publish to the relative Path
	!define srcsoapdir "..\Orchestration\SoapService\SunGardPS.Orchestration.SoapService\bin\Release\"
	!define srctransdir "..\Orchestration\Transformation\SunGardPS.Orchestration.Transform\bin\Release\"
	!define srcfiledir "..\Orchestration\FileService\SunGardPS.Orchestration.FileService\bin\Release\"
	!define srcscheddir "..\Orchestration\Scheduler\SunGardPS.Orchestration.SchedulerService\bin\Release\"
	!define metadatadir "..\Orchestration\Transformation\Metadata\"
	!define rabbitmqdir "$PROGRAMFILES\RabbitMQ Server\rabbitmq_server-3.0.2\sbin"
	!define erlangdir "C:\Program Files\erl5.10.1"
	!define srcutilitiesdir "..\Orchestration\Utilities\bin\Release\"
	!define scriptdir "..\InstallScripts\"
	!define sharedir "..\InstallScripts\shared\"
	!define mydir "..\InstallScripts\server\"
	!define externalsharedir "..\..\..\Shared\External\"
	!define company "SunGard Public Sector"
	!define companypathname "SunGardPublicSector"
	!define prodname "Orchestration Server"
	!define prodpathname "Orchestration"
	!define servicesdir "Services\"
	!define soapdir "${servicesdir}Soap\"
	!define transformdir "${servicesdir}Transform\"
	!define datadir "${servicesdir}Data\"
	!define filedir "${servicesdir}File\"
	!define scheddir "${servicesdir}Schedule\"
	;!define bindir "bin\"
	!define uninstalldir "$INSTDIR\uninstall\"
	;!define installationconfigurationfile "Install.config"
	!define productversion "7.0.0.1"
	!define setupversion "7.0.0.1"
	!define NSIS_CONFIG_LOG
	!define dotnetruntimedir "\DotNet40Runtime\"
	!define dotnetruntimefile "dotNetFx40_Full_x86_x64.exe"
	
    Var UninstLog
	Var uninstalldir
	Var target
	
	;Uninstall log file missing.
	LangString ApplyConfigSettings ${LANG_ENGLISH} "Updating configuration file."
	;LangString AutoconfigureSite ${LANG_ENGLISH} "Determining if host is specified in ${setupini}."
	LangString BasicAuthentication ${LANG_ENGLISH} "Turning off Basic Authentication..."
	LangString CannotAssignThreadpool ${LANG_ENGLISH} "***Warning! (x64) Cannot currently assign dedicated threadpool [$sitenamePool]. $(DoItYourself)"
	LangString CannotConnectToDatabase ${LANG_ENGLISH} "***Warning! Cannot connect to database - some required installation settings have not been configured! $(DoItYourself)."
	LangString ConfigureCustomProvider ${LANG_ENGLISH} "Configuring custom authentication provider for site."
	LangString ConfiguringAccess ${LANG_ENGLISH} "Configured for $accessright."
	LangString ConfiguringTransactionServices ${LANG_ENGLISH} "Configuring server for Distributed Transaction Services."	
	LangString MinimumOSType ${LANG_ENGLISH} "This installation requires 2008 or higher!"
	LangString ResolutionMethod ${LANG_ENGLISH} "Method for determining host name "
	LangString RestoringBackup ${LANG_ENGLISH} "Restoring installation backup from ${backupfile}."
	LangString SetupIniMissing ${LANG_ENGLISH} "${setupIni} not found!$\r$\nInstallation will not proceed!"
	LangString SiteReady ${LANG_ENGLISH} "Site is configured for "
	LangString SqlDatabaseMissing ${LANG_ENGLISH} "***Warning! The Database specified does NOT exist!"
	LangString SqlPermissions ${LANG_ENGLISH} "Setting required permissions for database."
	LangString SqlPermissionsError ${LANG_ENGLISH} "***Warning! Some of the required service permissions could not be set for the database!$\r$\nThe installation will continue but you will have to assign manually!"
	LangString StoppingSite ${LANG_ENGLISH} "Stopping services for $sitename."
	LangString TranslateAccess ${LANG_ENGLISH} "Translates to $accessright."
	LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"
	LangString UpdatedSite ${LANG_ENGLISH} "Updated ${setupini} to reflect Host ="
	LangString VerifydotNet ${LANG_ENGLISH} "Verifying .NET requirements"
	LangString WrongOSType ${LANG_ENGLISH} "Server installation requires a server operating system!"
	LangString RebootRequired ${LANG_ENGLISH} "Server installation may require a reboot to ensure all components are functional!"
	LangString VerifyWindowsComponents ${LANG_ENGLISH} "Verifying required windows components. Please wait - as this may take awhile..."
	
	VIProductVersion "${productversion}" ;could be read from a resource or whatever...	
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${prodname}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" ""
	VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${prodname} is a trademark of ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Service host application(s) for Raptor client"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${setupversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${productversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "Velociraptor"

Section -openlogfile
	StrCpy $uninstalldir "$INSTDIR\uninstall"
    ${CreateDirectory} "$uninstalldir"
    IfFileExists "$uninstalldir\${UninstLog}" +3
      FileOpen $UninstLog "$uninstalldir\${UninstLog}" w
    Goto +4
      SetFileAttributes "$uninstalldir\${UninstLog}" NORMAL
      FileOpen $UninstLog "$uninstalldir\${UninstLog}" a
      FileSeek $UninstLog 0 END
SectionEnd

Function .onInit
	/*Check for prerequisites*/
	IfFileExists "$EXEDIR\${SetupIni}" +3
		MessageBox MB_OK|MB_ICONSTOP "$(SetupIniMissing)"
		Abort
	SetOutPath "$EXEDIR"
	Call CheckMinimumOS
	
FunctionEnd

; registry stuff
!define regroot "HKLM"
!define regkey "Software\${company}\${prodpathname}"
!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${prodpathname}"
 
!define startmenu "$SMPROGRAMS\${company}\${prodpathname}"
!define uninstaller "uninstall.exe"

	;Name and file
	Name "${prodname}"
	BrandingText "${company}"
	OutFile "${releasedir}${setup}"
	InstallDir "$PROGRAMFILES\${company}\${prodpathname}"
	;Get installation folder from registry if available
	InstallDirRegKey "${regroot}""${regkey}" ""
	;Request application privileges for Windows Vista
	RequestExecutionLevel highest
	;Installer Sections
	
Function CheckMinimumOS
    ReadINIStr $1 "$EXEDIR\${setupini}" "client" "ElHefe"
	StrCmp $1 "TRUE" +10 0
	${IfNot} ${IsServerOS}
		MessageBox MB_OK|MB_ICONSTOP "$(WrongOSType)"
		Quit
	${Else}
		${IfNot} ${AtLeastWin2003}
			MessageBox MB_OK|MB_ICONSTOP "$(MinimumOSType)"
			Quit
		${EndIf}
	${EndIf}
FunctionEnd

!macro GetMachineName FORMATTYPE SERVER_NAME_OUT
	; ComputerNameNetBIOS 0
	; ComputerNameDnsHostname 1
	; ComputerNameDnsDomain 2
	; ComputerNameDnsFullyQualified 3
	; ComputerNamePhysicalNetBIOS 4
	; ComputerNamePhysicalDnsHostname 5
	; ComputerNamePhysicalDnsDomain 6
	; ComputerNamePhysicalDnsFullyQualified 7
	
  StrCpy $8 ${FORMATTYPE}
  System::Call 'kernel32.dll::GetComputerNameExW(i $8,w .r0,*i ${NSIS_MAX_STRLEN} r1)i.r2'
  ${If} $2 = 1
   StrCpy ${SERVER_NAME_OUT} "$0"
  ${Else}
   System::Call "kernel32.dll::GetComputerNameW(t .r0,*i ${NSIS_MAX_STRLEN} r1)i.r2"
   ${If} $2 = 1
    StrCpy ${SERVER_NAME_OUT} "$0"
   ${Else}
    StrCpy ${SERVER_NAME_OUT} ""
   ${EndIf}
  ${EndIf}
!macroend

!macro CheckAndRestoreIfFails _text
   ${IfNot} $0 == 0 
		${IfNot} $0 == 1 ;no idea why - still everything gets executed(Unless both 0 and 1 indicate ok?)
			;MessageBox MB_OK "[$0] - ${_text}" ;for testing only
			ExecWait "${appcmd} restore backup ${backupfile}"
			Abort
		${EndIf}
   ${EndIf}
!macroend

!macro RemoveReadOnlyAttribute _file
	System::Call "kernel32::GetFileAttributes(t '${_file}') i.R0"
	IntOp $R1 $R0 % 2
	${If} $R1 == 1  # odd number -> readonly attribute's set
		IntOp $R0 $R0 - 1
		System::Call "kernel32::SetFileAttributes(t '${_file}', i R0)"
	${EndIf}
!macroend

!macro ModifyConfig _app _target _file
	${Rename} "${_target}Orchestration.config" "${_target}${_file}"
	StrCpy $1 "${_app}log"
	${ReplaceToken} [log] "$1" "${_target}" "${_file}" 
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "queue" "connectionstring"	
	${ReplaceToken} [conn] "$0" "${_target}" "${_file}" 
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "${_app}" "topics"	
	${ReplaceToken} [topics] "$0" "${_target}" "${_file}"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "data" "dataconnectionstring"
	${ReplaceToken} [dbconn] "$0" "${_target}" "${_file}"	
	StrCpy $R1 ${_target}
	StrCpy $R2 ${_file}
	Call InjectWorkflow
!macroend

Function InjectWorkflow 
    StrCpy $0 0
	StrCpy $4 ""
    loop:
        ${EnumIniValue} $1 "$EXEDIR\${SetupIni}" "workflow" $0
        StrCmp $1 "" done
        IntOp $0 $0 + 1
		ReadIniStr $2 "$EXEDIR\${SetupIni}" "workflow" $1
		StrCpy "$3" '<add name="$1" statemachine="$2"/>$\n'
		StrCpy "$4" "$4$3"		 
		goto loop
    done:	
	${ReplaceToken} [workflow] "$4" "$R1" "$R2"
FunctionEnd

!macro ModifyCustom _app _target _file
	${Rename} "${_target}Orchestration.config" "${_target}${_file}"
	StrCpy $1 "${_app}log"
	${ReplaceToken} [log] "$1" "${_target}" "${_file}" 
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "queue" "connectionstring"	
	${ReplaceToken} [conn] "$0" "${_target}" "${_file}" 
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "${_app}" "topics"	
	${ReplaceToken} [topics] "$0" "${_target}" "${_file}"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "data" "dataconnectionstring"
	${ReplaceToken} [dbconn] "$0" "${_target}" "${_file}"	
	StrCpy $R1 ${_target}
	StrCpy $R2 ${_file}
	StrCpy $R3 ${_app}
	Call InjectCustomSettings
!macroend

Function InjectCustomSettings 
    StrCpy $0 0
	StrCpy $4 ""
    loop:
        ${EnumIniValue} $1 "$EXEDIR\${SetupIni}" $R3 $0
        StrCmp $1 "" done
        IntOp $0 $0 + 1
		ReadIniStr $2 "$EXEDIR\${SetupIni}" $R3 $1
		StrCmp $1 "topics" loop
		StrCmp $1 "logonas" loop
		StrCmp $1 "testmessages" loop
		
		StrCpy "$3" '<add key="$1" value="$2"/>$\n'
		StrCpy "$4" "$4$3"		 
		goto loop
    done:	
	${ReplaceToken} [customsettings] "$4" "$R1" "$R2"
FunctionEnd

Section "Main Section" MainSection

	;Check for .NET 4.0
	DetailPrint "$(VerifydotNet)"
	File "${sharedir}dotNetFx40_Full_setup.exe"
	Strcpy $1 $EXEDIR${dotnetruntimedir}${dotnetruntimefile} 
	IfFileExists $EXEDIR${dotnetruntimedir}${dotnetruntimefile} Install
	Strcpy $1 "dotNetFx40_Full_setup.exe"
Install:
	!insertmacro DotNetSearch 4 0 30319 "INSTALL_ABORT" "$1"
	Delete "$EXEDIR\dotNetFx40_Full_setup.exe"
	
	;Check for setup.ini
	IfFileExists "$EXEDIR\${SetupIni}" +3
		MessageBox MB_OK|MB_ICONSTOP "$(SetupIniMissing)"
		Abort		

	;Create uninstaller
	${SetOutPath} "${uninstalldir}"
	${WriteUninstaller} "${uninstalldir}Uninstall.exe"
	
	#Runtime
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "queue" "prerequisites"
	${If} $0 == 1
		${SetOutPath} "$INSTDIR"		
				
		DetailPrint "$(VerifyWindowsComponents)"
		${If} ${RunningX64}
			${File} "${externalsharedir}Erlang\""otp_win64_R16B.exe"
			DetailPrint "Installing Erlang... This will take awhile."
			ExecWait '"$INSTDIR\otp_win64_R16B.exe" /S'
			Delete "$INSTDIR\otp_win64_R16B.exe"
		${Else}
			${File} "${externalsharedir}Erlang\""otp_win32_R16B.exe"
			DetailPrint "Installing Erlang... This will take awhile."
			ExecWait '"$INSTDIR\otp_win32_R16B.exe" /S'
			Delete "$INSTDIR\otp_win32_R16B.exe"
		${EndIf}
		${File} "${externalsharedir}RabbitMQ\""rabbitmq-server-3.0.2.exe"
		DetailPrint "Installing rabbitmq-server-3.0.2... This will take awhile."
		ExecWait '"$INSTDIR\rabbitmq-server-3.0.2.exe" /S'
		Delete "$INSTDIR\rabbitmq-server-3.0.2.exe"	
	${EndIf}
	
	#Setup RabbitMQ Console
	;Yes, we have to set env ERLANG_HOME otherwise management console can't be enabled.
	DetailPrint "Setting up RabbitMQ Management Console..."
	StrCpy $R0 "${erlangdir}"
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("ERLANG_HOME", R0).r2'
	;ReadEnvStr $R0 "ERLANG_HOME"
	nsExec::ExecToLog '"${rabbitmqdir}\rabbitmq-plugins.bat" enable rabbitmq_management'
	nsExec::ExecToLog '"${rabbitmqdir}\rabbitmq-service.bat" stop'
	nsExec::ExecToLog '"${rabbitmqdir}\rabbitmq-service.bat" install'
	nsExec::ExecToLog '"${rabbitmqdir}\rabbitmq-service.bat" start'

	AccessControl::GrantOnFile "$INSTDIR" "Users" "FullAccess"	
	
	#Services::Soap
	${AddItem} "$INSTDIR\${soapdir}"
	${SetOutPath} "$INSTDIR\${soapdir}"
	${File} "${srcsoapdir}""SunGardPS.Orchestration.SoapService.exe"
	${File} "${srcsoapdir}""SunGardPS.Orchestration.Contracts.dll"	
	${File} "${srcsoapdir}""EasyNetQ.dll"
	${File} "${srcsoapdir}""log4net.dll"
	${File} "${srcsoapdir}""Newtonsoft.Json.dll"
	${File} "${srcsoapdir}""RabbitMQ.Client.dll"	
	${File} "${srcsoapdir}""Topshelf.dll"
	${File} "${srcsoapdir}""Topshelf.Log4Net.dll"	
	#${File} "${srcsoapdir}""Soap12.xml"
	${File} "${mydir}""Orchestration.config"
	StrCpy $target "$INSTDIR\${soapdir}"
	!insertmacro ModifyConfig "soap" "$target" "SunGardPS.Orchestration.SoapService.exe.config"
	!insertmacro ModifyCustom "soap" "$target" "SunGardPS.Orchestration.SoapService.exe.config"
	AccessControl::GrantOnFile "$targetSunGardPS.Orchestration.SoapService.exe.config" "Users" "FullAccess"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "soap" "logonas"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.SoapService.exe install --autostart --$0"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.SoapService.exe start"
	
	#Services::Transform
	${AddItem} "$INSTDIR\${transformdir}"
	${SetOutPath} "$INSTDIR\${transformdir}"
	${File} "${srctransdir}""SunGardPS.Orchestration.Transform.exe"
	${File} "${srctransdir}""SunGardPS.Orchestration.Contracts.dll"	
	${File} "${srctransdir}""EasyNetQ.dll"
	${File} "${srctransdir}""log4net.dll"
	${File} "${srctransdir}""Newtonsoft.Json.dll"
	${File} "${srctransdir}""RabbitMQ.Client.dll"	
	${File} "${srctransdir}""Topshelf.dll"
	${File} "${srctransdir}""Topshelf.Log4Net.dll"
	#${File} "${srctransdir}""FieldReporting.xml"
	${File} "${mydir}""Orchestration.config"		
	${AddItem} "$INSTDIR\${transformdir}StyleSheets"	
	
	${SetOutPath} "$INSTDIR\${transformdir}Temp"
	File /r /x *.xml /x *.xsd /x *.wsdl /x *.mfd /x *.cer /x *.pfx "${metadatadir}"
	${SetOutPath} "$INSTDIR\${transformdir}StyleSheets"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "client" "code"
	${CopyFiles} "$INSTDIR\${transformdir}Temp\$0\*.xsl" "$INSTDIR\${transformdir}StyleSheets"
	RMDir /R "$INSTDIR\${transformdir}Temp"	
	StrCpy $target "$INSTDIR\${transformdir}"
	!insertmacro ModifyConfig "transform" "$target" "SunGardPS.Orchestration.Transform.exe.config"
	!insertmacro ModifyCustom "transform" "$target" "SunGardPS.Orchestration.Transform.exe.config"
	AccessControl::GrantOnFile "$targetSunGardPS.Orchestration.Transform.exe.config" "Users" "FullAccess"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "transform" "logonas"
	nsExec::ExecToLog "$target\SunGardPS.Orchestration.Transform.exe install --autostart --$0"
	nsExec::ExecToLog "$target\SunGardPS.Orchestration.Transform.exe start"
	
	#Services::File
	${AddItem} "$INSTDIR\${filedir}"
	${SetOutPath} "$INSTDIR\${filedir}"
	${File} "${srcfiledir}""SunGardPS.Orchestration.FileService.exe"
	${File} "${srcfiledir}""SunGardPS.Orchestration.Contracts.dll"	
	${File} "${srcfiledir}""EasyNetQ.dll"
	${File} "${srcfiledir}""log4net.dll"
	${File} "${srcfiledir}""Newtonsoft.Json.dll"
	${File} "${srcfiledir}""RabbitMQ.Client.dll"	
	${File} "${srcfiledir}""Topshelf.dll"
	${File} "${srcfiledir}""Topshelf.Log4Net.dll"	
	#TODO - custom app section - like workflow (ignore loganas + topics)
	${File} "${mydir}""Orchestration.config"
	StrCpy $target "$INSTDIR\${filedir}"
	!insertmacro ModifyConfig "file" "$target" "SunGardPS.Orchestration.FileService.exe.config"
	!insertmacro ModifyCustom "file" "$target" "SunGardPS.Orchestration.FileService.exe.config"
	AccessControl::GrantOnFile "$targetSunGardPS.Orchestration.FileService.exe.config" "Users" "FullAccess"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "file" "logonas"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.FileService.exe install --autostart --$0"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.FileService.exe start"
	
	#Services::Scheduler
	${AddItem} "$INSTDIR\${scheddir}"
	${SetOutPath} "$INSTDIR\${scheddir}"
	${File} "${srcscheddir}""SunGardPS.Orchestration.SchedulerService.exe"
	${File} "${srcscheddir}""SunGardPS.Orchestration.Contracts.dll"	
	${File} "${srcscheddir}""EasyNetQ.dll"
	${File} "${srcscheddir}""log4net.dll"
	${File} "${srcscheddir}""Newtonsoft.Json.dll"
	${File} "${srcscheddir}""RabbitMQ.Client.dll"	
	${File} "${srcscheddir}""Topshelf.dll"
	${File} "${srcscheddir}""Topshelf.Log4Net.dll"
	#EXTRA FILES
	${File} "${srcscheddir}""C5.dll"
	${File} "${srcscheddir}""Common.Logging.dll"
	${File} "${srcscheddir}""Quartz.dll"
	#END EXTRA
	#TODO - custom app section - like workflow (ignore loganas + topics)
	${File} "${mydir}""Orchestration.config"
	StrCpy $target "$INSTDIR\${scheddir}"
	!insertmacro ModifyConfig "schedule" "$target" "SunGardPS.Orchestration.SchedulerService.exe.config"
	!insertmacro ModifyCustom "schedule" "$target" "SunGardPS.Orchestration.SchedulerService.exe.config"
	AccessControl::GrantOnFile "$targetSunGardPS.Orchestration.SchedulerService.exe.config" "Users" "FullAccess"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "schedule" "logonas"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.SchedulerService.exe install --autostart --$0"
	nsExec::ExecToLog "$targetSunGardPS.Orchestration.SchedulerService.exe start"
	
	
	#Utility::WORM
	${SetOutPath} "$INSTDIR"
	${File} "${srcutilitiesdir}""Worm.exe"
	${File} "${srcutilitiesdir}""SunGardPS.Orchestration.Contracts.dll"	
	${File} "${srcutilitiesdir}""EasyNetQ.dll"
	${File} "${srcutilitiesdir}""log4net.dll"
	${File} "${srcutilitiesdir}""Newtonsoft.Json.dll"
	${File} "${srcutilitiesdir}""RabbitMQ.Client.dll"	
	${File} "${mydir}""Orchestration.config"
	StrCpy $target "$INSTDIR\"
	!insertmacro ModifyConfig "worm" "$target" "worm.exe.config"	
	!insertmacro ModifyCustom "worm" "$target" "worm.exe.config"
	AccessControl::GrantOnFile "$targetworm.exe.config" "Users" "FullAccess"
	
	${WriteRegStr} "${regroot}" "${regkey}" "" $INSTDIR

	;MessageBox MB_OK "$4"
SectionEnd

;--------------------------------
;Descriptions
/*
  ;Language strings
  LangString DESC_SecDummy ${LANG_ENGLISH} "A test section."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${SecDummy} $(DESC_SecDummy)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
*/
;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall

  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort
	
  ReadRegStr $1 "${regroot}" "${regkey}" ""	
  DetailPrint "Uninstalling SunGardPSSoapClient service..."
  nsExec::ExecToLog "$1\${soapdir}SunGardPS.Orchestration.SoapService.exe stop"
  nsExec::ExecToLog "$1\${soapdir}SunGardPS.Orchestration.SoapService.exe uninstall"
  DetailPrint "Uninstalling SunGardPSTransformation service..."
  nsExec::ExecToLog "$1\${transformdir}SunGardPS.Orchestration.Transform.exe stop"
  nsExec::ExecToLog "$1\${transformdir}SunGardPS.Orchestration.Transform.exe uninstall"
  RMDir /R "$1\${transformdir}StyleSheets"
  DetailPrint "Uninstalling SunGardPSDataClient service..."
  nsExec::ExecToLog "$1\${datadir}SunGardPS.Orchestration.DataService.exe stop"
  nsExec::ExecToLog "$1\${datadir}SunGardPS.Orchestration.DataService.exe uninstall"
  DetailPrint "Uninstalling SunGardPSFile service..."
  nsExec::ExecToLog "$1\${filedir}SunGardPS.Orchestration.FileService.exe stop"
  nsExec::ExecToLog "$1\${filedir}SunGardPS.Orchestration.FileService.exe uninstall"
  DetailPrint "Uninstalling SunGardPSScheduler service..."
  nsExec::ExecToLog "$1\${scheddir}SunGardPS.Orchestration.SchedulerService.exe stop"
  nsExec::ExecToLog "$1\${scheddir}SunGardPS.Orchestration.SchedulerService.exe uninstall"
	  
  Push $R0
  Push $R1
  Push $R2
  SetFileAttributes "$INSTDIR\${UninstLog}" NORMAL
  FileOpen $UninstLog "$INSTDIR\${UninstLog}" r
  StrCpy $R1 -1
 
  GetLineCount:
    ClearErrors
    FileRead $UninstLog $R0
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -2
    Push $R0   
    IfErrors 0 GetLineCount
 
  Pop $R0
 
  LoopRead:
    StrCmp $R1 0 LoopDone
    Pop $R0
    IfFileExists "$R0\*.*" 0 +3
      RMDir $R0  #is dir
    Goto +9
    IfFileExists $R0 0 +3
      Delete $R0 #is file
    Goto +6
    StrCmp $R0 "${regroot} ${regkey}" 0 +3
      DeleteRegKey ${regroot} "${regkey}" #is Reg Element
    Goto +3
    StrCmp $R0 "${regroot} ${regkey}" 0 +2
      DeleteRegKey ${regroot} "${regkey}" #is Reg Element
    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  FileClose $UninstLog
  Delete "$INSTDIR\${UninstLog}"
  Pop $R2
  Pop $R1
  Pop $R0

	
	
  ;Remove registry keys
    ;DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    ;DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd
