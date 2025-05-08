// from: https://issues.chromium.org/issues/41145149
#define _GNU_SOURCE
#include <execinfo.h>
#include<stdlib.h>
#include<stdio.h>

int main(int argc, char **argv)
{
	void *bt[10];
	int i, cnt;

        cnt = backtrace(bt, 10);
        printf("backtrace() = %i\n", cnt);
        for (i = 0; i < cnt; ++i)
                printf("\t%p\n", bt[i]);
	return EXIT_SUCCESS;
}

