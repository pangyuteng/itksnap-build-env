# itksnap-build-env

based on below doc, create qt,vtk,itk,itksnap building in docker.

http://www.itksnap.org/pmwiki/pmwiki.php%3Fn%3DDocumentation.BuildingITK-SNAP

bash build.sh
cd ..
git clone git@github.com:pyushkevich/itksnap.git
cd itksnap
git checkout v3.4.0

docker run -it -w /workdir/itksnap -v $PWD:/workdir/itksnap itksnap-build-env bash

mkdir build
cd build
cmake .. \
    -DITK_DIR=/opt/vtk/ \
    -DVTK_DIR=/opt/itk/ \
    -DQt5_DIR=/opt/qt/lib/cmake/Qt5
make -j"$(nproc)" && make install -j"$(nproc)"