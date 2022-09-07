#
# below cmake,qt,vtk,itk versions specified per below link visited on 2022-SEP-06
# http://www.itksnap.org/pmwiki/pmwiki.php%3Fn%3DDocumentation.BuildingITK-SNAP
#
# ITK-SNAP version	GIT branch	CMake version	ITK version	VTK version	FLTK or Qt version
# 3.8.0 and later	rel_3.8	2.8.12	4.12.2	6.3.0	Qt 5.6.0
# Current development	master	3.22	5.2.1	9.1.0	Qt 6.2.2

ARG CMAKE_VER=3.22.6
ARG QT_VER=6.2.2
ARG VTK_VER=9.1.0
ARG ITK_VER=5.2.1

FROM ubuntu:18.04

RUN cp /etc/apt/sources.list /etc/apt/sources.list~ && \
    sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list

RUN apt-get update && \
    apt-get install -yq \
    autotools-dev build-essential ca-certificates \
    software-properties-common \
    git wget curl vim \    
    libpng-dev libx11-dev libxt-dev libgl1-mesa-dev \
    libglu1-mesa-dev libfontconfig-dev libxrender-dev libncurses5-dev \
    perl python3 python-dev && \
    apt-get build-dep -yq qtbase5-dev

#RUN  rm -rf /var/lib/apt/lists/*

#### CMAKE
ARG CMAKE_VER
WORKDIR /inst
RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.tar.gz && \
    tar -zxvf cmake-${CMAKE_VER}-linux-x86_64.tar.gz

ENV PATH=/inst/cmake-${CMAKE_VER}-linux-x86_64/bin:$PATH

#### QT
ARG QT_VER
WORKDIR /src
RUN git clone https://github.com/qt/qt5.git qt && \
    cd qt && git checkout v${QT_VER} && \
    perl init-repository --module-subset=default,-qtwebengine 

RUN apt install gcc-8 g++-8 -yq
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10

WORKDIR /src/qt-build
ARG CMAKE_GENERATOR=Ninja
RUN ../qt/configure -silent -opensource -confirm-license \
    -prefix /opt/qt \
    -opensource -confirm-license \
    -opengl \
    -xcb \
    -nomake tools \
    -nomake examples \
    -nomake tests \
    -skip qttools \
    -skip qtcoap \
    -skip qtmqtt \
    -skip qtopcua \
    -skip qttranslations \
    -skip qt3d \
    -skip qtactiveqt \
    -skip qtandroidextras \
    -skip qtcanvas3d \
    -skip qtcharts \
    -skip qtconnectivity \
    -skip qtdatavis3d \
    -skip qtdoc \
    -skip qtgamepad \
    -skip qtlocation \
    -skip qtmacextras \
    -skip qtmultimedia \
    -skip qtnetworkauth \
    -skip qtpurchasing \
    -skip qtremoteobjects \
    -skip qtscxml \
    -skip qtsensors \
    -skip qtserialbus \
    -skip qtserialport \
    -skip qtspeech \
    -skip qtvirtualkeyboard \
    -skip qtwayland \
    -skip qtwebchannel \
    -skip qtwebengine \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qtwebglplugin \
    -skip qtwinextras \
    -skip qtxmlpatterns

RUN make -j"$(nproc)" && make install -j"$(nproc)"


#### VTK
ARG CMAKE_GENERATOR="Unix Makefiles"
ARG VTK_VER
WORKDIR /inst
RUN mkdir -p /src/vtk
#RUN wget --quiet https://github.com/Kitware/VTK/archive/refs/tags/v${VTK_VER}.tar.gz -O vtk.tar.gz && \
RUN wget --quiet https://gitlab.kitware.com/vtk/vtk/-/archive/v${VTK_VER}/vtk-v${VTK_VER}.tar.gz -O vtk.tar.gz && \
    tar -xzf vtk.tar.gz -C /src/vtk --strip-components 1
RUN mkdir -p /src/vtk/build
WORKDIR /src/vtk/build

RUN /opt/qt/bin/qt-cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/vtk \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_GROUP_ENABLE_Qt=YES \
    -DVTK_MODULE_ENABLE_VTK_GuiSupportQt=YES \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick=NO \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=NO \
    -DVTK_REQUIRED_OBJCXX_FLAGS='' \
    -DVTK_QT_VERSION=6 \
    -DQt6_DIR:PATH=/opt/qt/lib/cmake/Qt6 && \
    make -j"$(nproc)" && make install -j"$(nproc)"

#Unix Makefiles, Ninja
#ENV CMAKE_GENERATOR=Ninja
#ENV CMAKE_GENERATOR=Makefiles
#RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 20
#RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-7 20


#### ITK
ARG ITK_VER
WORKDIR /inst
RUN mkdir -p /src/itk
RUN wget --quiet https://github.com/InsightSoftwareConsortium/ITK/releases/download/v${ITK_VER}/InsightToolkit-${ITK_VER}.tar.gz -O itk.tar.gz && \
    tar -xzf itk.tar.gz -C /src/itk --strip-components 1
RUN mkdir -p /src/itk/build
WORKDIR /src/itk/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/itk \
    -DBUILD_DOXYGEN=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_SHARED_LIBS=OFF \
    -DITK_DYNAMIC_LOADING=OFF \
    -DBUILD_TESTING=OFF \
    -DITK_USE_KWSTYLE=OFF \
    -DModule_ITKVtkGlue=ON \
    -DModule_ITKReview=ON \
    -DITK_BUILD_DEFAULT_MODULES=ON \
    -DModule_MorphologicalContourInterpolation=ON \
    -DQt6_DIR:PATH=/opt/qt/lib/cmake/Qt6 && \
    make -j"$(nproc)" && make install -j"$(nproc)"

ENV LD_LIBRARY_PATH /opt/qt/lib/:/opt/itk/lib:/opt/vtk/lib:$LD_LIBRARY_PATH
ENV Qt5_DIR /usr/local/qt/lib/cmake/Qt6

#### example
# RUN mkdir -p /src/vtk/Examples/GUI/Qt/SimpleView/build
# WORKDIR /src/vtk/Examples/GUI/Qt/SimpleView/build
# RUN cmake .. && make
