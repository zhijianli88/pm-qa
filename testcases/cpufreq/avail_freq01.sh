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
 #  To test ability to monitor and/or alter cpu frequency on the board, assure
 #  basic files are there.
###

if [ -d /sys/devices/system/cpu/cpu0/cpufreq ] ; then
	if [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies ] ; then
		echo "NA   no added frequencies"
		exit -1;
	fi
	if [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ] ; then
		echo "FAIL   missing current frequency file"
		exit -1;
	fi
	if [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed ] ; then
		echo "FAIL   missing file to set frequency speed"
		exit -1;
	fi
	echo "PASS      `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies `"
	exit  0;
else
	echo "NA   no added frequencies"
	exit  -1;
fi

