SRC_DIR              := src
TARGET_DIR           := target/site
DEV_TARGET_DIR       := target/dev-site
SOURCES              := $(wildcard $(SRC)/*)
RESOURCES            := $(addprefix $(SRC_DIR)/,odt2braille8.ttf)
TARGET               := $(TARGET_DIR)/index.html
DEV_TARGET           := $(DEV_TARGET_DIR)/index.html
TARGET_RESOURCES     := $(patsubst $(SRC_DIR)/%,$(TARGET_DIR)/%,$(RESOURCES))
DEV_TARGET_RESOURCES := $(patsubst $(SRC_DIR)/%,$(DEV_TARGET_DIR)/%,$(RESOURCES))
PHANTOMJS            := phantomjs
SKIP_TESTS           := false

all : $(TARGET) $(TARGET_RESOURCES)

dev : $(DEV_TARGET) $(DEV_TARGET_RESOURCES)

$(TARGET_RESOURCES) : $(TARGET_DIR)/% : $(SRC_DIR)/%
	cp $< $@

$(DEV_TARGET_RESOURCES) : $(DEV_TARGET_DIR)/% : $(SRC_DIR)/%
	cp $< $@

$(TARGET) : $(DEV_TARGET) respec
	mkdir -p $(TARGET_DIR)
	$(PHANTOMJS) respec/tools/respec2html.js $< >$@ || true

$(DEV_TARGET) : $(SOURCES) respec
	mkdir -p $(DEV_TARGET_DIR)
	mvn test -Dsource=$(SRC_DIR)/index.html -Dtarget=$@ -Dmy.skipTests=${SKIP_TESTS}

publish : all
	bash publish-on-gh-pages.sh $(TARGET_DIR) "git@github.com:snaekobbi/braille-css-spec.git"

respec :
	git clone -b phantomjs_ssl_issue "https://github.com/bertfrees/respec" --depth 1

clean :
	rm -rf target

.PHONY : all dev publish clean
