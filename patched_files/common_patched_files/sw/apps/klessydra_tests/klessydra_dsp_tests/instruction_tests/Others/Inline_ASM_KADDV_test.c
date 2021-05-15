//#include"klessydraCfunctions.h"

const int SPMADDR1 = 0x00109000;
const int SPMADDR2 = 0x00109200;
const int SPMADDR3 = 0x00109400;

int vect1[] = {0, 1, 2, 3};
int vect2[] = {3, 2, 1, 0};
int vect3[] = {0, 0, 0, 0};

int size1 = sizeof(vect1);
int size2 = sizeof(vect2);
int size3 = sizeof(vect3);

static int section1 = 0;
int* psection1 = &section1;

static int section2 = 0;
int* psection2 = &section2;

int flag = 0;
int* pflag = &flag;

int main()
{
	int key = 1;

	asm volatile(
		"csrrw zero, mcycle, zero;"
		"csrs 0x300, 0x8;"
		"amoswap.w.aq %0, %0, (%1);"			// il primo thread che arriva inserisce acquisce il dominio della sezione SCP_copyin_vect1
		"bnez %0, SCP_copyin_vect2;"			// gli altri threads saltano alla sezione successiva
		"SCP_copyin_vect1:"				// SECTION1:
		"	kmemld %2, %3, %4;"			// 	il thread che ha acqisito la sezione carica il primo vettore da memoria
		"	wfi;"					// 	e va in WFI - potrebbe saltare alla fine della funzione
		"SCP_copyin_vect2:"				// SECTION2:
		"	amoswap.w.aq %0, %0, (%5);"		//	il primo thread che arriva inserisce acquisce il dominio della sezione SCP_copyin_vect2
		"	bnez %0, SCP_vadd;"			//	l'ultimo rimasto salta alla sezione successiva
		"	kmemld %6, %7, %8;"			//	il thread che ha acqisito la sezione carica il primo vettore da memoria
		"	li %9, 1;"				//	alzo il flag di fine caricamento vettori
		"       sw %9, 0(%13); "			// 	carico la variabile flag in memoria globale
		"	csrw 0xBF0, %4; "			//	setto il registro vsize
		"	wfi;"					//	e va in WFI - potrebbe saltare alla fine della funzione
		"SCP_vadd:"					// SECTION3:
                "       lw %9, 0(%13);"				//	carico la variabile flag da memoria globale
		"	beqz %9, SCP_vadd;"			//	aspetto che termini il caricamento dei due vettori
		"	csrw 0xBF0, %4; "			//	setto il registro vsize
		"	kaddv %10, %2, %6;"			//	faccio eseguire la somma alla DSP unit
		"	kmemstr %11, %10, %12;"			//	faccio lo store dalla somma in RAM
                "       j 0x90000;"
		:
		:"r" (key), "r" (psection1), 
		 "r" (SPMADDR1), "r" (vect1), "r" (size1),
		 "r" (psection2),
		 "r" (SPMADDR2), "r" (vect2), "r" (size2),
		 "r" (flag), 
		 "r" (SPMADDR3), "r" (vect3), "r" (size3),
		 "r" (pflag)
		:
	
	);
}
