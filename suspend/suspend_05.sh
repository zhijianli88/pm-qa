#!/bin/bash
#
# PM-QA validation test suite for the power management on Linux
#
# Copyright (C) 2012, Linaro Limited.
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
#     Hongbo ZHANG <hongbo.zhang@linaro.org> (ST-Ericsson Corporation)
#       - initial API and implementation
#

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Doc/QA/Scripts#suspend_05


source ../include/functions.sh
source ../include/suspend.sh

# test_timed: switch on/off this test
test_timed=1
auto=1

if [ "$test_timed" -eq 1 ]; then
	save_timer_delay="$timer_delay"
	timer_delay=20
	sus_number=0

	ac_required 1
	phase
	while [ "$timer_delay" -gt 0 ]; do
		check "iteration variable delay suspend/resume" suspend_system
		delay_system
		let timer_delay="$timer_delay - 5"
		let sus_number="sus_number + 1"
	done
	if [ $? -eq 0 ]; then
		rm -f "$LOGFILE"
	fi
	timer_delay="$save_timer_delay"
fi

