### local.mak --- Local toplevel makefile for Emacs Lisp libraries

## Copyright (C) 2007, 2012, 2013 Didier Verna

## Author: Didier Verna <didier@didierverna.net>

## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License version 3,
## as published by the Free Software Foundation.

## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.

## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.


### Commentary:

## Contents management by FCM version 0.1.

## Please use GNU Make with this makefile.


### Code:


tag:
	git tag 'version_$(VERSION)'

tgz: $(TARBALL)
gpg: $(SIGNATURE)
dist: tgz gpg

distclean:
	-rm $(TARBALL) $(SIGNATURE)
	$(MAKE) gen TARGET=distclean

www-dist: dist
	echo "$(VERSION)" > /tmp/version.txt
	chmod 644 /tmp/version.txt
	scp -p /tmp/version.txt $(WWW_HOST):$(WWW_DIR)/
	scp -p NEWS             $(WWW_HOST):$(WWW_DIR)/news.txt
	scp -p $(TARBALL)       $(WWW_HOST):$(WWW_DIR)/attic/
	scp -p $(SIGNATURE)     $(WWW_HOST):$(WWW_DIR)/attic/
	echo "\
<? lref (\"$(PROJECT)/attic/$(TARBALL)\", \
	 contents (\"Dernière version\", \"Latest version\")); ?> \
| \
<? lref (\"$(PROJECT)/attic/$(SIGNATURE)\", \
	 contents (\"Signature GPG\", \"GPG Signature\")); ?>" \
	  > /tmp/latest.txt
	chmod 644 /tmp/latest.txt
	scp -p /tmp/latest.txt  $(WWW_HOST):$(WWW_DIR)/
	$(MAKE) gen TARGET=www-dist
	ssh $(WWW_HOST)					\
	  'cd $(WWW_DIR)					\
	   && ln -fs attic/$(TARBALL) latest.tar.gz		\
	   && ln -fs attic/$(SIGNATURE) latest.tar.gz.asc'

www-undist:
	ssh $(WWW_HOST) 'rm -fr $(WWW_DIR)'

xp-dist:
ifeq ($(SIMPLE),)
	hg convert --filemap .hgfilemap --authormap .hgauthormap \
	  . $(XP_DIR)/$(XP_PKG)/
else
	cd lisp && $(MAKE) xp-dist
endif

elpa-dist:
ifeq ($(SIMPLE),)
	@echo "#### FIXME: not implemented for multi-file packages yet"
else
	cd lisp && $(MAKE) elpa-dist
endif

$(TARBALL):
	git archive --format=tgz --prefix=$(DIST_NAME)/ -o $@ HEAD

$(SIGNATURE): $(TARBALL)
	gpg -b -a $<

.PHONY: tag convert tgz gpg dist distclean \
	www-dist www-undist elpa-dist


### local.mak ends here
