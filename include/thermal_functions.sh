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

THERMAL_PATH="/sys/devices/virtual/thermal"
MAX_ZONE=0-12
MAX_CDEV=0-50
ALL_ZONE=
ALL_CDEV=

check_valid_temp() {
    local file=$1
    local zone_name=$2
    local dir=$THERMAL_PATH/$2

    local temp_file=$dir/$1
    local func=cat
    shift 2;

    local temp_val=$($func $temp_file)
    local descr="'$zone_name'/'$file' ='$temp_val'"
    log_begin "checking $descr"

    if [ $temp_val > 0 ]; then
        log_end "pass"
        return 0
    fi

    log_end "fail"

    return 1
}

for_each_thermal_zone() {

    local func=$1
    shift 1

    zones=$(ls $THERMAL_PATH | grep "thermal_zone['$MAX_ZONE']")

    ALL_ZONE=$zone
    for zone in $zones; do
	INC=0
	$func $zone $@
    done

    return 0
}

get_total_trip_point_of_zone() {

    local zone_path=$THERMAL_PATH/$1
    local count=0
    shift 1
    trips=$(ls $zone_path | grep "trip_point_['$MAX_ZONE']_temp")
    for zone in $zones; do
	count=$((count + 1))
    done
    return $count
}

for_each_trip_point_of_zone() {

    local zone_path=$THERMAL_PATH/$1
    local count=0
    local func=$2
    shift 2
    trips=$(ls $zone_path | grep "trip_point_['$MAX_ZONE']_temp")
    for trip in $trips; do
	$func $zone $count
	count=$((count + 1))
    done
    return 0
}

for_each_binding_of_zone() {

    local zone_path=$THERMAL_PATH/$1
    local count=0
    local func=$2
    shift 2
    trips=$(ls $zone_path | grep "cdev['$MAX_CDEV']_trip_point")
    for trip in $trips; do
	$func $zone $count
	count=$((count + 1))
    done

    return 0

}

check_valid_binding() {
    local trip_point=$1
    local zone_name=$2
    local dirpath=$THERMAL_PATH/$2
    local temp_file=$2/$1
    local trip_point_val = $(cat $dirpath/$trip_point)
    local trip_point_max = get_total_trip_point_of_zone $zone_name
    local descr="'$temp_file' valid binding"
    shift 2

    log_begin "checking $descr"
    if [ $trip_point > $trip_point_max ]; then
        log_end "fail"
        return 1
    fi

    log_end "pass"
    return 0
}

validate_trip_bindings() {
    local zone_name=$1
    local bind_no=$2
    local dirpath=$THERMAL_PATH/$1
    local trip_point=cdev$2_trip_point
    shift 2

    check_file $trip_point $dirpath || return 1
    check_valid_binding $trip_point $zone_name || return 1
}

validate_trip_level() {
    local zone_name=$1
    local trip_no=$2
    local dirpath=$THERMAL_PATH/$1
    local trip_temp=trip_point_$2_temp
    local trip_type=trip_point_$2_type
    shift 2

    check_file $trip_temp $dirpath || return 1
    check_file $trip_type $dirpath || return 1
    check_valid_temp $trip_temp $zone_name || return 1
}
