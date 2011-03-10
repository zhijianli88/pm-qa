#!/bin/sh

#/*******************************************************************************
 # Copyright (C) 2011, Linaro Limited.
 #
 # This file is part of PM QA.
 #
 # All rights reserved. This program and the accompanying materials
 # are made available under the terms of the Eclipse Public License v1.0
 # which accompanies this distribution, and is available at
 # http://www.eclipse.org/legal/epl-v10.html
 #
 # Contributors:
 #     Vincent Guittot <vincent.guittot@linaro.org>
 #       - initial API and implementation
 #
 #     Torez Smith <torez.smith@linaro.org> (IBM Corporation)
 #       - editorial and/or harness conformance changes
 #******************************************************************************/

PWD=pwd

echo 0 > /sys/kernel/debug/tracing/tracing_on

echo 1 > /sys/kernel/debug/tracing/events/cpu_hotplug/enable

# echo "**** TEST LOADED CPU*****"

LOOP=10
MAX_PROCESS=$LOOP

while ( test $LOOP -ge 0 ); do

	PROCESS=$LOOP

	while ( test $PROCESS -lt $MAX_PROCESS ); do
		# echo "**** Start cyclictest *****"
		cyclictest -D 180 -t 10 -q  > /dev/null &
		PROCESS=$(( $PROCESS + 1 )) 
	done

	ILOOP=20
	echo 1 > /sys/kernel/debug/tracing/tracing_on

	while ( test $ILOOP -ge 1 ); do 

		# echo "**** TEST " $ILOOP " *****"
		# echo ""

		sleep 1

#		echo -n "Disabling CPU1 ... "
		echo 0 > /sys/devices/system/cpu/cpu1/online
		# echo "Disable"

		sleep 1

#		echo -n "Enabling CPU1 ... "
		echo 1 > /sys/devices/system/cpu/cpu1/online
		# echo "Enable"

		sleep 1

		ILOOP=$(( $ILOOP - 1 )) 

	done

	echo 0 > /sys/kernel/debug/tracing/tracing_on

	LIST=`ps | grep cyclictest | awk '{ print $1 }'`

	for I in $LIST; do
		# echo "**** Kill cyclictest *****"
		kill $I
	done

	LOOP=$(( $LOOP - 1 )) 

done

cat /sys/kernel/debug/tracing/trace > $PWD/test_load.txt

echo "PASS"
