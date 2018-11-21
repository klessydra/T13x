/*questo test effettua la somma due vettori di stessa dimensione usando la unità DSP*/

#include"klessydraCfunctions.h"
#include"KlessydraSPM.h"

#define NumOfElements 4		// changing the value of this this macro the size of the vectors will automatically change 

int MyGlobVect1[NumOfElements];
int MyGlobVect2[NumOfElements];
int MyGlobRes = 0;
int* PointMyGlobRes = &MyGlobRes;
int GlobThreshold = 0;

int main()
{
	int i = 0;
	int MyRet = 0;
	
	/* vectors generation */
	
	for(i=0; i<NumOfElements; i++)
	{
		MyGlobVect1[i] = i;
		MyGlobVect2[i] = NumOfElements-i;
		GlobThreshold += MyGlobVect1[i]*MyGlobVect2[i];
	}

	/* operative section*/
	
		// insert here the enabling of clock cycles counter register // <--------- TO EDIT
	
	MyRet=Klessydra_MultFunct_dprod((void*) PointMyGlobRes, (void*) MyGlobVect1, (void*) MyGlobVect2, NumOfElements*sizeof(int));
	
	while(MyRet != NumOfElements*sizeof(int))
	{
		// wait unitil the fuction VectSum finishes          	     
	}
	
		// insert here the reset of clock cycles counter register    // <--------- TO EDIT
	
	/* debug section */

	if(MyGlobRes==GlobThreshold) __asm__("j 0x90000;");
	else __asm__("j 0x90004;");
}
