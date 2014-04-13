#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <sys/poll.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <linux/types.h>
#include <linux/netlink.h>

FILE *fp;

void exit_handler()
{
	fprintf(stdout, "exiting from uevent reader...\n");
	fclose(fp);
}

int main(int argc, char *argv[])
{
	struct sockaddr_nl nls;
	struct pollfd pfd;
	char buf[512];

	fp = fopen(argv[1], "w+");
	if (fp == NULL) {
		fprintf(stderr, "Can't open input file\n");
		exit(1);
	}

	signal(SIGINT, exit_handler);

	/* bind to uevent netlink socket */
	memset(&nls, 0, sizeof(struct sockaddr_nl));
	nls.nl_family = AF_NETLINK;
	nls.nl_pid = getpid();
	nls.nl_groups = -1;

	pfd.events = POLLIN;
	pfd.fd = socket(PF_NETLINK, SOCK_DGRAM, NETLINK_KOBJECT_UEVENT);
	if (pfd.fd == -1) {
		perror("error: socket()");
		exit_handler();
	}

	if (bind(pfd.fd, (struct sockaddr *) &nls,
				sizeof(struct sockaddr_nl))) {
		perror("error : bind()");
		exit_handler();
	}

	while (-1 != poll(&pfd, 1, -1)) {
		int i, len = recv(pfd.fd, buf, sizeof(buf), MSG_DONTWAIT);
		if (len == -1) {
			perror("error : recv()");
			exit_handler();
		}

		i = 0;
		while (i < len) {
			fprintf(fp, "%s\n", buf+i);
			i += strlen(buf+i)+1;
		}
	}

	return 0;
}
