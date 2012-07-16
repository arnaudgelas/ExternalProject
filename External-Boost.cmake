#---------------------------------------------------------------------------
# Get and build boost

message( "External project - Boost" )

set( Boost_Bootstrap_Command )
if( UNIX )
  set( Boost_Bootstrap_Command ./bootstrap.sh )
  set( Boost_b2_Command ./b2 )
else()
  if( WIN32 )
    set( Boost_Bootstrap_Command bootstrap.bat )
    set( Boost_b2_Command b2.exe )
  endif()
endif()

ExternalProject_Add(boost
  URL "http://dl.dropbox.com/u/15135983/boost.tar.gz"
  URL_MD5 66f100a77f727e21d67fefd1827b6c64
  BUILD_IN_SOURCE 1
  UPDATE_COMMAND ""
  PATCH_COMMAND ""
  CONFIGURE_COMMAND ${Boost_Bootstrap_Command}
  BUILD_COMMAND  ${Boost_b2_Command} install
    --without-python
    --without-mpi
    --disable-icu
    --prefix=${CMAKE_BINARY_DIR}/INSTALL
    --threading=single,multi
    --link=shared
    --variant=release
    -j8
  INSTALL_COMMAND ""
#  INSTALL_COMMAND ${Boost_b2_Command} install 
#    --without-python
#    --without-mpi
#    --disable-icu
#    --prefix=${CMAKE_BINARY_DIR}/INSTALL
#    --threading=single,multi
#    --link=shared
#    --variant=release
#    -j8
  INSTALL_DIR ${CMAKE_BINARY_DIR}/INSTALL
)


if( NOT WIN32 )
  set(Boost_LIBRARY_DIR ${CMAKE_BINARY_DIR}/INSTALL/lib/boost/ )
  set(Boost_INCLUDE_DIR ${CMAKE_BINARY_DIR}/INSTALL/include/ )
else()
  set(Boost_LIBRARY_DIR ${CMAKE_BINARY_DIR}/INSTALL/lib/ )
  set(Boost_INCLUDE_DIR ${CMAKE_BINARY_DIR}/INSTALL/include/boost-1_49/ )
endif()
