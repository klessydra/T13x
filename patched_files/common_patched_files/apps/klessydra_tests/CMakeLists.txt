include_directories(
  ${CMAKE_SOURCE_DIR}/libs/klessydra_lib/general_libs/inc
  ${CMAKE_SOURCE_DIR}/libs/klessydra_lib/dsp_libs/inc
  )
#add_subdirectory(klessydra_dsp_tests)
add_subdirectory(klessydra_general_tests)
add_subdirectory(klessydra_dsp_tests)

