@REM This script is used to build the update application and create delta patch binary. The delta patch is generated and copied to the delta_dfu/binaries/patches folder for update.

@REM Build the application
west build -p -b nrf54l15dk/nrf54l15/cpuapp -d build_54l_2 -- -DFILE_SUFFIX=delta -DCONFIG_MCUBOOT_IMGTOOL_SIGN_VERSION=\"2.0.2+2\"
@REM Backup original hex file
copy build_54l_2\merged.hex delta_2022.hex
:: Check if the %ZEPHYR% environment variable is defined
if not defined ZEPHYR_BASE (
    echo %ZEPHYR_BASE% is not set, setting it to a relative path...
    set "ZEPHYR_BASE_REL=%CD%"
    set "ZEPHYR_BASE=%CD%..\..\..\zephyr"
)
:: Use for to get the absolute path
::for %%I in ("%ZEPHYR_BASE_REL%") do (
::    set "ZEPHYR_BASE=%%~fI"
::)

echo "%ZEPHYR_BASE%" current value: %ZEPHYR_BASE%

@REM Generate signed binary image from hex for later delta patch generation
arm-zephyr-eabi-objcopy --input-target=ihex --output-target=binary --gap-fill=0xff build_54l_2\keyboard_delta\zephyr\zephyr.signed.hex binaries\signed_images\target_2022.bin

@REM Check if patches directory exists, if not create it
setlocal
:: Define the directory want to create
set "dir=%ZEPHYR_BASE%\nrf\samples\bluetooth\keyboard_delta\binaries\patches"
:: Check if the directory exists
if not exist "%dir%" (
    :: Create the directory and its parent directories
    mkdir "%dir%"
)
endlocal

@REM Generate delta patch binary with patch_with_arg.py script
python scripts\patch_with_arg.py -d build_54l_2

PAUSE