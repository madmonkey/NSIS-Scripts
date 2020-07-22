; NSIS (Damn small install)
; Mutilated script from dozens of developers
; Mobile One - because installs shouldn't suck!

; Maximum compression
SetCompressor /SOLID lzma
;--------------------------------
;Include(s) 

	!include "Shared\UninstallLog.nsh"
	!include "Shared\LogicLib.nsh"
	!include "Shared\DotNetSearch.nsh"
	!include "Shared\DotNetVer.nsh"
	!include "Shared\TextReplace.nsh"
	
	!define MULTIUSER_EXECUTIONLEVEL Highest
	!define MULTIUSER_MUI
	!define MULTIUSER_INSTALLMODE_COMMANDLINE
	
	!include "Shared\MultiUser.nsh"
	!include "Shared\MUI2.nsh"

;--------------------------------
#http://nsis.sourceforge.net/Uninstall_only_installed_files
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
	;Set the name of the ini file
	!define setupini "setup.ini"
    Var UninstLog
	;Uninstall log file missing.
	;--------------------------------
	;Interface Settings
	!define MUI_ABORTWARNING
	;--------------------------------
	;Pages
	#!insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt"
	#!insertmacro MUI_PAGE_COMPONENTS
	!insertmacro MULTIUSER_PAGE_INSTALLMODE
	!insertmacro MUI_PAGE_DIRECTORY
	!insertmacro MUI_PAGE_INSTFILES
	!insertmacro MUI_UNPAGE_CONFIRM
	!insertmacro MUI_UNPAGE_INSTFILES  
	;--------------------------------
	;Languages 
	!insertmacro MUI_LANGUAGE "English"


	LangString UninstLogMissing ${LANG_ENGLISH} "${UninstLog} not found!$\r$\nUninstallation cannot proceed!"
	;setup.ini file missing.
	LangString SetupIniMissing ${LANG_ENGLISH} "${setupini} not found!$\r$\nInstallation cannot proceed!"
	LangString ApplyConfigWindowsPermissions ${LANG_ENGLISH} "Applying permissions to configuration file for all users."
	LangString SettingRegistry ${LANG_ENGLISH} "Setting registry for $MultiUser.InstallMode."
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
	!define setup "setup.exe"
	!define releasedir "client\release\"
	!define uninstaller "uninstall.exe"
	; change this to wherever the files to be packaged reside
	#!define srcdir "C:\TFS\GimmieGimmies\Development\MobileOne\Application\SunGardPS.ClientApp\bin\Release\"
	!define srcdir "..\Application\SunGardPS.ClientApp\bin\Release\"
	!define scriptdir "..\InstallScripts\"
	!define sharedir "..\InstallScripts\shared\"
	!define mydir "..\InstallScripts\client\"
	!define company "SunGard Public Sector"
	!define companypathname "SunGardPublicSector"
	!define prodname "MobileOne"
	!define prodpathname "MobileOne"
	!define exec "SunGardPS.ClientApp.exe"
	!define layoutdir "Layout\"
	!define modulesdir "Modules\"
	!define componentsdir "${modulesdir}Components\"
	!define accidentdir "${modulesdir}Accident\"
	!define incidentdir "${modulesdir}Incident\"
	!define interviewdir "${modulesdir}FieldInterview\"
	!define citationdir "${modulesdir}Citation\"
	!define arrestdir "${modulesdir}Arrest\"
	!define radardir "${modulesdir}RadarLog\"
	!define managerdir "${modulesdir}Manager\"
	!define securitydir "${modulesdir}Security\"
	!define resourcesdir "Resources\"
	!define themesdir "Themes\"
	!define logsdir "Logs\"
	!define uninstalldir "$INSTDIR\uninstall\"
	!define dotnetruntimedir "\DotNet40Runtime\"
	!define dotnetruntimefile "dotNetFx40_Full_x86_x64.exe"
	
	!define productversion "7.0.0.8"
	!define setupversion "7.0.0.8"
	
	VIProductVersion "${productversion}" ;could be read from a resource or whatever...	
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${prodname}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "Comments" ""
	VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "${prodname} Application is a trademark of ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© ${company}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "Composite application framework..."
	VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${setupversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${productversion}"
	VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "Raptor"

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
	!define regroot "SHCTX"
	!define regkey "Software\${company}\${prodpathname}"
	!define uninstkey "Software\Microsoft\Windows\CurrentVersion\Uninstall\${prodpathname}"
	 
	!define startmenu "$SMPROGRAMS\${company}\${prodpathname}"

	;Name and file
	Name "${company} - ${prodname}"
	OutFile "${releasedir}${setup}"
	BrandingText "${company}"
	;Default installation folder
	;InstallDir "$LOCALAPPDATA\${companypathname}\${prodpathname}"
	
	;Get installation folder from registry if available
	;InstallDirRegKey "${regroot}""${regkey}" ""
	;Request application privileges for Windows Vista
	RequestExecutionLevel user	

  
Function .onInit
	SetOutPath "$EXEDIR"
	File "${sharedir}dotNetFx40_Full_setup.exe"
	Strcpy $1 $EXEDIR${dotnetruntimedir}${dotnetruntimefile} 
	IfFileExists $EXEDIR${dotnetruntimedir}${dotnetruntimefile} Install
	Strcpy $1 "dotNetFx40_Full_setup.exe"
Install:
	!insertmacro DotNetSearch 4 0 30319 "INSTALL_ABORT" "$1"
	Delete "$EXEDIR\dotNetFx40_Full_setup.exe"
	!insertmacro MULTIUSER_INIT
	
	${If} $MultiUser.InstallMode == "AllUsers"		
		StrCpy $INSTDIR "$PROGRAMFILES\${company}\${prodpathname}"	
	${Else}
		StrCpy $INSTDIR "$LOCALAPPDATA\${company}\${prodpathname}"	
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

  IfFileExists "$EXEDIR\${SetupIni}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(SetupIniMissing)"
      Abort

	#Define basic folder layout
	${AddItem} "$INSTDIR"
	${AddItem} "$INSTDIR\${layoutdir}"
	${AddItem} "$INSTDIR\${modulesdir}"
	${AddItem} "$INSTDIR\${resourcesdir}"
	${AddItem} "$INSTDIR\${themesdir}"
	;Create uninstaller
	${SetOutPath} "${uninstalldir}"
	${WriteUninstaller} "${uninstalldir}Uninstall.exe"
	#Main Files
	${SetOutPath} "$INSTDIR"
	${File} "${srcdir}""${exec}"
	${File} "${mydir}""SunGardPS.ClientApp.exe.config"
	${File} "${srcdir}""InfragisticsWPF4.DataPresenter.v12.1.dll"
	${File} "${srcdir}""InfragisticsWPF4.Editors.v12.1.dll"
	${File} "${srcdir}""InfragisticsWPF4.Ribbon.v12.1.dll"
	${File} "${srcdir}""InfragisticsWPF4.v12.1.dll"
	${File} "${srcdir}""log4net.dll"
	${File} "${srcdir}""Microsoft.Expression.Interactions.dll"
	${File} "${srcdir}""Microsoft.Practices.Prism.dll"
	${File} "${srcdir}""Microsoft.Practices.Prism.Interactivity.dll"
	${File} "${srcdir}""Microsoft.Practices.Prism.UnityExtensions.dll"
	${File} "${srcdir}""Microsoft.Practices.ServiceLocation.dll"
	${File} "${srcdir}""Microsoft.Practices.Unity.Configuration.dll"
	${File} "${srcdir}""Microsoft.Practices.Unity.dll"
	${File} "${srcdir}""Microsoft.VisualBasic.dll"	
	${File} "${srcdir}""PostSharp.dll"
	${File} "${srcdir}""SLF.dll"
	${File} "${srcdir}""SLF.Log4netFacade.dll"
	${File} "${srcdir}""SunGardPS.Common.Authentication.dll"
	${File} "${srcdir}""SunGardPS.Common.Core.dll"
	${File} "${srcdir}""SunGardPS.Common.DataService.dll"
	${File} "${srcdir}""SunGardPS.Common.Interfaces.dll"
	${File} "${srcdir}""SunGardPS.Common.Resources.dll"
	${File} "${srcdir}""SunGardPS.Common.Security.dll"
	${File} "${srcdir}""SunGardPS.Common.UserControlBehaviors.dll"
	${File} "${srcdir}""SunGardPS.Communication.FieldReporting.Contracts.dll"
	${File} "${srcdir}""SunGardPS.FieldReporting.ModuleServices.dll"
	${File} "${srcdir}""SunGardPS.FieldReporting.Resources.dll"
	${File} "${srcdir}""System.CoreEx.dll"
	${File} "${srcdir}""System.Reactive.dll"
	${File} "${srcdir}""System.Windows.Controls.Input.Toolkit.dll"
	${File} "${srcdir}""System.Windows.Interactivity.dll"	
	${File} "${sharedir}""SvcConfigEditor.chm"
	${File} "${sharedir}""SvcConfigEditor.exe"
	${File} "${sharedir}""SvcConfigEditor.exe.config"
	${File} "${srcdir}""WPFToolkit.dll"	
	${File} "${srcdir}""Kjs.AppLife.Update.Controller.dll"
	${File} "${srcdir}""AutoMapper.dll"
	${File} "${srcdir}""SunGardPS.MobileOne.Contracts.dll"
	${File} "${srcdir}""SunGardPS.MobileOne.Resources.dll"
	#Layout
	${SetOutPath} "$INSTDIR\${layoutdir}"
	${File} "${srcdir}${layoutdir}""Layout.xaml"
	#Modules
	#Modules::Components
	${AddItem} "$INSTDIR\${componentsdir}"
	${SetOutPath} "$INSTDIR\${componentsdir}"
	${File} "${srcdir}${componentsdir}""SunGardPS.Common.Components.dll"
	#Modules::Accident
	${AddItem} "$INSTDIR\${accidentdir}"
	${SetOutPath} "$INSTDIR\${accidentdir}"
	${File} "${srcdir}${accidentdir}""SunGardPS.FieldReporting.Module.Accident.dll"
	#Modules::Incident
	${AddItem} "$INSTDIR\${incidentdir}"
	${SetOutPath} "$INSTDIR\${incidentdir}"
	${File} "${srcdir}${incidentdir}""SunGardPS.FieldReporting.Module.Incident.dll"
	#Modules::FieldInterview
	${AddItem} "$INSTDIR\${interviewdir}"
	${SetOutPath} "$INSTDIR\${interviewdir}"
	${File} "${srcdir}${interviewdir}""SunGardPS.FieldReporting.Module.FieldInterview.dll"
	#Modules::Citation
	${AddItem} "$INSTDIR\${citationdir}"
	${SetOutPath} "$INSTDIR\${citationdir}"
	${File} "${srcdir}${citationdir}""SunGardPS.FieldReporting.Module.Citation.dll"
	#Modules::Arrest
	${AddItem} "$INSTDIR\${arrestdir}"
	${SetOutPath} "$INSTDIR\${arrestdir}"
	${File} "${srcdir}${arrestdir}""SunGardPS.FieldReporting.Module.Arrest.dll"
	#Modules::RadarLog
	${AddItem} "$INSTDIR\${radardir}"
	${SetOutPath} "$INSTDIR\${radardir}"
	${File} "${srcdir}${radardir}""SunGardPS.FieldReporting.Module.RadarLog.dll"
	#Modules::Security
	${AddItem} "$INSTDIR\${securitydir}"
	${SetOutPath} "$INSTDIR\${securitydir}"
	${File} "${srcdir}${securitydir}""SunGardPS.MobileOne.Module.Security.dll"	
	#Modules::ReportManager
	${AddItem} "$INSTDIR\${managerdir}"
	${SetOutPath} "$INSTDIR\${managerdir}"
	${File} "${srcdir}${managerdir}""SunGardPS.FieldReporting.Messaging.dll"
	${File} "${srcdir}${managerdir}""SunGardPS.FieldReporting.Module.Manager.dll"
	${File} "${srcdir}${managerdir}""SunGardPS.FieldReporting.Persistence.dll"
	${File} "${srcdir}${managerdir}""Apollo.Provider.dll"
	${File} "${srcdir}${managerdir}""SDE7.dll"
	${File} "${srcdir}${managerdir}""SDECDX7.dll"
	;${File} "${srcdir}${managerdir}""c4dll.dll"
	;${File} "${srcdir}${managerdir}""zlib.dll"
	;${File} "${srcdir}${managerdir}""CodeBaseNetFxWrapper.dll"
	#Resources
	${AddItem} "$INSTDIR\${resourcesdir}"
	${SetOutPath} "$INSTDIR\${resourcesdir}"	
	${File} "${srcdir}${resourcesdir}""AboutLogo.png"
	${File} "${srcdir}${resourcesdir}""ApplicationsGroup.png"
	${File} "${srcdir}${resourcesdir}""Accident.png"
	${File} "${srcdir}${resourcesdir}""Arrest.png"
	${File} "${srcdir}${resourcesdir}""CaseNumber.png"
	${File} "${srcdir}${resourcesdir}""Central.png"
	${File} "${srcdir}${resourcesdir}""Citation.png"
	${File} "${srcdir}${resourcesdir}""Collapse.png"
	${File} "${srcdir}${resourcesdir}""Configuration.png"
	${File} "${srcdir}${resourcesdir}""Copy.png"
	${File} "${srcdir}${resourcesdir}""Dashboard.png"
	${File} "${srcdir}${resourcesdir}""Delete.png"
	${File} "${srcdir}${resourcesdir}""Edit.png"
	${File} "${srcdir}${resourcesdir}""Exit.png"
	${File} "${srcdir}${resourcesdir}""Expand.png"
	${File} "${srcdir}${resourcesdir}""FieldInterview.png"
	${File} "${srcdir}${resourcesdir}""Find.png"
	${File} "${srcdir}${resourcesdir}""GeneralGroup.png"
	${File} "${srcdir}${resourcesdir}""GetAllMasters.png"
	${File} "${srcdir}${resourcesdir}""GetCopy.png"
	${File} "${srcdir}${resourcesdir}""GetMaster.png"
	${File} "${srcdir}${resourcesdir}""Help.png"
	${File} "${srcdir}${resourcesdir}""Home.png"
	${File} "${srcdir}${resourcesdir}""Inbox.png"
	${File} "${srcdir}${resourcesdir}""Incident.png"
	${File} "${srcdir}${resourcesdir}""Local.png"
	${File} "${srcdir}${resourcesdir}""MessageAll.png"
	${File} "${srcdir}${resourcesdir}""MessageAllSm.png"
	${File} "${srcdir}${resourcesdir}""MessageError.png"
	${File} "${srcdir}${resourcesdir}""MessageErrorSm.png"
	${File} "${srcdir}${resourcesdir}""MessageInformation.png"
	${File} "${srcdir}${resourcesdir}""MessageInformationSm.png"
	${File} "${srcdir}${resourcesdir}""MessageNew.png"
	${File} "${srcdir}${resourcesdir}""MessageRead.png"
	${File} "${srcdir}${resourcesdir}""MessageWarning.png"
	${File} "${srcdir}${resourcesdir}""MessageWarningSm.png"
	${File} "${srcdir}${resourcesdir}""MobileOne.ico"
	${File} "${srcdir}${resourcesdir}""MobileOne.png"
	${File} "${srcdir}${resourcesdir}""NetworkOff.png"
	${File} "${srcdir}${resourcesdir}""NetworkOn.png"
	${File} "${srcdir}${resourcesdir}""NotificationBegin.png"
	${File} "${srcdir}${resourcesdir}""NotificationDelete.png"
	${File} "${srcdir}${resourcesdir}""NotificationDeleteAll.png"
	${File} "${srcdir}${resourcesdir}""NotificationEnd.png"
	${File} "${srcdir}${resourcesdir}""NotificationNext.png"
	${File} "${srcdir}${resourcesdir}""NotificationPause.png"
	${File} "${srcdir}${resourcesdir}""NotificationPrevious.png"
	${File} "${srcdir}${resourcesdir}""NotificationStop.png"
	${File} "${srcdir}${resourcesdir}""Preferences.png"
	${File} "${srcdir}${resourcesdir}""RadarLog.png"
	${File} "${srcdir}${resourcesdir}""Refresh.png"
	${File} "${srcdir}${resourcesdir}""ReportManager.png"
	${File} "${srcdir}${resourcesdir}""ReportManagerGroup.png"
	${File} "${srcdir}${resourcesdir}""Reports.png"
	${File} "${srcdir}${resourcesdir}""RollCall.png"
	${File} "${srcdir}${resourcesdir}""Send.png"
	${File} "${srcdir}${resourcesdir}""User.png"
	${File} "${srcdir}${resourcesdir}""UserAccounts.png"
	${File} "${srcdir}${resourcesdir}""UserDelete.png"
	${File} "${srcdir}${resourcesdir}""UserNew.png"
	${File} "${srcdir}${resourcesdir}""UserPassword.png"
	${File} "${srcdir}${resourcesdir}""Users.png"
	${File} "${srcdir}${resourcesdir}""UserSearch.png"
	${File} "${srcdir}${resourcesdir}""UserUpdate.png"
	${File} "${srcdir}${resourcesdir}""View.png"
	${File} "${srcdir}${resourcesdir}""webupdater.png"
	#Log file
	${AddItem} "$INSTDIR\${logsdir}"
	${SetOutPath} "$INSTDIR\${logsdir}"
	${File} "${sharedir}""SvcTraceViewer.chm"
	${File} "${sharedir}""SvcTraceViewer.exe"
	${File} "${sharedir}""SvcTraceViewer.exe.config"
	#Themes
	
	#Themes::Aero
	${AddItem} "$INSTDIR\${themesdir}Aero"
	${SetOutPath} "$INSTDIR\${themesdir}Aero"
	${File} "${srcdir}${themesdir}Aero\""Theme.xaml"
	#Themes::Generic
	${AddItem} "$INSTDIR\${themesdir}Generic"
	${SetOutPath} "$INSTDIR\${themesdir}Generic"
	${File} "${srcdir}${themesdir}Generic\""Theme.xaml"
	#Themes::LunaNormal
	${AddItem} "$INSTDIR\${themesdir}LunaNormal"
	${SetOutPath} "$INSTDIR\${themesdir}LunaNormal"
	${File} "${srcdir}${themesdir}LunaNormal\""Theme.xaml"
	#Themes::LunaOlive
	${AddItem} "$INSTDIR\${themesdir}LunaOlive"
	${SetOutPath} "$INSTDIR\${themesdir}LunaOlive"
	${File} "${srcdir}${themesdir}LunaOlive\""Theme.xaml"
	#Themes::LunaSilver
	${AddItem} "$INSTDIR\${themesdir}LunaSilver"
	${SetOutPath} "$INSTDIR\${themesdir}LunaSilver"
	${File} "${srcdir}${themesdir}LunaSilver\""Theme.xaml"
	#Themes::Office2k7Black
	${AddItem} "$INSTDIR\${themesdir}Office2k7Black"
	${SetOutPath} "$INSTDIR\${themesdir}Office2k7Black"
	${File} "${srcdir}${themesdir}Office2k7Black\""Theme.xaml"
	#Themes::Office2k7Blue
	${AddItem} "$INSTDIR\${themesdir}Office2k7Blue"
	${SetOutPath} "$INSTDIR\${themesdir}Office2k7Blue"
	${File} "${srcdir}${themesdir}Office2k7Blue\""Theme.xaml"
	#Themes::Office2k7Silver
	${AddItem} "$INSTDIR\${themesdir}Office2k7Silver"
	${SetOutPath} "$INSTDIR\${themesdir}Office2k7Silver"
	${File} "${srcdir}${themesdir}Office2k7Silver\""Theme.xaml"
	#Themes::Onyx
	${AddItem} "$INSTDIR\${themesdir}Onyx"
	${SetOutPath} "$INSTDIR\${themesdir}Onyx"
	${File} "${srcdir}${themesdir}Onyx\""Theme.xaml"
	#Themes::Royale
	${AddItem} "$INSTDIR\${themesdir}Royale"
	${SetOutPath} "$INSTDIR\${themesdir}Royale"
	${File} "${srcdir}${themesdir}Royale\""Theme.xaml"
	#Themes::RoyaleStrong
	${AddItem} "$INSTDIR\${themesdir}RoyaleStrong"
	${SetOutPath} "$INSTDIR\${themesdir}RoyaleStrong"
	${File} "${srcdir}${themesdir}RoyaleStrong\""Theme.xaml"
	;MessageBox MB_OK '$0'
	;Replace tokens in app.config file
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "FieldReporting" "LocalData"
	${ReplaceToken} [LocalData] "$0" "$INSTDIR" "${exec}.config" 
	ReadINIStr $1 "$EXEDIR\${SetupIni}" "Site" "Port"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Site" "UseSSL"
	${If} $0 == "0"
		${ReplaceToken} [protocol] "http" "$INSTDIR" "${exec}.config"
		${ReplaceToken} [SecurityMode] "TransportCredentialOnly" "$INSTDIR" "${exec}.config"
		${If} $1 == ""
			StrCpy $1 "80"
		${EndIf}		
	${Else}
		${ReplaceToken} [protocol] "https" "$INSTDIR" "${exec}.config"
		${ReplaceToken} [SecurityMode] "Transport" "$INSTDIR" "${exec}.config"
		${If} $1 == ""
			StrCpy $1 "443"
		${EndIf}		
	${EndIf}	
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Site" "Host"
	${If} $0 == ""
		StrCpy $0 "HOSTUNSPECIFIED"
	${EndIf}
	StrCpy $0 "$0:$1"
	${ReplaceToken} [Host] "$0/" "$INSTDIR" "${exec}.config"
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Application" "Name"
	${If} $0 == "" 
		${ReplaceToken} [Name] "$0" "$INSTDIR" "${exec}.config"
	${Else}
		${ReplaceToken} [Name] "$0/" "$INSTDIR" "${exec}.config"
	${EndIf}
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Client" "Title"
	${ReplaceToken} [Title] "$0" "$INSTDIR" "${exec}.config"	
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Client" "HideUnusedApplications"
	${If} $0 == ""
		StrCpy $0 "False"
	${EndIf}
	${ReplaceToken} [HideUnusedApplications] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "FieldReporting" "CloneEnabled"
	${If} $0 == ""
		StrCpy $0 "False"
	${EndIf}
	${ReplaceToken} [CloneEnabled] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "FieldReporting" "MaxCacheSearch"
	${If} $0 == ""
		StrCpy $0 "100"
	${EndIf}
	${ReplaceToken} [MaxCacheSearch] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "FieldReporting" "MasterColor"
	${ReplaceToken} [MasterColor] "$0" "$INSTDIR" "${exec}.config"
	
	ReadINIStr $0 "$EXEDIR\${SetupIni}" "Authentication" "AuthMode"
	${ReplaceToken} [AuthMode] "$0" "$INSTDIR" "${exec}.config"
	${If} $0 == "UnauthenticatedPrincipal"
		StrCpy $0 "Basic"
	${EndIf}
	${If} $0 == "WindowsPrincipal"
		StrCpy $0 "Windows"
	${EndIf}
	${ReplaceToken} [CredentialType] "$0" "$INSTDIR" "${exec}.config"
	
	;Create start menu & desktop shortcuts
	${SetOutPath} "$INSTDIR"
	${CreateShortcut} "$DESKTOP\${prodpathname}.lnk" "$INSTDIR\${exec}" "" "" ""
	${CreateDirectory} "${startmenu}"
	${CreateShortcut} "${startmenu}\${prodpathname}.lnk" "$INSTDIR\${exec}" "" "" ""

	;after editing file - permissions need to be explicitly set.
	${If} $MultiUser.InstallMode == "AllUsers"
		DetailPrint "$(ApplyConfigWindowsPermissions)"
		;BECAUSE WE CONTINUE TO DO STUPID THINGS! THIS IS LAZY!
		AccessControl::GrantOnFile "$INSTDIR" "Users" "FullAccess"
		AccessControl::GrantOnRegKey "${regroot}" "${regkey}" "(BU)" "FullAccess"
		;THIS IS NOT LAZY
		AccessControl::GrantOnFile "$INSTDIR\SunGardPS.ClientApp.exe.config" "Users" "FullAccess"
		;AccessControl::GrantOnFile "$INSTDIR\${logsdir}" "Users" "FullAccess"
	${EndIf}
	
	DetailPrint "$(SettingRegistry)"
	;Store installation folder
	${WriteRegStr} "${regroot}" "${regkey}" "" $INSTDIR
    ;Write the Uninstall information into the registry
    ${WriteRegStr} "${regroot}" "${regkey}" "UninstallString" "$INSTDIR\uninstall\Uninstall.exe"
	
	IfFileExists "$EXEDIR\webupdater\webupdatersetup.exe" InstallWU SkipWU
	InstallWU:
		IfFileExists "$EXEDIR\Webupdater\webupdatersetup.ini" ContinueWU SkipWU
	ContinueWU:
		DetailPrint "Installing WebUpdater instance..."
		nsExec::ExecToLog '"$EXEDIR\Webupdater\webupdatersetup.exe" /S -INSTDIR="$INSTDIR"' $0
		Pop $0
		StrCmp $0 "0" EndWU ErrorWU		
	SkipWU:
		DetailPrint "Missing either webupdater setup or ini file - skipping the installation"
		Goto EndWU
	ErrorWU:
		DetailPrint "WebUpdater setup failed. Please check ini settings."
		MessageBox MB_ICONEXCLAMATION "WebUpdater setup failed. Please check ini settings. This client currently cannot receive updates."
	EndWU:	
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
;Uninstaller Section

/*Section "Uninstall"

  ;ADD YOUR OWN FILES HERE...
	File "${srcdir}${exec}"
	File "${srcdir}SunGardPS.ClientApp.exe.config"
	File "${srcdir}Infragistics3.Wpf.Editors.v9.1.dll"
	File "${srcdir}Infragistics3.Wpf.Ribbon.v9.1.dll"
	File "${srcdir}Infragistics3.Wpf.v9.1.dll"
	File "${srcdir}Microsoft.Practices.Composite.dll"
	File "${srcdir}Microsoft.Practices.Composite.Presentation.dll"
	File "${srcdir}Microsoft.Practices.Composite.UnityExtensions.dll"
	File "${srcdir}Microsoft.Practices.ServiceLocation.dll"
	File "${srcdir}Microsoft.Practices.Unity.Configuration.dll"
	File "${srcdir}Microsoft.Practices.Unity.dll"
	File "${srcdir}Microsoft.VisualBasic.dll"
	File "${srcdir}SLF.dll"
	File "${srcdir}SunGardPS.Common.Authentication.dll"
	File "${srcdir}SunGardPS.Common.Core.dll"
	File "${srcdir}SunGardPS.Common.DataService.dll"
	File "${srcdir}SunGardPS.Common.Interfaces.dll"
	File "${srcdir}SunGardPS.Common.UserControlBehaviors.dll"
	File "${srcdir}SunGardPS.Communication.Contracts.dll"
	File "${srcdir}SunGardPS.FieldReporting.ModuleServices.dll"
	File "${srcdir}WPFToolkit.dll"
  Delete "$INSTDIR\Uninstall.exe"

  RMDir "$INSTDIR"

  DeleteRegKey /ifempty HKCU "${regkey}"

SectionEnd
*/
;--------------------------------
; Uninstaller
;--------------------------------
Section Uninstall
  ;Can't uninstall if uninstall log is missing!
  IfFileExists "$INSTDIR\${UninstLog}" +3
    MessageBox MB_OK|MB_ICONSTOP "$(UninstLogMissing)"
      Abort

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
  IfFileExists "$INSTDIR\webupdateruninstall.exe" UninstallWU SkipWU
	UninstallWU:
			IfFileExists "$INSTDIR\webupdateruninstall.log" ContinueWU SkipWU
	ContinueWU:
			nsExec::ExecToLog '"$INSTDIR\webupdateruninstall.exe" /S' $0
			Goto EndWU
	SkipWU:
		DetailPrint "Missing either webupdateruninstall or Uninstall log file - skipping the uninstallation"
	EndWU:	
  ;Remove registry keys
    ;DeleteRegKey ${REG_ROOT} "${REG_APP_PATH}"
    ;DeleteRegKey ${REG_ROOT} "${UNINSTALL_PATH}"
SectionEnd