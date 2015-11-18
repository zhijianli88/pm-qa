#!/bin/sh
#
# PM-QA validation test suite for the power management on Linux
#
# Copyright (C) 2011, Linaro Limited.
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Contributors:
#     Daniel Lezcano <daniel.lezcano@linaro.org> (IBM Corporation)
#       - initial API and implementation
#

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Resources/TestSuite/PmQaSpecification#cpufreq_06

. ../include/functions.sh

CPUCYCLE=../utils/cpucycle
freq_results_array="results"

compute_freq_ratio() {
    index=0
    cpu=$1
    freq=$2

    set_frequency $cpu $freq

    result=$($CPUCYCLE $cpu)
    if [ $? -ne 0 ]; then
	return 1
    fi

    value=$(echo $result $freq | awk '{ printf "%.3f", $1 / $2 }')
    eval $freq_results_array$index=$value
    eval export $freq_results_array$index     
    index=$((index + 1))
}

compute_freq_ratio_sum() {
    index=0
    sum=0

    res=$(eval echo \$$freq_results_array$index)
    sum=$(echo $sum $res | awk '{ printf "%f", $1 + $2 }')
    index=$((index + 1))

}

__check_freq_deviation() {
    res=$(eval echo \$$freq_results_array$index)

    if [ ! -z "$res" ]; then
        # compute deviation
        dev=$(echo $res $avg | awk '{printf "%.3f", (($1 - $2) / $2) * 100}')

        # change to absolute
        dev=$(echo $dev | awk '{ print ($1 >= 0) ? $1 : 0 - $1}')

        index=$((index + 1))
        res=$(echo $dev | awk '{printf "%f", ($dev > 5.0)}')

        if [ "$res" = "1" ]; then
            return 1
        fi
    else
        return 1
    fi

    return 0
}

check_freq_deviation() {

    cpu=$1
    freq=$2

    check "deviation for frequency $(frequnit $freq)" __check_freq_deviation

}

check_deviation() {

    cpu=$1

    set_governor $cpu userspace

    for_each_frequency $cpu compute_freq_ratio

    for_each_frequency $cpu compute_freq_ratio_sum

    avg=$(echo $sum $index | awk '{ printf "%.3f", $1 / $2}')

    for_each_frequency $cpu check_freq_deviation
}

supported=$(cat $CPU_PATH/cpu0/cpufreq/scaling_available_governors | grep "userspace")
if [ -z "$supported" ]; then
    log_skip "userspace not supported"
    return 0
fi

save_governors
save_frequencies

trap "restore_frequencies; restore_governors; sigtrap" HUP INT TERM

for_each_cpu check_deviation

restore_frequencies
restore_governors
test_status_show
