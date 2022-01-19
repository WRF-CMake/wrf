set(GUNZIP_FILES
    p3_lookupTable_1.dat-5.3-3momI
)
foreach (GUNZIP_FILE ${GUNZIP_FILES})
    add_custom_command(
        OUTPUT ${GUNZIP_FILE}
        COMMAND bash -c "gunzip -c ${CMAKE_CURRENT_SOURCE_DIR}/${GUNZIP_FILE}.gz >${GUNZIP_FILE}"
        DEPENDS ${GUNZIP_FILE}.gz
    )
endforeach()

foreach(gen_file ${GUNZIP_FILES})
    list(APPEND GEN_FILES_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${gen_file})
endforeach()

add_custom_target(generate_run ALL DEPENDS ${GEN_FILES_DEPENDS})
