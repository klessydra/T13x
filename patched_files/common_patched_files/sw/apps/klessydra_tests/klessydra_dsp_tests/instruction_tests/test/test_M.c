#define R 512
#define C 512
#define TH 18

unsigned char source[R][C], destin[R][C];
int i, j;

main()
{
for (i = 0;  i < R; i++)
  for (j = 0;  j < C - 1; j++)
    if (source[j][i] - source[j+1][i] > TH || source[j][i] - source[j+1][i] < -TH)
      destin[j][i] = 200;
}
