# --------------------------------
# X-PlaneSceneryLibrary
# --------------------------------

MESSAGE(STATUS "=================================================")
MESSAGE(STATUS "Generating X-Plane Scenery Library Project")

IF(WIN32)
    LIST(APPEND XPLIB_PLATFORM_SOURCES ${CMAKE_SOURCE_DIR}/xplib/config/X-PlaneSceneryLibrary.rc)
ENDIF()
SET(XPLIB_PLATFORM_SOURCES)
FILE(GLOB XPLIB_HEADER_FILES *.h *.hpp)
FILE(GLOB XPLIB_SOURCE_FILES *.cpp)

# --------------------------------

ADD_LIBRARY(X-PlaneSceneryLibrary
    ${XPLIB_HEADER_FILES}
    ${XPLIB_SOURCE_FILES}
	${RESOURCE_FILE}
	${XPLIB_PLATFORM_SOURCES}

)

# Use project-wide C++20 standard (required for <format> etc.)
SET_TARGET_PROPERTIES(X-PlaneSceneryLibrary PROPERTIES CXX_STANDARD 20 CXX_STANDARD_REQUIRED YES)

# Source groups for IDE organization
SOURCE_GROUP("Header Files" FILES
	${XPLIB_HEADER_FILES}
)
SOURCE_GROUP("Source Files" FILES
	${XPLIB_SOURCE_FILES}
)
SOURCE_GROUP("Resource" FILES
    ${RESOURCE_FILE}
	${XPLIB_PLATFORM_SOURCES}
)
SOURCE_GROUP("Tests" FILES
    DebugMain.cpp
)

# --------------------------------

TARGET_COMPILE_DEFINITIONS(X-PlaneSceneryLibrary
    PUBLIC
		UNICODE
		_UNICODE
		_CRT_SECURE_NO_WARNINGS
        XPdata
		$<$<CONFIG:Debug>:_CONSOLE>
		$<$<CONFIG:Debug>:_DEBUG>
        $<$<CONFIG:Debug>:SEDX_DEBUG>
        $<$<CONFIG:Release>:SEDX_RELEASE>
)

TARGET_INCLUDE_DIRECTORIES(X-PlaneSceneryLibrary
	PUBLIC
		${CMAKE_SOURCE_DIR}/xplib/includes
	PRIVATE
		${CMAKE_SOURCE_DIR}
		${CMAKE_SOURCE_DIR}/xplib/src
)

# Ensure consistent UTF-8 source decoding on MSVC (prevents fmt / Unicode warnings)
IF (MSVC)
	TARGET_COMPILE_OPTIONS(xMath PRIVATE /utf-8)
ENDIF()

# --------------------------------

# Set output directory
SET_TARGET_PROPERTIES(X-PlaneSceneryLibrary PROPERTIES
    OUTPUT_NAME "X-PlaneSceneryLibrary"
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
            TARGET X-PlaneSceneryLibrary
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
        ADD_DEPENDENCIES(X-PlaneSceneryLibrary IncrementXPlaneSceneryLibraryVersion)
    ENDIF()
ENDIF()

# --------------------------------
