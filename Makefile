EMACS ?= emacs
CASK ?= cask

-include makefile-local

ifdef EMACS
EMACS_ENV=EMACS=$(EMACS)
endif

all: robot-and-test

install:
	$(EMACS_ENV) $(CASK) install

test: install just-test

robot-and-test: basic-robot-test just-test

just-test:
	$(EMACS_ENV) $(CASK) emacs --batch -q \
	--directory=. \
	--load assess-discover.el \
	--eval '(assess-discover-run-and-exit-batch t)'

DOCKER_TAG=26
test-cp:
	docker run -it --rm --name docker-cp -v $(PWD):/usr/src/app -w /usr/src/app --entrypoint=/bin/bash  silex/emacs:$(DOCKER_TAG)-dev ./test-by-cp

test-git:
	docker run -it --rm --name docker-git -v $(PWD):/usr/src/app -w /usr/src/app --entrypoint=/bin/bash  silex/emacs:$(DOCKER_TAG)-dev ./test-from-git

docker-test:
	$(MAKE) test-git DOCKER_TAG=26.2
	$(MAKE) test-cp DOCKER_TAG=26.2
	$(MAKE) test-git DOCKER_TAG=25.3
	$(MAKE) test-cp DOCKER_TAG=25.3

basic-robot-test:
	$(CASK) clean-elc
	$(EMACS_ENV) ./robot/basic-run.sh

.PHONY: test
