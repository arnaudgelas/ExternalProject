find_package(Git)
if(NOT GIT_FOUND)
  message(ERROR "Cannot find git. git is required for Superbuild")
endif()

option( USE_GIT_PROTOCOL "If behind a firewall turn this off to use http instead." ON)

set(git_protocol "git")
if(NOT USE_GIT_PROTOCOL)
  set(git_protocol "http")
endif()

set( CMAKE_MODULE_PATH
  ${CMAKE_CURRENT_SOURCE_DIR}/../cmake
  ${CMAKE_MODULE_PATH}
)

include( ExternalProject )

# Compute -G arg for configuring external projects with the same CMake
# generator:
if(CMAKE_EXTRA_GENERATOR)
  set(gen "${CMAKE_EXTRA_GENERATOR} - ${CMAKE_GENERATOR}")
else()
  set(gen "${CMAKE_GENERATOR}" )
endif()

set( NewCore_DEPENDENCIES )

# ---------------------------------------------------------------------------------------------
# Boost with Boost.Log
#

option( BUILD_BOOST_WITH_LOG "Build Boost 1.49 along with Boost.Log" ON )

if( ${BUILD_BOOST_WITH_LOG} )
  include( ${CMAKE_CURRENT_SOURCE_DIR}/External-Boost.cmake )
  set( NewCore_DEPENDENCIES ${NewCore_DEPENDENCIES} boost )
endif()

# ---------------------------
# include( ${CMAKE_CURRENT_SOURCE_DIR}/External-Taucs.cmake )
# set( NewCore_DEPENDENCIES ${NewCore_DEPENDENCIES} Taucs )

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
    set( OPENCV_DIR ${OpenCV_DIR} )
  endif()
else()
  message( "OpenCV not found" )
  set( _processOpenCV true )
endif()

if( ${_processOpenCV} )
  option( BUILD_OPENCV "Build OpenCV ${OpenCV_RequiredVersion}" ON )

  if( ${BUILD_OPENCV} )
    include( ${CMAKE_CURRENT_SOURCE_DIR}/External-OpenCV.cmake )
    set( NewCore_DEPENDENCIES ${NewCore_DEPENDENCIES} opencv )
  endif()
endif()

# ---------------------------------------------------------------------------------------------
# ITK With Bridge to OpenCV
#
option( BUILD_ITK "Build ITK v4.2" ON )

if( ${BUILD_ITK} )
  include( ${CMAKE_CURRENT_SOURCE_DIR}/External-ITK.cmake )
  set( NewCore_DEPENDENCIES ${NewCore_DEPENDENCIES} ITK )
endif()

# ---------------------------------------------------------------------------------------------
option( BUILD_TINYXML "Build TinyXML" ON )

if( ${BUILD_TINYXML} )
  include( ${CMAKE_CURRENT_SOURCE_DIR}/External-TinyXML.cmake )
  set( NewCore_DEPENDENCIES ${NewCore_DEPENDENCIES} TinyXML )
endif()
