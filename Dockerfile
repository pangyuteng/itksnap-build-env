ARG CMAKE_VER=6.2.2
ARG QT_VER=6.2.2
ARG VTK_VER=9.1.0
ARG ITK_VER=5.2.1

FROM ubuntu:18.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    autotools-dev \
    build-essential \
    ca-certificates \
    git wget curl vim \
    software-properties-common \
    libpng-dev libx11-dev libxt-dev libgl1-mesa-dev \
    libglu1-mesa-dev libfontconfig-dev libxrender-dev libncurses5-dev \
    python python-dev -yq
#RUN  rm -rf /var/lib/apt/lists/*
RUN mkdir /inst

#### CMAKE
ARG CMAKE_VER
WORKDIR /inst
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-linux-x86_64.sh
RUN bash cmake-${CMAKE_VER}-linux-x86_64.sh

#### QT
ARG QT_VER
RUN mkdir -p /src/qt
WORKDIR /inst

RUN git clone https://github.com/qt/qt5.git qt && \
    cd qt && git checkout v${QT_VER} && ./init-repository

RUN ./configure --prefix /opt/qt \
    -no-webkit -fast -nomake demos -nomake tools \
    -nomake examples -no-multimedia -no-phonon  \
    -no-qt3support -opensource && \
    make -j"$(nproc)" && make install -j"$(nproc)"

#### VTK
ARG VTK_VER
WORKDIR /inst
RUN mkdir -p /src/vtk
RUN wget https://gitlab.kitware.com/vtk/vtk/-/archive/v${VTK_VER}/vtk-v${VTK_VER}.tar.gz -O vtk.tar.gz && \
    tar -xzf vtk.tar.gz -C /src/vtk --strip-components 1
RUN mkdir -p /src/vtk/build
WORKDIR /src/vtk/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/vtk \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DVTK_GROUP_ENABLE_Qt=YES \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtQuick=NO \
    -DVTK_MODULE_ENABLE_VTK_GUISupportQtSQL=NO \
    -DVTK_REQUIRED_OBJCXX_FLAGS='' \
    -DQt5_DIR:PATH=/opt/qt/lib/cmake/Qt5 && \
    make -j"$(nproc)" && make install -j"$(nproc)"

#### ITK
ARG ITK_VER
WORKDIR /inst
RUN mkdir -p /src/itk
RUN wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v${ITK_VER}/InsightToolkit-${ITK_VER}.tar.gz -O itk.tar.gz && \
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
    -DQt5_DIR:PATH=/opt/qt/lib/cmake/Qt5 && \
    make -j"$(nproc)" && make install -j"$(nproc)"

ENV LD_LIBRARY_PATH /opt/qt/lib/:/opt/itk/lib:/opt/vtk/lib:$LD_LIBRARY_PATH
ENV Qt5_DIR /usr/local/qt/lib/cmake/Qt5

#### example
# RUN mkdir -p /src/vtk/Examples/GUI/Qt/SimpleView/build
# WORKDIR /src/vtk/Examples/GUI/Qt/SimpleView/build
# RUN cmake .. && make
