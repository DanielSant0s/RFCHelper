	@ECHO OFF

	TITLE Renderware File Converter Helper

	ECHO Renderware File Converter Helper
	ECHO Created by Daniel Santos

	ECHO.
	ECHO E - English
	ECHO P - Portuguese
	ECHO.
	CHOICE /c EP /m "Choice you language: "
	ECHO.
	IF %errorlevel%==1 SET lang=.\lang\english.lng
	IF %errorlevel%==2 SET lang=.\lang\portuguese.lng

	:LANGSET
	CALL:INI "%lang%" nofile nofilestr
	CALL:INI "%lang%" dffdetected dffdetectedstr
	CALL:INI "%lang%" txddetected txddetectedstr
	CALL:INI "%lang%" coldetected coldetectedstr
	CALL:INI "%lang%" selecttype selecttypestr
	CALL:INI "%lang%" dfffile dfffilestr
	CALL:INI "%lang%" txdfile txdfilestr
	CALL:INI "%lang%" filekind filekindstr
	CALL:INI "%lang%" typeplatform typeplatformstr
	CALL:INI "%lang%" typeoutput typeoutputstr
	CALL:INI "%lang%" plat platstr
	CALL:INI "%lang%" filelist fileliststr
	CALL:INI "%lang%" cmodeltype cmodeltypestr
	CALL:INI "%lang%" genericmodel genericmodelstr
	CALL:INI "%lang%" mapmodel mapmodelstr
	CALL:INI "%lang%" pedmodel pedmodelstr
	CALL:INI "%lang%" vehiclemodel vehiclemodelstr
	CALL:INI "%lang%" modelkind modelkindstr
	CALL:INI "%lang%" smodeltype smodeltypestr
	CALL:INI "%lang%" cmeshtype cmeshtypestr
	CALL:INI "%lang%" tristrip tristripstr
	CALL:INI "%lang%" tripdesca tripdescastr
	CALL:INI "%lang%" tripdescb tripdescbstr 
	CALL:INI "%lang%" defmesh defmeshstr
	CALL:INI "%lang%" defdesc defdescstr 
	CALL:INI "%lang%" cmesh cmeshstr
	CALL:INI "%lang%" convprop convpropstr
	CALL:INI "%lang%" finconv finconvstr

	:INIT

	IF NOT EXIST .\Default\*.dff (
		IF NOT EXIST .\Default\*.txd (
		ECHO %nofilestr%
		ECHO.
		GOTO PAUSE
		)
	) ELSE (
		GOTO BREAK
		)


	:BREAK
	IF EXIST .\Default\*.dff ( 
		SET hasdff=D
		SET dff=M
	ECHO %dffdetectedstr%
	) ELSE (
		SET hasdff=N
	)
	IF EXIST .\Default\*.txd ( 
		SET hastxd=T
		SET txd=T
	ECHO %txddetectedstr%
	) ELSE (
		SET hastxd=N
	)

	:DETECT
	ECHO.
	IF hasdff==N ( 
	SET program=convtxd
	GOTO PROCESS
	)
	IF hastxd==N ( 
	SET program=convdff
	SET dffinst=-i
	GOTO PROCESS
	)

	:TYPESEL
	ECHO %selecttypestr%
	ECHO.
	IF %hasdff%==D (
	ECHO %dfffilestr%
	)
	IF %hastxd%==T ( 
	ECHO %txdfilestr%
	)
	ECHO.
	CHOICE /c %dff%%txd% /m "%filekindstr%"
	IF %errorlevel%==1 ( 
	SET program=convdff
	SET dffinst=-i
	)
	IF %errorlevel%==2 SET program=convtxd


	:PROCESS
	ECHO.
	ECHO %typeplatformstr%
	ECHO.
	ECHO P - PS2
	ECHO X - Xbox
	ECHO M - Mobile
	ECHO 8 - PC(III, VC)
	ECHO 9 - PC(SA)
	ECHO.
	CHOICE /c PXM89 /m "%typeoutputstr%"

	IF %errorlevel%==1 (
	SET platformname=PS2
	SET platform=ps2
	)
	IF %errorlevel%==2 (
	SET platformname=Xbox
	SET platform=xbox
	)
	IF %errorlevel%==3 (
	SET platformname=Mobile
	SET platform=mobile
	)
	IF %errorlevel%==4 (
	SET platformname=PC - III, VC
	SET platform=d3d8
	)
	IF %errorlevel%==5 (
	SET platformname=PC - SA
	SET platform=d3d9
	)
	ECHO.
	ECHO %platstr% %platformname%
	ECHO.


	ECHO %fileliststr%
	ECHO. 
	DIR /b Default

	IF %program%==convtxd GOTO TEXTUREC

	:MODELC
	ECHO.
	ECHO %cmodeltypestr%
	ECHO.
	ECHO %genericmodelstr%
	ECHO %mapmodelstr%
	ECHO %pedmodelstr%
	ECHO %vehiclemodelstr%
	ECHO.

	CHOICE /c GMPV /m "%modelkindstr%"

	IF %errorlevel%==1 (
	SET modeltype=%genericmodelstr%
	)
	IF %errorlevel%==2 (
	SET modeltype=%mapmodelstr%
	SET model= --ps2sabuilding
	)
	IF %errorlevel%==3 (
	SET modeltype=%pedmodelstr%
	SET model= --ps2saped
	)
	IF %errorlevel%==4 (
	SET modeltype=%vehiclemodelstr%
	SET model= --ps2sacar
	CALL:COLCONVERT
	)

	ECHO.
	ECHO %smodeltypestr% %modeltype%

	ECHO.
	ECHO %cmeshtypstr%
	ECHO.

	ECHO %tristripstr%
	ECHO %tripdescastr%
	ECHO %tripdescbstr%
	ECHO.
	ECHO %defmeshstr%
	ECHO %defdescstr%
	ECHO.


	CHOICE /c TD /m "%cmeshstr%"
	ECHO.
	ECHO %convpropstr%
	ECHO Platform: %platformname%
	ECHO Type: %modeltype%
	IF %ERRORLEVEL%==1 (
		SET meshtype=Tristrip 
		SET mesh= -w -s
	) else (
		SET meshtype=Default
		)
	ECHO Mesh: %meshtype%
	ECHO.

	:TEXTUREC

	IF %program%==convtxd GOTO CONVTXD


	:CONVDFF
	FOR /R .\Default\ %%G IN (*.dff) DO ( 
	convdff.exe %mesh% %dffinst% -o %platform% %model% .\Default\%%~nxG .\Converted\%%~nxG
	)
	GOTO END
	:CONVTXD
	FOR /R .\Default\ %%G IN (*.txd) DO ( 
	convtxd.exe -o %platform% .\Default\%%~nxG .\Converted\%%~nxG
	)

	:END
	ECHO %finconvstr%
	ECHO. 
	DIR /b Converted
	ECHO.

	:PAUSE
	PAUSE

	:INI    
	FOR /f "tokens=2 delims==" %%a in ('find "%~2 = " "%~1"') do SET %~3=%%a    
	GOTO:eof

