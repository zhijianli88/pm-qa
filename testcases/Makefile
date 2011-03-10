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

tmp := $(shell find -maxdepth 2 -mindepth 2 -name Makefile)
paths := $(subst Makefile, ,$(tmp))
SUBDIRS := $(subst ./, ,$(paths))

.PHONY:	$(SUBDIRS)

all:
	@for X in $(SUBDIRS) ; do $(MAKE) -C $$X all ; done;


clean:
	@for X in $(SUBDIRS) ; do $(MAKE) -C $$X clean; done;



