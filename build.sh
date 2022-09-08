#!/bin/bash

DOCKER_BUILDKIT=1

#
# below cmake,qt,vtk,itk versions specified per below link visited on 2022-SEP-06
# http://www.itksnap.org/pmwiki/pmwiki.php%3Fn%3DDocumentation.BuildingITK-SNAP
# Current development	master	3.22	5.2.1	9.1.0	Qt 6.2.2
CMAKE_VER=3.22.6
QT_VER=6.2.2
VTK_VER=9.1.0
ITK_VER=5.2.1

docker build \
    --build-arg CMAKE_VER=${CMAKE_VER} \
    --build-arg QT_VER=${QT_VER} \
    --build-arg VTK_VER=${VTK_VER} \
    --build-arg ITK_VER=${ITK_VER} \
    -t itksnap-${CMAKE_VER}-${QT_VER}-${VTK_VER}-${ITK_VER} .

#
# 
# https://sourceforge.net/p/itk-snap/cdash/ci/master/tree/products/itksnap.cmake
# git branch    cmake   vtk         itk         QT
# master          ?     vtk/v7.1.1  itk/v4.13.2 ?
# ITK-SNAP version	GIT branch	CMake version	ITK version	VTK version	FLTK or Qt version
# 3.8.0 and later	rel_3.8	2.8.12	4.12.2	6.3.0	Qt 5.6.0

CMAKE_VER=3.22.6
QT_VER=5.6.3
VTK_VER=7.1.1
ITK_VER=4.13.2

docker build \
    --build-arg CMAKE_VER=${CMAKE_VER} \
    --build-arg QT_VER=${QT_VER} \
    --build-arg VTK_VER=${VTK_VER} \
    --build-arg ITK_VER=${ITK_VER} \
    -f Dockerfile.qt5 \
    -t itksnap-${CMAKE_VER}-${QT_VER}-${VTK_VER}-${ITK_VER} .
