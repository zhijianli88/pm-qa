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

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Resources/TestSuite/PmQaSpecification#cpuhotplug_02

. ../include/functions.sh

check_state() {
    cpu=$1
    dirpath=$CPU_PATH/$cpu
    shift 1

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    set_offline $cpu
    state=$(get_online $cpu)

    check "$cpu is offline" "test $state -eq 0"
    if [ $? -ne 0 ]; then
	set_online $cpu
	return 1
    fi

    set_online $cpu
    state=$(get_online $cpu)

    check "$cpu is online" "test $state -eq 1"
    if [ $? -ne 0 ]; then
	return 1
    fi

    return 0
}

for_each_cpu check_state
test_status_show
