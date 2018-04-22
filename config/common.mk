PRODUCT_BRAND ?= CarbonROM
CARBON_BUILD := true

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/carbon/prebuilt/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/carbon/prebuilt/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_GENERIC_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_GENERIC_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

# Fixes: terminate called after throwing an instance of 'std::out_of_range' what(): basic_string::erase
# error with prop override
PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

# general properties
PRODUCT_GENERIC_PROPERTIES += \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    persist.sys.root_access=1 \
    ro.opa.eligible_device=true

PRODUCT_GENERIC_PROPERTIES += \
    ro.build.selinux=1

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/carbon/prebuilt/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/carbon/prebuilt/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/carbon/prebuilt/bin/50-hosts.sh:system/addon.d/50-hosts.sh \
    vendor/carbon/prebuilt/bin/blacklist:system/addon.d/blacklist

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/carbon/config/permissions/backup.xml:system/etc/sysconfig/backup.xml

# init.d support
PRODUCT_COPY_FILES += \
    vendor/carbon/prebuilt/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/carbon/prebuilt/bin/sysinit:system/bin/sysinit \
    vendor/carbon/prebuilt/etc/init.carbon.rc:root/init.carbon.rc

# Enable SIP and VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Additional packages
-include vendor/carbon/config/packages.mk

# Versioning
-include vendor/carbon/config/version.mk

# SELinux Policy
-include vendor/carbon/sepolicy/sepolicy.mk

# Add our overlays
PRODUCT_PACKAGE_OVERLAYS += vendor/carbon/overlay/common

# Squisher Location
SQUISHER_SCRIPT := vendor/carbon/tools/squisher

# Include SDCLANG definitions if it is requested and available
ifeq ($(HOST_OS),linux)
    ifneq ($(wildcard vendor/qcom/sdclang-4.0/),)
        include vendor/carbon/sdclang/sdclang.mk
    endif
endif
