SRC_DIR              := src
TARGET_DIR           := target/site
INDEX_SOURCES        := $(SRC_DIR)/index.html $(wildcard $(SRC_DIR)/main/*.html)
SCRIPTS              := $(wildcard $(SRC_DIR)/*.js)
RESOURCES            := $(addprefix $(SRC_DIR)/,style.css odt2braille8.ttf)
DEV_DIR              := target/tmp
DEV_HTML             := $(addprefix $(DEV_DIR)/,index.html obfl.html text-transform.html)
DEV_SCRIPTS          := $(patsubst $(SRC_DIR)/%,$(DEV_DIR)/%,$(SCRIPTS))
DEV_RESOURCES        := $(patsubst $(SRC_DIR)/%,$(DEV_DIR)/%,$(RESOURCES))
TARGET_HTML          := $(patsubst $(DEV_DIR)/%,$(TARGET_DIR)/%,$(DEV_HTML))
TARGET_RESOURCES     := $(patsubst $(SRC_DIR)/%,$(TARGET_DIR)/%,$(RESOURCES))
SKIP_TESTS           := false
RESPEC2HTML          := docker-compose run respec2html
SPECREF_URL          ?= http://specref:5000
RESPEC_URL           ?= http://respec

all : $(TARGET_HTML) $(TARGET_RESOURCES)

$(TARGET_RESOURCES) : $(TARGET_DIR)/% : $(DEV_DIR)/%
	mkdir -p $(dir $@)
	cp $< $@

$(TARGET_HTML) : $(TARGET_DIR)/% : $(DEV_DIR)/%
	mkdir -p $(dir $@)
	$(RESPEC2HTML) $< $@

$(DEV_DIR)/index.html : $(INDEX_SOURCES)

$(DEV_HTML) : $(DEV_DIR)/% : $(SRC_DIR)/% $(DEV_SCRIPTS) $(DEV_RESOURCES)
	trap "rm -f $<.tmp" EXIT; \
	cat $< | SPECREF_URL="$(SPECREF_URL)" RESPEC_URL="$(RESPEC_URL)" envsubst '$${SPECREF_URL} $${RESPEC_URL}' >$<.tmp && \
	mkdir -p $(dir $@) && \
	mvn test -Dsource=$<.tmp -Dtarget=$@ -Dmy.skipTests=${SKIP_TESTS}

$(DEV_SCRIPTS) $(DEV_RESOURCES) : $(DEV_DIR)/% : $(SRC_DIR)/%
	mkdir -p $(dir $@)
	cat $< | SPECREF_URL="$(SPECREF_URL)" RESPEC_URL="$(RESPEC_URL)" envsubst '$${SPECREF_URL} $${RESPEC_URL}' >$@

publish : all
	bash publish-on-gh-pages.sh $(TARGET_DIR)

respec/src :
	git clone -b config-specref --depth 1 "https://github.com/snaekobbi/respec" $@

specref/src :
	git clone "https://github.com/tobie/specref" $@
	cd $@ && git checkout 5e2266af931cb835998a00c8c1aada93cdb8e0e8

clean :
	rm -rf target

.PHONY : all dev publish clean
