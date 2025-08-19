DOCKER_FLAGS = --project-directory $(DOCKER_DIR)

docker-build:
	$(ECHO) " DOCKER   BUILD -> $(APP)"
	$(Q)export COMPOSE_BAKE=true
	$(Q)$(DOCKER) $(DOCKER_FLAGS) build --no-cache $(REDIRECT)
	$(Q)$(DOCKER) $(DOCKER_FLAGS) create $(REDIRECT)

docker-start:
	$(ECHO) " DOCKER  START -> $(APP)"
	$(Q)$(DOCKER) $(DOCKER_FLAGS) up -d $(REDIRECT)

docker-stop:
	$(ECHO) " DOCKER   STOP -> $(APP)"
	$(Q)$(DOCKER) $(DOCKER_FLAGS) down $(REDIRECT)

docker-shell:
	$(ECHO) " DOCKER   SHELL -> $(APP)"
	$(DOCKER) $(DOCKER_FLAGS) exec $(APP) $(SHELL)

docker-vcode:
	$(ECHO) " DOCKER   VCODE -> $(APP)"
	$(ECHO) $(DOCKER) $(DOCKER_FLAGS) exec $(APP) $(VCODE) $(REDIRECT)

docker-install_deps: 
	$(ECHO) " DOCKER   INSTALL_DEPS"
	$(Q)sudo bash -c '\
		set -e; \
		apt update && \
		apt install -y ca-certificates curl gnupg apt-transport-https gpg && \
		curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker.gpg && \
		echo "deb [arch=$$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" > /etc/apt/sources.list.d/docker.list && \
		apt update && \
		apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose \
	'


# docker-clean:
# 	$(ECHO) " DOCKER   CLEAN -> $(APP)"
# 	$(Q)$(DOCKER) 	   $(DOCKER_FLAGS) down		$(REDIRECT)
#	$(Q)$(DOCKER_CONT) rm $(CONTAINER) $(REDIRECT)
# 	$(Q)$(DOCKER_IMG)  rm docker-$(APP):latest	$(REDIRECT)
# 	$(Q)$(DOCKER_VOL)  rm docker-$(CODE_VOL)	$(REDIRECT)
# 	$(Q)$(DOCKER_VOL)  rm docker-$(PLAT_VOL)	$(REDIRECT)

