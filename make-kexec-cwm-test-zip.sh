#!/bin/bash

#
# This script takes your locally built Kernel/arch/arm/boot/zImage and
# stuffs it into boot_zImage.zip, ready for kexec boot from CWM.
# This allows rapid testing of your local kernel builds.
#
# Copyright 2012 Warren Togami <wtogami@gmail.com>
# License: BSD

# Abort on error
. include/functions
set -e

if [ ! -f ./Kernel/arch/arm/boot/zImage ]; then
  echo "ERROR: File not found: ./Kernel/arch/arm/boot/zImage"
  echo 
  echo "       Run build_kernel.sh first?"
  echo
  exit 255
fi
vcp ./Kernel/arch/arm/boot/zImage tools/kexec-cwm-test-zip/

if [ ! -f tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary ]; then
  if [ -f ../../../out/target/product/epicmtd/system/bin/updater ]; then
    vcp ../../../out/target/product/epicmtd/system/bin/updater tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary
  elif [ -f ../../../out/target/product/epicmtd/symbols/system/bin/updater ]; then
    # Check if unstripped updater is built (-userdebug), if so copy and strip it
    vcp ../../../out/target/product/epicmtd/symbols/system/bin/updater tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary
    find_toolchain
    echo $TCPATH/arm-eabi-strip tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary
    $TCPATH/arm-eabi-strip tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary
  else
    echo "ERROR: File not found: ../../../out/target/product/epicmtd/system/bin/updater"
    echo "                                             OR"
    echo "                       ../../../out/target/product/epicmtd/symbols/system/bin/updater"
    echo 
    echo "       You probably need to 'make bacon' in order to build it, or manually put a binary at"
    echo "       tools/kexec-cwm-test-zip/META-INF/com/google/android/update-binary"
    echo
    exit 255
  fi
fi

rm -f boot_zImage.zip
cd tools/kexec-cwm-test-zip/
zip -r ../../boot_zImage.zip *
cd - > /dev/null

echo
echo "SUCCESS: boot_zImage.zip complete."
echo 
echo "Suggested next steps to test your local kernel build..."
echo "    adb push boot_zImage.zip /sdcard/"
echo "    adb reboot recovery"
echo "Then fakeflash boot_zImage.zip in CWM."
echo
