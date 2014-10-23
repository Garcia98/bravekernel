#!/bin/bash

# All in One script
echo "All in One script for building BraveKernel"
usage="Usage: ./BraveKernel.sh -u | -p | -s | -g"

if [ ! -f "Makefile" ]; then
    echo "It's your first time, downloading all files that are needed"
    ./repo init -u git://github.com/CyanogenMod/android -b cm-11.0
    ./repo sync -cq -j8
    echo "All files downloaded"
else
    echo "Updating files"
    git pull
    ./repo sync -cq -j8
    echo "All is updated"
fi

if [[ $# = 1 ]]; then
    if [ -f "out" ]; then dirty=yes
        echo "Cleaning out dir"
        make clean
        make clobber
        rm -rf out
        echo "Cleanup done"
    fi

    echo "Patching needed files"
    cd device/sony/montblanc-common/patches
    ./patch.sh
    cd ../../../..
    echo "Patching has finished"

    if [ ! "$BRAVEKERNEL" == cool ]; then
        echo "Setting some parameters"
        export BRAVEKERNEL=cool
        export LD_LIBRARY_PATH=out/host/linux-x86/lib
        if (( $(java -version 2>&1 | grep version | cut -f2 -d".") > 6 )); then
            echo "Using local JDK 6..."
            export JAVA_HOME=$(realpath ../jdk1.6.0_45);
        fi
        echo "Everything is ready"
    fi

    if [[ $? = 0 ]]; then
        . build/envsetup.sh
        echo "Building"
        case $1 in
        -u)
          lunch cm_kumquat-eng && mka bootimage
        ;;
        -p)
          lunch cm_nypon-eng && mka bootimage
        ;;
        -s)
          lunch cm_pepper-eng && mka bootimage
        ;;
        -g)
          lunch cm_lotus-eng && mka bootimage
        ;;
        *)
          echo "Unknow option"
          echo $usage
          exit -1
        ;;
        esac
        if [ -f out/target/product/kumquat/kernel.zip ]; then
            echo "Build succeeded!"
        else
            echo "Build failed!"
        fi
    fi

    echo "Clearing patches"
    cd device/sony/montblanc-common/patches
    ./clearpatches.sh
    cd ../../../..
    echo "Patches cleared"
            
else
    echo "For which device do you want to build BraveKernel?"
    echo $usage
    exit -1
fi
