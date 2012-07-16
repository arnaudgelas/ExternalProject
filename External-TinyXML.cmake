message( "External project - TinyXML" )

ExternalProject_Add( TinyXML
  GIT_REPOSITORY ${git_protocol}://tinyxml.git.sourceforge.net/gitroot/tinyxml/tinyxml
  GIT_TAG 94b1760fb66268262b2aad8533e2639bab3ff5b1
  SOURCE_DIR TinyXML
  BINARY_DIR TinyXML-build
  UPDATE_COMMAND ""
  PATCH_COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/TinyXML_CMakeLists.txt ${CMAKE_BINARY_DIR}/TinyXML/CMakeLists.txt
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
    ${ep_common_args}
    -DCMAKE_BUILD_TYPE:STRING=Release
    -DCMAKE_INSTALL_PREFIX:PATH=${CMAKE_BINARY_DIR}/INSTALL
)

set( TINYXML_INCLUDE_DIR ${CMAKE_BINARY_DIR}/INSTALL/include )

if( WIN32 )
  set( TINYXML_LIBRARIES ${CMAKE_BINARY_DIR}/INSTALL/lib/tinyxml.lib )
else()
  if( UNIX )
    set( TINYXML_LIBRARIES ${CMAKE_BINARY_DIR}/INSTALL/lib/libtinyxml.a )
  endif()
endif()
