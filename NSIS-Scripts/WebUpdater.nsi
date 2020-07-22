	; Maximum compression
	SetCompressor /SOLID lzma
	
	!include "Shared\UninstallLog.nsh"
	!include "Shared\DotNetSearch.nsh"
	!include "Shared\DotNetVer.nsh"
	!include "Shared\TextReplace.nsh"
	!include "FileFunc.nsh"
	!include "Shared\x64.nsh"
	
	!define MULTIUSER_EXECUTIONLEVEL Highest
	!define MULTIUSER_MUI
	!define MULTIUSER_INSTALLMODE_COMMANDLINE
	
	
	!include "Shared\MultiUser.nsh"
	!include "Shared\MUI2.nsh"
	
	;Set the name of the uninstall log
    !define UninstLog "webupdateruninstall.log"
	;Set the name of the ini file
	;!define setupini "webupdatersetup.ini"
	!define setup "webupdatersetup.exe"
    Var UninstLog
	Var SetupIni
	Var NoExe
	;Uninstall log file missing.
	;--------------------------------
	;Interface Settings
	!define MUI_ABORTWARNING
	;--------------------------------
	;Pages
	;!insertmacro MULTIUSER_PAGE_INSTALLMODE
	;!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES  
	;--------------------------------
	;Languages 
	!insertmacro MUI_LANGUAGE "English"
	LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\n$\r$\nUninstallation cannot proceed!"
	;setup.ini file missing.
	LangString SetupIniMissing ${LANG_ENGLISH} "The $SetupIni not found!$\r$\n$\r$\nInstallation cannot proceed!"
	LangString InstallationPathMissing ${LANG_ENGLISH} `Missing a required parameter -INSTDIR or -APPEXE $\r$\n$\r$\nInstallation will not proceed without an install path!$\r$\n$\r$\n Usage example:$\r$\n ${setup} -INSTDIR="C:\Program Files\MyApp" $\r$\n ${setup} -APPEXE="C:\Program Files\MyApp\MyApp.exe"`
	LangString SettingsMissing ${LANG_ENGLISH} "is not specified in the $SetupIni file."
		
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
	
	;General
	
	!define releasedir "webupdater\release\"
	!define uninstaller "webupdateruninstall.exe"
	; change this to wherever the files to be packaged reside
	#!define srcdir "C:\TFS\Raptor\Dev\Shared\WebUpdater\Updater\SunGardPS.WebUpdater\bin\Release\"
	!define srcdir "..\Shared\WebUpdater\Updater\SunGardPS.WebUpdater\bin\Release\"
	!define installerdir "..\Shared\WebUpdater\ServiceInstaller\"
	!define scriptdir "..\InstallScripts\"
	!define sharedir "..\InstallScripts\shared\"
	!define mydir "..\InstallScripts\WebUpdater\"
	!define company "SunGard Public Sector"
	!define companypathname "SunGardPublicSector"
	!define prodname "WebUpdater"
	!define prodpathname "WebUpdater"
	!define exec "SunGardPS.WebUpdater.exe"
	!define uninstalldir "$INSTDIR\uninstall\"
	!define dotnetruntimedir "\DotNet40Runtime\"
	!define dotnetruntimefile "dotNetFx40_Full_x86_x64.exe"
	
	!define productversion "1.0.0.10"
	!define setupversion "1.0.0.10"
	
	Var appid
	Var modulus
	Var exponent
	Var serviceinstall
	Var appcmd
	Var displayname
	Var instanceguid
	Var version
	Var publickey
	Var siteport
	Var separator
	Var upgradeguid
	Var packageguid
	Var hivekey
		
	VIProductVersion "${productversion}" ;could be read from a resource or whatever...	
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${prodname}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" ""
	VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${prodname} Application is a trademark of ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Remote Updater"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${setupversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${productversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "MobileFlashKiller - HTE Everywhere - Fleet Management - DOT is sooo tired"

	LangString ApplyConfigWindowsPermissions ${LANG_ENGLISH} "Applying permissions to configuration file for all users."
	LangString SettingRegistry ${LANG_ENGLISH} "Setting registry."
	
	/*
	; optional stuff
	 
	; text file to open in notepad after installation
	; !define notefile "README.txt"
	 
	; license text file
	; !define licensefile license.txt
	 
	; icons must be Microsoft .ICO files
	; !define icon "icon.ico"
	 
	; installer background screen
	; !define screenimage background.bmp
	 
	; file containing list of file-installation commands
	; !define files "files.nsi"
	 
	; file containing list of file-uninstall commands
	; !define unfiles "unfiles.nsi"
	*/
	; registry stuff
	;!define regroot "SHCTX"
	!define regroot "HKLM"
	;!define regkey "Software\${company}\${prodpathname}"
	!define regkey "Software\KineticJump\AppLifeUpdate\ServiceKeys\$upgradeguid"
	!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${prodpathname}"
	 
	!define startmenu "$SMPROGRAMS\${company}\${prodpathname}"

	;Name and file
	Name "${company} - ${prodname}"
	OutFile "${releasedir}${setup}"
	BrandingText "${company}"
	RequestExecutionLevel admin	

 Function un.StrTok
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
Function .onInit
	SetOutPath "$EXEDIR"
	SetShellVarContext all
	File "${sharedir}dotNetFx40_Full_setup.exe"
	Strcpy $1 $EXEDIR${dotnetruntimedir}${dotnetruntimefile} 
	IfFileExists $EXEDIR${dotnetruntimedir}${dotnetruntimefile} Install
	Strcpy $1 "dotNetFx40_Full_setup.exe"
Install:
	!insertmacro DotNetSearch 4 0 30319 "INSTALL_ABORT" "$1"
	Delete "$EXEDIR\dotNetFx40_Full_setup.exe"
	${GetParameters} $0
	;default the setup ini name
	StrCpy $SetupIni "webupdatersetup.ini"
	;otherwise known as the if Phil routine
	${GetOptions} $0 "-INI=" $1
	${If} $1 != ""
		StrCpy $SetupIni $1
	${EndIf}
	
	IfFileExists "$EXEDIR\$SetupIni" +3
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "$(SetupIniMissing)" /SD IDOK
		Quit
			
	${GetOptions} $0 "-INSTDIR=" $1
	${If} $1 != ""
		StrCpy $3 $1
	${EndIf}
	${GetOptions} $0 "-APPEXE="  $2
	${If} $1 == "" 
		${If} $2 != ""
			${GetParent} $2 $3 
		${EndIf}
	${EndIf}
		
	${If} $3 == ""
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "$(InstallationPathMissing)" /SD IDOK
		Quit		
	${EndIf}
	StrCpy $INSTDIR $3
	${GetOptions} $0 "-NOEXE=" $4
	StrCpy $NoExe ""
	${If} $4 == "TRUE"
		StrCpy $NoExe $4
	${EndIf}
	ReadINIStr $version "$EXEDIR\$SetupIni" "Client" "Version"
	${If} $version == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Version $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}
	ReadINIStr $appid "$EXEDIR\$SetupIni" "Client" "ApplicationId"
	${If} $appid == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Application Id $(SettingsMissing)" /SD IDOK
		Quit
	${EndIf}	
	ReadINIStr $modulus "$EXEDIR\$SetupIni" "Client" "Modulus"
	${If} $modulus == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Modulus $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}	
	ReadINIStr $exponent "$EXEDIR\$SetupIni" "Client" "Exponent"	
	${If} $exponent == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Exponent $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}		
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "Protocol"
	${If} $0 == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Updates Protocol $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}		
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "Host"
	${If} $0 == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Updates Host $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}		
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "UpdatePath"
	${If} $0 == "" 
		;IfSilent +2
		MessageBox MB_OK|MB_ICONSTOP "Updates Path $(SettingsMissing)" /SD IDOK
		Quit		
	${EndIf}	
	
FunctionEnd

Function un.onInit
	!insertmacro MULTIUSER_UNINIT
  
	ClearErrors
	EnumRegKey $0 HKCU "${regkey}" 0
	IfErrors end
		SetShellVarContext current
	end:  
FunctionEnd

Function PreCleanup
${If} ${RunningX64}
	StrCpy $hivekey "SOFTWARE\Wow6432Node\KineticJump\AppLifeUpdate\ServiceKeys"
${Else}
	StrCpy $hivekey "SOFTWARE\KineticJump\AppLifeUpdate\ServiceKeys"
${EndIf}

StrCpy $0 0
loop:
  EnumRegKey $1 HKLM $hivekey $0
  StrCmp $1 "" done
  ReadRegStr $2 HKLM "$hivekey\$1" "Path" 
  StrCmp $2 $INSTDIR\${exec} 0 nextkey
  DeleteRegKey HKLM "$hivekey\$1" 
  IntOp $0 $0 - 1
nextkey:  
  IntOp $0 $0 + 1
  GoTo loop
done:	
FunctionEnd

Function un.Cleanup
${If} ${RunningX64}
	StrCpy $hivekey "SOFTWARE\Wow6432Node\KineticJump\AppLifeUpdate\ServiceKeys"
${Else}
	StrCpy $hivekey "SOFTWARE\KineticJump\AppLifeUpdate\ServiceKeys"
${EndIf}

StrCpy $0 0
loop:
  EnumRegKey $1 HKLM $hivekey $0
  StrCmp $1 "" done
  ReadRegStr $2 HKLM "$hivekey\$1" "Path" 
  StrCmp $2 $INSTDIR\${exec} 0 nextkey
  DeleteRegKey HKLM "$hivekey\$1" 
  IntOp $0 $0 - 1
nextkey:  
  IntOp $0 $0 + 1
  GoTo loop
done:	
FunctionEnd

Section -openlogfile
    ${CreateDirectory} "${uninstalldir}"
    IfFileExists "${uninstalldir}\${UninstLog}" +3
      FileOpen $UninstLog "${uninstalldir}\${UninstLog}" w
    Goto +4
      SetFileAttributes "${uninstalldir}\${UninstLog}" NORMAL
      FileOpen $UninstLog "${uninstalldir}\${UninstLog}" a
      FileSeek $UninstLog 0 END
SectionEnd
  
;--------------------------------
;Installer Sections

Section "Main Section" MainSection

	#Define basic folder layout
	${AddItem} "$INSTDIR"
	
	;Create uninstaller
	${SetOutPath} "${uninstalldir}"
	${WriteUninstaller} "${uninstalldir}${uninstaller}"
	#Main Files
	${SetOutPath} "$INSTDIR"
	${File} "${mydir}""SunGardPS.WebUpdater.exe.config"
	${File} "${mydir}""WiRunSQL.vbs"
	${File} "${mydir}""WiSumInf.vbs"
	${File} "${mydir}""RegisterApplication.cmd"
	${If} ${RunningX64}
		StrCpy $serviceinstall "ServiceInstaller_x64.msi"
		${File} "${installerdir}" "ServiceInstaller_x64.msi"
	${Else}
		StrCpy $serviceinstall "ServiceInstaller_x86.msi"
		${File} "${installerdir}" "ServiceInstaller_x86.msi"
	${EndIf}
		
	;Replace tokens in app.config file
	;Client Settings
	;ReadINIStr $version "$EXEDIR\$SetupIni" "Client" "Version"
	${ReplaceToken} [version] "$version" "$INSTDIR" "${exec}.config"
	
	;ReadINIStr $appid "$EXEDIR\$SetupIni" "Client" "ApplicationId"
	${ReplaceToken} [appid] $appid "$INSTDIR" "${exec}.config"
	
	;ReadINIStr $modulus "$EXEDIR\$SetupIni" "Client" "Modulus"
	${ReplaceToken} [modulus] $modulus "$INSTDIR" "${exec}.config"
	
	;ReadINIStr $exponent "$EXEDIR\$SetupIni" "Client" "Exponent"
	${ReplaceToken} [exponent] $exponent "$INSTDIR" "${exec}.config"	
	
	ReadINIStr $displayname "$EXEDIR\$SetupIni" "Client" "DisplayName"
	${ReplaceToken} [displayname] "$displayname" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "IsTester"
	${If} $0 != "true"
		StrCpy $0 "false"
	${EndIf}
	${ReplaceToken} [tester] "$0" "$INSTDIR" "${exec}.config"
	
	;Updates Protocol and Port
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "Protocol"
	${If} $0 == "http"
		StrCpy $0 "http://"
		StrCpy $siteport ":80"
		StrCpy $separator "/"
	${EndIf}
	${If} $0 == "https"
		StrCpy $0 "https://"
		StrCpy $siteport ":443"
		StrCpy $separator "/"
	${EndIf}
	${If} $0 == "ftp"
		StrCpy $0 "ftp://"
		StrCpy $siteport ":21"
		StrCpy $separator "/"
	${EndIf}
	
	;read all protocols and defaulted the port - check to see if one specified
	ReadINIStr $1 "$EXEDIR\$SetupIni" "Updates" "Port"
	${If} $1 != ""
		StrCpy $siteport ":$1"
	${EndIf}
	
	${If} $0 == "file"
		StrCpy $0 ""
		StrCpy $separator "\"
		StrCpy $siteport ""
	${EndIf}
	
	${If} $0 == "unc"
		StrCpy $0 "\\"
		StrCpy $separator "\"
		StrCpy $siteport ""
	${EndIf}
	
	${ReplaceToken} [protocol] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "Host"
	${If} $0 == ""
		StrCpy $0 "HOSTUNSPECIFIED"
	${EndIf}	
	${ReplaceToken} [host] "$0$siteport$separator" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Updates" "UpdatePath"
	${ReplaceToken} [updatepath] "$0" "$INSTDIR" "${exec}.config"
	
	;R0 - Host, R1 - Port
	;0 - Enable reporting
	
	;Audit Reporting
	ReadINIStr $R0 "$EXEDIR\$SetupIni" "AuditHost" "Host"
	${If} $R0 == ""
		StrCpy $0 "false"		
	${Else}
		ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "EnableReporting"
		${If} $0 != "true"
			StrCpy $0 "false"
		${EndIf}		
	${EndIf}
	
	ReadINIStr $R1 "$EXEDIR\$SetupIni" "AuditHost" "Port"
	${If} $R1 == ""
		StrCpy $R1 "4401"
	${EndIf}	
	StrCpy $R0 "$R0:$R1"
	${ReplaceToken} [audithost] "$R0/" "$INSTDIR" "${exec}.config"
	${ReplaceToken} [enable] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "ControlledRollout"
	${If} $0 != "true"
			StrCpy $0 "false"
	${EndIf}
	${ReplaceToken} [controlledrollout] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "Timeout"
	${If} $0 == ""
			StrCpy $0 "00:00:05:00"
	${EndIf}
	${ReplaceToken} [timeout] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "AuditHost" "ApplicationName"
	${If} $0 == "" 
		${ReplaceToken} [Name] "$0" "$INSTDIR" "${exec}.config"
	${Else}
		${ReplaceToken} [Name] "$0/" "$INSTDIR" "${exec}.config"
	${EndIf}
	
	;single-to-multi-tenant database requirements 1.0.0.7
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "ProductCode"
	${ReplaceToken} [productcode] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "ProductDescription"
	${ReplaceToken} [productdescription] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "ClientCode"
	${ReplaceToken} [clientcode] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "ClientDescription"
	${ReplaceToken} [clientname] "$0" "$INSTDIR" "${exec}.config"
	;end single-to-multi-tenant database requirements 1.0.0.7
	
	;uninstall previous webupdater if there is 
	Call PreCleanup
	
	;understanding msi - http://blogs.msdn.com/b/pusu/archive/2009/06/10/understanding-msi.aspx
	;StrCpy $appcmd '$SYSDIR\cscript.exe "$INSTDIR\wirunsql.vbs" "$INSTDIR\$serviceinstall"'
	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0
	StrCpy $instanceguid $0	
	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0
	StrCpy $upgradeguid $0
	System::Call 'ole32::CoCreateGuid(g .s)'
	Pop $0
	StrCpy $packageguid $0

	;StrCpy $appcmd `"$INSTDIR\RegisterApplication.cmd" "$INSTDIR\$serviceinstall" "SunGardPS $displayname WebUpdater" "{$appid}" "$instanceguid" "$version" "$packageguid"`
	StrCpy $appcmd `"$INSTDIR\RegisterApplication.cmd" "$INSTDIR\$serviceinstall" "SunGardPS $displayname WebUpdater" "$instanceguid" "$upgradeguid" "$packageguid" "$version"`
	DetailPrint $appcmd
	nsExec::ExecToLog $appcmd $0
	StrCpy $publickey "<RSAKeyValue><Modulus>$modulus</Modulus><Exponent>$exponent</Exponent></RSAKeyValue>"
	StrCpy $appcmd `msiexec /i $serviceinstall /qn PATH="$INSTDIR\${exec}" PUBLICKEY="$publickey" TARGETDIR="$INSTDIR"`
	DetailPrint $appcmd
	nsExec::ExecToLog $appcmd $0
	;THIS IS AN UPGRADE INSTALL
	${If} $NoExe != "TRUE"
		${File} "${srcdir}""${exec}"
	${EndIf}
	Delete "$INSTDIR\RegisterApplication.cmd"
	Delete "$INSTDIR\WiRunSql.vbs"
	Delete "$INSTDIR\WiSumInf.vbs"
	;Delete "$INSTDIR\$serviceinstall"	
	Rename "$INSTDIR\$serviceinstall" "$INSTDIR\uninstall\$serviceinstall"
	
	StrCpy $appcmd "eventcreate /T INFORMATION /ID 101 /L APPLICATION /SO SunGardPS.WebUpdater /D Register"
	DetailPrint $appcmd
	nsExec::ExecToLog $appcmd $0

	;overwrite event log as needed to prevent event log full error
	WriteRegDWORD "${regroot}" "SYSTEM\CurrentControlSet\Services\Eventlog\Application" "Retention" 0
	
	;schedule tasks
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "Scheduler"
	${If} $0 != "" 
		StrCpy $appcmd '"$INSTDIR\SunGardPS.WebUpdater.exe" $0'
		DetailPrint $appcmd
		nsExec::ExecToLog $appcmd $0
		${WriteRegStr} "${regroot}" "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "$displayname" $appcmd
		DetailPrint 'Adding to ${regroot} - $displayname $appcmd'
		
		;permissions to add scheduled tasks
		AccessControl::GrantOnFile "$WINDIR\tasks" "Users" "FullAccess"
		
		;Write the name information into the registry
		DetailPrint "$(SettingRegistry)"
		;${WriteRegStr} "HKLM" "Software\KineticJump\AppLifeUpdate\ServiceKeys\$upgradeguid" "Name" "$displayname" 
		${WriteRegStr} "${regroot}" "${regkey}" "Name" "$displayname"		
	${EndIf}
	
	ReadINIStr $0 "$EXEDIR\$SetupIni" "Client" "RegRun"
	${If} $0 != "" 
		${If} $0 == "silent"
			StrCpy $appcmd '"$INSTDIR\SunGardPS.WebUpdater.exe" /s'
		${Else}
			StrCpy $appcmd '"$INSTDIR\SunGardPS.WebUpdater.exe"'
		${EndIf}
		DetailPrint $appcmd
		${WriteRegStr} "${regroot}" "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "$displaynameRegRun" $appcmd
	${Else}
		DeleteRegKey "${regroot}" "SOFTWARE\Microsoft\Windows\CurrentVersion\Run\$displaynameRegRun"
	${EndIf}
	
	${SetOutPath} "$AppData\SunGard Public Sector\WebUpdater"
	AccessControl::GrantOnFile "$AppData\SunGard Public Sector\WebUpdater" "(BU)" "FullAccess"

	/*
	DetailPrint $appcmd
	nsExec::ExecToLog  `$appcmd "UPDATE `Property` SET `Property`.`Value`='SunGardPS $displayname Updater' WHERE `Property`.`Property`='ProductName'"` $0
	DetailPrint `$appcmd "UPDATE `Property` SET `Property`.`Value`='$instanceguid' WHERE `Property`.`Property`='UpgradeCode'"`
	nsExec::ExecToLog  `$appcmd "UPDATE `Property` SET `Property`.`Value`='$instanceguid' WHERE `Property`.`Property`='UpgradeCode'"` $0
	DetailPrint `$appcmd "UPDATE `Property` SET `Property`.`Value`='$appcmd' WHERE `Property`.`Property`='ProductCode'"`
	nsExec::ExecToLog  `$appcmd "UPDATE `Property` SET `Property`.`Value`='$appcmd' WHERE `Property`.`Property`='ProductCode'"` $0
	DetailPrint `$appcmd "DELETE FROM `Upgrade` WHERE `Upgrade`.`ActionProperty`='NEWERPRODUCTFOUND'"`
	nsExec::ExecToLog  `$appcmd "DELETE FROM `Upgrade` WHERE `Upgrade`.`ActionProperty`='NEWERPRODUCTFOUND'"` $0
	DetailPrint `$appcmd "INSERT INTO `Upgrade` (`Upgrade`.`UpgradeCode`, `Upgrade`.`VersionMin`, `Upgrade`.`VersionMax`, `Upgrade`.`Language`, `Upgrade`.`Attributes`, `Upgrade`.`Remove`, `Upgrade`.`ActionProperty`) VALUES ('$instanceguid', '$version', '', '','258','','NEWERPRODUCTFOUND')"`
	nsExec::ExecToLog  `$appcmd "INSERT INTO `Upgrade` (`Upgrade`.`UpgradeCode`, `Upgrade`.`VersionMin`, `Upgrade`.`VersionMax`, `Upgrade`.`Language`, `Upgrade`.`Attributes`, `Upgrade`.`Remove`, `Upgrade`.`ActionProperty`) VALUES ('$instanceguid', '$version', '', '','258','','NEWERPRODUCTFOUND')"` $0
	*/
	/*
	cscript wirunsql.vbs ServiceInstaller.msi "UPDATE `Property` SET `Property`.`Value`='SunGardPS.MobileOne.Updater' WHERE `Property`.`Property`='ProductName'"
	cscript wirunsql.vbs ServiceInstaller.msi "UPDATE `Property` SET `Property`.`Value`='{12345678-1111-1111-1111-123456789012}' WHERE `Property`.`Property`='UpgradeCode'"
	cscript wirunsql.vbs ServiceInstaller.msi "UPDATE `Property` SET `Property`.`Value`='{12345678-2222-2222-2222-123456789012}' WHERE `Property`.`Property`='ProductCode'"
	cscript wirunsql.vbs ServiceInstaller.msi "DELETE FROM `Upgrade` WHERE `Upgrade`.`ActionProperty`='NEWERPRODUCTFOUND'"
	cscript wirunsql.vbs ServiceInstaller.msi "INSERT INTO `Upgrade` (`Upgrade`.`UpgradeCode`, `Upgrade`.`VersionMin`, `Upgrade`.`VersionMax`, `Upgrade`.`Language`, `Upgrade`.`Attributes`, `Upgrade`.`Remove`, `Upgrade`.`ActionProperty`) VALUES ('{12345678-1111-1111-1111-123456789012}', '1.0.0', '', '','258','','NEWERPRODUCTFOUND')"
	*/

	;after editing file - permissions need to be explicitly set.
	DetailPrint "$(ApplyConfigWindowsPermissions)"
	AccessControl::GrantOnFile "$INSTDIR\SunGardPS.WebUpdater.exe.config" "Users" "FullAccess"

SectionEnd

;--------------------------------
;Uninstaller Section
;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall

	${If} ${RunningX64}
		StrCpy $serviceinstall "ServiceInstaller_x64.msi"
	${Else}
		StrCpy $serviceinstall "ServiceInstaller_x86.msi"
	${EndIf}
	
	StrCpy $appcmd `msiexec /qn /x "$INSTDIR\$serviceinstall"`
	DetailPrint $appcmd
	nsExec::ExecToLog $appcmd $0
	
	${GetParent} "$INSTDIR" $R0	
	Rename "$INSTDIR\$serviceinstall" "$R0\$serviceinstall"
	
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
	;IfSilent +2
	MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)" /SD IDOK
	Quit	

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
    Goto KeepProcessing
    IfFileExists $R0 0 +3
      Delete $R0 #is file
    Goto KeepProcessing
	Push $R0
	Push " "
	Call un.strTok
	Pop $0
	Pop $1
	StrCmp $R0 "${regroot} $1" 0 KeepProcessing
      DeleteRegKey ${regroot} "$1" #is Reg Element
  KeepProcessing:  
    IntOp $R1 $R1 - 1
    Goto LoopRead
  LoopDone:
  FileClose $UninstLog
  Delete "$INSTDIR\${UninstLog}"
  Pop $R2
  Pop $R1
  Pop $R0
  ${GetParent} "$INSTDIR" $R0
  IfFileExists "$R0\${exec}" 0 RemoveRegEntries
	Delete "$R0\${exec}"
  RemoveRegEntries:
  StrCpy $INSTDIR $R0
  Call un.Cleanup
  
SectionEnd
