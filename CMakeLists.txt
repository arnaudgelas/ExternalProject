cmake_minimum_required( VERSION 2.8.3 )

project( BoostCamp )

include( ExternalProject )

# Compute -G arg for configuring external projects with the same CMake
# generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}" )
endif()

ExternalProject_Add(boost
  URL "http://dl.dropbox.com/u/15135983/boost.tar.gz"
  URL_MD5 66f100a77f727e21d67fefd1827b6c64
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ./bootstrap.sh
    --with-libraries=filesystem
    --with-libraries=program_options
    --with-libraries=system
    --with-libraries=iostreams
    --with-libraries=date_time
    --with-libraries=random
    --with-libraries=serialization
    --with-libraries=log
    --with-libraries=thread
    --with-libraries=chrono
    --with-libraries=iostreams
    --with-libraries=timer
    --with-libraries=math
    --prefix=${CMAKE_BINARY_DIR}/INSTALL
  BUILD_COMMAND  ./bjam --threading=multi --link=static --variant=release -j8
  INSTALL_COMMAND ./bjam install
  INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL
)

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
    -DBUILD_TESTS:BOOL=OFF
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DWITH_FFMPEG:BOOL=OFF
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
)

find_package(Git REQUIRED)
if(NOT GIT_FOUND)
  message(ERROR "Cannot find git. git is required for Superbuild")
endif()

option( USE_GIT_PROTOCOL "If behind a firewall turn this off to use http instead." ON)

set(git_protocol "git")
if(NOT USE_GIT_PROTOCOL)
  set(git_protocol "http")
endif()

ExternalProject_Add(ITK
  DEPENDS opencv
  GIT_REPOSITORY ${git_protocol}://itk.org/ITK.git
  GIT_TAG 026e253d1deae6d9e0c7c6cac564f3a70f1e4bbe
  SOURCE_DIR ITK
  BINARY_DIR ITK-build
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${ep_common_args}
    -DBUILD_EXAMPLES:BOOL=OFF
    -DBUILD_SHARED_LIBS:BOOL=ON
    -DBUILD_TESTING:BOOL=OFF
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DITK_BUILD_ALL_MODULES:BOOL=ON
    -DModule_ITKVideoBridgeOpenCV:BOOL=ON
    -DOpenCV_DIR:PATH=${CMAKE_BINARY_DIR}/INSTALL
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
)
