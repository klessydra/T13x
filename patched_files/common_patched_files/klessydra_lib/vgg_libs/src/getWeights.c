#include"definitions_data_test.h"
/*
//VERSIONE LITE.A PER VD_F2
//getWeights(FILE *fp, int num_param, int i, int k, int maxColumn, int maxRow, float *kernel)
void getWeights(FILE *fp, int num_param, int k, int maxColumn, float *kernel)
{
	float variable;
	int q = 0;
	int column = k*9;

	while (fscanf(fp, "%f", &variable) > 0){
		kernel[q] = variable;
		q++;
		if (q == num_param) 
		{
			break;
		}
		column++;
	}
}*/
//Versione lite.B
//getWeights(FILE *fp, int num_param, int i, int k, int maxColumn, int maxRow, float *kernel)
float *pt_filt_min;
float *pt_filt_max;
void getWeights(const float *fp, int num_param, float *kernel, int cont)
{
	float variable;
	int q = 0;
	int ind=0;
	//int column = k*9;

	for (ind=0; ind<9; ind++){
	
		kernel[ind] = fp[cont*9+ind];
		
	}
	
}
/*
{
	float variable;
	int q = 0;
	int row = i, column = k*9;

	while (fscanf(fp, "%f", &variable) > 0)
	{
		kernel[q] = variable;
		q++;
		if (q == num_param) 
		{
			break;
		}
	column++;
	}
}*/
//questo codice non è per niente robusto, ogni volta che entra, sin dal primo ciclo, legge solo per il
//numero di volte indicato su num_param che viene usato per discretizzare, forse alla base di questo funzionamento
//è il fatto che ogni volta viene fatto una lettura sullo stream che parte da dove era rimasto l'iterazione 
//precedente, quindi tutto calza

//per come avevo pensato io la mia funzione, invece, tutto si basa sul fatto che ognivolta che si entra
//nella chiamata a funzione, si apre uno streaming del tutto nuovo del file, quindi forse il mio è più lento perchè
//pur di essere robusto, per ogni volta che esegui la chiamata i parametri verranno pescati solo quando le coordinate
//saranno quelle giuste.
//come fare un programma robusto, partendo dai presupposti del programma proposto dai ragazzi?

