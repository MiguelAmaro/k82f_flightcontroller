@echo off
if not exist build mkdir build

rem FILES
rem ************************************************************
set PROJECT_NAME=fc
set BOARD=MK82F25615
set SOURCES= F:\Dev\Embedded\FlightController_K82F\src\k82f_%PROJECT_NAME%.c
set OBJECTS= k82f_%PROJECT_NAME%.o ringbuffer.o startup_%BOARD%.o system_%BOARD%.o


rem TARGET
rem ************************************************************
rem set TARGET=arm-arm-none-eabi
set DFP=%BOARD%_DFP\12.2.0
set MFPU=fpv4-sp-d16
set ARCH=armv7-m


rem BUILD TOOLS
rem ************************************************************
set GCC=F:\Dev_Tools\ARMGNU\bin\arm-none-eabi-gcc.exe
set LD=F:\Dev_Tools\ARMGNU\bin\arm-none-eabi-ld.exe
set OBJDUMP=F:\Dev_Tools\ARMGNU\bin\arm-none-eabi-objdump.exe
rem READELF=F:\Dev_Tools\ARMGNU\bin\arm-none-eabi-readelf.exe

rem ************************************************************
rem COMPILER(ARMCLANG) OPTIONS
rem ************************************************************
set GCC_WARNINGS=^
-Wno-pedantic ^
-Wno-packed ^
-Wno-missing-prototypes ^
-Wno-strict-prototypes ^
-Wno-missing-noreturn ^
-Wno-sign-conversion ^
-Wno-unused-macros ^
-Wno-unused-parameter ^
-Wno-unused-variable ^
-Wno-shadow

set GCC_FLAGS=^
-c ^
-std=gnu11 ^
-O0 ^
-ggdb ^
-gdwarf-3 ^
-mfloat-abi=hard ^
-mthumb ^
-fno-common ^
-fno-builtin ^
-fshort-enums ^
-fshort-wchar ^
-ffreestanding ^
-fdata-sections ^
-funsigned-char ^
-ffunction-sections ^
%GCC_WARNINGS% ^
-MD

set GCC_MACROS=^
-D__EVAL ^
-D__MICROLIB ^
-D__UVISION_VERSION="531" ^
-D_RTE_ ^
-DCPU_MK82FN256VLL15 ^
-D_RTE_ ^
-DDEBUG ^
-DCPU_MK82FN256VLL15 ^
-DFRDM_K82F ^
-DFREEDOM ^
-DSERIAL_PORT_TYPE_UART="1"

set GCC_INCLUDE_DIRS=^
-I..\src\systems\MK82FN256VLL15 ^
-IC:\Users\mAmaro\AppData\Local\Arm\Packs\ARM\CMSIS\5.7.0\CMSIS\DSP\Include ^
-IC:\Users\mAmaro\AppData\Local\Arm\Packs\ARM\CMSIS\5.7.0\CMSIS\Core\Include ^
-IC:\Users\mAmaro\AppData\Local\Arm\Packs\ARM\CMSIS\5.7.0\CMSIS\DSP\PrivateInclude


rem ************************************************************
rem LINKER(LD) OPTIONS
rem ************************************************************
set MEMORY=^
--ro-base 0x00000000 ^
--entry 0x00000000 ^
--rw-base 0x1FFF8000 ^
--entry Reset_Handler ^
--first __Vectors

set LD_FLAGS=^
-T "F:\Dev\Embedded\FlightController_K82F\src\systems\MK82FN256VLL15\MK82FN256xxx15_flash.scf" ^
--keep=*(.FlashConfig) ^
--summary_stderr ^
--bestdebug ^
--remove ^
--map ^
--xref ^
--symbols ^
--callgraph ^
--info sizes ^
--info totals ^
--info unused ^
--info veneers ^
--info summarysizes ^
--load_addr_map_info ^
--list "..\debug\%PROJECT_NAME%.map"

set LIBRARIES=


rem ************************************************************
rem START BUILD
rem ************************************************************
set path="F:\Dev\Embedded\FlightController_K82F\build";path

pushd build

echo ==================        COMPILE         ==================
rem  ============================================================
call %GCC% -march=%ARCH% -mfpu=%MFPU% ^
-x c ^
%GCC_FLAGS% ^
%GCC_MACROS% ^
%GCC_INCLUDE_DIRS% ^
%SOURCES%

call %GCC% -march=%ARCH% -mfpu=%MFPU% ^
-x assembler-with-cpp ^
%GCC_FLAGS% ^
%GCC_MACROS% ^
%GCC_INCLUDE_DIRS% ^
..\src\systems\MK82FN256VLL15\startup_MK82F25615.S ^
-x c ^
..\src\systems\MK82FN256VLL15\system_%BOARD%.c

rem //~COMPILE OTHER SOURCE FILES
call %GCC% -march=%ARCH% -mfpu=%MFPU% ^
-x c ^
%GCC_FLAGS% ^
%GCC_MACROS% ^
%GCC_INCLUDE_DIRS% ^
..\src\RingBuffer.c


echo ==================         LINK           ==================
rem  ============================================================
call %LD% ^
%OBJECTS% %LD_FLAGS% ^
--library-path=%LIBRARIES% ^
-o .\k82f_%PROJECT_NAME%.axf

rem //~CONVERT OUTPUT TO BINARY
call C:\Keil_v5\ARM\\bin\fromelf.exe ^
--cpu=Cortex-M4 ^
--bincombined .\k82f_%PROJECT_NAME%.axf ^
--output=.\k82f_%PROJECT_NAME%.bin

call C:\Keil_v5\ARM\\bin\fromelf.exe --text -c *.o --output=./

rem //~CREATE CORRECT DEBUG INFO
rem F:\Dev_Tools\GNU_Arm_Embedded_Toolchain\bin\arm-none-eabi-objcopy.exe ^
rem k82f_%PROJECT_NAME%.axf ^
rem --update-section ER_RO=main.bin ^
rem --remove-section=ER_RW  main.gdb.elf

rem objdump -h(print sections) -t(print symbols)

popd

pause

