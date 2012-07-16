#---------------------------------------------------------------------------
# Get and build taucs

message( "External project - Taucs" )

set( proj Taucs )

ExternalProject_Add(${proj}
  URL http://www.tau.ac.il/~stoledo/taucs/2.2/taucs_full.zip
  SOURCE_DIR ${proj}
  CONFIGURE_COMMAND ""
  UPDATE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)

set( TAUCS_DIR ${CMAKE_BINARY_DIR}/${proj} )
