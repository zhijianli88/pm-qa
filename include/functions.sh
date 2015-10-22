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

. ../Switches/Switches.sh

CPU_PATH="/sys/devices/system/cpu"
TEST_NAME=$(basename ${0%.sh})
PREFIX=$TEST_NAME
INC=0
cpus=$(ls $CPU_PATH | grep "cpu[0-9].*")
pass_count=0
fail_count=0
skip_count=0
test_script_status="pass"
NANOSLEEP="../utils/nanosleep"
gov_array="governors_backup"
freq_array="frequencies_backup"

test_status_show() {
    if [ $fail_count -ne 0 ]; then
        test_script_status="fail"
    else
        if [ $skip_count -ne 0 ]; then
            if [ $pass_count -ne 0 ]; then
                test_script_status="pass"
            else
                test_script_status="skip"
            fi
        fi
    fi

    echo " "
    if [ "$test_script_status" = "fail" ]; then
        echo "$TEST_NAME: fail"
    elif [ "$test_script_status" = "skip" ]; then
        echo "$TEST_NAME: skip"
    else
        echo "$TEST_NAME: pass"
    fi
    echo " "
}

skip_tests() {
    dir=$1

    test_script_list=$(ls ../$1/*.sh | grep -v 'sanity.sh$' | grep -v '00.sh$')

    for test_script in $test_script_list; do
        test_case=$(basename $test_script .sh)
        echo "$test_case: skip"
    done
}

log_begin() {
    printf "%-76s" "$TEST_NAME.$INC$CPU: $@... "
    INC=$(($INC+1))
}

log_end() {
    printf "$*\n"

    if [ "$*" = "Err" ]; then
        fail_count=$((fail_count + 1))
    elif [ "$*" = "skip" ]; then
        skip_count=$((skip_count + 1))
    else
        pass_count=$((pass_count + 1))
    fi
}

log_skip() {
    log_begin "$@"
    log_end "skip"
}

for_each_cpu() {

    cpu_func=$1
    shift 1

    for cpu in $cpus; do
	INC=0
	CPU=/$cpu
	$cpu_func $cpu $@
    done

    return 0
}

for_each_governor() {

    gov_cpu=$1
    gov_func=$2
    cpufreq_dirpath=$CPU_PATH/$gov_cpu/cpufreq
    governors=$(cat $cpufreq_dirpath/scaling_available_governors)
    shift 2

    for governor in $governors; do
	$gov_func $gov_cpu $governor $@
    done

    return 0
}

for_each_frequency() {

    freq_cpu=$1
    freq_func=$2
    cpufreq_dirpath=$CPU_PATH/$freq_cpu/cpufreq
    frequencies=$(cat $cpufreq_dirpath/scaling_available_frequencies)
    shift 2

    for frequency in $frequencies; do
	$freq_func $freq_cpu $frequency $@
    done

    return 0
}

set_governor() {

    gov_cpu=$1
    scaling_gov_dirpath=$CPU_PATH/$gov_cpu/cpufreq/scaling_governor
    newgov=$2

    echo $newgov > $scaling_gov_dirpath
}

get_governor() {

    gov_cpu=$1
    scaling_gov_dirpath=$CPU_PATH/$gov_cpu/cpufreq/scaling_governor

    cat $scaling_gov_dirpath
}

wait_latency() {
    wait_latency_cpu=$1
    cpufreq_dirpath=$CPU_PATH/$wait_latency_cpu/cpufreq
    gov=$(cat $cpufreq_dirpath/scaling_governor)

    # consider per-policy governor case
    if [ -e $CPU_PATH/$wait_latency_cpu/cpufreq/$gov ]; then
	sampling_rate=$(cat $CPU_PATH/$wait_latency_cpu/cpufreq/$gov/sampling_rate)
    else
        sampling_rate=$(cat $CPU_PATH/cpufreq/$gov/sampling_rate)
    fi
    sampling_rate=$((sampling_rate * 1000)) # unit nsec

    latency=$(cat $cpufreq_dirpath/cpuinfo_transition_latency)
    if [ $? -ne 0 ]; then
	return 1
    fi

    nrfreq=$(cat $cpufreq_dirpath/scaling_available_frequencies | wc -w)
    if [ $? -ne 0 ]; then
	return 1
    fi

    nrfreq=$((nrfreq + 1))

    sleep_time=$(($latency + $sampling_rate))

    $NANOSLEEP $(($nrfreq * $sleep_time))
}

frequnit() {
    freq=$1
    ghz=$(echo $freq | awk '{printf "%.1f", ($1 / 1000000)}')
    mhz=$(echo $freq | awk '{printf "%.1f", ($1 / 1000)}')

    ghz_value=$(echo $ghz | awk '{printf "%f", ($1 > 1.0)}')
    if [ "$ghz_value" = "1" ]; then
	echo $ghz GHz
	return 0
    fi

    mhz_value=$(echo $mhz | awk '{printf "%f", ($1 > 1.0)}')
    if [ "$mhz_value" = "1" ];then
	echo $mhz MHz
	return 0
    fi

    echo $freq KHz
}

set_frequency() {

    freq_cpu=$1
    cpufreq_dirpath=$CPU_PATH/$freq_cpu/cpufreq
    newfreq=$2
    setfreqpath=$cpufreq_dirpath/scaling_setspeed

    echo $newfreq > $setfreqpath
    wait_latency $freq_cpu
}

get_frequency() {
    freq_cpu=$1
    scaling_cur_freq=$CPU_PATH/$freq_cpu/cpufreq/scaling_cur_freq
    cat $scaling_cur_freq
}

get_max_frequency() {
    freq_cpu=$1
    scaling_max_freq=$CPU_PATH/$freq_cpu/cpufreq/scaling_max_freq
    cat $scaling_max_freq
}

get_min_frequency() {
    freq_cpu=$1
    scaling_min_freq=$CPU_PATH/$freq_cpu/cpufreq/scaling_min_freq
    cat $scaling_min_freq
}

set_online() {
    current_cpu=$1
    current_cpu_path=$CPU_PATH/$current_cpu

    if [ "$current_cpu" = "cpu0" ]; then
	return 0
    fi

    echo 1 > $current_cpu_path/online
}

set_offline() {
    current_cpu=$1
    current_cpu_path=$CPU_PATH/$current_cpu

    if [ "$current_cpu" = "cpu0" ]; then
	return 0
    fi

    echo 0 > $current_cpu_path/online
}

get_online() {
    current_cpu=$1
    current_cpu_path=$CPU_PATH/$current_cpu

    cat $current_cpu_path/online
}

check() {

    check_descr=$1
    check_func=$2
    shift 2;

    log_begin "checking $check_descr"

    $check_func $@
    if [ $? -ne 0 ]; then
	log_end "Err"
	return 1
    fi

    log_end "Ok"

    return 0
}

check_file() {
    file=$1
    dir=$2

    check "'$file' exists in '$dir'" "test -f" $dir/$file
}

check_cpufreq_files() {
    cpu_id=$1
    cpufreq_files_dir=$CPU_PATH/$cpu_id/cpufreq
    shift 1

    for i in $@; do
	check_file $i $cpufreq_files_dir || return 1
    done

    return 0
}

check_sched_mc_files() {

    for i in $@; do
	check_file $i $CPU_PATH || return 1
    done

    return 0
}

check_topology_files() {
    cpu=$1
    topology_files_dir=$CPU_PATH/$cpu/topology
    shift 1

    for i in $@; do
	check_file $i $topology_files_dir || return 1
    done

    return 0
}

check_cpuhotplug_files() {

    cpuhotplug_files_dir=$CPU_PATH/$1
    shift 1

    for i in $@; do
	if [ `echo $cpuhotplug_files_dir | grep -c "cpu0"` -eq 1 ]; then
        	if [ $hotplug_allow_cpu0 -eq 0 ]; then
			continue
		fi
	fi

	check_file $i $cpuhotplug_files_dir || return 1
    done

    return 0
}

save_governors() {

    index=0

    for cpu in $cpus; do
        scaling_gov_value=$(cat $CPU_PATH/$cpu/cpufreq/scaling_governor)
        eval $gov_array$index=$scaling_gov_value
        eval export $gov_array$index
    done
}

restore_governors() {

    index=0

    for cpu in $cpus; do
        oldgov=$(eval echo \$$gov_array$index)
        echo $oldgov > $CPU_PATH/$cpu/cpufreq/scaling_governor
        index=$((index + 1))
    done
}

save_frequencies() {

    index=0

    for cpu in $cpus; do
        freq_value=$(cat $CPU_PATH/$cpu/cpufreq/scaling_cur_freq)
        eval $freq_array$index=$freq_value
        eval export $freq_array$index
    done
}

restore_frequencies() {

    index=0

    for cpu in $cpus; do
	oldfreq=$(eval echo \$$freq_array$index)
	echo $oldfreq > $CPU_PATH/$cpu/cpufreq/scaling_setspeed
	index=$((index + 1))
    done
}

sigtrap() {
    exit 255
}

# currently we support ubuntu and android
get_os() {
    lsb_release -a 2>&1 | grep -i ubuntu > /dev/null
    if [ $? -eq 0 ]; then
        # for ubuntu
        return 1
    else
        # for android (if needed can look for build.prop)
        return 2
    fi
}

is_root() {
    get_os
    if [ $? -eq 1 ]; then
        # for ubuntu
        ret=$(id -u)
    else
        # for android
        ret=$(id | sed -n 's/uid=//p' | sed -n 's/(root) [a-z]*=[0-9]*(log)//p')
    fi
    return $ret
}

is_cpu0_hotplug_allowed() {
    status=$1

    if [ $status -eq 1 ]; then
	return 0
    else
	return 1
    fi
}
