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
 #  For each available governor, can we change the cpu governor to
 #  that new value?  Sleep a few seconds after changing to allow system
 #  to settle down.
###

for i in `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`
do
	echo $i >  /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	if [ $? != 0 ]; then 
		echo "FAIL   can not write governor for $i"
		exit -1
	fi
	sleep 5
	if [ `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor` != $i ]; then
		echo "FAIL   could not change governor to $i"
		exit -1
	fi
done

echo PASS


