IMG_DATE = $(shell date +%Y-%m-%d)
IMG_NAME = $(shell bash -c 'source ./config; echo $$IMG_NAME')

# pi-gen outputs builds in `deploy` directory by default. We are not enforcing
# this out of convenience, since it seems pretty unlikely to ever change.
PI_GEN_DEPLOY_DIR = deploy
BASE_IMG_FILENAME = $(PI_GEN_DEPLOY_DIR)/$(IMG_DATE)-$(IMG_NAME).img

FIRST_USER_NAME = $(shell bash -c 'source ./config; echo $$FIRST_USER_NAME')

PACKER_CONFIG_HOME = ${HOME}
PACKER_DIR = packer
ONLY ?= *

PACKER = $(shell which packer)
SHA256 = sha256sum
CUT = cut
SUDO = sudo
TEE = tee
RM = rm
SUDO_TEE = $(SUDO) $(TEE)

$(BASE_IMG_FILENAME):
	$(SUDO) -E ./build.sh

%.sha256: %
	$(SHA256) $< | $(SUDO_TEE) $@

images: $(BASE_IMG_FILENAME) $(BASE_IMG_FILENAME).sha256
	cd packer && \
		PACKER_CONFIG_DIR=$(PACKER_CONFIG_HOME) $(SUDO) -E \
		$(PACKER) build \
		-only=$(ONLY) \
		-var source_iso_url=../$(BASE_IMG_FILENAME) \
		-var source_iso_checksum=$$($(CUT) -d' ' -f1 < ../$(BASE_IMG_FILENAME).sha256) \
		-var output_directory=../$(PI_GEN_DEPLOY_DIR) \
		-var operator_user_name=$(FIRST_USER_NAME) \
		.

clean:
	$(SUDO) $(RM) -rf $(PI_GEN_DEPLOY_DIR)/*.img

all: images

