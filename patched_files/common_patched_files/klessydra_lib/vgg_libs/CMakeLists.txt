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
	src/layer0_bias.c
	src/layer1_bias.c
	src/layer1_filters.c
	src/layer2_bias.c
	src/layer2_filters.c
	src/layer4_bias.c
	src/layer4_filters.c
	src/layer5_bias.c
	src/layer5_filters.c
	src/layer7_bias.c
	src/layer7_filters.c
	src/layer8_bias.c
	src/layer8_filters.c
	src/layer9_bias.c
	src/layer9_filters.c
	src/layer11_bias.c
	src/layer11_filters.c
	src/layer12_bias.c
	src/layer12_filters.c
	src/layer13_bias.c
	src/layer13_filters.c
	src/layer15_bias.c
	src/layer15_filters.c
	src/layer16_bias.c
	src/layer16_filters.c
	src/layer17_bias.c
	src/layer17_filters.c
	src/layer19_bias.c
	src/layer19_filters.c
	src/layer20_bias.c
	src/layer20_filters.c
	src/layer21_bias.c
	src/layer21_filters.c
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

