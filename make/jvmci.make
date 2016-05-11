# This Makefile is generated automatically, do not edit

TARGET=.
# Bootstrap JDK to be used (for javac and jar)
ABS_BOOTDIR=

JAVAC=$(ABS_BOOTDIR)/bin/javac -g -target 1.8
JAR=$(ABS_BOOTDIR)/bin/jar

HS_COMMON_SRC=.

# Directories, where the generated property-files reside within the JAR files
SERVICES_INF=/META-INF/jvmci.services

JARS = $(foreach dist,$(DISTRIBUTIONS),$($(dist)_JAR))

ifeq ($(ABS_BOOTDIR),)
    $(error Variable ABS_BOOTDIR must be set to a JDK installation.)
endif
ifeq ($(MAKE_VERBOSE),)
    QUIETLY=@
endif

# Required to construct a whitespace for use with subst
space :=
space +=

# Extracts META-INF/jvmci.services from a JAR file into a given directory
# Arguments:
#  1: JAR file to extract
#  2: target directory (which already exists)
define extract
    $(eval TMP := $(shell mktemp -d $(TARGET)/tmp_XXXXX))
    $(QUIETLY) cd $(TMP) && $(JAR) xf $(abspath $(1)) && \
         (test ! -d .$(SERVICES_INF) || cp -r .$(SERVICES_INF) $(abspath $(2)));
    $(QUIETLY) rm -r $(TMP);
    $(QUIETLY) cp $(1) $(2)
endef

# Calls $(JAVAC) with the boot class path $(JDK_BOOTCLASSPATH) and sources taken from the automatic variable $^
# Arguments:
#  1: processorpath
#  2: classpath
#  3: resources to copy
#  4: target JAR file
define build_and_jar
    $(info Building $(4))
    $(eval TMP := $(shell mkdir -p $(TARGET) && mktemp -d $(TARGET)/tmp_XXXXX))
    $(QUIETLY) $(JAVAC) -d $(TMP) -processorpath :$(1) -bootclasspath $(JDK_BOOTCLASSPATH) -cp :$(2) $(filter %.java,$^)
    $(QUIETLY) test "$(3)" = "" || cp -r $(3) $(TMP)

    @# Since all projects are built together with one javac call we cannot determine
    @# which project contains HotSpotVMConfig.inline.hpp so we hardcode it.
    $(eval vmconfig := $(TMP)/hotspot/HotSpotVMConfig.inline.hpp)
    $(eval vmconfigDest := $(HS_COMMON_SRC)/../mxbuild/jvmci/jdk.vm.ci.hotspot/src_gen/hotspot)
    $(QUIETLY) test ! -f $(vmconfig) || (mkdir -p $(vmconfigDest) && cp $(vmconfig) $(vmconfigDest))

    $(QUIETLY) mkdir -p $(shell dirname $(4))
    $(QUIETLY) $(JAR) -0cf $(4) -C $(TMP) .
    $(QUIETLY) rm -r $(TMP)
endef

# Verifies that make/defs.make contains an appropriate line for each JVMCI service
# and that only existing JVMCI services are exported.
# Arguments:
#  1: list of service files
#  2: variable name for directory of service files
define verify_defs_make
    $(eval defs := make/defs.make)
    $(eval uncondPattern := EXPORT_LIST += $$$$($(2))/)
    $(eval condPattern := CONDITIONAL_EXPORT_LIST += $$$$($(2))/)
    $(eval unconditionalExports := $(shell grep '^EXPORT_LIST += $$($2)' make/defs.make | sed 's:.*($(2))/::g'))
    $(eval conditionalExports := $(shell grep '^CONDITIONAL_EXPORT_LIST += $$($2)' make/defs.make | sed 's:.*($(2))/::g'))
    $(eval allExports := $(unconditionalExports) $(conditionalExports))
    $(foreach file,$(1),$(if $(findstring $(file),$(allExports)), ,$(error "Line matching '$(uncondPattern)$(file)' or '$(condPattern)$(file)' not found in $(defs)")))
    $(foreach export,$(unconditionalExports),$(if $(findstring $(export),$(1)), ,$(error "The line '$(uncondPattern)$(export)' should not be in $(defs)")))
endef

all: default
	$(info Put $(EXPORTED_FILES) into SHARED_DIR $(SHARED_DIR))
	$(shell mkdir -p $(SHARED_DIR))
	$(foreach export,$(EXPORTED_FILES),$(call extract,$(export),$(SHARED_DIR)))

export: all
	$(call verify_defs_make,$(notdir $(wildcard $(SHARED_DIR)/jvmci.services/*)),EXPORT_JRE_LIB_JVMCI_SERVICES_DIR)
.PHONY: export

clean:
	$(QUIETLY) rm $(JARS) 2> /dev/null || true
	$(QUIETLY) rmdir -p $(dir $(JARS)) 2> /dev/null || true
.PHONY: export clean



JDK_BOOTCLASSPATH = $(ABS_BOOTDIR)/jre/lib/resources.jar:$(ABS_BOOTDIR)/jre/lib/rt.jar:$(ABS_BOOTDIR)/jre/lib/sunrsasign.jar:$(ABS_BOOTDIR)/jre/lib/jsse.jar:$(ABS_BOOTDIR)/jre/lib/jce.jar:$(ABS_BOOTDIR)/jre/lib/charsets.jar:$(ABS_BOOTDIR)/jre/lib/jfr.jar:$(ABS_BOOTDIR)/jre/classes

JVMCI_SERVICES_SRC += $(shell find jvmci/jdk.vm.ci.services/src -type f 2> /dev/null)

JVMCI_SERVICES_JAR = $(TARGET)/jvmci-services.jar

EXPORTED_FILES += $(JVMCI_SERVICES_JAR)

JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.inittimer/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.meta/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.code/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.runtime/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.aarch64/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.amd64/src -type f 2> /dev/null)
JVMCI_API_SRC += $(shell find jvmci/jdk.vm.ci.sparc/src -type f 2> /dev/null)

JVMCI_API_JAR = $(TARGET)/jvmci-api.jar

JVMCI_API_DEP_JARS = $(TARGET)/jvmci-services.jar

EXPORTED_FILES += $(JVMCI_API_JAR)

JVMCI_HOTSPOTVMCONFIG_SRC += $(shell find jvmci/jdk.vm.ci.hotspotvmconfig/src -type f 2> /dev/null)

JVMCI_HOTSPOTVMCONFIG_JAR = $(TARGET)/jvmci-hotspotvmconfig.jar

EXPORTED_FILES += $(JVMCI_HOTSPOTVMCONFIG_JAR)

JVMCI_HOTSPOTVMCONFIG_PROCESSOR_SRC += $(shell find jvmci/jdk.vm.ci.hotspotvmconfig.processor/src -type f 2> /dev/null)

JVMCI_HOTSPOTVMCONFIG_PROCESSOR_JAR = $(TARGET)/jvmci-hotspotvmconfig-processor.jar

JVMCI_HOTSPOTVMCONFIG_PROCESSOR_DEP_JARS = $(TARGET)/jvmci-services.jar $(TARGET)/jvmci-api.jar $(TARGET)/jvmci-hotspotvmconfig.jar

JVMCI_HOTSPOT_SRC += $(shell find jvmci/jdk.vm.ci.hotspot/src -type f 2> /dev/null)
JVMCI_HOTSPOT_SRC += $(shell find jvmci/jdk.vm.ci.hotspot.aarch64/src -type f 2> /dev/null)
JVMCI_HOTSPOT_SRC += $(shell find jvmci/jdk.vm.ci.hotspot.amd64/src -type f 2> /dev/null)
JVMCI_HOTSPOT_SRC += $(shell find jvmci/jdk.vm.ci.hotspot.sparc/src -type f 2> /dev/null)
ifeq ($(shell find $(ABS_BOOTDIR)/ -name 'jfr.jar'; echo $$?),'0')
JVMCI_HOTSPOT_SRC += $(shell find jvmci/jdk.vm.ci.hotspot.jfr/src -type f 2> /dev/null)
endif

JVMCI_HOTSPOT_JAR = $(TARGET)/jvmci-hotspot.jar

JVMCI_HOTSPOT_DEP_JARS = $(TARGET)/jvmci-hotspotvmconfig.jar $(TARGET)/jvmci-services.jar $(TARGET)/jvmci-api.jar

EXPORTED_FILES += $(JVMCI_HOTSPOT_JAR)

DISTRIBUTIONS = JVMCI_SERVICES JVMCI_API JVMCI_HOTSPOTVMCONFIG JVMCI_HOTSPOTVMCONFIG_PROCESSOR JVMCI_HOTSPOT

$(JVMCI_SERVICES_JAR): $(JVMCI_SERVICES_SRC)  
	$(call build_and_jar,,$(subst  $(space),:,),,$(JVMCI_SERVICES_JAR))


$(JVMCI_API_JAR): $(JVMCI_API_SRC)  $(JVMCI_API_DEP_JARS)
	$(call build_and_jar,,$(subst  $(space),:,$(JVMCI_API_DEP_JARS)),,$(JVMCI_API_JAR))


$(JVMCI_HOTSPOTVMCONFIG_JAR): $(JVMCI_HOTSPOTVMCONFIG_SRC)  
	$(call build_and_jar,,$(subst  $(space),:,),,$(JVMCI_HOTSPOTVMCONFIG_JAR))


$(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_JAR): $(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_SRC)  $(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_DEP_JARS)
	$(call build_and_jar,,$(subst  $(space),:,$(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_DEP_JARS)),jvmci/jdk.vm.ci.hotspotvmconfig.processor/src/META-INF,$(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_JAR))


$(JVMCI_HOTSPOT_JAR): $(JVMCI_HOTSPOT_SRC) $(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_JAR) $(JVMCI_HOTSPOT_DEP_JARS)
	$(call build_and_jar,$(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_JAR):$(subst  $(space),:,$(JVMCI_HOTSPOTVMCONFIG_PROCESSOR_DEP_JARS)),$(subst  $(space),:,$(JVMCI_HOTSPOT_DEP_JARS)),jvmci/jdk.vm.ci.hotspot.aarch64/src/META-INF jvmci/jdk.vm.ci.hotspot.amd64/src/META-INF jvmci/jdk.vm.ci.hotspot.sparc/src/META-INF jvmci/jdk.vm.ci.hotspot.jfr/src/META-INF,$(JVMCI_HOTSPOT_JAR))


default: $(JVMCI_SERVICES_JAR) $(JVMCI_API_JAR) $(JVMCI_HOTSPOT_JAR) $(JVMCI_HOTSPOTVMCONFIG_JAR)
.PHONY: default
