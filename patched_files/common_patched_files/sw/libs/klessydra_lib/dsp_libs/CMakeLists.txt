set(SOURCES
    src/CSR_MVSIZE.c
    src/kaddv.c
	src/kbcast.c
    src/kdotp.c
    src/kdotpps.c
    src/kdotpps_emul.c
	src/krelu.c
    src/ksrav.c
    src/ksrlv.c
    src/ksvaddrf.c
    src/ksvaddsc.c
    src/ksvmulrf.c
    src/ksvmulsc.c
    src/kvcp.c
    src/kvmul.c
    src/kvmuladd.c
    src/kvred.c
    src/kless_dot_product.c
	src/kless_post_scal_dot_product.c
	src/kless_post_scal_dot_product_emul.c
    src/kless_rectify_linear_unit
    src/kless_vector_addition.c
    src/kless_vector_subtraction.c
    src/kless_vector_multiplication.c
	src/kless_vector_reduction.c
    src/kless_scalar_vect_add.c
    src/kless_scalar_vect_mult.c
    src/kless_scalar_broadcast.c
	src/kless_vector_copy.c
    src/kless_vector_right_shift_arith.c
    src/kless_vector_right_shift_logic.c
    src/kmemld.c
    src/kmemstr.c
    )

set(HEADERS
    inc/dsp_functions.h
    )

include_directories(inc/)

add_library(kless_dsp_libs STATIC ${SOURCES} ${HEADERS})

