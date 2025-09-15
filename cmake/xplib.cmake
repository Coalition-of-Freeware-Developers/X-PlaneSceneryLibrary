# --------------------------------
# X-PlaneSceneryLibrary
# --------------------------------

MESSAGE(STATUS "=================================================")
MESSAGE(STATUS "Generating X-Plane Scenery Library Project")

SET(XPLIB_PLATFORM_SOURCES)
IF(WIN32)
    LIST(APPEND XPLIB_PLATFORM_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/xplib/config/X-PlaneSceneryLibrary.rc)
ENDIF()

# Discover headers and sources from project subfolders
FILE(GLOB_RECURSE XPLIB_HEADER_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/xplib/include/*.h"
    "${CMAKE_CURRENT_SOURCE_DIR}/xplib/include/*.hpp"
)
FILE(GLOB_RECURSE XPLIB_SOURCE_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/xplib/src/*.cpp"
)

# --------------------------------

ADD_LIBRARY(XPSceneryLib
    ${XPLIB_HEADER_FILES}
    ${XPLIB_SOURCE_FILES}
	${XPLIB_PLATFORM_SOURCES}

)

# Use project-wide C++20 standard (required for <format> etc.)
SET_TARGET_PROPERTIES(XPSceneryLib PROPERTIES
    CXX_STANDARD 20
    CXX_STANDARD_REQUIRED YES
    LINKER_LANGUAGE CXX
)

# Source groups for IDE organization
SOURCE_GROUP("Header Files" FILES
	${XPLIB_HEADER_FILES}
)
SOURCE_GROUP("Source Files" FILES
	${XPLIB_SOURCE_FILES}
)
SOURCE_GROUP("Resource" FILES
    ${XPLIB_PLATFORM_SOURCES}
)
SOURCE_GROUP("Tests" FILES
    DebugMain.cpp
)

# --------------------------------

TARGET_COMPILE_DEFINITIONS(XPSceneryLib
    PUBLIC
		UNICODE
		_UNICODE
		_CRT_SECURE_NO_WARNINGS
		$<$<CONFIG:Debug>:_CONSOLE>
		$<$<CONFIG:Debug>:_DEBUG>
        $<$<CONFIG:Debug>:SEDX_DEBUG>
        $<$<CONFIG:Release>:SEDX_RELEASE>
)

TARGET_INCLUDE_DIRECTORIES(XPSceneryLib
	PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/xplib/include
	PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/xplib/src
)

# Ensure consistent UTF-8 source decoding on MSVC (prevents fmt / Unicode warnings)
IF (MSVC)
    TARGET_COMPILE_OPTIONS(XPSceneryLib PRIVATE /utf-8)
ENDIF()

# --------------------------------

# Set output directory
SET_TARGET_PROPERTIES(XPSceneryLib PROPERTIES
    OUTPUT_NAME "XPSceneryLib"
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
    ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

IF (WIN32)
    FIND_PACKAGE(Python3 COMPONENTS Interpreter REQUIRED)

    # Script path
    SET(XPLIB_VERSION_SCRIPT ${CMAKE_SOURCE_DIR}/scripts/increment_xplib_build.py)

    IF (MSVC)
        # PRE_BUILD supported by Visual Studio
        ADD_CUSTOM_COMMAND(
            TARGET XPSceneryLib
            PRE_BUILD
            COMMAND ${Python3_EXECUTABLE} ${XPLIB_VERSION_SCRIPT}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMENT "Incrementing X-Plane Scenery Library build number (resource.h)"
            VERBATIM
        )
    ELSE()
        # Fallback for other Windows generators
        ADD_CUSTOM_TARGET(IncrementXPlaneSceneryLibraryVersion
            COMMAND ${Python3_EXECUTABLE} ${XPLIB_VERSION_SCRIPT}
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            COMMENT "Incrementing X-Plane Scenery Library build number (resource.h)"
            VERBATIM
            BYPRODUCTS ${CMAKE_SOURCE_DIR}/source/resource.h
        )
        ADD_DEPENDENCIES(XPSceneryLib IncrementXPlaneSceneryLibraryVersion)
    ENDIF()
ENDIF()

# --------------------------------
