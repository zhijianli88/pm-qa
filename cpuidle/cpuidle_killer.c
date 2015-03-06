#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/timex.h>
#ifdef ANDROID
/* 
* As of 5.0.0, Bionic provides timex, but not the
* adjtimex interface.
* However, the kernel does.
*/
#include <linux/timex.h> /* for struct timex */
#include <asm/unistd.h> /* for __NR_adjtimex */
static int adjtimex(struct timex *buf)
{
	return syscall(__NR_adjtimex, buf);
}
#endif
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/param.h>
#include <sched.h>
#include <signal.h>

#define DURATION  120 /* seconds */
#define SEC_TO_USEC(d) ((d) * 1000 * 1000)

static int sigon;

void sighandler(int sig)
{
	sigon = 1;
}

void timeout(int sig)
{
	printf("Err : Test duration exceeded\n");
	exit(1);
}

int tick_me(int nrsleeps, int delay, int cpu)
{
	int i;
	cpu_set_t mask;
	unsigned long counter = 0;
	struct itimerval t = { };

	CPU_ZERO(&mask);
	CPU_SET(cpu, &mask);

	/* stick on the specified cpu */
	if (sched_setaffinity(getpid(), sizeof(mask), &mask)) {
		fprintf(stderr, "sched_setaffinity (%d): %m", cpu);
		return -1;
	}

	signal(SIGALRM, sighandler);

	for (i = 0; i < nrsleeps / 2; i++) {
		usleep(delay);

		sigon = 0;
		t.it_value.tv_sec = 0;
		t.it_value.tv_usec = delay;

		if (setitimer(ITIMER_REAL, &t, NULL)) {
			perror("setitimer");
			return 1;
		}

		while (!sigon)
			counter++;
	}

	fprintf(stderr, "CPU%d counter value %lu\n", cpu, counter);

	return 0;
}

int isonline(int cpu)
{
        FILE *f;
        char path[MAXPATHLEN];
        int online;

        if (!cpu)
                return 1;

        sprintf(path, "/sys/devices/system/cpu/cpu%d/online", cpu);

        f = fopen(path, "r");
        if (!f) {
                perror("fopen");
                return -1;
        }

        fscanf(f, "%d", &online);

        fclose(f);

        return online;
}

int main(int argc, char *argv[])
{
	int ret, i, nrcpus;
	int nrsleeps, delay;
	pid_t *pids;
	struct timex timex = { 0 };

	if (adjtimex(&timex) < 0) {
		perror("adjtimex");
		return 1;
	}

	fprintf(stderr, "jiffies are : %ld usecs\n", timex.tick);

	nrcpus = sysconf(_SC_NPROCESSORS_CONF);
	if (nrcpus < 0) {
		perror("sysconf");
		return 1;
	}

	fprintf(stderr, "found %d cpu(s)\n", nrcpus);
	pids = (pid_t *) calloc(nrcpus, sizeof(pid_t));
	if (pids == NULL) {
		fprintf(stderr, "error: calloc failed\n");
		return 1;
	}

	for (i = 0; i < nrcpus; i++) {

		ret = isonline(i);
		if (!ret) {
			fprintf(stderr, "cpu%d is offline, ignoring\n", i);
			continue;
		}

		pids[i] = fork();
		if (pids[i] < 0) {
			perror("fork");
			return 1;
		}

		if (!pids[i]) {

			struct timeval before, after;
			long duration;
			float deviation;

			nrsleeps = SEC_TO_USEC(DURATION) / (timex.tick * 10);
			delay    = SEC_TO_USEC(DURATION) / nrsleeps;

			fprintf(stderr, "CPU%d duration: %d secs, #sleep: %d,"
			       " delay: %d us\n", i, DURATION, nrsleeps, delay);

			gettimeofday(&before, NULL);
			if (tick_me(nrsleeps, delay, i))
				return 1;
			gettimeofday(&after, NULL);

			duration = SEC_TO_USEC(after.tv_sec - before.tv_sec) +
				(after.tv_usec - before.tv_usec);

			fprintf(stderr, "CPU%d test duration: %f secs\n", i,
				(float)(duration) / (float)SEC_TO_USEC(1));

			deviation = ((float)duration - (float)SEC_TO_USEC(DURATION)) /
				(float)SEC_TO_USEC(DURATION);

			fprintf(stderr, "CPU%d deviation %f\n", i, deviation);
			if (deviation > 0.5) {
				fprintf(stderr, "expected test duration too long\n");
				return 1;
			}

			return 0;
		}
	}

	ret = 0;

	signal(SIGALRM, timeout);

	alarm(DURATION + 20);

	for (i = 0; i < nrcpus; i++) {
		int status;

		/* skip for offline cpus */
		if (!pids[i]) {
			fprintf(stderr, "no_wait_for_process on cpu %d\n", i);
			continue;
		}

		waitpid(pids[i], &status, 0);
		if (status != 0) {
			fprintf(stderr, "test for cpu %d has failed\n", i);
			ret = 1;
		}
	}

	return ret;
}
