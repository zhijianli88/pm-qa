/*
 *heat_cpu.c
 *
 * Copyright (C) 2011, Linaro Limited.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA  02110-1301, USA.
 *
 * Contributors:
 *	Robert Lee <rob.lee@linaro.org>
 *	Amit Daniel <amit.kachhap@linaro.org>
 *	VERSION=0.4
 */

/*
 * program to heat up your cpus
 *
 * Creates a thread for each cpu which will run in a loop that executes
 * code that (hopefully) produces a large amount of heat.
 *
 * The each thread's policy is set to make it very low priority.  This allows
 * this script to be ran in conjunction with other code that may want to run
 * and exercise (produce heat) from other various parts of the SoC such
 * as the GPU and VPU.
 */


#define _GNU_SOURCE

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <pthread.h>
#include <string.h>
#include <math.h>

#define NR_THREAD 3

int cont = 1;
int cpu_index;

long long a = 1, c = 1;
float f = M_PI;
pid_t thr_id[NR_THREAD];
int moderate_inst;


#ifdef ANDROID
int                 conditionMet;
pthread_cond_t      cond  = PTHREAD_COND_INITIALIZER;
pthread_mutex_t     mutex = PTHREAD_MUTEX_INITIALIZER;
#endif

void *do_loop(void *data)
{
	const long long b = 3;
	float f = 1.12;

	a = 1;
	c = 1;
#ifdef ANDROID
	long int thread = (long int) data;
	thr_id[thread] = gettid();
	pthread_mutex_lock(&mutex);
	while (!conditionMet)
		pthread_cond_wait(&cond, &mutex);
	pthread_mutex_unlock(&mutex);
#endif

	while (cont) {
		if (!moderate_inst) {
			a += a * b;
			c += c * b;
			f += f * b;
		} else {
			a += 1;
		}
	}

	return 0;
}

int main(int arg_count, char *argv[])
{
	int ret, i;
	int num_cpus = sysconf(_SC_NPROCESSORS_ONLN);
	cpu_set_t cpuset;

	if (num_cpus < 0) {
		printf("ERROR: sysconf failed to online cpus\n");
		return 1;
	}

	printf("Num CPUs: %d\n", num_cpus);
	if (arg_count > 1) {
		if (!strcmp("moderate", argv[1])) {
			moderate_inst = 1;
			printf("use moderate heating\n");
		}
	}

	/* clear out cpus */
	CPU_ZERO(&cpuset);

	/* Create a pthread_attr_t object for each core */
	pthread_attr_t *p = (pthread_attr_t *) malloc(
				num_cpus * sizeof(pthread_attr_t));

	if (!p) {
		printf("ERROR: out of memory\n");
		return -1;
	}

	pthread_t *p_thread_ptr = (pthread_t *) malloc(
					num_cpus * sizeof(pthread_t));

	if (!p_thread_ptr) {
		printf("ERROR: out of memory\n");
		return -1;
	}

	for (i = 0; i < num_cpus; i++) {
		ret = pthread_attr_init(&p[i]);

		if (ret) {
			printf("Error initializing pattr\n");
			return ret;
		}
#ifndef ANDROID
		/* Make workload thread's very low priority if allowed*/
#ifdef SCHED_IDLE
		ret = pthread_attr_setschedpolicy(&p[i], SCHED_IDLE);
#endif

#else
		ret = pthread_attr_setschedpolicy(&p[i], SCHED_OTHER);
#endif
		/* for each new object */
		CPU_SET(i, &cpuset);
#ifndef ANDROID
		ret = pthread_attr_setaffinity_np(&p[i],
					sizeof(cpu_set_t), &cpuset);

		if (ret) {
			printf("Error setting affinity on pthread attribute\n");
			printf("i: %i\n", i);
			printf("Error: %s\n", strerror(ret));
			return ret;
		}
#endif
	CPU_CLR(i, &cpuset);

	}

	for (i = 0; i < num_cpus; i++) {
		/* create a new thread that will execute 'do_loop()' */
		ret = pthread_create(&p_thread_ptr[i], &p[i],
							do_loop, (void *)i);
		if (ret < 0)
			printf("Error pthread_create failed for cpu%d\n", i);

#ifdef ANDROID
		CPU_ZERO(&cpuset);
		CPU_SET(i, &cpuset);

		ret = sched_setaffinity(thr_id[i], sizeof(cpuset), &cpuset);
		if (ret) {
			printf("Error setting affinity on pthread th_id\n");
			printf("Error: %s\n", strerror(ret));
			return ret;
		}
#endif
	}

#ifdef ANDROID
	pthread_mutex_lock(&mutex);
	conditionMet = 1;
	pthread_cond_broadcast(&cond);
	pthread_mutex_unlock(&mutex);
#endif

	while (1)
		sleep(1);
	return 0;
}
