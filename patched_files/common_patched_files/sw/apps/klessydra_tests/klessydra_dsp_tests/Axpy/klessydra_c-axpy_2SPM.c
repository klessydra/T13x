#include<stdlib.h> 
#include<float.h>  
#include<stdio.h>
#include<time.h>
#include<math.h>

//Klessydra lib
#include"dsp_functions.h"
#include"functions.h"
#include"klessydra_defs.h"

#define SPM_MAX 128
#define SIZE_OF_INT 4
#define SIZE_OF_CHAR 1
#define N 256
#define N_round 10

char a_c=4;
char x_c[N]={0, 6, 4, 7, 4, 8, 5, 8, 2, 6, 0, 6, 6, 4, 6, 2, 8, 9, 6, 0, 7, 0, 1, 0, 1, 3, 7, 7, 2, 6, 4, 5, 2, 0, 2, 9, 0, 9, 9, 4, 5, 1, 0, 3, 7, 8, 8, 6, 0, 4, 6, 7, 6, 0, 9, 7, 5, 9, 7, 8, 5, 3, 3, 8, 3, 7, 9, 3, 7, 8, 7, 4, 1, 9, 0, 9, 8, 8, 5, 8, 4, 3, 7, 1, 3, 8, 0, 9, 7, 9, 9, 3, 2, 4, 3, 7, 1, 2, 2, 0, 2, 1, 7, 5, 1, 7, 4, 1, 7, 1, 1, 1, 7, 0, 4, 0, 8, 5, 1, 6, 6, 2, 1, 9, 6, 4, 8, 0, 8, 1, 0, 2, 2, 9, 7, 5, 6, 4, 6, 3, 7, 9, 7, 4, 9, 1, 7, 0, 6, 0, 8, 5, 3, 9, 4, 1, 5, 4, 1, 5, 5, 4, 9, 8, 3, 8, 5, 2, 2, 2, 7, 0, 3, 4, 6, 3, 6, 3, 3, 4, 4, 3, 9, 7, 2, 5, 8, 9, 0, 2, 4, 7, 6, 5, 7, 1, 3, 3, 3, 8, 5, 1, 0, 8, 7, 6, 3, 5, 0, 8, 0, 4, 1, 1, 3, 5, 9, 3, 4, 1, 5, 0, 8, 3, 5, 6, 5, 9, 9, 0, 7, 6, 3, 7, 6, 1, 5, 0, 6, 5, 0, 8, 1, 2, 2, 6, 9, 1, 0, 4, 2, 7, 4, 0, 3, 2};
char y_c[N]={8, 0, 3, 7, 0, 0, 3, 4, 9, 2, 7, 4, 2, 5, 2, 4, 4, 3, 8, 6, 0, 8, 9, 2, 2, 3, 1, 8, 3, 4, 2, 2, 4, 5, 1, 7, 5, 7, 1, 6, 9, 8, 1, 3, 3, 3, 7, 9, 8, 6, 7, 0, 4, 8, 4, 8, 1, 6, 8, 5, 2, 1, 9, 9, 6, 0, 6, 4, 9, 9, 0, 8, 9, 3, 1, 4, 8, 9, 6, 7, 7, 3, 7, 1, 2, 2, 1, 5, 0, 9, 0, 4, 0, 1, 3, 7, 4, 1, 1, 3, 0, 3, 2, 1, 7, 5, 6, 5, 4, 2, 2, 1, 7, 2, 4, 1, 6, 5, 7, 8, 5, 9, 2, 7, 3, 6, 4, 7, 9, 7, 2, 2, 1, 6, 3, 0, 2, 1, 5, 6, 5, 0, 0, 3, 4, 6, 6, 0, 2, 5, 8, 9, 5, 0, 6, 0, 8, 3, 7, 8, 2, 1, 0, 5, 8, 5, 5, 0, 7, 3, 8, 2, 3, 0, 7, 7, 7, 6, 9, 1, 1, 9, 0, 8, 9, 8, 8, 0, 3, 7, 0, 6, 9, 2, 1, 7, 7, 9, 7, 6, 2, 7, 1, 5, 8, 8, 4, 5, 6, 5, 6, 8, 4, 8, 8, 3, 8, 7, 5, 2, 4, 5, 0, 5, 7, 3, 2, 7, 2, 1, 3, 4, 9, 4, 1, 9, 5, 7, 4, 1, 2, 2, 1, 6, 2, 0, 2, 2, 9, 7, 4, 3, 5, 6, 1, 4};
char temp[N];
char zero=0;

int main(){
	int n=N;
	int m=N_round;
	int offset[3];
	for(int i=0;i<n;i++){
		temp[i]=0;
	}
	int n_cycle=n/(SPM_MAX*SPM_MAX/6);
    if(n-(n_cycle*(SPM_MAX*SPM_MAX/6))>0){
		n_cycle++;
	}
	int scl=SPM_MAX*SPM_MAX/6;
	
	__asm__("csrw 0x300, 0x8;" );//Enable interrupts for all threads
	__asm__("csrrw zero, mcycle, zero");
	CSR_MVSIZE(SPM_MAX*SPM_MAX*SIZE_OF_CHAR);
	if(Klessydra_get_coreID()==0){
		kbcast((void *)spmaddrA, (void *)zero);
	}
	else if(Klessydra_get_coreID()==1){
		kbcast((void *)spmaddrB, (void *)zero);
	}
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		offset[1]=scl+scl+scl;
		for(int p=0;p<n_cycle;p++){
			if(n-(scl*(n_cycle-1))>(SPM_MAX*SPM_MAX/6)){
				n_cycle++;
			}
			if(p<(n_cycle-1)){
				kmemld((void *)((char *)spmaddrA), &x_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrB), &y_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*scl);
				CSR_MVSIZE(SIZE_OF_CHAR*scl);
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA),a_c);
					kaddv((void *)((char *)spmaddrB),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB),	SIZE_OF_CHAR*scl);
			}
			else{
				kmemld((void *)((char *)spmaddrA), &x_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrB), &y_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				CSR_MVSIZE(SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA),a_c);
					kaddv((void *)((char *)spmaddrB),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB),	SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
			}
			
		}
	}
	/*if(Klessydra_get_coreID()==1){
		for(int p=0;p<n_cycle;p++){
			offset[0]=scl;
			offset[1]=scl+scl+scl+scl;
			if(n-(scl*(n_cycle-1))>(SPM_MAX*SPM_MAX/6)){
				n_cycle++;
			}
			if(p<(n_cycle-1)){
				kmemld((void *)((char *)spmaddrA+offset[0]), &x_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrB+offset[0]), &y_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*scl);
				CSR_MVSIZE(SIZE_OF_CHAR*scl);
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA+offset[0]),a_c);
					kaddv((void *)((char *)spmaddrB+offset[0]),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB+offset[0]));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB+offset[0]),	SIZE_OF_CHAR*scl);
			}
			else{
				kmemld((void *)((char *)spmaddrA+offset[0]), &x_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrB+offset[0]), &y_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				CSR_MVSIZE(SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA+offset[0]),a_c);
					kaddv((void *)((char *)spmaddrB+offset[0]),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB+offset[0]));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB+offset[0]),	SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
			}
			
		}
	}
	if(Klessydra_get_coreID()==2){
		for(int p=0;p<n_cycle;p++){
			offset[0]=scl+scl;
			offset[1]=scl+scl+scl+scl+scl;
			if(n-(scl*(n_cycle-1))>(SPM_MAX*SPM_MAX/6)){
				n_cycle++;
			}
			if(p<(n_cycle-1)){
				kmemld((void *)((char *)spmaddrA+offset[0]), &x_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrB+offset[0]), &y_c[scl*p],  SIZE_OF_CHAR*scl);
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*scl);
				CSR_MVSIZE(SIZE_OF_CHAR*scl);
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA+offset[0]),a_c);
					kaddv((void *)((char *)spmaddrB+offset[0]),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB+offset[0]));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB+offset[0]),	SIZE_OF_CHAR*scl);
			}
			else{
				kmemld((void *)((char *)spmaddrA+offset[0]), &x_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrB+offset[0]), &y_c[scl*p],  SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				kmemld((void *)((char *)spmaddrA+offset[1]), &temp[scl*p], SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				CSR_MVSIZE(SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
				for(int i=0;i<m;i++){
					kbcast((void *)((char *)spmaddrA+offset[1]), (void *)zero);
					ksvmulrf((void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrA+offset[0]),a_c);
					kaddv((void *)((char *)spmaddrB+offset[0]),(void *)((char *)spmaddrA+offset[1]),(void *)((char *)spmaddrB+offset[0]));
				}
				kmemstr(&y_c[scl*p],  (void *)((char *)spmaddrB+offset[0]),	SIZE_OF_CHAR*(n-scl*(n_cycle-1)));
			}
			
		}
	}*/
	sync_barrier();
	sync_barrier_reset();		
	sync_barrier_thread_registration();
	if(Klessydra_get_coreID()==0){
		printf("\ny_out:\n");
		for(int i=0;i<n;i++){
			printf("%d\t",y_c[i]);
		}
		printf("\n");
	}
	sync_barrier();
	
	
	return 0;
}