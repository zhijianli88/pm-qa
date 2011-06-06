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
 #  Simple test to assure governor support for cpu frequency altering is possible.
 #  Assure the files are available that allow you to switch between governors.
###
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ] ; then
	if [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors ] ; then
		echo "NA   no added frequencies"
		exit -1;
	fi
	if [ ! -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ] ; then
		echo "FAIL   missing scaling governor file"
		exit -1;
	fi
	echo "PASS      `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors `"
	exit  0;
else
	echo "NA   no added frequencies"
	exit  -1;
fi

