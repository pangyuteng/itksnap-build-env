# itksnap-build-env

based on below doc, create qt,vtk,itk,itksnap building in docker.

http://www.itksnap.org/pmwiki/pmwiki.php%3Fn%3DDocumentation.BuildingITK-SNAP
https://wiki.qt.io/Building_Qt_5_from_Git

bash build.sh
cd ..
git clone git@github.com:pyushkevich/itksnap.git
cd itksnap
git checkout v3.4.0

docker run -it -w /workdir/itksnap -v $PWD:/workdir/itksnap itksnap-build-env bash

mkdir build
cd build
cmake .. \
    -DITK_DIR=/opt/itk \
    -DVTK_DIR=/opt/vtk \
    -DQt5_DIR=/opt/qt/lib/cmake/Qt5
make -j"$(nproc)" && make install -j"$(nproc)"