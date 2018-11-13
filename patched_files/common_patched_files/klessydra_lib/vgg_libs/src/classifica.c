#include"definitions_data_test.h"

void result(FILE *fp, int posizione)
{

char nome;
int i=0;

printf("The item is: ");

while(fscanf(fp,"%c", &nome)>0){

	if(i==posizione){
		printf("%c", nome);
	}
	if( nome == '\n'){
		i++;
	}
}

printf("\n");

return ;

}

int main(){

FILE *fp;

fp=fopen("classification.txt", "r");

result(fp, 0);
rewind(fp);

result(fp, 248);
rewind(fp);

result(fp, 957);
rewind(fp);

result(fp, 721);
rewind(fp);

result(fp, 892);
rewind(fp);

fclose(fp);



}

