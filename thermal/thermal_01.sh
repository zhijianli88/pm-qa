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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
# Contributors:
#     Amit Daniel <amit.kachhap@linaro.org> (Samsung Electronics)
#       - initial API and implementation
#

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Resources/TestSuite/PmQaSpecification#thermal_01

. ../include/functions.sh

ATTRIBUTES="mode temp type uevent"

check_thermal_zone_attributes() {
    zone_name=$1
    dirpath=$THERMAL_PATH/$zone_name
    shift 1
    for attribute in $ATTRIBUTES; do
	check_file $attribute $dirpath || return 1
    done

    check_valid_temp "temp" $zone_name || return 1
}

check_thermal_zone_mode() {
    zone_name=$1
    dirpath=$THERMAL_PATH/$zone_name
    shift 1
    prev_mode=$(cat $dirpath/mode)
    echo -n enabled > $dirpath/mode
    cur_mode=$(cat $dirpath/mode)
    check "$zone_name cur_mode=$cur_mode"\
			 "test $cur_mode = enabled" || return 1
    echo -n disabled > $dirpath/mode
    cur_mode=$(cat $dirpath/mode)
    check "$zone_name cur_mode=$cur_mode"\
			"test $cur_mode = disabled" || return 1

    echo $prev_mode > $dirpath/mode
}

check_thermal_zone_trip_level() {
    for thermal_zone in $thermal_zones; do
        for_each_trip_point_of_zone $thermal_zone "validate_trip_level" || return 1
    done
}

check_thermal_zone_bindings() {
    for thermal_zone in $thermal_zones; do
        for_each_binding_of_zone $thermal_zone "validate_trip_bindings" || return 1
    done
}

check_for_thermal_zones
if [ $? -ne 0 ]; then
   log_skip "No thermal zones found"
else
    for_each_thermal_zone check_thermal_zone_attributes
    for_each_thermal_zone check_thermal_zone_mode
    check_thermal_zone_trip_level
    check_thermal_zone_bindings
fi
test_status_show
