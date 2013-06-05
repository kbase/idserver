TOP_DIR = ../..
include $(TOP_DIR)/tools/Makefile.common
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment

SERVER_SPEC = IDServer-API.spec

SERVICE_MODULE = lib/Bio/KBase/IDServer/Service.pm

SERVICE = idserver
SERVICE_NAME = IDServer
SERVICE_PSGI_FILE = $(SERVICE_NAME).psgi
SERVICE_NAME_PY = idserver
SERVICE_PORT = 7031

# Needed if we are using Makefile directly, instead of from
# the dev_container
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_DIR ?= $(TARGET)/services/$(SERVICE)

# You can change these if you are putting your tests somewhere
# else or if you are not using the standard .t suffix
CLIENT_TESTS = $(wildcard t/*.t)

TPAGE = $(DEPLOY_RUNTIME)/bin/perl $(DEPLOY_RUNTIME)/bin/tpage
TPAGE_ARGS = --define kb_top=$(TARGET) --define kb_runtime=$(DEPLOY_RUNTIME) --define kb_service_name=$(SERVICE) \
	--define kb_service_port=$(SERVICE_PORT)

all: bin server

server: compile-typespec

bin: $(BIN_PERL)

deploy: deploy-client deploy-service
deploy-all: deploy-service deploy-client
deploy-service: compile-typespec  deploy-dir-service deploy-scripts deploy-libs deploy-services deploy-monit deploy-docs deploy-cfg
deploy-client: compile-typespec deploy-scripts deploy-libs deploy-docs

deploy-services: deploy-monit
	$(TPAGE) $(TPAGE_ARGS) service/start_service.tt > $(TARGET)/services/$(SERVICE)/start_service
	chmod +x $(TARGET)/services/$(SERVICE)/start_service
	$(TPAGE) $(TPAGE_ARGS) service/stop_service.tt > $(TARGET)/services/$(SERVICE)/stop_service
	chmod +x $(TARGET)/services/$(SERVICE)/stop_service

deploy-monit:
	$(TPAGE) $(TPAGE_ARGS) service/process.$(SERVICE).tt > $(TARGET)/services/$(SERVICE)/process.$(SERVICE)

deploy-docs: compile-typespec
	# Refresh comments in .pms from typespec (is that dangerous? Might the developers have changed the .pms in place?)
	-mkdir doc
	-mkdir $(SERVICE_DIR)
	-mkdir $(SERVICE_DIR)/webroot
	$(DEPLOY_RUNTIME)/bin/perl $(DEPLOY_RUNTIME)/bin/pod2html -t "ID Server API" lib/Bio/KBase/IDServer/Service.pm > doc/idserver_service_api.html
	$(DEPLOY_RUNTIME)/bin/perl $(DEPLOY_RUNTIME)/bin/pod2html -t "ID Service Client API" lib/Bio/KBase/IDServer/Client.pm > doc/idserver_client_api.html
	$(DEPLOY_RUNTIME)/bin/perl $(DEPLOY_RUNTIME)/bin/pod2html -t "ID Servicer API" lib/Bio/KBase/IDServer/Impl.pm > doc/idserver_impl_api.html
	cp doc/*html $(SERVICE_DIR)/webroot/.
	
compile-typespec:
	mkdir -p lib/biokbase/$(SERVICE_NAME_PY)
	touch lib/biokbase/__init__.py #do not include code in biokbase/__init__.py
	touch lib/biokbase/$(SERVICE_NAME_PY)/__init__.py 
	mkdir -p lib/javascript/$(SERVICE_NAME)
	compile_typespec \
		--psgi $(SERVICE_PSGI_FILE) \
		--impl Bio::KBase::$(SERVICE_NAME)::Impl \
		--service Bio::KBase::$(SERVICE_NAME)::Service \
		--client Bio::KBase::$(SERVICE_NAME)::Client \
		--py biokbase/$(SERVICE_NAME_PY)/client \
		--js javascript/$(SERVICE_NAME)/Client \
		$(SERVER_SPEC) lib

include $(TOP_DIR)/tools/Makefile.common.rules

test: test-client 
	echo "running client and script tests"

# What does it mean to test a client. This is a test of a client
# library. If it is a client-server module, then it should be
# run against a running server. You can say that this also tests
# the server, and I agree. You can add a test-server dependancy
# to the test-client target if it makes sense to you. This test
# example assumes there is already a tested running server.
test-client:
	# run each test
	for t in $(CLIENT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done



