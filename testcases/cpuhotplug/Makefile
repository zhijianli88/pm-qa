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
 #     Vincent Guittot <vincent.guittot@linaro.org>
 #       - initial API and implementation
 #
 #     Torez Smith <torez.smith@linaro.org> (IBM Corporation)
 #       - editorial and/or harness conformance changes
 #******************************************************************************/

testcases =  cpu_hotplug_latency.sh

all:
	@for t in $(testcases) ; do chmod +x $$t; done;

clean:
	@for t in $(testcases) ; do chmod -x $$t; done;
	rm -rf test_load.txt
