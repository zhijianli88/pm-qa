#!/bin/bash
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
# Contributors:
#     Amit Daniel <amit.kachhap@linaro.org> (Samsung Electronics)
#       - initial API and implementation
#

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Doc/QA/Scripts#thermal_06

source ../include/functions.sh
source ../include/thermal_functions.sh

CPU_HEAT_BIN=../utils/heat_cpu
GPU_HEAT_BIN=/usr/bin/glmark2
TEST_LOOP=100
TRIP_CROSSED_COUNT=

check_trip_point_change() {
    local dirpath=$THERMAL_PATH/$1
    local zone_name=$1
    shift 1

    local count=0
    local cur_temp=0
    local trip_temp=0
    local trip_cross=
    local trip_id=
    local cpu_pid=0
    local gpu_pid=0
    local trip_type=0
    local trip_type_path=0
    $CPU_HEAT_BIN &
    cpu_pid=$(ps | grep heat_cpu| awk '{print $1}')
    test -z $cpu_pid && cpu_pid=0
    check "start cpu heat binary" "test $cpu_pid -ne 0"

    if [ -x $GPU_HEAT_BIN ]; then
        $GPU_HEAT_BIN &
        gpu_pid=$(ps | grep $GPU_HEAT_BIN| awk '{print $1}')
        test -z $gpu_pid && gpu_pid=0
    else
        echo "glmark2 not found." 1>&2
    fi
    check "start gpu heat binary" "test $gpu_pid -ne 0"

    local index=0
    for trip in $(ls $dirpath | grep "trip_point_['$MAX_ZONE']_temp"); do
	trip_cross[$index]=0
	index=$((index + 1))
    done
    while (test $count -lt $TEST_LOOP); do
	index=0
	sleep 1
	for trip in $(ls $dirpath | grep "trip_point_['$MAX_ZONE']_temp"); do
	    cur_temp=$(cat $dirpath/temp)
	    trip_temp=$(cat $dirpath/$trip)
	    if [ $cur_temp -gt $trip_temp ]; then
	        trip_cross[$index]=$((${trip_cross[$index]} + 1))
 	    fi
	    index=$((index + 1))

	done
	count=$((count + 1))
    done
    index=0
    for trip in $(ls $dirpath | grep "trip_point_['$MAX_ZONE']_temp"); do
	get_trip_id $trip
	trip_id=$?
	trip_type=$(cat $dirpath/trip_point_$((trip_id))_type)
	trip_temp=$(cat $dirpath/$trip)

	if [ $trip_type != "critical" ]; then
	    count=${trip_cross[$index]}
	    check "$trip:$trip_temp crossed" "test $count -gt 0"
	fi
	index=$((index + 1))
    done

    if [ $cpu_pid != 0 ]; then
	kill -9 $cpu_pid
    fi
    if [ $gpu_pid != 0 ]; then
	kill -9 $gpu_pid
    fi
}

for_each_thermal_zone check_trip_point_change