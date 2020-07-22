; NSIS (Damn small install)
; Mutilated script from dozens of developers
; Web Updater - because installations shouldn't suck!

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
    !define UninstLog "webupdateruninstall.log"
	!define setupini "webupdatersetup.ini"
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
	!define backupfile "webupdaterbackup[${productversion}]"
	!define exec "Web"
	!define CheckAndRestoreIfFails "!insertmacro CheckAndRestoreIfFails"
	!define appcmd "$SYSDIR\inetsrv\appcmd"
	;AddItem macro
    !define AddItem "!insertmacro AddItem"
	;File macro
    !define File "!insertmacro File"
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
	;Add System services to database
	!define AddSqlPermissions "!insertmacro AddSqlPermissions"
	!define AddSqlPermissions2000 "!insertmacro AddSqlPermissions2000"
	!define AddSqlPermissions2005 "!insertmacro AddSqlPermissions2005"
	!define AddSqlPermissions2000PerDb "!insertmacro AddSqlPermissions2000PerDb"
	!define RemoveReadOnlyAttribute "!insertmacro RemoveReadOnlyAttribute"
	;General
	!define setup "webupdaterserversetup.exe"
	!define releasedir "WebUpdaterServer\Release\"
	; change this to wherever the files to be packaged reside
	; This is effectively our release branch - the precompiled web. From Studio -> Build Website and Publish to the relative Path
	!define srcdir "..\Services\PrecompiledWeb\SunGardPS.WebUpdater.Application\"
	!define scriptdir "..\InstallScripts\"
	!define sharedir "..\InstallScripts\shared\"
	!define mydir "..\InstallScripts\WebUpdaterServer\"
	!define company "SunGard Public Sector"
	!define companypathname "SunGardPublicSector"
	!define prodname "WebUpdater Server"
	!define prodpathname "WebUpdater"
	!define bindir "bin\"
	!define uninstalldir "$INSTDIR\uninstall\"
	!define installationconfigurationfile "Install.config"
	!define configurationfile "Web.config"
	!define productversion "1.0.0.10"
	!define setupversion "1.0.0.10"
	!define NSIS_CONFIG_LOG
	!define dotnetruntimedir "\DotNet40Runtime\"
	!define dotnetruntimefile "dotNetFx40_Full_x86_x64.exe"

    Var UninstLog
	Var sitename
	Var siteid
	Var siteport
	Var protocol
	Var iisparam
	Var register
	Var sector
	Var accessright
	Var datasource
	Var dblanguage
	Var database
	Var uname
	Var pword
	Var	fqdn
	;Uninstall log file missing.
	LangString ApplyConfigSettings ${LANG_ENGLISH} "Updating configuration file."
	LangString ApplyConfigWindowsPermissions ${LANG_ENGLISH} "Applying permissions to configuration file for $accessright and $sitenamePool."
	LangString ApplyLogFileWindowsPermissions ${LANG_ENGLISH} "Applying permissions to log directory for $accessright and $sitenamePool."
	LangString ApplyFolderWindowsPermissions ${LANG_ENGLISH} "Applying permissions to folder hierarchy for $accessright."
	LangString ApplyingBindings ${LANG_ENGLISH} "Applying site bindings for $sitename."
	LangString AssigningApplicationPool ${LANG_ENGLISH} "Assigning threadpool to application site."
	LangString AssigningPriviledge ${LANG_ENGLISH} "Assigning permissions for $sitenamePool."
	LangString AssignThreadpool ${LANG_ENGLISH} "Assigning threadpool to site."
	LangString AutoconfigureSite ${LANG_ENGLISH} "Determining if host is specified in ${setupini}."
	LangString BasicAuthentication ${LANG_ENGLISH} "Turning off Basic Authentication..."
	LangString CannotAssignThreadpool ${LANG_ENGLISH} "***Warning! (x64) Cannot currently assign dedicated threadpool [$sitenamePool]. $(DoItYourself)"
	LangString CannotConnectToDatabase ${LANG_ENGLISH} "***Warning! Cannot connect to database - some required installation settings have not been configured! $(DoItYourself)."
	LangString ConfigureCertificate ${LANG_ENGLISH} "Configuring application for mutual certificate authorization."
	LangString ConfigureCustomProvider ${LANG_ENGLISH} "Configuring custom authentication provider for site."
	LangString ConfiguringAccess ${LANG_ENGLISH} "Configured for $accessright."
	LangString ConfiguringSSL ${LANG_ENGLISH} "Enabling SSL for site."
	LangString CreateThreadPool ${LANG_ENGLISH} "Creating dedicated threadpool for $sitename called $sitenamePool."
	LangString ConfiguringTransactionServices ${LANG_ENGLISH} "Configuring server for Distributed Transaction Services."	
	LangString CreatingApplication ${LANG_ENGLISH} "Creating application for site - called $sector."
	LangString CreatingSite ${LANG_ENGLISH} "Creating site $sitename."
	LangString CredentialConfiguration ${LANG_ENGLISH} "Ensuring that Internet Information Server is configured for custom authentication."
	LangString DeletingBackup ${LANG_ENGLISH} "Deleting old ${backupfile}..."
	LangString DoItYourself ${LANG_ENGLISH} "This has to be done manually."
	LangString ListingBackup ${LANG_ENGLISH} "Listing current backup in storage..."
	LangString LocatedIIS ${LANG_ENGLISH} "Located Microsoft Internet Information Server v"
	LangString MakingBackup ${LANG_ENGLISH} "Backing up current settings to ${backupfile}..."
	LangString MinimumIISInstalled ${LANG_ENGLISH} "This installation requires Microsoft Internet Information Server; version 7.0 or higher!$\r$\nInstallation will abort."
	LangString MinimumOSType ${LANG_ENGLISH} "This installation requires 2008 or higher!"
	LangString RegisteringIIS ${LANG_ENGLISH} "Registering IIS for .NET 4.0 compatibility."
	LangString ResolutionMethod ${LANG_ENGLISH} "Method for determining host name "
	LangString RestoringBackup ${LANG_ENGLISH} "A backup of your IIS server was made during installation if you need to restore to its original state it is called ${backupfile}."
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
	LangString VerifyWindowsComponents ${LANG_ENGLISH} "Verifying required windows components. Please wait - as this may take awhile..."
	LangString WindowsAuthentication ${LANG_ENGLISH} "Turning off Windows Authentication..."
	LangString WrongOSType ${LANG_ENGLISH} "Server installation requires a server operating system!"
	LangString RebootRequired ${LANG_ENGLISH} "Server installation may require a reboot to ensure all components are functional!"
	
	VIProductVersion "${productversion}" ;could be read from a resource or whatever...	
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${prodname}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" ""
	VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${prodname} is a trademark of ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Service host application(s) for updating client"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${setupversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${productversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "HotfixIntallerKiller"

Section -openlogfile
    ${CreateDirectory} "${uninstalldir}"
    IfFileExists "${uninstalldir}\${UninstLog}" +3
      FileOpen $UninstLog "${uninstalldir}\${UninstLog}" w
    Goto +4
      SetFileAttributes "${uninstalldir}\${UninstLog}" NORMAL
      FileOpen $UninstLog "${uninstalldir}\${UninstLog}" a
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
	RequestExecutionLevel admin
	;Installer Sections
	
Function CheckMinimumOS
    ReadINIStr $1 "$EXEDIR\${setupini}" "AuditHost" "ElHefe"
	StrCmp $1 "TRUE" +10 0
	${IfNot} ${IsServerOS}
		MessageBox MB_OK|MB_ICONSTOP "$(WrongOSType)"
		Quit
	${Else}
		${IfNot} ${AtLeastWin2008}
			MessageBox MB_OK|MB_ICONSTOP "$(MinimumOSType)"
			Quit
		${EndIf}
	${EndIf}
FunctionEnd
;--------------------------------
; CheckIISVersion Function
;
; This is built off MSFT's required keys for IIS
; (info at http://nsis.sf.net/wiki)
; and the NSIS Wiki (http://nsis.sf.net/wiki).
Function CheckIISVersion
 
	ClearErrors
	ReadRegDWORD $0 HKLM "SOFTWARE\Microsoft\InetStp" "MajorVersion"
	ReadRegDWORD $1 HKLM "SOFTWARE\Microsoft\InetStp" "MinorVersion"
 
	IfErrors 0 NoAbort
	Abort "$(MinimumIISInstalled)"
 
	IntCmp $0 7 NoAbort IISMajVerLT7 NoAbort
 
	NoAbort:
		
		DetailPrint "$(LocatedIIS)$0.$1"
		Goto ExitFunction
 
	IISMajVerLT7:
		Abort "$(MinimumIISInstalled)"
 
	ExitFunction:
 
FunctionEnd

Function TranslatePriviledge
	${If} $accessright == "LocalSystem"
		StrCpy $accessright "NT AUTHORITY\LOCAL SYSTEM"
	${ElseIf} $accessright == "LocalService"
		StrCpy $accessright "NT AUTHORITY\LOCAL SERVICE"
	${Else}
		StrCpy $accessright "NT AUTHORITY\NETWORK SERVICE"
	${EndIf}
FunctionEnd 

Function StrTok
  Exch $R1
  Exch 1
  Exch $R0
  Push $R2
  Push $R3
  Push $R4
  Push $R5
 
  ;R0 fullstring
  ;R1 tokens
  ;R2 len of fullstring
  ;R3 len of tokens
  ;R4 char from string
  ;R5 testchar
 
  StrLen $R2 $R0
  IntOp $R2 $R2 + 1
 
  loop1:
    IntOp $R2 $R2 - 1
    IntCmp $R2 0 exit
 
    StrCpy $R4 $R0 1 -$R2
 
    StrLen $R3 $R1
    IntOp $R3 $R3 + 1
 
    loop2:
      IntOp $R3 $R3 - 1
      IntCmp $R3 0 loop1
 
      StrCpy $R5 $R1 1 -$R3
 
      StrCmp $R4 $R5 Found
    Goto loop2
  Goto loop1
 
  exit:
  ;Not found!!!
  StrCpy $R1 ""
  StrCpy $R0 ""
  Goto Cleanup
 
  Found:
  StrLen $R3 $R0
  IntOp $R3 $R3 - $R2
  StrCpy $R1 $R0 $R3
 
  IntOp $R2 $R2 - 1
  IntOp $R3 $R3 + 1
  StrCpy $R0 $R0 $R2 $R3
 
  Cleanup:
  Pop $R5
  Pop $R4
  Pop $R3
  Pop $R2
  Exch $R0
  Exch 1
  Exch $R1
 
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

Function GetQualifiedMachineName
System::Call 'Netapi32::NetGetJoinInformation(t .r0, *i r1, *i .r2)i.r3'
${If} $3 == 0
	;Success
	${If} $2 == 3
		;Domain information available
		!insertmacro GetMachineName 7 $fqdn
		Push $fqdn
		Push "."
		Call StrTok
		Pop $R1
		Pop $R2
		Push $R2
		Push "."
		Call StrTok
		Pop $R3
		StrCpy $fqdn '$R3\$R1$$'
	${EndIf}
${EndIf}
FunctionEnd

!macro CheckAndRestoreIfFails _text
   ${IfNot} $0 == 0 
		${IfNot} $0 == 1 ;no idea why - still everything gets executed(Unless both 0 and 1 indicate ok?)
			;MessageBox MB_OK "[$0] - ${_text}" ;for testing only
			ExecWait "${appcmd} restore backup ${backupfile}"
			Abort
		${EndIf}
   ${EndIf}
!macroend

!macro SqlExecutionCheck _success _print
	pop $0
	pop $1
	${If} ${_print} == 1
		DetailPrint "[$0] $1"
	${EndIf}
	StrCpy ${_success} $0
	;print all errors regardless
	${IfNot} $0 == 0
		MSSQL_OLEDB::SQL_GetError /NOUNLOAD
		pop $0
		pop $1
		DetailPrint "[$0] $1"
	${EndIf}
    
!macroend

!macro AddSqlPermissions2005 _user
		MSSQL_OLEDB::SQL_Execute /NOUNLOAD "USE master"
		;THE REASON FOR ABANDONING THE CHECK IS THAT THE NATIVE OLEDB DRIVER INCORRECTLY RETURNS INVALID SYNTAX NEAR "("
		DetailPrint "IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'${_user}') DROP LOGIN [${_user}]"
		MSSQL_OLEDB::SQL_Execute /NOUNLOAD "IF  EXISTS (SELECT * FROM sys.server_principals WHERE name = N'${_user}') DROP LOGIN [${_user}]"
		;we don't care if user doesn't already exist - ignore error code
		${SqlExecutionCheck} $R1 0
		DetailPrint "CREATE LOGIN [${_user}] FROM WINDOWS WITH DEFAULT_DATABASE=[$database], DEFAULT_LANGUAGE=[$dblanguage]"
		MSSQL_OLEDB::SQL_Execute /NOUNLOAD "CREATE LOGIN [${_user}] FROM WINDOWS WITH DEFAULT_DATABASE=[$database], DEFAULT_LANGUAGE=[$dblanguage]"
		${SqlExecutionCheck} $R1 1
		${If} $R1 == 0
			DetailPrint "USE [$database]"
			MSSQL_OLEDB::SQL_Execute /NOUNLOAD "USE [$database]"
			${SqlExecutionCheck} $R1 1
			${If} $R1 == 0
				DetailPrint "IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'${_user}') DROP USER [${_user}]"
				MSSQL_OLEDB::SQL_Execute /NOUNLOAD "IF  EXISTS (SELECT * FROM sys.database_principals WHERE name = N'${_user}') DROP USER [${_user}]"
				${SqlExecutionCheck} $R1 0
				DetailPrint "CREATE USER [${_user}] FOR LOGIN [${_user}]"
				MSSQL_OLEDB::SQL_Execute /NOUNLOAD "CREATE USER [${_user}] FOR LOGIN [${_user}]"
				${SqlExecutionCheck} $R1 1
				${If} $R1 == 0
					DetailPrint "EXEC sp_addrolemember N'db_owner', N'${_user}'"
					MSSQL_OLEDB::SQL_Execute /NOUNLOAD "EXEC sp_addrolemember N'db_owner', N'${_user}'"
					${SqlExecutionCheck} $R1 1
				${Else}
					DetailPrint "$(SqlPermissionsError)"
				${EndIf}
			${Else}
				DetailPrint "$(SqlDatabaseMissing)"
			${EndIf}
		${Else}
			DetailPrint "$(SqlPermissionsError)"
		${EndIf}
!macroend

!macro AddSqlPermissions2000 _user
	${AddSqlPermissions2000PerDb} "${_user}" "master"
	${AddSqlPermissions2000PerDb} "${_user}" "$database"
!macroend

!macro AddSqlPermissions2000PerDb _user _db
	MSSQL_OLEDB::SQL_Execute /NOUNLOAD "USE ${_db}"
	;THE REASON FOR ABANDONING THE CHECK IS THAT THE NATIVE OLEDB DRIVER INCORRECTLY RETURNS INVALID SYNTAX NEAR "("
	DetailPrint "IF  EXISTS (SELECT * FROM dbo.sysusers WHERE name = N'${_user}') EXEC sp_droplogin '${_user}'"
	MSSQL_OLEDB::SQL_Execute /NOUNLOAD "IF  EXISTS (SELECT * FROM dbo.sysusers WHERE name = N'${_user}') EXEC sp_droplogin '${_user}'"
	;we don't care if user doesn't already exist - ignore error code
	${SqlExecutionCheck} $R1 0
	DetailPrint "EXEC sp_grantlogin N'${_user}'"
	MSSQL_OLEDB::SQL_Execute /NOUNLOAD "EXEC sp_grantlogin N'${_user}'"
	${SqlExecutionCheck} $R1 1
	${If} $R1 == 0
		DetailPrint "EXEC sp_defaultdb @loginame = N'${_user}', @defdb = N'$database'"
		MSSQL_OLEDB::SQL_Execute /NOUNLOAD "EXEC sp_defaultdb @loginame = N'${_user}', @defdb = N'$database'"
		${SqlExecutionCheck} $R1 1
		${If} $R1 == 0
			DetailPrint "EXEC sp_defaultlanguage  @loginame = N'${_user}', @language  = N'$dblanguage'"
			MSSQL_OLEDB::SQL_Execute /NOUNLOAD "EXEC sp_defaultlanguage @loginame = N'${_user}', @language = N'$dblanguage'"
			${SqlExecutionCheck} $R1 1
			${If} $R1 == 0
				DetailPrint "EXEC sp_addrolemember 'db_owner', '${_user}'"
				MSSQL_OLEDB::SQL_Execute /NOUNLOAD "EXEC sp_addrolemember 'db_owner', '${_user}'"
				${SqlExecutionCheck} $R1 1
			${Else}
				DetailPrint "$(SqlPermissionsError)"
			${EndIf}
		${Else}
				DetailPrint "$(SqlPermissionsError)"
		${EndIf}
	${Else}
		DetailPrint "$(SqlPermissionsError)"
	${EndIf}
!macroend

!macro AddSqlPermissions _user
DetailPrint "select @@MICROSOFTVERSION / 0x01000000 AS VERSION" 
MSSQL_OLEDB::SQL_Execute "select @@MICROSOFTVERSION / 0x01000000 AS VERSION" 
${SqlExecutionCheck} $R1 1
${If} $R1 == 0
	MSSQL_OLEDB::SQL_GetRow
	Pop $R2
	Pop $R3
	${If} $R2 == 0
		${If} $R3 == 8
			${AddSqlPermissions2000} "${_user}"
		${Else}
			${AddSqlPermissions2005} "${_user}"
		${EndIf}
	${EndIf}
${Else}
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
	
	;Check for Windows Components - will install prerequisites if need be...
	DetailPrint "$(VerifyWindowsComponents)"
	${If} ${RunningX64}
		System::Call "kernel32::Wow64DisableWow64FsRedirection(*i)"	
	${EndIf}
	nsExec::ExecToLog "$SYSDIR\ServerManagerCmd.exe -install Application-Server Web-Server AS-Dist-Transaction"
	
	;MSDTC - Registry settings
	;http://support.microsoft.com/kb/899191
	DetailPrint "$(ConfiguringTransactionServices)"
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\MSDTC\Security" "NetworkDtcAccess" 0x00000001
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\MSDTC" "AllowOnlySecureRpcCalls" 0x00000000
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\MSDTC" "FallbackToUnsecureRPCIfNecessary" 0x00000000
	WriteRegDWORD HKLM "SOFTWARE\Microsoft\MSDTC" "TurnOffRpcSecurity" 0x00000001
	;ANY DTC changes require a reboot in order to "stick"
	;Maybe not for 2008
	;SetRebootFlag true
	
	;Enable Firewall Exceptions for MS DTC
	;http://technet.microsoft.com/en-us/library/cc725913%28WS.10%29.aspx
	;http://www.stringbuilder.net/post/2009/07/30/Enable-Network-Access-for-MS-DTC.aspx
	
	;Check for IIS v7 and above
	Call CheckIISVersion
	
	ReadINIStr $sector "$EXEDIR\${setupini}" "AuditHost" "ApplicationName"
	#Define basic folder layout
	${AddItem} "$INSTDIR"
	${AddItem} "$INSTDIR\${bindir}"
	${AddItem} "$INSTDIR\$sector"
	${AddItem} "${uninstalldir}"
	
	;Create uninstaller
	${SetOutPath} "${uninstalldir}"
	${WriteUninstaller} "${uninstalldir}Uninstall.exe"
	#logs folder
	${SetOutPath} "$INSTDIR\$sector\logs"
	#Main Configuration file
	${SetOutPath} "$INSTDIR\$sector"
	${File} "${mydir}""${configurationfile}"
	${File} "${mydir}""Global.asax"
	#Main binary files
	;${SetOutPath} "$INSTDIR\${bindir}"
	${SetOutPath} "$INSTDIR\$sector\${bindir}"
	${File} "${srcdir}${bindir}""App_Code.dll"
	${File} "${srcdir}${bindir}""App_global.asax.dll"
	${File} "${srcdir}${bindir}""AutoMapper.dll"
	${File} "${srcdir}${bindir}""CommonServiceLocator.NinjectAdapter.dll"
	${File} "${srcdir}${bindir}""log4net.dll"
	${File} "${srcdir}${bindir}""Microsoft.Practices.ServiceLocation.dll"
	${File} "${srcdir}${bindir}""Ninject.dll"
	${File} "${srcdir}${bindir}""Ninject.Extensions.Conventions.dll"
	${File} "${srcdir}${bindir}""Ninject.Extensions.Wcf.CommonServiceLocator.dll"
	${File} "${srcdir}${bindir}""Ninject.Extensions.Wcf.dll"
	${File} "${srcdir}${bindir}""PostSharp.dll"
	${File} "${srcdir}${bindir}""SLF.dll"
	${File} "${srcdir}${bindir}""SLF.Log4netFacade.dll"
	${File} "${srcdir}${bindir}""SunGardPS.Communication.dll"
	${File} "${srcdir}${bindir}""SunGardPS.Common.Logging.Service.dll"
	${File} "${srcdir}${bindir}""SunGardPS.Common.Data.dll"
	${File} "${srcdir}${bindir}""SunGardPS.WebUpdater.Contracts.dll"
	${File} "${srcdir}${bindir}""SunGardPS.WebUpdater.Service.Data.dll"
	${File} "${srcdir}${bindir}""SunGardPS.WebUpdater.Service.dll"
	${File} "${srcdir}${bindir}""FluentNHibernate.dll"
	${File} "${srcdir}${bindir}""NHibernate.dll"
	${File} "${srcdir}${bindir}""NHibernate.ByteCode.Castle.dll"
	${File} "${srcdir}${bindir}""Remotion.Data.Linq.dll"
	${File} "${srcdir}${bindir}""Antlr3.Runtime.dll"
	${File} "${srcdir}${bindir}""Iesi.Collections.dll"
	${File} "${srcdir}${bindir}""Castle.Core.dll"
	${File} "${srcdir}${bindir}""FluentMigrator.dll"
	${File} "${srcdir}${bindir}""FluentMigrator.Runner.dll"
	
	;Store installation folder
	${WriteRegStr} "${regroot}""${regkey}" "" $INSTDIR
    ;Write the Uninstall information into the registry
    ${WriteRegStr} ${regroot} "${regkey}" "UninstallString" "${uninstalldir}Uninstall.exe"
	
	ReadINIStr $iisparam "$EXEDIR\${setupini}" "IIS" "regiisparam"
	ReadINIStr $register "$EXEDIR\${setupini}" "IIS" "registeriis"
    ReadINIStr $sitename "$EXEDIR\${setupini}" "AuditHost" "Name"
	ReadINIStr $siteid "$EXEDIR\${setupini}" "AuditHost" "Id"
	ReadINIStr $siteport "$EXEDIR\${setupini}" "AuditHost" "Port"
	ReadINIStr $accessright "$EXEDIR\${setupini}" "AuditHost" "Privilege"
	${If} $accessright == ""
		StrCpy $accessright "NetworkService"
	${EndIf}
	
	StrCpy $protocol "http"
	${If} $siteport = ""
		StrCpy $siteport "4401"
	${EndIf}
	
	/*
	SimpleFC::IsFirewallServiceRunning
	pop $0
	;${If} $0 == 1
		SimpleFC::AddPort $siteport "${prodname}" 6 0 2 "" 1
		;SimpleFC::AdvAddRule ${prodname} "${prodname} - communication rule" "6" "1" "1" "2147483647" "1" "Application" "128" "" $siteport "" "" ""
		Pop $0 ; return error(1)/success(0)
		SimpleFC::EnableDisableApplication "$SYSDIR\msdtc.exe" 1
	;${EndIf}
	*/
	;0. RESTORE FROM BACKUP USING (for testing only)
	;Using different register to not "effect" the one we use for error-check
	;ExecToLog - more user-friendly (no pop-ups)
	;DetailPrint "Restoring current settings from ${backupfile}..."
	;nsExec::ExecToLog  `${appcmd} restore backup "${backupfile}"` $0
	
	;1. DELETE BACKUP EXISTING IIS SETTINGS
	DetailPrint "$(DeletingBackup)" 
	nsExec::ExecToLog  `${appcmd} delete backup "${backupfile}"` $0
	
	;2. BACKUP EXISTING IIS SETTINGS
	DetailPrint "$(MakingBackup)" 
	nsExec::ExecToLog  `${appcmd} add backup "${backupfile}"` $0
	StrCpy $0 "0"
	
	;3. LIST EXISTING BACKUPS
	DetailPrint "$(ListingBackup)" 
	nsExec::ExecToLog  `${appcmd} list backup` $R0
	${CheckAndRestoreIfFails} "3. BACKUP EXISTING IIS SETTINGS"
	/*http://s2.howna.com/apache-iis-configuration/appcmd-restore-and-delete-backup-access-denied-error-800700005.html
	I have first-hand see this return 1 (instead of 0) - and still create the backup (manually performing list)
	I'm removing the check for now*/
	;MessageBox MB_OK| $0
	;4. REGISTER .NET 4.0 COMPATIBILITY FOR IIS (x64)
	/* Invaluable reference resources
	http://msdn.microsoft.com/en-us/library/k6h9cz8h%28v=VS.100%29.aspx
	http://weblogs.asp.net/owscott/archive/2006/05/30/ASPNet_5F00_regiis.exe-tool_2C00_-setting-the-default-version-without-forcing-an-upgrade-on-all-sites.aspx
	*/
	/*Running this frequently - testing; will cause issues after awhile - will return error code 1*/
	${IfNot} $register == "0"
		DetailPrint "$(RegisteringIIS)"
		${If} ${RunningX64}
			nsExec::ExecToLog  "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\aspnet_regiis $iisparam" $0  
		${Else}
			nsExec::ExecToLog  "$WINDIR\Microsoft.NET\Framework\v4.0.30319\aspnet_regiis $iisparam" $0  
		${EndIf}
		${CheckAndRestoreIfFails} "4. REGISTER DOTNET 4.0"
	${EndIf}
	;Note: Spaces in potential values are killing us!
	;5. CREATES SITE
	; For some reason also returns 1 on occasion - may need to check for both return values...
	; Register $0 - gets set to one (and stays there?)
	;Ignoring here as stopping a non-existent site will "prove" not created.
	DetailPrint "$(CreatingSite)"
	nsExec::ExecToLog  `${appcmd} add site /name:"$sitename" /id:$siteid /physicalPath:"$INSTDIR" /+bindings.[protocol='$protocol',bindingInformation='*:$siteport:']` $0
	${CheckAndRestoreIfFails} "5. CREATES SITE"

	;5a
	;when the site already exists, the binding is not set properly
	;so we force to set it again
	DetailPrint "$(ApplyingBindings)"
	nsExec::ExecToLog  `${appcmd} set site /site.name:"$sitename" /+bindings.[protocol='$protocol',bindingInformation='*:$siteport:']` $0
	${CheckAndRestoreIfFails} "5a. SET SITE"
	
	;6. STOP THE NEWLY CREATED SITE - FOR SAFETY
	DetailPrint	"$(StoppingSite)"
	nsExec::ExecToLog  `${appcmd} stop site /site.name:"$sitename"` $0
	${CheckAndRestoreIfFails} "6. STOP THE NEWLY CREATED SITE"
	
	;6a
	;when the site already exists, the binding is not set properly
	;so we force to set it again
	DetailPrint "$(ConfigureCertificate)"
	;DetailPrint `${appcmd} set config /"$sitename/$sector" /section:system.webServer/security/access /sslFlags:"None" /commit:APPHOST`
	nsExec::ExecToLog  `${appcmd} set config "$sitename/$sector" /section:system.webServer/security/access /sslFlags:"None" /commit:APPHOST` $0
	${CheckAndRestoreIfFails} "6a. TURN OFF SITE DEFAULT FOR APPLICATION"
	nsExec::ExecToLog  `${appcmd} set config "$sitename/$sector" /section:system.webServer/security/access /sslFlags:"SslNegotiateCert" /commit:APPHOST` $0
	;DetailPrint `${appcmd} set config /"$sitename/$sector" /section:system.webServer/security/access /sslFlags:"SslNegotiateCert" /commit:APPHOST`
	${CheckAndRestoreIfFails} "6a. MODIFY APPLICATION DEFAULT TO ACCEPT CLIENT CERTIFICATE"
	;nsExec::ExecToLog  `${appcmd} set config /"$sitename/$sector" /section:system.webServer/security/access /requireSsl:false /commit:apphost` $0
	
	DetailPrint "$(CreateThreadPool)"
	;7. CREATES A DEDICATED THREADPOOL FOR THE SITE (WITH 4.0 INTEGRATION) 
	nsExec::ExecToLog  `${appcmd} add apppool /name:"$sitenamePool" /managedRuntimeVersion:v4.0 /managedPipelineMode:Integrated` $0
	${CheckAndRestoreIfFails} "7. CREATES A DEDICATED THREADPOOL"
	
	DetailPrint "$(CredentialConfiguration)"
	;8. BY DEFAULT IIS WILL ONLY USE WINDOWS CREDENTIALS - THIS ALLOWS BOTH 
	nsExec::ExecToLog  "${appcmd} set config /section:windowsAuthentication /useKernelMode:false" $0
	${CheckAndRestoreIfFails} "8. DEFAULT IIS USE WINDOWS CREDENTIALS"
	
	;9. ASSIGN NEWLY CREATED APPPOOL TO NEWLY CREATED SITE (WARNING THIS WILL CORRUPT THE SITE UNDER x64 - MANUAL)
	;	NOTE: This corruption may have something to do with threadpool (default) working under 32-bit context.
	${IfNot} ${RunningX64}
		DetailPrint "$(AssignThreadpool)"
		nsExec::ExecToLog  `${appcmd} set site "$sitename" -[path='/'].applicationPool:"$sitenamePool"` $0
		${CheckAndRestoreIfFails} "9. ASSIGN NEWLY CREATED APPPOOL TO NEWLY CREATED SITE"
	${Else}
		DetailPrint "$(CannotAssignThreadpool)"
	${EndIf}
	
;	;10. CONFIGURE ON - ANONYMOUS FOR OUR CUSTOM PROVIDER 
;	DetailPrint "$(ConfigureCustomProvider)"
;	nsExec::ExecToLog  `${appcmd} set config "$sitename" -section:system.webServer/security/authentication/anonymousAuthentication /enabled:"True" /commit:apphost` $0
;	${CheckAndRestoreIfFails} "10. CONFIGURE ON - ANONYMOUS FOR OUR CUSTOM PROVIDER"
	
;	DetailPrint "$(BasicAuthentication)"
;	;11. CONFIGURE OFF BASIC AUTHENTICATION(CONFLICTS WITH CUSTOM) 
;	nsExec::ExecToLog  `${appcmd} set config "$sitename" -section:system.webServer/security/authentication/basicAuthentication /enabled:"False" /commit:apphost` $0
;	${CheckAndRestoreIfFails} "11. CONFIGURE OFF BASIC AUTHENTICATION"
	
	DetailPrint "$(WindowsAuthentication)"
	;12. CONFIGURE OFF WINDOWS AUTHENTICATION (CONFLICTS WITH EVERYTHING) 
	nsExec::ExecToLog  `${appcmd} set config "$sitename" -section:system.webServer/security/authentication/windowsAuthentication /enabled:"False" /commit:apphost` $0
	${CheckAndRestoreIfFails} "12. CONFIGURE OFF WINDOWS AUTHENTICATION"

	DetailPrint "$(CreatingApplication)"
	;13. CREATE SEPARATE SITE - FOR FUTURE?
	;Remove the trailing / from the physical path. Or you get illegal characters in path.
	nsExec::ExecToLog  `${appcmd} add app /site.name:"$sitename" /path:"/$sector" /physicalPath:"$INSTDIR\$sector"` $0
	${CheckAndRestoreIfFails} "13. CREATE PUBLIC SAFETY SITE"

	DetailPrint "$(AssigningApplicationPool)"
	;14. MANUALLY ASSIGN APPLICATION SINCE INHERITS FROM ROOT (WHICH ISN'T SET IN x64) 
	nsExec::ExecToLog  `${appcmd} set site "$sitename" -[path='/$sector'].applicationPool:"$sitenamePool"` $0
	${CheckAndRestoreIfFails} "14. MANUALLY ASSIGN APPLICATION SINCE INHERITS FROM ROOT"

	DetailPrint "$(AssigningPriviledge)"
	;15. ASSIGN THREAD-POOL PRIVILEGE (NETWORKSERVICE) FOR INTERACTION 
	nsExec::ExecToLog  `${appcmd} set config /section:applicationPools /[name='$sitenamePool'].processModel.identityType:$accessright` $0
	${CheckAndRestoreIfFails} "15. ASSIGN THREAD-POOL PRIVILEGE (NETWORKSERVICE) FOR INTERACTION"

	;16.SWAP CONFIGURATION
	DetailPrint "$(ApplyConfigSettings)"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Database" "WebConnectionString"
	${ReplaceToken} [WebConnectionString] $0 "$INSTDIR\$sector" "${configurationfile}"
	
	ReadINIStr $datasource "$EXEDIR\${SetupIni}" "Database" "Datasource" 
	${If} $datasource == ""
		StrCpy $datasource "."
	${EndIf}
	${ReplaceToken} [Datasource] $datasource "$INSTDIR\$sector" "${configurationfile}"
	
	ReadINIStr $database "$EXEDIR\${SetupIni}" "Database" "Database"
	${If} $database == ""
		StrCpy $database "WebUpdater"
	${EndIf}
	${ReplaceToken} [Database] $database "$INSTDIR\$sector" "${configurationfile}"
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Database" "WebConnectionProvider"
	${ReplaceToken} [WebConnectionProvider] $0 "$INSTDIR\$sector" "${configurationfile}"
	${ReplaceToken} [ApplicationDir] "$INSTDIR\$sector\" "$INSTDIR\$sector" "${configurationfile}"
	
	;keep server timeout in sync with client timeout...sigh (this is Kissimmee-inspired)
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Client" "Timeout"
	${If} $0 == ""
			StrCpy $0 "00:00:05:00"
	${EndIf}
	${ReplaceToken} [timeout] $0 "$INSTDIR\$sector" "${configurationfile}"
	
	;17. CREATE WEBUPDATER DATABASE
	ReadINIStr $pword "$EXEDIR\${SetupIni}" "Database" "Pword"
	${If} $pword == ""
		StrCpy $pword "xxLarge!"
	${ElseIf} $pword == "(blank)"
		StrCpy $pword ""
	${EndIf}
	;execute sql commands for db access
	ReadINIStr $uname "$EXEDIR\${SetupIni}" "Database" "Uname"
	${If} $uname == ""
		StrCpy $uname "sa"
	${EndIf}
	${If} $uname == "(SSPI)"
		StrCpy $uname ""
		StrCpy $pword ""
	${EndIf}
	${ReplaceToken} [Uname] $uname "$INSTDIR\$sector" "${configurationfile}"
	${ReplaceToken} [Pword] $pword "$INSTDIR\$sector" "${configurationfile}"
	MSSQL_OLEDB::SQL_Logon /NOUNLOAD "$datasource" "$uname" "$pword"
	${SqlExecutionCheck} $R1 1
	${If} $R1 == 0
		StrCpy $R1 "IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = '$database') CREATE DATABASE [$database]"
		DetailPrint $R1
		MSSQL_OLEDB::SQL_Execute /NOUNLOAD $R1
		${SqlExecutionCheck} $R1 1
		
		;18. SERVICE PERMISSIONS FOR SQL
		DetailPrint "$(SqlPermissions)"
		ReadINIStr $0 "$EXEDIR\${SetupIni}" "Database" "RegisterPrivilege"
		${IfNot} $0 == "0"
			ReadINIStr $dblanguage "$EXEDIR\${SetupIni}" "Database" "Language"
			DetailPrint "$(ConfiguringAccess)"
			Call TranslatePriviledge
			DetailPrint "$(TranslateAccess)"
			${AddSqlPermissions} "$accessright"
			${AddSqlPermissions} "NT AUTHORITY\ANONYMOUS LOGON" ;required for IIS 
			Call GetQualifiedMachineName
			${IfNot} $fqdn == ""
				${AddSqlPermissions} $fqdn
			${EndIf}
		${EndIf}
		
		MSSQL_OLEDB::SQL_Logout		
	${Else}
		DetailPrint "$(CannotConnectToDatabase)"
	${EndIf}

	;after editing file - permissions need to be explicitly set.
	DetailPrint "$(ApplyConfigWindowsPermissions) and $sitenamePool"
	AccessControl::GrantOnFile "$INSTDIR\$sector\${configurationfile}" "$accessright" "FullAccess"
	;we noticed at St.Cloud that the previous function didn't always "stick" - this seemed to help ensure
	;that we at least had access to our web.config file
	nsExec::ExecToLog `$SYSDIR\icacls.exe "$INSTDIR\$sector\${configurationfile}" /grant "IIS AppPool\$sitenamePool":F`
	;In some cases IIS did not grant the application privledge to read the necessary machine.config file.
	${If} ${RunningX64}
		nsExec::ExecToLog `$SYSDIR\icacls.exe "$WINDIR\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config" /grant "IIS AppPool\$sitenamePool":F`
	${Else}
		nsExec::ExecToLog `$SYSDIR\icacls.exe "$WINDIR\Microsoft.NET\Framework\v4.0.30319\Config\machine.config" /grant "IIS AppPool\$sitenamePool":F`
	${EndIf}
	DetailPrint "$(ApplyLogFileWindowsPermissions)"
	AccessControl::GrantOnFile "$INSTDIR\$sector\logs" "$accessright" "FullAccess"
	nsExec::ExecToLog `$SYSDIR\icacls.exe "$INSTDIR\$sector\logs" /grant "IIS AppPool\$sitenamePool":(OI)(CI)F`
	
	;19. START THE SITE
	nsExec::ExecToLog  `${appcmd} start site /site.name:"$sitename"` $0
	
	;20. ADD THREADPOOL IDENTITY TO CONTROL OF INSTALL DIRECTORY
	/*
	http://support.microsoft.com/default.aspx?scid=kb;EN-US;Q243330
	http://nsis.sourceforge.net/AccessControl_plug-in
	(We might not need the ANONYMOUS LOGON)
	*/
	DetailPrint "$(ApplyFolderWindowsPermissions)"
	AccessControl::GrantOnFile $INSTDIR "$accessright" "FullAccess"
	AccessControl::GrantOnFile $INSTDIR "NT AUTHORITY\ANONYMOUS LOGON" "FullAccess" ;required for IIS 
	
	;21. Update setup.ini with hostname
	DetailPrint "$(AutoconfigureSite)"
	ReadINIStr $R0 "$EXEDIR\${SetupIni}" "AuditHost" "Host"
	${If} $R0 == ""
		${RemoveReadOnlyAttribute} "$EXEDIR\${SetupIni}"
		ReadINIStr $R1 "$EXEDIR\${SetupIni}" "AuditHost" "ResolveBy"
		${If} $R1 == ""
			StrCpy $R1 7
		${EndIf}
		DetailPrint "$(ResolutionMethod) [$R1]."
		!insertmacro GetMachineName $R1 $0
		WriteINIStr "$EXEDIR\${SetupIni}" "AuditHost" "Host" $0
		DetailPrint "$(UpdatedSite)[$0]" 
	${EndIf}
	ReadINIStr $R0 "$EXEDIR\${SetupIni}" "AuditHost" "Host"
	DetailPrint "$(SiteReady) $protocol://$R0:$siteport/$sector/" 
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
	/*This will restore IIS to state it was before installation might want
	to prompt to skip or not*/
	DetailPrint "$(RestoringBackup)"
	DetailPrint "To restore the settings before you ran the installation run the following:"
	DetailPrint "${appcmd} restore backup ${backupfile}"
	;nsExec::ExecToLog  "${appcmd} restore backup ${backupfile}" $0
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
