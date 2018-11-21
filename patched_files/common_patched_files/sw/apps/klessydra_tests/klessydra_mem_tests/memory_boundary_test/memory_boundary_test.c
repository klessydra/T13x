#include<stdlib.h>

#define SIZE (260*1024)

// char mem[SIZE];

int main()
{
	char mem[SIZE];
	char *ptr;
	ptr = mem;
	for (int i = 0; i < SIZE; i++) 
	{
		mem[i] = i;
		asm
		(
		"sb %[i], 0(%[ptr])"
                :
                : [i] "r" (i), [ptr] "r" (ptr)
		);
		ptr++;
	}
	ptr = mem;
	for (int i = 0; i < SIZE; i++) 
	{
		asm
		(
		"lbu t3, 0(%[ptr])"
                :
		: [ptr] "r" (ptr)
		);
		ptr++;
	}
return 0;
}
