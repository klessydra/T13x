#include<stdlib.h> 
#include<float.h>  
#include<stdio.h>
#include<time.h>
#include<math.h>

//Klessydra lib
#include"dsp_functions.h"
#include"functions.h"
#include"klessydra_defs.h"

#define SPM_MAX 64
#define SIZE_OF_INT 4
#define FRACTIONAL_PART 18
#define SHIFT 9
#define N_ROW_1 5
#define N_COL_1 5
#define N_COL_2 5

float M1[N_ROW_1][N_COL_1]={0.840188,	0.394383,	0.783099,	0.798440,	0.911647,	
0.197551,	0.335223,	0.768230,	0.277775,	0.553970,	
0.477397,	0.628871,	0.364784,	0.513401,	0.952230,	
0.916195,	0.635712,	0.717297,	0.141603,	0.606969,	
0.016301,	0.242887,	0.137232,	0.804177,	0.156679	};
float M2[N_COL_1][N_COL_2]={0.400944,	0.129790,	0.108809,	0.998924,	0.218257,	
0.512932,	0.839112,	0.612640,	0.296032,	0.637552,	
0.524287,	0.493583,	0.972775,	0.292517,	0.771358,	
0.526745,	0.769914,	0.400229,	0.891529,	0.283315,	
0.352458,	0.807725,	0.919026,	0.069755,	0.949327	};

int zero=0;

int main(){
	int n=N_ROW_1;
	int m=N_COL_1;
	int u=N_COL_2;
	int shft = SHIFT;
	int n_cycle1=(n*m)/(SPM_MAX*SPM_MAX/3);
	if((n*m)-(n_cycle1*(SPM_MAX*SPM_MAX/3))>0){
		n_cycle1++;
	}
	int n_cycle2=(m*u)/(SPM_MAX*SPM_MAX/3);
	if((u*m)-(n_cycle2*(SPM_MAX*SPM_MAX/3))>0){
		n_cycle2++;
	}
	int scl=SPM_MAX*SPM_MAX/(3*m);
	int offset[3]={0,0,0};
	
	//Matrix initialization
	int m1[n][m];
	for(int i=0;i<n;i++){
		for(int j=0;j<m;j++){
			m1[i][j]=(int)round(M1[i][j]*pow(2,FRACTIONAL_PART));
			m1[i][j]=m1[i][j]>>shft;
		}
	}
	int m2[m][u];
	int m2T[u][m];
	for(int i=0;i<n;i++){
		for(int j=0;j<m;j++){
			m2[i][j]=(int)round(M2[i][j]*pow(2,FRACTIONAL_PART));
			m2[i][j]=m2[i][j]>>shft;
		}
	}
	for(int i=0;i<n;i++){
		for(int j=0;j<m;j++){
			m2T[i][j]=m2[j][i];
		}
	}
	
	int m_out[n][u];
	for(int i=0;i<n;i++){
		for(int j=0;j<u;j++){
			m_out[i][j]=0;
		}
	}
	__asm__("csrw 0x300, 0x8;" );//Enable interrupts for all threads
	__asm__("csrrw zero, mcycle, zero");
	CSR_MVSIZE(SPM_MAX*SPM_MAX*SIZE_OF_INT);

	if(Klessydra_get_coreID()==0){
		kbcast((void *)spmaddrA, (void *)zero);
	}
	else if(Klessydra_get_coreID()==1){
		kbcast((void *)spmaddrB, (void *)zero);
	}
	else if(Klessydra_get_coreID()==2){
		kbcast((void *)spmaddrC, (void *)zero);
	}
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		CSR_MVSIZE(m*SIZE_OF_INT);
		for(int p=0;p<n_cycle1;p++){
			//Load matrix1 in SPM_A
			if((n*m)-((scl*m)*(n_cycle1-1))>(SPM_MAX*SPM_MAX/3)){
				n_cycle1++;
			}
			
			if(p<(n_cycle1-1)){
				kmemld((void *)((int *)spmaddrA), &m1[scl*p][0],  SIZE_OF_INT*(scl*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=i*m;
								offset[2]=j*m;
								kdotp((void *)((int *)spmaddrC),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC),  SIZE_OF_INT);	
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=i*m;
								offset[2]=j*m;
								kdotp((void *)((int *)spmaddrC),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
			else{
				kmemld((void *)((int *)spmaddrA), &m1[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle1-1))*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=i*m;
								offset[2]=j*m;
								kdotp((void *)((int *)spmaddrC),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC),  SIZE_OF_INT);		
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=i*m;
								offset[2]=j*m;
								kdotp((void *)((int *)spmaddrC),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
		}
	}
	if(Klessydra_get_coreID()==1){
		CSR_MVSIZE(m*SIZE_OF_INT);
		for(int p=0;p<n_cycle1;p++){
			//Load matrix1 in SPM_A
			if((n*m)-((scl*m)*(n_cycle1-1))>(SPM_MAX*SPM_MAX/3)){
				n_cycle1++;
			}
			
			if(p<(n_cycle1-1)){
				kmemld((void *)((int *)spmaddrA+scl*m), &m1[scl*p][0],  SIZE_OF_INT*(scl*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+i*m;
								offset[2]=scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+1),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+1),  SIZE_OF_INT);	
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+i*m;
								offset[2]=scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+1),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+1),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
			else{
				kmemld((void *)((int *)spmaddrA+scl*m), &m1[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle1-1))*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+i*m;
								offset[2]=scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+1),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+1),  SIZE_OF_INT);		
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+i*m;
								offset[2]=scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+1),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+1),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
		}
	}
 	if(Klessydra_get_coreID()==2){
    //printf("%d\n",scl);
	  CSR_MVSIZE(m*SIZE_OF_INT);
		for(int p=0;p<n_cycle1;p++){
			//Load matrix1 in SPM_A
			if((n*m)-((scl*m)*(n_cycle1-1))>(SPM_MAX*SPM_MAX/3)){
				n_cycle1++;
			}
			
			if(p<(n_cycle1-1)){
				kmemld((void *)((int *)spmaddrA+scl*m+scl*m), &m1[scl*p][0],  SIZE_OF_INT*(scl*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB+scl*m+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+scl*m+i*m;
								offset[2]=scl*m+scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+2),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+2),  SIZE_OF_INT);	
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB+scl*m+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<scl;i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+scl*m+i*m;
								offset[2]=scl*m+scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+2),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+2),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
			else{
				kmemld((void *)((int *)spmaddrA+scl*m+scl*m), &m1[scl*p][0],  SIZE_OF_INT*((n-scl*(n_cycle1-1))*m));
				for(int q=0;q<n_cycle2;q++){
					//Load matrix2 in SPM_B
					if((u*m)-((scl*m)*(n_cycle2-1))>(SPM_MAX*SPM_MAX/3)){
						n_cycle2++;
					}	
					if(q<(n_cycle2-1)){
						kmemld((void *)((int *)spmaddrB+scl*m+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*(scl*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<scl;j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+scl*m+i*m;
								offset[2]=scl*m+scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+2),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+2),  SIZE_OF_INT);		
							}
						}
					}
					else{
						kmemld((void *)((int *)spmaddrB+scl*m+scl*m), &m2T[scl*q][0],  SIZE_OF_INT*((u-scl*(n_cycle2-1))*m));
						for(int i=0;i<(n-scl*(n_cycle1-1));i++){
							//printf("Dentro\n");
							for(int j=0;j<(u-scl*(n_cycle2-1));j++){
								offset[0]=i*m+j;
								offset[1]=scl*m+scl*m+i*m;
								offset[2]=scl*m+scl*m+j*m;
								kdotp((void *)((int *)spmaddrC+2),  (void *)((int *)spmaddrA+offset[1]),  (void *)((int *)spmaddrB+offset[2]));
								//Store in main memory
								kmemstr(&m_out[(p*scl)+i][(q*scl)+j],  (void *)((int *)spmaddrC+2),  SIZE_OF_INT);		
							}
						}
					}
				}
			}
		}
	}
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		printf("Matrice output\n");
		for(int i=0;i<n;i++){
			for(int j=0;j<u;j++){
				printf("%d\t",m_out[i][j]);
			}
			printf("\n");
		}
	}
  sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==1){
		printf("Matrice output\n");
		for(int i=0;i<n;i++){
			for(int j=0;j<u;j++){
				printf("%d\t",m_out[i][j]);
			}
			printf("\n");
		}
	}
  sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==2){
		printf("Matrice output\n");
		for(int i=0;i<n;i++){
			for(int j=0;j<u;j++){
				printf("%d\t",m_out[i][j]);
			}
			printf("\n");
		}
	}
	sync_barrier();
	
	return 0;
}