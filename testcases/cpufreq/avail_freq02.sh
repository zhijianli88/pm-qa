#!/bin/bash
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
 #     Torez Smith <torez.smith@linaro.org> (IBM Corporation)
 #       - initial API and implementation
 #******************************************************************************/

###
 #  Track how much time it takes to cycle through a loop 1000 times at this current frequency
###
loop_it() {
	LOOP_LIMIT=1000
	time while ( test $LOOP_LIMIT -ge 1 ); do
		LOOP_LIMIT=$(( $LOOP_LIMIT - 1 ))
	done
}


###
 #  set governor to be user space governor which allows you to manually alter the frequency
###
echo "userspace" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
if [ $? != 0 ]; then 
	echo "FAIL   could not change governor to userspace, remained `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`"
	exit -1
fi


###
 #  Now loop through, changing the cpu frequency to available frequencies. Sleep for a 
 #  period of about 5 seconds each time it's set to a new frequency to allow the system
 #  to settle down.
###
for LOOP_FREQ  in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies`
do
	echo $LOOP_FREQ > /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed
	if [ $? != 0 ]; then 
		echo "FAIL   could not write freq for $LOOP_FREQ"
		exit -1
	fi
	sleep 5
	if [ `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` != $LOOP_FREQ ]; then
		echo "FAIL   could not change freq to $LOOP_FREQ  remained  `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq`"
		exit -1
	fi
	loop_it
done

echo PASS

