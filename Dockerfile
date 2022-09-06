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

ARG QT_VER=6.2.2
ARG VTK_VER=9.1.0
ARG ITK_VER=5.1.0
ARG MYPATH=/usr/local
ARG MYLIBPATH=/usr/local/lib

FROM ubuntu:20.04 as builder

ARG MYPATH
ARG MYLIBPATH
ARG QT_VER
ARG VTK_VER
ARG ITK_VER


ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update &&  apt-get install -yq --no-install-recommends \
    wget autotools-dev build-essential ca-certificates \
    cmake git wget curl vim \
    libosmesa6-dev 

# Prefetch sources
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

# prefetch sources
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


WORKDIR /opt/sources
RUN wget --quiet --no-check-certificate https://github.com/qt/qt5/archive/refs/tags/v${QT_VER}.tar.gz -O qt.tar.gz && \
    tar xfz qt.tar.gz

# RUN mkdir -p /opt/sources/QT-${QT_VER}/build
# WORKDIR /opt/sources/QT-${QT_VER}/build

# WORKDIR /inst
# RUN wget https://download.qt.io/new_archive/qt/5.10/5.10.1/single/qt-everywhere-src-5.10.1.tar.xz -O qt.tar.xz && \
#     tar -xf qt.tar.xz -C /src/qt --strip-components 1
# RUN apt-get install python python-dev -yq
# WORKDIR /src/qt
# RUN ./configure -prefix /usr/local/qt -release -opensource -confirm-license \
#     -opengl desktop -nomake examples -nomake tests
# RUN make -j"$(nproc)" && make install
