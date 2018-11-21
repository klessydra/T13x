set(SOURCES
	src/addBias.c
	src/classifica.c
	src/convolution2D.c
	src/cumulativeSum.c
	src/displayResult.c
	src/fullyconnect.c
	src/getBias.c
	src/getWeights.c
	src/input.c
	src/kern.c
	src/matrixReset.c
	src/maxpool.c
	src/relu.c
	src/softmax.c
	src/testo.c
	)
	
set(HEADERS
    inc/definitions_data_test.h
    )

#set(CMAKE_C_COMPILER klessydra-unknown-elf-gcc)
#set(CMAKE_C_FLAGS "-O3 -g")

include_directories(inc/)

add_library(kless_vgg_libs STATIC ${SOURCES} ${HEADERS})

