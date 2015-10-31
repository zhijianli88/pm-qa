#!/bin/sh
#
# PM-QA validation test suite for the power management on Linux
#
# Copyright (C) 2013, Linaro Limited.
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
#     Sanjay Singh Rawat <sanjay.rawat@linaro.org> (LG Electronics)
#       - initial API and implementation
#

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Doc/QA/Scripts#thermal_00

. ../include/functions.sh

check_cooling_device_type() {
    all_zones=$(ls $THERMAL_PATH | grep "cooling_device['$MAX_CDEV']")
    echo "Cooling Device list"
    echo "-------------------"
    if [ -z "$all_zones" ]; then
	echo "- None"
    else
        for i in $all_zones; do
	    type=$(cat $THERMAL_PATH/$i/type)
            echo $i
	    echo "- $type"
        done
    fi
    echo "\n"
}

check_thermal_zone_type() {
    all_zones=$(ls $THERMAL_PATH | grep "thermal_zone['$MAX_ZONE']")
    echo "Thermal Zone list"
    echo "-----------------"
    if [ -z "$all_zones" ]; then
        echo "- None"
    else
        for i in $all_zones; do
	    type=$(cat $THERMAL_PATH/$i/type)
            echo $i
	    echo "- $type"
        done
    fi
    echo "\n"
}

check_thermal_zone_type
check_cooling_device_type
