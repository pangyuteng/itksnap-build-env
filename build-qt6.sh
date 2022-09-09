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
    -f Dockerfile.qt6 \
    -t itksnap-${CMAKE_VER}-${QT_VER}-${VTK_VER}-${ITK_VER} .
