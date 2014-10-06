file(GLOB JS_SRC_FILES
     RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
     *.js)
add_custom_target(sudoku-app_JsFiles ALL SOURCES ${JS_SRC_FILES})
