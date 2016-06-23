SRC_DIR              := src
TARGET_DIR           := target/site
INDEX_SOURCES        := $(SRC_DIR)/index.html $(wildcard $(SRC_DIR)/main/*.html)
SCRIPTS              := $(wildcard $(SRC_DIR)/*.js)
RESOURCES            := $(addprefix $(SRC_DIR)/,style.css odt2braille8.ttf)
DEV_DIR              := target/tmp
DEV_HTML             := $(addprefix $(DEV_DIR)/,index.html obfl.html text-transform.html)
DEV_SCRIPTS          := $(patsubst $(SRC_DIR)/%,$(DEV_DIR)/%,$(SCRIPTS))
TARGET_HTML          := $(patsubst $(DEV_DIR)/%,$(TARGET_DIR)/%,$(DEV_HTML))
TARGET_RESOURCES     := $(patsubst $(SRC_DIR)/%,$(TARGET_DIR)/%,$(RESOURCES))
SKIP_TESTS           := false
RESPEC2HTML          := docker compose run respec2html

all : $(TARGET_HTML) $(TARGET_RESOURCES)

$(TARGET_RESOURCES) : $(TARGET_DIR)/% : $(SRC_DIR)/%
	mkdir -p $(dir $@)
	cp $< $@

$(TARGET_HTML) : $(TARGET_DIR)/% : $(DEV_DIR)/%
	mkdir -p $(dir $@)
	$(RESPEC2HTML) $< $@

$(DEV_DIR)/index.xhtml : $(INDEX_SOURCES)

$(DEV_HTML) : $(DEV_DIR)/% : $(SRC_DIR)/% $(DEV_SCRIPTS)
	mkdir -p $(dir $@)
	mvn test -Dsource=$< -Dtarget=$@ -Dmy.skipTests=${SKIP_TESTS}

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
