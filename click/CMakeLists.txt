if(CLICK_MODE)
    if(NOT BZR_REVNO)
        set(BZR_REVNO "latest")
    endif(NOT BZR_REVNO)
    configure_file(manifest.json.in ${CMAKE_CURRENT_BINARY_DIR}/manifest.json)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/manifest.json sudoku.apparmor
            DESTINATION ${CMAKE_INSTALL_PREFIX})

    # make the click files visible on qtcreator
    file(GLOB CLICK_FILES
         RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
         *.json *.json.in *.apparmor)

    add_custom_target(com_ubuntu_sudoku_CLICKFiles ALL SOURCES ${CLICK_FILES})
endif(CLICK_MODE)
