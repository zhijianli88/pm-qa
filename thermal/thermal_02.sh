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

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Resources/TestSuite/PmQaSpecification#thermal_02

. ../include/functions.sh

CDEV_ATTRIBUTES="cur_state max_state type uevent"

check_cooling_device_attributes() {
    cdev_name=$1
    cdev_name_dir=$THERMAL_PATH/$cdev_name
    shift 1

    for attribute in $CDEV_ATTRIBUTES; do
	check_file $attribute $cdev_name_dir || return 1
    done

}

check_cooling_device_states() {
    cdev_name=$1
    cdev_name_dir=$THERMAL_PATH/$cdev_name
    shift 1
    max_state=$(cat $cdev_name_dir/max_state)
    prev_state_val=$(cat $cdev_name_dir/cur_state)
    count=0
    cur_state_val=0
    while (test $count -le $max_state); do
	echo $count > $cdev_name_dir/cur_state
	cur_state_val=$(cat $cdev_name_dir/cur_state)
	check "$cdev_name cur_state=$count"\
				"test $cur_state_val -eq $count" || return 1
	count=$((count + 1))
    done
    echo $prev_state_val > $cdev_name_dir/cur_state
}

set_thermal_governors user_space

for_each_cooling_device check_cooling_device_attributes
for_each_cooling_device check_cooling_device_states

restore_thermal_governors

test_status_show
