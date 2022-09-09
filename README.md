# itksnap-build-env

based on below doc, create qt,vtk,itk,itksnap building in docker.

http://www.itksnap.org/pmwiki/pmwiki.php%3Fn%3DDocumentation.BuildingITK-SNAP
https://wiki.qt.io/Building_Qt_5_from_Git


+ building containers

```

bash build.sh &> qt6.out

build-qt5.sh &> qt5.out
```


+ build itksnap within the container

```
cd ..
git clone git@github.com:pyushkevich/itksnap.git
cd itksnap
git submodule update --init
git checkout master

docker run -it -w /workdir/itksnap -v $PWD:/workdir/itksnap itksnap-build-env bash

git config --global --add safe.directory /workdir/itksnap
git config --global --add safe.directory /workdir/itksnap/Submodules/greedy
git config --global --add safe.directory /workdir/itksnap/Submodules/c3d

mkdir build
cd build
/opt/qt/bin/qt-cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/itksnap \
    -DITK_DIR=/opt/itk \
    -DVTK_DIR=/opt/vtk \
    -DQt6_DIR=/opt/qt/lib/cmake/Qt6

make -j"$(nproc)" && make install -j"$(nproc)"

```
```
cd ..
git clone git@github.com:pyushkevich/itksnap.git
cd itksnap
git checkout v3.4.0
 
docker run -it -w /workdir/itksnap -v $PWD:/workdir/itksnap itksnap-build-env bash

git config --global --add safe.directory /workdir/itksnap
mkdir build && cd build
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/itksnap \
    -DITK_DIR=/opt/itk/lib/cmake/ITK-4.13 \
    -DVTK_DIR=/opt/vtk/lib/cmake/vtk-7.1 \
    -DQt5_DIR=/opt/qt/lib/cmake/Qt5 \
    -DQt5Concurrent_DIR=/opt/qt/lib/cmake/Qt5Concurrent \
    -DQt5OpenGL_DIR=/opt/qt/lib/cmake/Qt5OpenGL \
    -DQt5Qml_DIR=/opt/qt/lib/cmake/Qt5Qml \
    -DQt5Widgets_DIR=/opt/qt/lib/cmake/Qt5Widgets \
    -DOpenGL_GL_PREFERENCE=GLVND
&> itksnap.out

make -j"$(nproc)" && make install -j"$(nproc)"

```
