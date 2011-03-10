/*******************************************************************************
 * Copyright (C) 2011, Linaro Limited.
 *
 * This file is part of PM QA.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Amit Daniel <amit.kachhap@linaro.org>
 *       - initial API and implementation
 *
 *     Torez Smith <torez.smith@linaro.org> (IBM Corporation)
 *       - editorial and/or harness conformance changes
 *******************************************************************************/


#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
//void usleep(unsigned long usec);


#define MAX_COUNT 1024
int main(int argc, char *argv[])
{
	int err = 0;
	FILE *fp = 0;
	int byteCount = 0;
	int iterCount = 0;
	char dataArray[MAX_COUNT];
/*
	printf("\nUSB mass storage test: parameters --device_name, byte to read, times to run\n");
*/
	if(argc!=4) {
		printf("Error: No of argumets not proper\n");
		return 0;
	}
	byteCount = atoi(argv[2]);
	iterCount = atoi(argv[3]);
/*
	printf("Device to open=%s, bytes read =%d, iteration =%d\n",argv[1], byteCount, iterCount);
*/
	fp = fopen(argv[1], "r");
	if(fp == NULL)
	{
		printf("Error: Invalid device name passed\n");
		return 0;
	}

	/*Init random generator*/
	srand((unsigned int)time(NULL));
	while(iterCount != 0) {	
		/*read from the begining*/	
		err = fread(dataArray,1,byteCount,fp);
		if(err < 0) {
			printf("Error: Data read failed\n");
			return 0;
		}
		fseek(fp,((iterCount%5)*100*1024), SEEK_SET);
		if(err < 0) {
			printf("Error: Data seek failed\n");
			return 0;
		}

		/*read from somewhere in the middle*/	
		err = fread(dataArray,1,byteCount,fp);
		if(err < 0) {
			printf("Error: Data read failed\n");
			return 0;
		}
		fseek(fp, byteCount, SEEK_END);
		if(err < 0) {
			printf("Error: Data seek failed\n");
			return 0;
		}

		/*read from the end*/	
		err = fread(dataArray,1,byteCount,fp);
		if(err < 0) {
			printf("Error: Data read failed\n");
			return 0;
		}
		
		rewind(fp);
		iterCount--;
		fclose(fp);
		/*sleep between 1ms to 50ms*/
		usleep(((rand()%50) + 1)*1000);
		fp = fopen(argv[1], "r");
	}
	fclose(fp);
	return 0;
}
