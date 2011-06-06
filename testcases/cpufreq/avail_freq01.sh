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
 #     Daniel Lezcano <daniel.lezcano@linaro.org> (IBM Corporation)
 #       - Added SMP support
 #******************************************************************************/

# Description : We are checking the frequency scaling file system is
#  available. This test checks we have the framework to run the other
#  tests in order to test the ability to monitor and/or alter cpu
#  frequency on the board, let's assure the basic files are there.

CPU_PATH="/sys/devices/system/cpu"

check_freq() {
    if [ ! -f $CPU_PATH/$1/cpufreq/scaling_available_frequencies ] ; then
	echo "NA no added frequencies"
	return 1;
    fi

    if [ ! -f $CPU_PATH/$1/cpufreq/scaling_cur_freq ] ; then
	echo "missing current frequency file"
	return 1;
    fi

    if [ ! -f $CPU_PATH/$1/cpufreq/scaling_setspeed ] ; then
	echo "missing file to set frequency speed"
	return 1;
    fi

    echo "PASS `cat $CPU_PATH/$1/cpufreq/scaling_available_frequencies `"
    return  0;
}

for i in $(ls $CPU_PATH | grep "cpu[0-9].*"); do
    check_freq $i
done

