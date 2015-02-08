#!/bin/bash

# All in One script
echo "All in One script for building BraveKernel"
usage="Usage: ./BraveKernel.sh kumquat | nypon | pepper | lotus"

if [ ! -f "Makefile" ]; then
    echo "It's your first time, downloading all files that are needed"
    sleep 3
    ./repo init -u git://github.com/CyanogenMod/android -b cm-11.0
    ./repo sync -cq -j8
    clear
    echo "All files downloaded"
    sleep 2
else
    echo "Updating files"
    sleep 2
    git pull
    ./repo sync -cq -j8
    clear
    echo "All is updated"
    sleep 2
fi

rm -rf system/core/uncrypt

if [[ $# = 1 ]]; then
    if [ -d "out" ]; then dirty=yes
        clear
        echo "Cleaning out dir"
        sleep 2
        make clean
        make clobber
        rm -rf out
        clear
        echo "Cleanup done"
        sleep 2
    fi

    clear
    echo "Patching needed files"
    sleep 2
    cd device/sony/montblanc-common/patches
    ./patch.sh
    cd ../../../..
    clear
    echo "Patching has finished"
    sleep 2

    if [ ! "$BRAVEKERNEL" == cool ]; then
        clear
        echo "Setting some parameters"
        sleep 2
        export BRAVEKERNEL=cool
        export LD_LIBRARY_PATH=out/host/linux-x86/lib
        if (( $(java -version 2>&1 | grep version | cut -f2 -d".") > 6 )); then
            echo "Using local JDK 6..."
            export JAVA_HOME=$(realpath ../jdk1.6.0_45);
        fi
        clear
        echo "Everything is ready"
        sleep 1
    fi

    if [[ $? = 0 ]]; then
        . build/envsetup.sh
        clear
        echo "Building"
        sleep 2
        case $1 in
        kumquat)
          DEVICE=kumquat && lunch cm_kumquat-eng && make -j8 bootimage
        ;;
        nypon)
          DEVICE=nypon && lunch cm_nypon-eng && make -j8 bootimage
        ;;
        pepper)
          DEVICE=pepper && lunch cm_pepper-eng && make -j8 bootimage
        ;;
        lotus)
          DEVICE=lotus && lunch cm_lotus-eng && make -j8 bootimage
        ;;
        *)
          echo "Unknow option"
          echo $usage
          exit -1
        ;;
        esac
        if [ -f out/target/product/$DEVICE/boot.img ]; then
            cp -R device/sony/montblanc-common/scripts/META-INF out/target/product/$DEVICE
            cp -R out/target/product/$DEVICE/system/lib/modules out/target/product/$DEVICE/
            cd out/target/product/$DEVICE
            rm -rf system
            mkdir system
            cd system
            mkdir lib
            cd ..
            mv modules system/lib/modules
            cd ../../../..
            cp -R device/sony/montblanc-common/scripts/system/bin out/target/product/$DEVICE/system
            cp -R device/sony/montblanc-common/scripts/system/etc out/target/product/$DEVICE/system
            cd out/target/product/$DEVICE
            zip -r kernel boot.img system META-INF
            cd ../../../..
        fi
        if [ -f out/target/product/$DEVICE/kernel.zip ]; then
            clear
            echo "Build succeeded!"
            sleep 2
        else
            clear
            echo "Build failed!"
            sleep 2
        fi
    fi

    clear
    echo "Clearing patches"
    sleep 2
    cd device/sony/montblanc-common/patches
    ./clearpatches.sh
    cd ../../../..
    clear
    echo "Patches cleared"
    sleep 1

else
    echo "For which device do you want to build BraveKernel?"
    echo $usage
    clear
    echo "Patching needed files"
    sleep 2
    cd device/sony/montblanc-common/patches
    ./patch.sh
    cd ../../../..
    clear
    echo "Patching has finished"
    sleep 2
    clear
    echo "Clearing patches"
    sleep 2
    cd device/sony/montblanc-common/patches
    ./clearpatches.sh
    cd ../../../..
    clear
    echo "Patches cleared"
    sleep 1
fi

clear
