FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        autotools-dev \
        build-essential \
        ca-certificates \
        cmake \
        git \
        wget \
        unzip \
        libx11-dev \
        libxt-dev \
        libgl1-mesa-dev \
        vim \
        software-properties-common

#RUN  rm -rf /var/lib/apt/lists/*

RUN apt-get install libpng-dev libx11-dev libxt-dev libgl1-mesa-dev libglu1-mesa-dev libfontconfig-dev libxrender-dev libncurses5-dev -yq

#### QT

RUN mkdir /inst
RUN mkdir -p /src/qt
WORKDIR /inst
RUN wget https://download.qt.io/new_archive/qt/5.10/5.10.1/single/qt-everywhere-src-5.10.1.tar.xz -O qt.tar.xz && \
    tar -xf qt.tar.xz -C /src/qt --strip-components 1
RUN apt-get install python python-dev -yq
WORKDIR /src/qt
RUN ./configure -prefix /opt/qt \
    -release -opensource -confirm-license \
    -opengl desktop -nomake examples -nomake tests
RUN make -j"$(nproc)" && make install -j"$(nproc)"


#### VTK

WORKDIR /inst
RUN mkdir -p /src/vtk
RUN wget https://gitlab.kitware.com/vtk/vtk/-/archive/v9.0.1/vtk-v9.0.1.tar.gz -O vtk.tar.gz && \
    tar -xzf vtk.tar.gz -C /src/vtk --strip-components 1
RUN mkdir -p /src/vtk/build
WORKDIR /src/vtk/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/vtk \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_GROUP_ENABLE_Qt=YES \
    -DVTK_GROUP_ENABLE_Qt=YES \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick=NO \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=NO \
    -DVTK_REQUIRED_OBJCXX_FLAGS='' \
    -DQt5_DIR:PATH=/opt/qt/lib/cmake/Qt5 && \
    make -j"$(nproc)" && make install -j"$(nproc)"

WORKDIR /inst
RUN mkdir -p /src/itk
RUN wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v5.1.0/InsightToolkit-5.1.0.tar.gz -O itk.tar.gz && \
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
    -DCMAKE_BACKWARDS_COMPATIBILITY=3.1 \
    -DITK_USE_KWSTYLE=OFF \
    -DITK_BUILD_ALL_MODULES=ON \
    -DModule_ITKVtkGlue=ON \
    -DITK_USE_REVIEW=ON \
    -DQt5_DIR:PATH=/opt/qt/lib/cmake/Qt5 \
    -DModule_MorphologicalContourInterpolation=TRUE && \
    make -j"$(nproc)" && make install -j"$(nproc)"

#### example

ENV Qt5_DIR /usr/local/qt/lib/cmake/Qt5
ENV LD_LIBRARY_PATH /opt/itk/lib:/opt/vtk/lib:$LD_LIBRARY_PATH
RUN mkdir -p /src/vtk/Examples/GUI/Qt/SimpleView/build
WORKDIR /src/vtk/Examples/GUI/Qt/SimpleView/build
RUN cmake .. && make
