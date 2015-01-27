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

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Resources/TestSuite/PmQaSpecification#cpuhotplug_07

. ../include/functions.sh
TMPFILE=cpuhotplug_07.tmp
UEVENT_READER="../utils/uevent_reader"

check_notification() {
    cpu=$1

    if [ "$cpu" = "cpu0" ]; then
	is_cpu0_hotplug_allowed $hotplug_allow_cpu0 || return 0
    fi

    # damn ! udevadm is buffering the output, we have to use a temp file
    # to retrieve the output

    rm -f $TMPFILE
    $UEVENT_READER $TMPFILE &
    pid=$!
    sleep 1

    set_offline $cpu
    set_online $cpu

    # let the time the notification to reach userspace
    # and buffered in the file
    sleep 1
    kill -s INT $pid

    grep "offline@/devices/system/cpu/$cpu" $TMPFILE
    ret=$?
    check "offline event was received" "test $ret -eq 0"

    grep "online@/devices/system/cpu/$cpu" $TMPFILE
    ret=$?
    check "online event was received" "test $ret -eq 0"

    rm -f $TMPFILE
}

for_each_cpu check_notification
test_status_show
