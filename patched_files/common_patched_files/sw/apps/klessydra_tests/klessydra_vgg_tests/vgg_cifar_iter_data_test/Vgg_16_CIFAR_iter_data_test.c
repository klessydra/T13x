#include"definitions_data_test.h"

union FeatureMaps
{
	// float lay_1[64][SIZE_L1_2][SIZE_L1_2]; 		// conv
	// float lay_2[64][SIZE_L1_2][SIZE_L1_2]; 		// conv

	float lay_3[64][SIZE_L3_5][SIZE_L3_5]; 		// pool

	// float lay_4[128][SIZE_L3_5][SIZE_L3_5]; 		// conv
	// float lay_5[128][SIZE_L3_5][SIZE_L3_5]; 		// conv

	float lay_6[128][SIZE_L6_9][SIZE_L6_9];		// pool

	float lay_7[256][SIZE_L6_9][SIZE_L6_9];		// conv
	float lay_8[256][SIZE_L6_9][SIZE_L6_9];		// conv
	float lay_9[256][SIZE_L6_9][SIZE_L6_9];		// conv

	float lay_10[256][SIZE_L10_13][SIZE_L10_13];		// pool

	float lay_11[512][SIZE_L10_13][SIZE_L10_13];		// conv
	float lay_12[512][SIZE_L10_13][SIZE_L10_13];		// conv
	float lay_13[512][SIZE_L10_13][SIZE_L10_13];		// conv

	float lay_14[512][SIZE_L14_17][SIZE_L14_17];		// pool

	float lay_15[512][SIZE_L14_17][SIZE_L14_17];		// conv
	float lay_16[512][SIZE_L14_17][SIZE_L14_17];		// conv
	float lay_17[512][SIZE_L14_17][SIZE_L14_17];		// conv

	float lay_18[512][SIZE_L18][SIZE_L18];		// pool

	float lay_19[4096];			// fc
	float lay_20[4096];			// fc
	float lay_21[OUTPUT_SIZE];			// fc

	float lay_22[OUTPUT_SIZE];			// softmax
};

/* Matrici di appoggio per memorizzare i risultati di ogni convoluzione prima di salvarli nei vari layer */
union TemporaryMatrix
{
	float temp224[224][224];
	float temp112[112][112];
	float temp56[56][56];
	float temp28[28][28];
	float temp14[14][14];
};

union KernelVector
{
	float kernel_9[9];
	float kernel_4096[4096];
	float kernel_25088[25088];
};


int main(int argc, char *argv[])
{	printf("\t\tInizioprog_iterativo_da_microcontrollore\n");
	
	// clock_t end;
	int lt=0;
	
	float x;						// variabile di appoggio per la lettura da file
	int k = 0, i = 0, j = 0;  		// variabili contatore

	float input_int[CHANNEL_SIZE][INPUT_SIZE][INPUT_SIZE];		// immagine di ingresso (RGB)

	float *punt, *punt2;			// puntatori per le feature maps
	float bias;

	union FeatureMaps odds;
	union FeatureMaps even;
	union KernelVector kern;
	
			//	volatile float supp_1[8][INPUT_SIZE][INPUT_SIZE];
			//	volatile float supp_2[8][INPUT_SIZE][INPUT_SIZE];
	
	
	float lay_1[SIZE_L1_2][SIZE_L1_2];
	float lay_2[SIZE_L1_2][SIZE_L1_2];
	float lay_4[SIZE_L3_5][SIZE_L3_5];
	float lay_5[SIZE_L3_5][SIZE_L3_5];

	lt=0;
	int uni_ind=0;
	
	// Normalizzazione zero-center
	//print for debugging
	printf("durante ZEROCENT HO:\n");
		
    for (k = 0; k < CHANNEL_SIZE; k++)
    {
		for (i = 0; i < INPUT_SIZE; i++)
			{
			    for (j = 0; j < INPUT_SIZE; j++)
				{		
					uni_ind=k*(INPUT_SIZE*INPUT_SIZE)+i*INPUT_SIZE+j;
	            	input_int[k][i][j] = input[k][i][j] - layer0_bias[uni_ind];
	            	printf("%d ", (int)input_int[k][i][j]);
	            	
			    }
			}
	}
	for (i=0 ;i<2; i++){
	printf("FINITO ZEROCENT\n");
	}
	uni_ind=0;	
	

	// layer1 - layer2 - layer3 CONV3-64 + POOL /
	int mf1=0;
	int mb1=0;
	int mf2=0;
	int mb2=0;
	int ind=0;
	const float* ptf1 = &layer1_filters[0];
	const float* ptb1 = &layer1_bias[0];
	const float* ptf2 = &layer2_filters[0];
	const float* ptb2 = &layer2_bias[0];
	
	for (i=0 ;i<2; i++){
	printf("COMINCIO LAYER 123\n");
	}
	uni_ind=0;
	for (k = 0; k < 64; k++)
	{
	printf("Ora eseguo i calcoli per la uscita %d-esima di Layer_3\n",(k+1));
		for (i = 0; i < 64; i++)
		{
			for (j = 0; j < CHANNEL_SIZE; j++)
			{
			
				getWeights(ptf1, 9, kern.kernel_9, mf1);
				
				mf1++;
				convolution2D(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				printf("Layer_1: conv %d*%d alla riga %d\n",(j+1),(j+1),(i+1));
				//convolution2D_KE(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				//convolution2D_KF(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				//convolution2D_KD(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				//convolution2D_KB(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				//convolution2D_KH(SIZE_L1_2, input_int[j], kern.kernel_9, &lay_1[0][0]);
				
			}
			printf("Terminate le 3 conv di Layer_1 di riga:%d\n",(i+1));
			
			//bias = getBias(ptb1,mb1);
			bias= ptb1[mb1];
			
			mb1++;
			addBias(SIZE_L1_2, &lay_1[0][0], bias);
			relu(SIZE_L1_2, &lay_1[0][0]);
			
			getWeights(ptf2, 9, kern.kernel_9, mf2);
			
			mf2++;
			convolution2D(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			printf("Layer_2: conv %d*%d alla riga %d\n",(i+1),(i+1),(k+1));
			//convolution2D_KE(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			//convolution2D_KF(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			//convolution2D_KD(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			//convolution2D_KB(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			//convolution2D_KH(SIZE_L1_2, &lay_1[0],  kern.kernel_9, &lay_2[0][0]);
			
			matrixReset(SIZE_L1_2, &lay_1[0][0]);
		}
		printf("Terminate le 64 conv di Layer_2 di riga:%d\n",(j+1));
		mf1=0;		// rewind del file per la ri-lettura dei 64 filtri del layer 1
		mb1=0;
		//bias = getBias(ptb2,mb2);
		bias=ptb2[mb2];
		
		mb2++;
		addBias(SIZE_L1_2, &lay_2[0][0], bias);
		relu(SIZE_L1_2, &lay_2[0][0]);
		maxpool(SIZE_L1_2, &lay_2[0][0], SIZE_L3_5, &odds.lay_3[k][0][0]);
		matrixReset(SIZE_L1_2, &lay_2[0][0]);
	}	
	
	
	lt=3;
	printf("DOPO LAYER 3 HO:\n");
	
	//stampa a video su modelsim
	for (k = 0; k < 64; k++){ 
			for (i = 0; i < SIZE_L3_5; i++){
				for (j = 0; j < SIZE_L3_5; j++)
				{
					printf("%d ", (int)odds.lay_3[k][i][j]);
				}
			}
		}
		
	
	printf("fine layer %d\n",lt);
	
	
	
	/*
	// layer4 - layer5 - layer6 CONV3-128 + POOL //
	fp = fopen("layer4_filters.txt", "r");
	fp1 = fopen("layer4_bias.txt", "r");
	fp2 = fopen("layer5_filters.txt", "r");
	fp3 = fopen("layer5_bias.txt", "r");
	// Itera sui 128 filtri del layer 5. L'u-esimo filtro contiene 3x3x128 parametri. Ogni set da 9 di questi
    // parametri deve essere convoluto con le 128 matrici prese dal layer 4 ed in uscita si avrà dopo
	// la somma con i bias e la relu un set di 128 matrici 112x112. Effettua quindi l'operazione di maxpool
	// e salva il risultato in even.lay_6. Si ottiene un set di 128 matrici 56x56 //
	for (k = 0; k < 128; k++)
	{
		//Fissato l'u-esimo filtro del layer 5, itera sui 128 filtri del layer 4. L'i-esimo filtro contiene 3x3x64 parametri.
		// Ogni set da 9 di questi parametri deve essere convoluto con le 64 matrici prese dal layer 3 ed in uscita si avrà dopo
	 	// la somma con i bias e la relu un set di 128 matrici 112x112. //
		for (i = 0; i < 128; i++)
		{
		// Per ognuna delle 64 matrici 16x16 provenienti da even.lay_3, effettua una convoluzione con la k-esima componente
		// del filtro i-esimo del layer4, somma i risultati in lay_4 e dopo 64 conv effettua la somma
		// con i bias e la relu //
			for (j = 0; j < 64; j++)
			{
				getWeights(fp, 9, kern.kernel_9);
				// convolution2D(112, &odds.lay_3[j][0][0], kern.kernel_9, &lay_4[0][0]);
				convolution2D(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);
				convolution2D_KB(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);
				convolution2D_KD(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);
				convolution2D_KE(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);
				convolution2D_KF(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);
				convolution2D_KH(SIZE_L3_5, odds.lay_3[j], kern.kernel_9, &lay_4[0][0]);

			}
			bias = getBias(fp1);
			addBias(SIZE_L3_5, &lay_4[0][0], bias);
			relu(SIZE_L3_5, &lay_4[0][0]);
			// Ottenuta l'immagine di lay_4, effettua la convoluzione con la componente i-esima
			// del filtro u-esimo del layer5 e somma i risultati in lay_5 //
			getWeights(fp2, 9, kern.kernel_9);
			convolution2D(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			convolution2D_KB(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			convolution2D_KD(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			convolution2D_KE(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			convolution2D_KF(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			convolution2D_KH(SIZE_L3_5, &lay_4[0], kern.kernel_9, &lay_5[0][0]);
			//cumulativeSum(112, &lay_5[0][0], &temp.temp112[0][0]);
			//matrixReset(224, &temp.temp224[0][0]);
			matrixReset(SIZE_L3_5, &lay_4[0][0]);
		}
		// Effettua somma con bias, relu e maxpool di ogni immagine prodotta in uscita dal layer5 e salva i risultati in even_lay6 //
		bias = getBias(fp3);
		addBias(SIZE_L3_5, &lay_5[0][0], bias);
		relu(SIZE_L3_5, &lay_5[0][0]);
		rewind(fp);
		rewind(fp1);
		maxpool(SIZE_L3_5, &lay_5[0][0], SIZE_L6_9, &even.lay_6[k][0][0]);
		matrixReset(SIZE_L3_5, &lay_5[0][0]);
	}
	fclose(fp);
	fclose(fp1);
	fclose(fp2);
	fclose(fp3);
	lt=6;
	//temp_lay(lt,start,pt_start);
	printf("fine layer %d\n",lt);


	//////////////////////////////////////////////////////////////////////////
	
	
	// layer7 CONV3-256//
	fp = fopen("layer7_filters.txt", "r");
	fp2= fopen("layer7_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	for (i = 0; i < 256; i++)
	{
		punt2 = &odds.lay_7[i][0][0];
		for (k = 0; k < 128; k++)
		{
			punt = &even.lay_6[k][0][0];
			// getCose(filters_7, 9, i, k, 1152, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L6_9, even.lay_6[k],kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L6_9, punt2, bias);
		relu(SIZE_L6_9, punt2);
	}
 	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	printf("CIAO!\n");
	printf("fine layer %d\n",lt);

	
	// layer8 CONV3-256//
	fp = fopen("layer8_filters.txt", "r");
	fp2= fopen("layer8_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}								 
	for (i = 0; i < 256; i++)
	{
		punt2 = &even.lay_8[i][0][0];
		for (k = 0; k < 256; k++)
		{
			punt = &odds.lay_7[k][0][0];
			// getCose(filters_8, 9, i, k, 2304, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L6_9, odds.lay_7[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L6_9, punt2, bias);
		relu(SIZE_L6_9, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	printf("CIAO!\n");
	printf("fine layer %d\n",lt);



	// layer9 CONV3-256//
	fp = fopen("layer9_filters.txt", "r");
	fp2= fopen("layer9_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	for (i = 0; i < 256; i++)
	{
		punt2 = &odds.lay_9[i][0][0];
		for (k = 0; k < 256; k++)
		{
			punt = &even.lay_8[k][0][0];
			// getCose(filters_9, 9, i, k, 2304, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L6_9, even.lay_8[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L6_9, punt2, bias);
		relu(SIZE_L6_9, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	printf("fine layer %d\n",lt);
	//conteggio
	fclose(fp);
	fclose(fp2);
	

	// Layer10 POOL2//
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	for (k = 0; k < 256; k++)
	{
		punt = &odds.lay_9[k][0][0];
		punt2 = &even.lay_10[k][0][0];
		maxpool(SIZE_L6_9, punt, SIZE_L10_13, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	printf("fine layer %d\n",lt);
	//conteggio
  
	
	// layer11 CONV3-512//
	fp = fopen("layer11_filters.txt", "r");
	fp2= fopen("layer11_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	for (i = 0; i < 512; i++)
	{
		punt2 = &odds.lay_11[i][0][0];
		for (k = 0; k < 256; k++)
		{
			punt = &even.lay_10[k][0][0];
			// getCose(filters_11, 9, i, k, 2304, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L10_13, even.lay_10[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L10_13, punt2, bias);
		relu(SIZE_L10_13, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer12 CONV3-512//
	fp = fopen("layer12_filters.txt", "r");
	fp2= fopen("layer12_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	for (i = 0; i < 512; i++)
	{
		punt2 = &even.lay_12[i][0][0];
		for (k = 0; k < 512; k++)
		{
			punt = &odds.lay_11[k][0][0];
			// getCose(filters_12, 9, i, k, 4608, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L10_13, odds.lay_11[k], kern.kernel_9, punt2);
			// cumulativeSum(28, punt2, &temp.temp_8th[0][0]);
			// matrixReset(224, &temp.temp_1th[0][0]);
		}	
		bias = getBias(fp2);
		addBias(SIZE_L10_13, punt2, bias);
		relu(SIZE_L10_13, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer13 CONV3-512//
	fp = fopen("layer13_filters.txt", "r");
	fp2= fopen("layer13_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	for (i = 0; i < 512; i++)
	{
		punt2 = &odds.lay_13[i][0][0];
		for (k = 0; k < 512; k++)
		{
			punt = &even.lay_12[k][0][0];
			// getCose(filters_13, 9, i, k, 4608, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L10_13, even.lay_12[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L10_13, punt2, bias);
		relu(SIZE_L10_13, punt2);
	}
	//conteggio di fine layer aggiunto da me//
 	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer14 POOL //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	for (k = 0; k < 512; k++)
	{
		punt = &odds.lay_13[k][0][0];
		punt2 = &even.lay_14[k][0][0];
		maxpool(SIZE_L10_13, punt, SIZE_L14_17, punt2);
	}
 	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	
	
	// layer15 CONV3-512//
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	fp = fopen("layer15_filters.txt", "r");
	fp2= fopen("layer15_bias.txt", "r");
	for (i = 0; i < 512; i++)
	{
		punt2 = &odds.lay_15[i][0][0];
		for (k = 0; k < 512; k++)
		{
			punt = &even.lay_14[k][0][0];
			// getCose(filters_15, 9, i, k, 4608, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L14_17, even.lay_14[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L14_17, punt2, bias);
		relu(SIZE_L14_17, punt2);
	}
	//conteggio di fine layer aggiunto da me//
 	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer16 CONV3-512 //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	fp = fopen("layer16_filters.txt", "r");
	fp2= fopen("layer16_bias.txt", "r");
	for (i = 0; i < 512; i++)
	{
		punt2 = &even.lay_16[i][0][0];
		for (k = 0; k < 512; k++)
		{
			punt = &odds.lay_15[k][0][0];
			// getCose(filters_16, 9, i, k, 4608, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L14_17, odds.lay_15[k], kern.kernel_9, punt2);
			// cumulativeSum(14, punt2, &temp.temp_32th[0][0]);
			// matrixReset(224, &temp.temp_1th[0][0]);
		}
		bias = getBias(fp2);
		addBias(SIZE_L14_17, punt2, bias);
		relu(SIZE_L14_17, punt2);
	}
	//conteggio di fine layer aggiunto da me//
 	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer17 CONV3-512//
	fp = fopen("layer17_filters.txt", "r");
	fp2= fopen("layer17_bias.txt", "r");
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	for (i = 0; i < 512; i++)
	{
		punt2 = &odds.lay_17[i][0][0];
		for (k = 0; k < 512; k++)
		{
			punt = &even.lay_16[k][0][0];
			// getCose(filters_17, 9, i, k, 4608, kern.kernel_9);
			getWeights(fp, 9, kern.kernel_9);
			convolution2D(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
			convolution2D_KE(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
			convolution2D_KF(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
			convolution2D_KD(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
			convolution2D_KB(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
			convolution2D_KH(SIZE_L14_17, even.lay_16[k], kern.kernel_9, punt2);
		}
		bias = getBias(fp2);
		addBias(SIZE_L14_17, punt2, bias);
		relu(SIZE_L14_17, punt2);
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer18 POOL //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	for (k = 0; k < 512; k++)
	{
		punt = &odds.lay_17[k][0][0];
		punt2 = &even.lay_18[k][0][0];
		maxpool(SIZE_L14_17, punt, SIZE_L18, punt2);
	}
	
    // Converti il set di matrici in even.lay_18 in un vettore unidimensionale //
    int total = 0;
    // float flattened[7*7*512];
	float flattened[SIZE_L18*SIZE_L18*512];
    for (i = 0; i < 512; i++)
	{
		for (j = 0; j < SIZE_L18; j++) //era j fino a 7
		{
			for (k = 0; k < SIZE_L18; k++) //era k fino a 7
			{
				flattened[total] = even.lay_18[i][k][j];
				total += 1;
			}
		}
	}	
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	
	
	// layer19 FC //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	punt = &flattened[0];
	fp = fopen("layer19_filters.txt", "r");
	fp2 = fopen("layer19_bias.txt", "r");
	for (i = 0; i < 4096; i++)
	{
		getWeights(fp, (SIZE_L18*SIZE_L18*512), kern.kernel_25088);
		// getCose(filters_19, (SIZE_L18*SIZE_L18*512), i, 0, (SIZE_L18*SIZE_L18*512), kern.kernel_25088);
		odds.lay_19[i] += fullyconnect((SIZE_L18*SIZE_L18*512), punt, kern.kernel_25088);
		bias = getBias(fp2);
		odds.lay_19[i] +=bias;
	}
	reluVect(4096, odds.lay_19);
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer20 FC //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	fp = fopen("layer20_filters.txt", "r");
	fp2 = fopen("layer20_bias.txt", "r");
	punt = &odds.lay_19[0];
	for (i = 0; i < 4096; i++)
	{
		// getCose(filters_20, 4096, i, 0, 4096, kern.kernel_4096);
		getWeights(fp, 4096, kern.kernel_4096);
		even.lay_20[i] = fullyconnect(4096, punt, kern.kernel_4096);
		bias = getBias(fp2);
		even.lay_20[i]+= bias;
	}
	reluVect(4096, even.lay_20);
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer21 FC //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &odds.lay_3[k][0][0]);
	}
	fp = fopen("layer21_filters.txt", "r");
	fp2 = fopen("layer21_bias.txt", "r");
	punt = &even.lay_20[0];
	for (i = 0; i < OUTPUT_SIZE; i++)
	{
		// getCose(filters_21, 4096, i, 0, 4096, kern.kernel_4096);
		getWeights(fp, 4096, kern.kernel_4096);
		odds.lay_21[i] = fullyconnect(4096, punt, kern.kernel_4096);
		bias = getBias(fp2);
		odds.lay_21[i] += bias;
	}
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio
	fclose(fp);
	fclose(fp2);
	
	
	// layer22 SOFTMAX //
	for (k = 0; k < 64; k++)
	{
		matrixReset(INPUT_SIZE/2, &even.lay_3[k][0][0]);
	}
	punt = &odds.lay_21[0];
	punt2 = &even.lay_22[0];
	softmax(OUTPUT_SIZE, punt, punt2);
	//conteggio di fine layer aggiunto da me//
	lt++;
	//temp_lay(lt,start,pt_start);
	//conteggio									   
	
	
	
	// Calcola il tempo totale //
	// end_all=clock();
	// sec= ((double)(end_all-start_all))/CLOCKS_PER_SEC;
	// millisec=sec*10000- (int)sec*10000;
	// minuti= (int)sec / 60;
	// secondi= (int)sec % 60;
	// printf("il tempo che ha impiegato è pari a %f secondi:\t%dm %ds %dms\n",sec,minuti,secondi,millisec );
	
	
	// Stampa a schermo il risultato //
	// Ricava la posizione del massimo elemento nel vettore di softmax //
	float max = 0;
        int maxpos;
        for (j = 0; j < OUTPUT_SIZE; j++)
        {
                if (even.lay_22[j] > max)
		{
                	max = even.lay_22[j];
                        maxpos = j;
                }
        }
	fp = fopen("classification.txt", "r");
	displayResult(fp, maxpos);
	printf("The probability is: %f\n",max);
	fclose(fp);
	printf("\n\t\tFINEPROGR_VGG_CIFAR_benchmark\n------------------------\n\n");
	*/
	return 0;
}

