/*questo test effettua la somma due vettori di stessa dimensione usando la unità DSP*/

#include"klessydraCfunctions.h"
//#include"KlessydraSPM.h"

#define NumOfElements 4		// changing the value of this this macro the size of the vectors will automatically change 

int MyGlobVect1[NumOfElements];
int MyGlobVect2[NumOfElements];
int MyGlobRes[NumOfElements];
int GlobThreshold[NumOfElements];

int main()
{
	int i = 0;
	int MyCount = 0;
	int MyRet = 0;
	
	/* vectors generation */
	
	for(i=0; i<NumOfElements; i++)
	{
		MyGlobVect1[i] = i;
		MyGlobVect2[i] = NumOfElements-i;
		GlobThreshold[i] = NumOfElements;
	}

	/* operative section*/
	
	__asm__("csrw PCER, 0x00000001");
	
	MyRet=Klessydra_MultFunct_vadd((void*) MyGlobRes, (void*) MyGlobVect1, (void*) MyGlobVect2, NumOfElements*sizeof(int));
	
	while(MyRet != NumOfElements*sizeof(int))
	{
		// wait untill the fuction VectSum finishes          	     
	}
	
		// insert here the reset of clock cycles counter register    // <--------- TO EDIT
	
	/* debug section */

	for(i=0; i<NumOfElements; i++)
	{
		if(MyGlobRes[i]==GlobThreshold[i]) MyCount++;
	}		

	if(MyCount==NumOfElements) __asm__("j 0x90000;");
	else __asm__("j 0x90004;");
}
