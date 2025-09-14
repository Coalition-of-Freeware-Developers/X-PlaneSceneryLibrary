# --------------------------------
# X-PlaneSceneryLibrary
# --------------------------------

MESSAGE(STATUS "=================================================")
MESSAGE(STATUS "Generating X-Plane Scenery Library Project")

FILE(GLOB XPLIB_HEADER_FILES *.h *.hpp)
FILE(GLOB XPLIB_SOURCE_FILES *.cpp)

ADD_LIBRARY(X-PlaneSceneryLibrary
    ${XPLIB_HEADER_FILES}
    ${XPLIB_SOURCE_FILES}
	${RESOURCE_FILE}
    X-PlaneSceneryLibrary.rc
)
SOURCE_GROUP("Header Files" FILES
	${XPLIB_HEADER_FILES}
)
SOURCE_GROUP("Source Files" FILES
	${XPLIB_SOURCE_FILES}
)
SOURCE_GROUP("Resource" FILES
    ${RESOURCE_FILE}
    X-PlaneSceneryLibrary.rc
)
SOURCE_GROUP("Tests" FILES
    DebugMain.cpp
)

TARGET_COMPILE_DEFINITIONS(X-PlaneSceneryLibrary
    PUBLIC
        XPdata
        $<$<CONFIG:Debug>:SEDX_DEBUG>
        $<$<CONFIG:Release>:SEDX_RELEASE>
)

# --------------------------------

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
