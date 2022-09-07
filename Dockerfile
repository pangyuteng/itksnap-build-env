# http://www.itksnap.org/pmwiki/pmwiki.php?n=Documentation.BuildingITK-SNAP
# 3.22	5.2.1	9.1.0	Qt 6.2.2
# itk/
# itk/itk-5.2.1/itk/               <- ITK source tree
# itk/itk-5.2.1/gcc64rel
# vtk
# vtk/vtk-9.1.0/vtk/               <- VTK source tree
# vtk/vtk-9.1.0/gcc64rel/
# itksnap/
# itksnap/itksnap                  <- ITK-SNAP source tree 
# itksnap/gcc64rel

ARG QT_MAJOR_MINOR_VER=5.11
ARG QT_VER=5.11.3
ARG VTK_VER=9.1.0
ARG ITK_VER=5.1.0
ARG MYPATH=/usr/local
ARG MYLIBPATH=/usr/local/lib

FROM ubuntu:20.04 as builder

ARG MYPATH
ARG MYLIBPATH

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -yq --no-install-recommends \
        autotools-dev build-essential ca-certificates \
        cmake git wget vim \
        software-properties-common \
        libpng-dev libx11-dev libxt-dev libgl1-mesa-dev libglu1-mesa-dev \
        libfontconfig-dev libxrender-dev libncurses5-dev libosmesa6-dev \
        python python-dev

#RUN  rm -rf /var/lib/apt/lists/*

ARG VTK_VER
WORKDIR /opt/sources
RUN wget --quiet --no-check-certificate https://gitlab.kitware.com/vtk/vtk/-/archive/v${VTK_VER}/vtk-v${VTK_VER}.tar.gz -O vtk.tar.gz && \
	tar xfz vtk.tar.gz

# compile
RUN mkdir -p /opt/sources/vtk-v${VTK_VER}/build
WORKDIR /opt/sources/vtk-v${VTK_VER}/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$MYPATH \
    -DBUILD_SHARED_LIBS=ON \
    -DVTK_BUILD_TESTING=OFF \
    -DVTK_BUILD_DOCUMENTATION=OFF \
    -DVTK_BUILD_EXAMPLES=OFF \
    -DVTK_OPENGL_HAS_EGL=False \
    -DVTK_OPENGL_HAS_OSMESA=True \
    -DVTK_USE_COCOA=FALSE \
    -DVTK_USE_X=FALSE \
    -DVTK_DEFAULT_RENDER_WINDOW_HEADLESS=True \
    -DVTK_MODULE_ENABLE_VTK_PythonInterpreter:STRING=NO \
    -DVTK_WHEEL_BUILD=OFF \
    -DVTK_WRAP_PYTHON=OFF \
    && make -j"$(nproc)" && make install -j"$(nproc)"

ARG ITK_VER
WORKDIR /opt/sources
RUN wget --quiet --no-check-certificate https://github.com/InsightSoftwareConsortium/ITK/releases/download/v${ITK_VER}/InsightToolkit-${ITK_VER}.tar.gz -O itk.tar.gz && \
    tar xfz itk.tar.gz

# compile itk
RUN mkdir -p /opt/sources/InsightToolkit-${ITK_VER}/build
WORKDIR /opt/sources/InsightToolkit-${ITK_VER}/build

RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$MYPATH \
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
    && make -j"$(nproc)" && make install -j"$(nproc)"

ARG QT_MAJOR_MINOR_VER
ARG QT_VER
WORKDIR /opt/sources
RUN  wget --quiet --no-check-certificate https://download.qt.io/new_archive/qt/${QT_MAJOR_MINOR_VER}/${QT_VER}/single/qt-everywhere-src-${QT_VER}.tar.xz -O qt.tar.xz && \
    tar xf qt.tar.xz

WORKDIR /opt/sources/qt-everywhere-src-${QT_VER}
RUN ./configure -prefix /usr/local/qt -release -opensource -confirm-license \
    -opengl desktop -nomake examples -nomake tests && \
    make -j"$(nproc)" && make install -j"$(nproc)"



