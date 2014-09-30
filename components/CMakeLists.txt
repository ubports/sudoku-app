file(GLOB COMPONENTS_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.qml)
add_custom_target(sudoku-app_ComponentsFiles ALL SOURCES ${COMPONENTS_SRC_FILES})
