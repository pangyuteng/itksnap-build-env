#!/bin/bash

DOCKER_BUILDKIT=1

#
# 
# https://sourceforge.net/p/itk-snap/cdash/ci/master/tree/products/itksnap.cmake
# git branch    cmake   vtk         itk         QT
# master          ?     vtk/v7.1.1  itk/v4.13.2 ?
# ITK-SNAP version	GIT branch	CMake version	ITK version	VTK version	FLTK or Qt version
# 3.8.0 and later	rel_3.8	2.8.12	4.12.2	6.3.0	Qt 5.6.0

CMAKE_VER=3.22.6
QT_VER=5.12.11
#VTK_VER=7.1.1
#VTK_MM_VER=7.1
VTK_VER=6.3.0
VTK_MM_VER=6.3
ITK_VER=4.13.2
ITK_MM_VER=4.13
#ITKSNAP_TAG=v3.4.0
ITKSNAP_TAG=55a738f

docker build \
    --build-arg CMAKE_VER=${CMAKE_VER} \
    --build-arg QT_VER=${QT_VER} \
    --build-arg VTK_VER=${VTK_VER} \
    --build-arg VTK_MM_VER=${VTK_MM_VER} \
    --build-arg ITK_VER=${ITK_VER} \
    --build-arg ITK_MM_VER=${ITK_MM_VER} \
    --build-arg ITKSNAP_TAG=${ITKSNAP_TAG} \
    -f Dockerfile.qt5 \
    -t itksnap-${ITKSNAP_TAG} .

