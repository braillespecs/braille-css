SRC_DIR              := src
TARGET_DIR           := target/site
SOURCES              := $(wildcard $(SRC_DIR)/*.html)
SCRIPTS              := $(wildcard $(SRC_DIR)/*.js)
RESOURCES            := $(addprefix $(SRC_DIR)/,style.css odt2braille8.ttf text-transform.html obfl.html)
DEV_DIR              := target/tmp
DEV_INDEX            := $(DEV_DIR)/index.html
DEV_SCRIPTS          := $(patsubst $(SRC_DIR)/%,$(DEV_DIR)/%,$(SCRIPTS))
TARGET_INDEX         := $(TARGET_DIR)/index.html
TARGET_RESOURCES     := $(patsubst $(SRC_DIR)/%,$(TARGET_DIR)/%,$(RESOURCES))
SKIP_TESTS           := false
RESPEC2HTML          := docker compose run respec2html

all : $(TARGET_INDEX) $(TARGET_RESOURCES)

$(TARGET_RESOURCES) : $(TARGET_DIR)/% : $(SRC_DIR)/%
	mkdir -p $(dir $@)
	cp $< $@

$(TARGET_INDEX) : $(DEV_INDEX)
	mkdir -p $(dir $@)
	$(RESPEC2HTML) $< $@

$(DEV_INDEX) : $(SOURCES) $(DEV_SCRIPTS)
	mkdir -p $(dir $@)
	mvn test -Dsource=$(SRC_DIR)/index.html -Dtarget=$@ -Dmy.skipTests=${SKIP_TESTS}

$(DEV_SCRIPTS) : $(DEV_DIR)/% : $(SRC_DIR)/%
	mkdir -p $(dir $@)
	cp $< $@

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
