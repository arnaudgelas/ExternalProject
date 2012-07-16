message( "External project - OpenCV" )

find_package( Subversion REQUIRED )
if( NOT SUBVERSION_FOUND )
  message( ERROR "Cannot find subversion. Subversion is required for Superbuild." )
endif()

ExternalProject_Add(opencv
  SVN_REPOSITORY http://code.opencv.org/svn/opencv/tags/2.3.1/opencv/
  SOURCE_DIR opencv
  BINARY_DIR opencv-build
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${ep_common_args}
    -DBUILD_DOCS:BOOL=OFF
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_NEW_PYTHON_SUPPORT:BOOL=OFF
    -DBUILD_PACKAGE:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_TESTS:BOOL=OFF
#   -DCMAKE_BUILD_TYPE:STRING=Release
    -DWITH_FFMPEG:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
)

set( OPENCV_ROOT_DIR ${CMAKE_BINARY_DIR}/INSTALL )
set( OPENCV_DIR ${CMAKE_BINARY_DIR}/INSTALL )
