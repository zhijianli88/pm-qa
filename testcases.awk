#/*******************************************************************************
 # Copyright (C) 2011, Linaro Limited.
 #
 # This file is part of PM QA.
 #
 # All rights reserved. This program and the accompanying materials
 # are made available under the terms of the Eclipse Public License v1.0
 # which accompanies this distribution, and is available at
 # http://www.eclipse.org/legal/epl-v10.html
 #
 # Contributors:
 #     Torez Smith <torez.smith@linaro.org> (IBM Corporation)
 #       - initial API and implementation
 #******************************************************************************/

###
 # For a series of power management related test, cycle through and 
 # execute. Each test to be executed is in file testcases  where the 
 # following columns make sense....
 # column 1:  name of the test case
 # column 2:  sub directory housing the test
 # column 3:  name of file for the test case
 # column 4:  from column 4 onwards, any arguments to pass on to the test
###
{
	printf $1 ":    "
	cmd = "cd  ./testcases/"$2   " ;  sudo ./"$3   " " substr($0, length($1 $2 $3) +4)
	system(cmd)
	printf "\n"
}

