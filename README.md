BraveKernel [![Build Status](http://jenkins.hubdroid.com/buildStatus/icon?job=bravekernel)](http://jenkins.hubdroid.com/job/bravekernel/)
-----------

### Instructions for building BraveKernel:

    git clone https://github.com/Garcia98/bravekernel.git
    cd bravekernel
    ./BraveKernel.sh [ -u / -p / -g / -s ]

### Bug list

* zRAM not working: check SLQB and xvMalloc, also add memory and swap cgroups
