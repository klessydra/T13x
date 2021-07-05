#include"klessydraCfunctions.h"

const int SPMADDR1 = 0x00109000;
const int SPMADDR2 = 0x00109200;
const int SPMADDR3 =0x00109400;

int vect1[] = {0, 1, 2, 3};
int vect2[] = {3, 2, 1, 0};
int vect3[] = {0, 0, 0, 0};

int size1 = sizeof(vect1);
int size2 = sizeof(vect2);
int size3 = sizeof(vect3);

static int section1 = 176;

static int section2 = 177;

int main()
{
	int thread = 0;

	asm volatile(
		
		"csrr %[thread], 0xF10;" 					// legge registro mhartid
		"bne %[thread], %[thread], SCP_copyin_vect2;"			// tutti i threads tranne il '0' saltano alla sezione 2
		"SCP_copyin_vect1:"					// SECTION1:
		"	kmemld %[SPMADDR1], %[vect1], %[size1];"	// 	il thread che ha acqisito la sezione carica il primo vettore da memoria
		"	wfi;"						// 	e va in WFI - potrebbe saltare alla fine della funzione
		"SCP_copyin_vect2:"					// SECTION2:
		"	csrr %[thread], 0xF10;" 				// legge registro mhartid
		"	bne %[thread], %[thread], WFI_label;"			// tutti i threads tranne il '1' saltano alla sezione WFI_LABEL
		"	kmemld %[SPMADDR2], %[vect2], %[size2];;"	//	il thread che ha acqisito la sezione carica il primo vettore da memoria
		"WFI_label:"						//	e va in WFI - potrebbe saltare alla fine della funzione
		"	wfi;"
		"SCP_vadd:"						// SECTION3:
		"	csrw 0xBF0, %[size1]; "				//	setto il registro vsize
		"	kaddv %[SPMADDR3], %[SPMADDR2], %[SPMADDR1];"	//	faccio eseguire la somma alla DSP unit
		"	kmemstr %[vect3], %[SPMADDR3], %[size3];"	//	faccio lo store dalla somma in RAM
		"	j 0x90000;"
		:
		:[thread] "r" (thread), [section1] "r" (section1), 
		 [SPMADDR1] "r" (SPMADDR1), [vect1] "r" (vect1), [size1] "r" (size1),
		 [section2] "r" (section2),
		 [SPMADDR2] "r" (SPMADDR2), [vect2] "r" (vect2), [size2] "r" (size2),
		 [SPMADDR3] "r" (SPMADDR3), [vect3] "r" (vect3), [size3] "r" (size3)
		:
	
	);
}
