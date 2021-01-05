	@ECHO OFF

	TITLE Renderware File Converter Helper

	ECHO Renderware File Converter Helper
	ECHO Created by Daniel Santos

	ECHO.

	:LANGSET
	CALL:INI "english.lng" nofile nofilestr
	CALL:INI "english.lng" dffdetected dffdetectedstr
	CALL:INI "english.lng" txddetected txddetectedstr
	CALL:INI "english.lng" coldetected coldetectedstr
	CALL:INI "english.lng" selecttype selecttypestr
	CALL:INI "english.lng" dfffile dfffilestr
	CALL:INI "english.lng" txdfile txdfilestr
	CALL:INI "english.lng" filekind filekindstr
	CALL:INI "english.lng" typeplatform typeplatformstr
	CALL:INI "english.lng" typeoutput typeoutputstr
	CALL:INI "english.lng" plat platstr
	REM CALL:INI "english.lng" 
	REM CALL:INI "english.lng" 
	REM CALL:INI "english.lng" 
	REM CALL:INI "english.lng" 
	REM CALL:INI "english.lng" 

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


	ECHO Here are the models you want to convert:
	ECHO. 
	DIR /b Default

	IF %program%==convtxd GOTO TEXTUREC

	:MODELC
	ECHO.
	ECHO Choose the type of model you want to convert:
	ECHO.
	ECHO G - Generic Model
	ECHO M - Map Model
	ECHO P - Ped Model
	ECHO V - Vehicle Model
	ECHO.

	CHOICE /c GMPV /m "What kind of model are you converting?"

	IF %errorlevel%==1 (
	SET modeltype=Generic Model
	)
	IF %errorlevel%==2 (
	SET modeltype=Map Model
	SET model= --ps2sabuilding
	)
	IF %errorlevel%==3 (
	SET modeltype=Ped Model
	SET model= --ps2saped
	)
	IF %errorlevel%==4 (
	SET modeltype=Vehicle Model
	SET model= --ps2sacar
	CALL:COLCONVERT
	)

	ECHO.
	ECHO Model Type: %modeltype%

	ECHO.
	ECHO Choose the type of mesh that will be used in the models:
	ECHO.

	ECHO T - Tristrip Mesh
	ECHO [RECOMMENDED] Creates a mesh based on a series of connected triangles 
	ECHO sharing vertices, allowing more efficient use of memory.
	ECHO.

	ECHO D - Default Mesh
	ECHO Uses standard triangle mesh, recommended to use only if tristrip does not work.
	ECHO.


	CHOICE /c TD /m "What type of mesh do you want to use on the models?"
	ECHO.
	ECHO Conversion Properties:
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
	ECHO Conversion has finished, here are the converted files:
	ECHO. 
	DIR /b Converted
	ECHO.

	:PAUSE
	PAUSE

	:INI    
	FOR /f "tokens=2 delims==" %%a in ('find "%~2 = " "%~1"') do SET %~3=%%a    
	GOTO:eof

