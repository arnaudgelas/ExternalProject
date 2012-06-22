cmake_minimum_required( VERSION 2.8.3 )

project( BootCamp )

include( ExternalProject )

# Compute -G arg for configuring external projects with the same CMake
# generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}" )
endif()


set( CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR} )

# ---------------------------------------------------------------------------------------------
# Boost with Boost.Log
#

option( BUILD_BOOST_WITH_LOG "Build Boost 1.49 along with Boost.Log" OFF )

if( ${BUILD_BOOST_WITH_LOG} )
  set( Boost_Bootstrap_Command )
  if( UNIX )
    set( Boost_Bootstrap_Command ./bootstrap.sh )
  else()
    if( WIN32 )
      set( Boost_Bootstrap_Command .\bootstrap.bat )
    endif()
  endif()

  ExternalProject_Add(boost
    URL "http://dl.dropbox.com/u/15135983/boost.tar.gz"
    URL_MD5 66f100a77f727e21d67fefd1827b6c64
    BUILD_IN_SOURCE 1
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CONFIGURE_COMMAND ${Boost_Bootstrap_Command}
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

  set( Boost_INCLUDE_DIR ${CMAKE_BINARY_DIR}/INSTALL/include )
  set( Boost_LIBRARY_DIRS ${CMAKE_BINARY_DIR}/INSTALL/lib )

endif()


# ---------------------------------------------------------------------------------------------
# OpenCV
#
set( OpenCV_RequiredVersion 2.3.1 )
find_package( OpenCV )

set( _processOpenCV false )

if( ${OpenCV_FOUND} )
  if( ${OpenCV_VERSION} LESS ${OpenCV_RequiredVersion} )
    message( "OpenCV found --- ${OpenCV_VERSION}  ( < ${OpenCV_RequiredVersion} )" )
    set( processOpenCV true )
  else()
    message( "OpenCV found --- ${OpenCV_VERSION}  OK" )
    set( _processOpenCV false )
  endif()
else()
  message( "OpenCV not found" )
  set( _processOpenCV true )
endif()

if( ${_processOpenCV} )
  option( BUILD_OPENCV "Build OpenCV ${OpenCV_RequiredVersion}" ON )

  if( ${BUILD_OPENCV} )
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
  endif()
endif()

# ---------------------------------------------------------------------------------------------
# ITK With Bridge to OpenCV
#
option( BUILD_ITK "Build ITK v4.2rc02" OFF )

find_package(Git REQUIRED)
  if(NOT GIT_FOUND)
    message(ERROR "Cannot find git. git is required for Superbuild")
  endif()

  option( USE_GIT_PROTOCOL "If behind a firewall turn this off to use http instead." ON)

  set(git_protocol "git")
  if(NOT USE_GIT_PROTOCOL)
    set(git_protocol "http")
  endif()

if( ${BUILD_ITK} )
  ExternalProject_Add(ITK
    DEPENDS opencv
    GIT_REPOSITORY ${git_protocol}://itk.org/ITK.git
    GIT_TAG v4.2rc02
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
endif()

# ---------------------------------------------------------------------------------------------
# OpenSceneGraph
#
set( OSG_RequiredVersion 3.0.0 )
find_package( OpenSceneGraph )

set( _processOSG false )

if( ${OPENSCENEGRAPH_FOUND} )
  if( ${OPENSCENEGRAPH_VERSION} LESS ${OSG_RequiredVersion} )
    message( "OpenSceneGraph found --- ${OPENSCENEGRAPH_VERSION}  ( < ${OSG_    RequiredVersion} )" )
    set( _processOSG true )
  else()
    message( "OpenSceneGraph found --- ${OPENSCENEGRAPH_VERSION}  OK" )
    set( _processOSG false )
  endif()
else()
  message( "OpenSceneGraph not found" )
  set( _processOSG true )
endif()

if( ${_processOSG} )
  option( BUILD_OPENSCENEGRAPH "Build OpenSceneGraph ${OSG_RequiredVersion}" ON )

  ExternalProject_Add( OpenSceneGraph
    SVN_REPOSITORY http://www.openscenegraph.org/svn/osg/OpenSceneGraph/tags/OpenSceneGraph-${OSG_RequiredVersion}/
    SOURCE_DIR OpenSceneGraph
    BINARY_DIR OpenSceneGraph-build
    UPDATE_COMMAND ""
    PATCH_COMMAND ""
    CMAKE_GENERATOR ${gen}
    CMAKE_ARGS
    ${ep_common_args}
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
    #    -DBUILD_NEW_PYTHON_SUPPORT:BOOL=OFF
  )
endif()

option( BUILD_TINYXML "Build TinyXML" ON )

if( ${BUILD_TINYXML} MATCHES "ON" )
  find_package( TinyXML )

  if( NOT ${TINYXML_FOUND} )
    ExternalProject_Add( TinyXML
      GIT_REPOSITORY ${git_protocol}://tinyxml.git.sourceforge.net/gitroot/tinyxml/tinyxml
      GIT_TAG 94b1760fb66268262b2aad8533e2639bab3ff5b1
      SOURCE_DIR TinyXML
      BINARY_DIR TinyXML-build
      UPDATE_COMMAND ""
      PATCH_COMMAND git apply ${CMAKE_SOURCE_DIR}/0001-Add-CMakeLists.txt-file.patch
      CMAKE_GENERATOR ${gen}
      CMAKE_ARGS
        ${ep_common_args}
        -DBUILD_SHARED:BOOL=ON
        -DCMAKE_BUILD_TYPE:STRING=Release
        -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
    )

  endif()
endif()

#find_package( Boost 1.49 REQUIRED COMPONENTS filesystem system date_time thread regex log )
#if( Boost_FOUND )
#  include_directories( ${Boost_INCLUDE_DIRS} )
#endif()
#add_subdirectory( BoostLogExamples )
