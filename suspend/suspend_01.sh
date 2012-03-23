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

# URL : https://wiki.linaro.org/WorkingGroups/PowerManagement/Doc/QA/Scripts#suspend_01


source ../include/functions.sh
source ../include/suspend.sh

test_dbus=1
auto=1

if [ "$test_dbus" -eq 1 -a \
		\( "$SUDO_USER" = "" -o "$SUDO_USER" = "root" \) ]; then
	ECHO "*** no primary user (via sudo) dbus tests skipped ..."
elif [ "$test_dbus" -eq 1 ]; then
	ac_required 1
	suspend_dbus=1
	phase
	check "suspend via dbus message" suspend_system 
	if [ $? -eq 0 ]; then
		rm -f "$LOGFILE"
	fi
	suspend_dbus=0
fi

