# # Change this to your feature branch name
# FEATURE_BRANCH=feature/ci-cd-enhancements
# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@echo "Merging $(FEATURE_BRANCH) into $(STAGING_BRANCH)..."
# 	git checkout $(STAGING_BRANCH)
# 	git pull origin $(STAGING_BRANCH)
# 	git merge $(FEATURE_BRANCH)
# 	git push origin $(STAGING_BRANCH)
# 	@echo "✅ Staging deploy triggered via GitHub Actions."

# deploy-prod:
# 	@echo "Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
# 	git checkout $(MAIN_BRANCH)
# 	git pull origin $(MAIN_BRANCH)
# 	git merge $(STAGING_BRANCH)
# 	git push origin $(MAIN_BRANCH)
# 	@echo "🚀 Production deploy triggered via GitHub Actions."



# Makefile with Auto-Detected Feature Branch
#----------------------------------------------
# STAGING_BRANCH=staging
# MAIN_BRANCH=main
# # Makefile with Auto-Detected Feature Branch
# #----------------------------------------------
# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# .PHONY: deploy-staging deploy-prod


# deploy-staging:
# 	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
# 	if [ "$$CURRENT_BRANCH" = "$(STAGING_BRANCH)" ] || [ "$$CURRENT_BRANCH" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: You must run this from a feature branch, not '$$CURRENT_BRANCH'."; \
# 		exit 1; \
# 	fi; \
# 	echo "🔄 Merging '$$CURRENT_BRANCH' into '$(STAGING_BRANCH)'..."; \
# 	git checkout $(STAGING_BRANCH); \
# 	git pull origin $(STAGING_BRANCH); \
# 	git merge $$CURRENT_BRANCH; \
# 	git push origin $(STAGING_BRANCH); \
# 	echo "✅ Staging deploy triggered via GitHub Actions."

# deploy-prod:
# 	@echo "🔄 Merging '$(STAGING_BRANCH)' into '$(MAIN_BRANCH)'..."
# 	git checkout $(MAIN_BRANCH)
# 	git pull origin $(MAIN_BRANCH)
# 	git merge $(STAGING_BRANCH)
# 	git push origin $(MAIN_BRANCH)
# 	@echo "🚀 Production deploy triggered via GitHub Actions."



# Makefile with uncommitted check logic
#-----------------------------------------------------------------
# # Makefile with uncommitted check logic
# #-----------------------------------------------------------------
STAGING_BRANCH=staging
MAIN_BRANCH=main
CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: deploy-staging deploy-prod

deploy-staging:
	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
		echo "❌ ERROR: You must run this from a feature branch, not $(CURRENT_BRANCH)."; \
		exit 1; \
	fi
	@if ! git diff-index --quiet HEAD --; then \
		echo "❌ ERROR: You have uncommitted changes. Please commit or stash before deploying."; \
		exit 1; \
	fi
	@echo "🔁 Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."
	git checkout $(STAGING_BRANCH)
	git pull origin $(STAGING_BRANCH)
	git merge $(CURRENT_BRANCH)
	git push origin $(STAGING_BRANCH)
	@echo "✅ Staging deploy triggered via GitHub Actions."

deploy-prod:
	@echo "🔁 Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
	git checkout $(MAIN_BRANCH)
	git pull origin $(MAIN_BRANCH)
	git merge $(STAGING_BRANCH)
	git push origin $(MAIN_BRANCH)
	@echo "🚀 Production deploy triggered via GitHub Actions."

deploy-staging:
	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
		echo "❌ ERROR: You must run this from a feature branch, not $(CURRENT_BRANCH)."; \
		exit 1; \
	fi
	@if ! git diff-index --quiet HEAD --; then \
		echo "❌ ERROR: You have uncommitted changes. Please commit or stash before deploying."; \
		exit 1; \
	fi
	@echo "🔁 Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."
	git checkout $(STAGING_BRANCH)
	git pull origin $(STAGING_BRANCH)
	git merge $(CURRENT_BRANCH)
	git push origin $(STAGING_BRANCH)
	@echo "✅ Staging deploy triggered via GitHub Actions."

deploy-prod:
	@echo "🔁 Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
	git checkout $(MAIN_BRANCH)
	git pull origin $(MAIN_BRANCH)
	git merge $(STAGING_BRANCH)
	git push origin $(MAIN_BRANCH)
	@echo "🚀 Production deploy triggered via GitHub Actions."

