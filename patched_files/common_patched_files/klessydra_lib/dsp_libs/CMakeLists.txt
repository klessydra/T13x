set(SOURCES
    src/CSR_MVSIZE.c
    src/kaddv.c
    src/kdotp.c
    src/ksvmul.c
    src/kless_dot_product.c
    src/kless_vector_addition.c
    src/kless_scalar_vect_mult.c
    src/kmemld.c
    src/kmemstr.c
    )

set(HEADERS
    inc/dsp_functions.h
    )

#set(CMAKE_C_COMPILER klessydra-unknown-elf-gcc)
#set(CMAKE_C_FLAGS "-O3 -g")

include_directories(inc/)

add_library(kless_dsp_libs STATIC ${SOURCES} ${HEADERS})

