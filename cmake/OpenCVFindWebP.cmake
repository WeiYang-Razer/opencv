#=============================================================================
# Find WebP library
#=============================================================================
# Find the native WebP headers and libraries.
#
#  WEBP_INCLUDE_DIRS - where to find webp/decode.h, etc.
#  WEBP_LIBRARIES    - List of libraries when using webp.
#  WEBP_FOUND        - True if webp is found.
#=============================================================================

# Prefer libwebp's own CMake package. Its exported targets carry per-config
# IMPORTED_IMPLIB/IMPORTED_LOCATION, so a Debug build links libwebpd.lib and a
# Release build links libwebp.lib. The find_library() fallback below cannot
# tell the two apart -- it resolves one path for every configuration, which on
# multi-config generators silently links the Release import library (and hence
# the Release DLL) into the Debug binaries.
find_package(WebP CONFIG QUIET)

if(TARGET WebP::webp)
  set(WEBP_LIBRARY WebP::webp)
  set(WEBP_LIBRARIES WebP::webp)

  # Upstream names the mux target WebP::libwebpmux, not WebP::webpmux.
  foreach(_webp_component webpdemux libwebpmux)
    if(TARGET WebP::${_webp_component})
      list(APPEND WEBP_LIBRARIES WebP::${_webp_component})
    endif()
  endforeach()
  unset(_webp_component)

  get_target_property(WEBP_INCLUDE_DIR WebP::webp INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT WEBP_INCLUDE_DIR)
    unset(WEBP_INCLUDE_DIR)
    find_path(WEBP_INCLUDE_DIR NAMES webp/decode.h)
  endif()
  set(WEBP_INCLUDE_DIRS ${WEBP_INCLUDE_DIR})

  set(WEBP_FOUND TRUE)
  if(NOT WebP_FIND_QUIETLY)
    message(STATUS "Found WebP: ${WEBP_LIBRARIES} (CONFIG mode)")
  endif()
else()
  # Look for the header file.

  FIND_PATH(WEBP_INCLUDE_DIR NAMES webp/decode.h)

  if(NOT WEBP_INCLUDE_DIR)
      unset(WEBP_FOUND)
  else()
      MARK_AS_ADVANCED(WEBP_INCLUDE_DIR)

      # Look for the library.
      FIND_LIBRARY(WEBP_LIBRARY NAMES webp)
      FIND_LIBRARY(WEBP_MUX_LIBRARY NAMES webpmux)
      FIND_LIBRARY(WEBP_DEMUX_LIBRARY NAMES webpdemux)

      # handle the QUIETLY and REQUIRED arguments and set WEBP_FOUND to TRUE if
      # all listed variables are TRUE
      INCLUDE(${CMAKE_ROOT}/Modules/FindPackageHandleStandardArgs.cmake)
      FIND_PACKAGE_HANDLE_STANDARD_ARGS(WebP DEFAULT_MSG WEBP_LIBRARY WEBP_INCLUDE_DIR)

      SET(WEBP_LIBRARIES ${WEBP_LIBRARY} ${WEBP_MUX_LIBRARY} ${WEBP_DEMUX_LIBRARY})
      SET(WEBP_INCLUDE_DIRS ${WEBP_INCLUDE_DIR})
  endif()
endif()
