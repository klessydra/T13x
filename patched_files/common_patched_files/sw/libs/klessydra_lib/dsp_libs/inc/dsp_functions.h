#include <stdint.h>
#include "klessydra_defs.h"

#define MHARTID_IDCORE_MASK 15
#define THREAD_POOL_SIZE 4

/* 
If the user adds more scratchpad in the rtl, he must define more scratchpads belwo i.e. spmaddrE, spmaddrF etc..
If the user changes the starting address of the scratchpads in the rtl, he must also change the define values below
*/
#define spmaddrA 0x10000000  // Startung address of SPMA
#define spmaddrB 0x10001000  // Startung address of SPMB
#define spmaddrC 0x10002000  // Startung address of SPMC
#define spmaddrD 0x10003000  // Startung address of SPMD


#ifndef __KLESSYDRACFUNCTIONS_H__
#define __KLESSYDRACFUNCTIONS_H__

int Klessydra_get_coreID();

void CSR_MVSIZE(int rs1);  // Takes on argument as the number of bytes in the vector, and sets the MVSIZE CSR register to that size

int kmemld(void* rd, void* rs1, int rs2);  // loads the vector indexed in rs1, of size rs2 (in Bytes), and stores the result in the scratchpad memory index in rd

int kmemstr(void* rd, void* rs1, int rs2); // loads the vector in the scratchpad memory index of rd, of size rs2 (in Bytes). and stores the result in the main memory index in rs1

int kaddv8(void* rd, void* rs1, void* rs2);   // Perfroms 8-bit  vector addition of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd
int kaddv16(void* rd, void* rs1, void* rs2);  // Perfroms 16-bit vector addition of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd
int kaddv32(void* rd, void* rs1, void* rs2);  // Perfroms 32-bit vector addition of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd

int kaddv8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the kaddv8  function except that it takes the vector size as an additional argument
int kaddv16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kaddv16 function except that it takes the vector size as an additional argument
int kaddv32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kaddv32 function except that it takes the vector size as an additional argument

int kvmul8(void* rd, void* rs1, void* rs2);  // Multiplies each 8-bit  element in the vectors indecies referred in rs1, and rs2, and stores the vecor result in the address referred in rd
int kvmul16(void* rd, void* rs1, void* rs2); // Multiplies each 16-bit element in the vectors indecies referred in rs1, and rs2, and stores the vecor result in the address referred in rd
int kvmul32(void* rd, void* rs1, void* rs2);// Multiplies each 32-bit element in the vectors indecies referred in rs1, and rs2, and stores the vecor result in the address referred in rd

int kvmul8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the kvmul8  function except that it takes the vector size as an additional argument
int kvmul16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kvmul16 function except that it takes the vector size as an additional argument
int kvmul32_v2(void* rd, void* rs1, void* rs2, int size);// Perfroms the same operation as the kvmul32 function except that it takes the vector size as an additional argument

int kdotp8(void* rd, void* rs1, void* rs2);  // Perfroms 8-bit  vector dot-product of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd
int kdotp16(void* rd, void* rs1, void* rs2); // Perfroms 16-bit vector dot-product of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd
int kdotp32(void* rd, void* rs1, void* rs2); // Perfroms 32-bit vector dot-product of the spm indexes referred in rs1 and rs2, and stores the result in spm referred in rd

int kdotp8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the kdotp8  function except that it takes the vector size as an additional argument
int kdotp16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kdotp16 function except that it takes the vector size as an additional argument
int kdotp32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kdotp32  function except that it takes the vector size as an additional argument

int ksvaddsc8(void* rd, void* rs1, void* rs2);  // Perfroms 8-bit  scalar vector addition of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd
int ksvaddsc16(void* rd, void* rs1, void* rs2); // Perfroms 16-bit scalar vector addition of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd
int ksvaddsc32(void* rd, void* rs1, void* rs2); // Perfroms 32-bit scalar vector addition of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd

int ksvaddsc8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksvaddsc8  function except that it takes the vector size as an additional argument
int ksvaddsc16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksvaddsc16 function except that it takes the vector size as an additional argument
int ksvaddsc32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksvaddsc32 function except that it takes the vector size as an additional argument

int ksvmulsc8(void* rd, void* rs1, void* rs2);  // Perfroms 8-bit  scalar vector multiplication of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd
int ksvmulsc16(void* rd, void* rs1, void* rs2); // Perfroms 16-bit scalar vector multiplication of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd
int ksvmulsc32(void* rd, void* rs1, void* rs2); // Perfroms 32-bit scalar vector multiplication of the spm indexes referred in rs1 by the scalar in rs2, and stores the result in spm referred in rd

int ksvmulsc8_v2(void* rd, void* rs1, void* rs2, int size);   // Perfroms the same operation as the ksvmulsc8  function except that it takes the vector size as an additional argument
int ksvmulsc16_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksvmulsc16 function except that it takes the vector size as an additional argument
int ksvmulsc32_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksvmulsc32 function except that it takes the vector size as an additional argument

int ksvmulrf8(void* rd, void* rs1, void* rs2);  // Does 8-bit  scalar vector multiplication of the spm indexe referred in rs1 by the spm scalar index in rs2, and stores the result in spm referred in rd
int ksvmulrf16(void* rd, void* rs1, void* rs2); // Does 16-bit scalar vector multiplication of the spm indexe referred in rs1 by the spm scalar index in rs2, and stores the result in spm referred in rd
int ksvmulrf32(void* rd, void* rs1, void* rs2); // Does 32-bit scalar vector multiplication of the spm indexe referred in rs1 by the spm scalar index in rs2, and stores the result in spm referred in rd

int ksvmulrf8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksvmulrf8  function except that it takes the vector size as an additional argument
int ksvmulrf16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksvmulrf16 function except that it takes the vector size as an additional argument
int ksvmulrf32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksvmulrf32 function except that it takes the vector size as an additional argument

int ksrav8(void* rd, void* rs1, void* rs2);  // Perfroms 8-bit  right arithmetic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd
int ksrav16(void* rd, void* rs1, void* rs2); // Perfroms 16-bit right arithmetic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd
int ksrav32(void* rd, void* rs1, void* rs2); // Perfroms 32-bit right arithmetic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd

int ksrav8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksravf8 function except that it takes the vector size as an additional argument
int ksrav16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksrav16 function except that it takes the vector size as an additional argument
int ksrav32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksrav32 function except that it takes the vector size as an additional argument

int ksrlv8(void* rd, void* rs1, void* rs2);  // Perfroms 8-bit  right logic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd
int ksrlv16(void* rd, void* rs1, void* rs2); // Perfroms 16-bit right logic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd
int ksrlv32(void* rd, void* rs1, void* rs2); // Perfroms 32-bit right logic shift of the spm indexes referred in rs1 by the shift amount in rs2, and stores the result in spm referred in rd

int ksrlv8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the ksrlv8  function except that it takes the vector size as an additional argument
int ksrlv16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksrlv16 function except that it takes the vector size as an additional argument
int ksrlv32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the ksrlv32 function except that it takes the vector size as an additional argument

int kvred8(void* rd, void* rs1);  // Perfroms 8-bit  reduction of the spm index referred in rs1, and stores the scalar result in spm address referred in rd
int kvred16(void* rd, void* rs1); // Perfroms 16-bit  reduction of the spm index referred in rs1, and stores the scalar result in spm address referred in rd
int kvred32(void* rd, void* rs1); // Perfroms 32-bit  reduction of the spm index referred in rs1, and stores the scalar result in spm address referred in rd

int kvred8_v2(void* rd, void* rs1, int size);  // Perfroms the same operation as the ksrlv8  function except that it takes the vector size as an additional argument
int kvred16_v2(void* rd, void* rs1, int size); // Perfroms the same operation as the ksrlv16 function except that it takes the vector size as an additional argument
int kvred32_v2(void* rd, void* rs1,  int size); // Perfroms the same operation as the ksrlv32 function except that it takes the vector size as an additional argument

int kvmuladd8(void* rd, void* rs1, void* rs2, void* rs3);  // Perfroms ksvmulsc8  between vector indexed in rs2 and rs3, and the resulting vector is added with vector indexed in rs1 using kaddv8
int kvmuladd16(void* rd, void* rs1, void* rs2, void* rs3); // Perfroms ksvmulsc16 between vector indexed in rs2 and rs3, and the resulting vector is added with vector indexed in rs1 using kaddv16
int kvmuladd32(void* rd, void* rs1, void* rs2, void* rs3); // Perfroms ksvmulsc32 between vector indexed in rs2 and rs3, and the resulting vector is added with vector indexed in rs1 using kaddv32

int kvmuladd8_v2(void* rd, void* rs1, void* rs2, void* rs3, int size);  // Perfroms the same operation as the kvmuladd8   function except that it takes the vector size as an additional argument
int kvmuladd16_v2(void* rd, void* rs1, void* rs2, void* rs3, int size); // Perfroms the same operation as the kvmuladd16  function except that it takes the vector size as an additional argument
int kvmuladd32_v2(void* rd, void* rs1, void* rs2, void* rs3, int size); // Perfroms the same operation as the kvmuladd65  function except that it takes the vector size as an additional argument

int krelu8(void* rd, void *rs1);   // Perfroms 8-bit  linear rectification of the spm indexes referred in rs1, and stores the result in spm referred in rd
int krelu16(void* rd, void *rs1);  // Perfroms 16-bit linear rectification of the spm indexes referred in rs1, and stores the result in spm referred in rd
int krelu32(void* rd, void *rs1);  // Perfroms 32-bit linear rectification of the spm indexes referred in rs1, and stores the result in spm referred in rd

int krelu8_v2(void* rd, void *rs1, int size);  // Perfroms the same operation as the krelu8  function except that it takes the vector size as an additional argument
int krelu16_v2(void* rd, void *rs1, int size); // Perfroms the same operation as the krelu16 function except that it takes the vector size as an additional argument
int krelu32_v2(void* rd, void *rs1, int size); // Perfroms the same operation as the ksrlv32 function except that it takes the vector size as an additional argument

int kdotpps8(void* rd, void* rs1, void* rs2);  // Performs post scaling 8-bit  dot-product of the spm indexes referred in rs1 and rs2, and stores the scalar result in spm referred in rd
int kdotpps16(void* rd, void* rs1, void* rs2); // Performs post scaling 16-bit dot-product of the spm indexes referred in rs1 and rs2, and stores the scalar result in spm referred in rd
int kdotpps32(void* rd, void* rs1, void* rs2); // Performs post scaling 32-bit dot-product of the spm indexes referred in rs1 and rs2, and stores the scalar result in spm referred in rd

int kdotpps8_v2(void* rd, void* rs1, void* rs2, int size);  // Perfroms the same operation as the kdotpps8  function except that it takes the vector size as an additional argument
int kdotpps16_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kdotpps16 function except that it takes the vector size as an additional argument
int kdotpps32_v2(void* rd, void* rs1, void* rs2, int size); // Perfroms the same operation as the kdotpps32 function except that it takes the vector size as an additional argument

int kdotpps8_v3(void* rd, void* rs1, void* rs2, void* p_scal);  // Perfroms the same operation as the kdotpps8  function except that it takes the scaling factor as an additional argument
int kdotpps16_v3(void* rd, void* rs1, void* rs2, void* p_scal); // Perfroms the same operation as the kdotpps16 function except that it takes the scaling factor as an additional argument
int kdotpps32_v3(void* rd, void* rs1, void* rs2, void* p_scal); // Perfroms the same operation as the kdotpps16 function except that it takes the scaling factor as an additional argument

int kdotpps8_v4(void* rd, void* rs1, void* rs2, void* p_scal,  int size); // Perfroms the same operation as the kdotpps8  function except that it takes "p_scal" and "size" as an additional argument
int kdotpps16_v4(void* rd, void* rs1, void* rs2, void* p_scal, int size); // Perfroms the same operation as the kdotpps16 function except that it takes "p_scal" and "size" as an additional argument
int kdotpps32_v4(void* rd, void* rs1, void* rs2, void* p_scal, int size); // Perfroms the same operation as the kdotpps32 function except that it takes "p_scal" and "size" as an additional argument

int kdotpps8_emul(void* rd, void* rs1, void* rs2, void* p_scal);  // Emulates the same operation as the kdotpps8  using three instructions "kvmul8",  "ksrav8",  "kvred8"
int kdotpps16_emul(void* rd, void* rs1, void* rs2, void* p_scal); // Emulates the same operation as the kdotpps16 using three instructions "kvmul16", "ksrav16", "kvred16"
int kdotpps32_emul(void* rd, void* rs1, void* rs2, void* p_scal); // Emulates the same operation as the kdotpps32 using three instructions "kvmul32", "ksrav32", "kvred32"

int kdotpps8_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size);  // Perfoms the same operation as the kdotpps8_emul  function except that it takes the vector size as additional argument
int kdotpps16_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size); // Perfoms the same operation as the kdotpps16_emul function except that it takes the vector size as additional argument
int kdotpps32_emul_v2(void* rd, void* rs1, void* rs2, void* p_scal, int size); // Perfoms the same operation as the kdotpps32_emul function except that it takes the vector size as additional argument

int kbcast8(void* rd, void *rs1);  // Broadcasts the 8-bit  scalar in rs1 over the entire vector starting at the index referred in rd
int kbcast16(void* rd, void *rs1); // Broadcasts the 16-bit scalar in rs1 over the entire vector starting at the index referred in rd
int kbcast32(void* rd, void *rs1); // Broadcasts the 32-bit scalar in rs1 over the entire vector starting at the index referred in rd

int kbcast8_v2(void* rd, void *rs1, int size);  // Perfroms the same operation as the kbcast8  function except that it takes the vector size as an additional argument
int kbcast16_v2(void* rd, void *rs1, int size); // Perfroms the same operation as the kbcast16 function except that it takes the vector size as an additional argument
int kbcast32_v2(void* rd, void *rs1, int size); // Perfroms the same operation as the kbcast32 function except that it takes the vector size as an additional argument

int kvcp(void* rd, void* rs1);  // Copies the vector specified in the index in rs1 into the destination index in rd
int kvcp_v2(void* rd, void* rs1, int size); // Perfroms the same operation as the kvcp function except that it takes the vector size as an additional argument

/*
The three functions below perfrom full dot product using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
uint8_t* kless_dot_product_8(void* result, void* src1, void* src2, int size);
uint16_t* kless_dot_product_16(void* result, void* src1, void* src2, int size);
uint32_t* kless_dot_product_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector addition between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
void* kless_vector_addition_8(void* result, void* src1, void* src2, int size);
void* kless_vector_addition_16(void* result, void* src1, void* src2, int size);
void* kless_vector_addition_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom multiply the corresponding vector elements in the sources by each other
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector addition between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
int8_t* kless_vector_multiplication_8(void *result, void* src1, void* src2, int size);
int16_t* kless_vector_multiplication_16(void *result, void* src1, void* src2, int size);
int32_t* kless_vector_multiplication_32(void *result, void* src1, void* src2, int size);

/*
The three functions below perfrom full dot product including post scaling between 
the multiplication and the accumulation using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does post scaling dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
int8_t* kless_post_scal_dot_product_8(void *result, void* src1, void* src2, void* p_scal, int size);
int16_t* kless_post_scal_dot_product_16(void *result, void* src1, void* src2, void* p_scal, int size);
int32_t* kless_post_scal_dot_product_32(void *result, void* src1, void* src2, void* p_scal, int size);

/*
The three functions below perfrom "through emulation" full dot product including 
post scaling between the multiplication and the accumulation using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 emulates post scaling dot product between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
int8_t* kless_post_scal_dot_product_emul_8(void *result, void* src1, void* src2, void* p_scal, int size);
int16_t* kless_post_scal_dot_product_emul_16(void *result, void* src1, void* src2, void* p_scal, int size);
int32_t* kless_post_scal_dot_product_emul_32(void *result, void* src1, void* src2, void* p_scal, int size);

/*
The three functions below perfrom full vector addition using multi-threading
thread 1 loads the vector (of size int size) from main memory into spmA and exits
thread 2 does vector reduction by accumulatin the elements in vect1
thread 2 then stores the value back in the main memory at the address in "result"
*/
int8_t* kless_vector_reduction_8(void *result, void* src, int size);
int16_t* kless_vector_reduction_16(void *result, void* src, int size);
int32_t* kless_vector_reduction_32(void *result, void* src, int size);

/*
The three functions below perfrom full vector subtraction using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads vector 2 (of size int size) from main memory into spmB and exits
thread 3 does vector subtraction between vect1 and vect2
thread 3 then stores the value back in the main memory at the address in "result"
*/
int8_t*  kless_vector_subtraction_8(void* result, void* src1, void* src2, int size);
int16_t* kless_vector_subtraction_16(void* result, void* src1, void* src2, int size);
int32_t* kless_vector_subtraction_32(void* result, void* src1, void* src2, int size);


/*
The three functions below perfrom full right arithmetic shift using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does right arithmetic shift between vect1 and the shift amount in src2
thread 2 then stores the value back in the main memory at the address in "result"
*/
int8_t*  kless_vector_right_shift_arith_8(void* result, void* src1, void* src2, int size);
int16_t* kless_vector_right_shift_arith_16(void* result, void* src1, void* src2, int size);
int32_t* kless_vector_right_shift_arith_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full right logic shift using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does right logic shift between vect1 and the shift amount in src2
thread 2 then stores the value back in the main memory at the address in "result"
*/
uint8_t*  kless_vector_right_shift_logic_8(void* result, void* src1, void* src2, int size);
uint16_t* kless_vector_right_shift_logic_16(void* result, void* src1, void* src2, int size);
uint32_t* kless_vector_right_shift_logic_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does scalar vector addition between vect1 and the scalar in src2 (src2 is not an index)
thread 2 then stores the value back in the main memory at the address in "result"
*/
int8_t*  kless_scalar_vect_add_rf_8(void* result, void* src1, void* src2, int size);
int16_t* kless_scalar_vect_add_rf_16(void* result, void* src1, void* src2, int size);
int32_t* kless_scalar_vect_add_rf_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector addition using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads scalar 1 from main memory into spmB and exits
thread 3 does scalar vector addition between vect1 and the scalar in src2
thread 3 then stores the value back in the main memory at the address in "result"
*/
int8_t*  kless_scalar_vect_add_sc_8(void* result, void* src1, void* src2, int size);
int16_t* kless_scalar_vect_add_sc_16(void* result, void* src1, void* src2, int size);
int32_t* kless_scalar_vect_add_sc_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector multiplication using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does scalar vector multiplication between vect1 and the scalar in src2 (src2 is not an index)
thread 2 then stores the value back in the main memory at the address in "result"
*/
uint8_t*  kless_scalar_vect_mult_rf_8(void* result, void* src1, void* src2, int size);
uint16_t* kless_scalar_vect_mult_rf_16(void* result, void* src1, void* src2, int size);
uint32_t* kless_scalar_vect_mult_rf_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full scalar vector multiplication using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 loads scalar 1 from main memory into spmB and exits
thread 3 does scalar vector multiplication between vect1 and the scalar in src2
thread 3 then stores the value back in the main memory at the address in "result"
*/
uint8_t*  kless_scalar_vect_mult_sc_8(void* result, void* src1, void* src2, int size);
uint16_t* kless_scalar_vect_mult_sc_16(void* result, void* src1, void* src2, int size);
uint32_t* kless_scalar_vect_mult_sc_32(void* result, void* src1, void* src2, int size);

/*
The three functions below perfrom full vector rectification using multi-threading
thread 1 loads vector 1 (of size int size) from main memory into spmA and exits
thread 2 does vector rectification of vect1
thread 2 then stores the value back in the main memory at the address in "result"
*/
int8_t*  kless_rectify_linear_unit_8(void* result, void* src1, int size);
int16_t* kless_rectify_linear_unit_16(void* result, void* src1, int size);
int32_t* kless_rectify_linear_unit_32(void* result, void* src1, int size);

/*
The three functions below perfrom vector broadcast
there are no vector loads in this function
thread 1 does vector broadcast of the "src" (src is a scalar and not an index) into "dest
thread 1 then stores the value of "dest" back in the main memory at the address in "result"
*/
int8_t*  kless_scalar_broadcast_8(void *result, void *dest, void* src, int size);
int16_t* kless_scalar_broadcast_16(void *result, void *dest, void* src, int size);
int32_t* kless_scalar_broadcast_32(void *result, void *dest, void* src, int size);

/*
TThe function below is for debugging purposes and might not serve useful to the user, use
instead the function called "kvcp" or "kvcp_v2" to od vector copies
it laods a vector from main mem into spmA,
the vector spmA is copied into spmB. and the resut is stored back in the main memory 
at the index in "result
*/
uint32_t* kless_vector_copy(void* result, void* src1, int size);

#endif
