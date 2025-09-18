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



# # 2. Automatic Detection of Current Branch & Context-Aware Switching
# #----------------------------------------------------------------
# # Environment branches (can be overridden)
# STAGING_BRANCH ?= staging
# MAIN_BRANCH ?= main

# # Get current git branch dynamically
# CURRENT_BRANCH := $(shell git symbolic-ref --short HEAD 2>/dev/null)

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
# 	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
# 		echo "⚠️  Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
# 		git checkout $(STAGING_BRANCH); \
# 		git merge $(CURRENT_BRANCH); \
# 		git push origin $(STAGING_BRANCH); \
# 		git checkout $(CURRENT_BRANCH); \
# 	else \
# 		echo "✅ Already on $(STAGING_BRANCH). Pulling latest and pushing..."; \
# 		git push origin $(STAGING_BRANCH); \
# 	fi
# 	@echo "✅ Staging deploy triggered via GitHub Actions."

# deploy-prod:
# 	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
# 	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
# 		echo "🔁 Merging $(CURRENT_BRANCH) → $(STAGING_BRANCH)..."; \
# 		git checkout $(STAGING_BRANCH); \
# 		git merge $(CURRENT_BRANCH); \
# 		git push origin $(STAGING_BRANCH); \
# 	fi
# 	@echo "🚀 Merging $(STAGING_BRANCH) → $(MAIN_BRANCH)..."
# 	@git checkout $(MAIN_BRANCH)
# 	@git merge $(STAGING_BRANCH)
# 	@git push origin $(MAIN_BRANCH)
# 	@git checkout $(CURRENT_BRANCH)
# 	@echo "🎉 Production deploy triggered via GitHub Actions."


# # 3. Uncommitted Changes & Safety Checks + Smart Auto-Stashing
# #----------------------------------------------------------------
# # Define your branches
# FEATURE_BRANCH = feature/ci-cd-enhancements
# STAGING_BRANCH ?= staging
# MAIN_BRANCH ?= main

# # Get current git branch dynamically
# CURRENT_BRANCH := $(shell git symbolic-ref --short HEAD 2>/dev/null)

# .PHONY: deploy-staging deploy-prod check-dirty

# check-dirty:
# 	@echo "🔍 Checking for uncommitted changes..."
# 	@if ! git diff --quiet || ! git diff --cached --quiet; then \
# 		echo "📦 Uncommitted changes found. Committing them..."; \
# 		git add .; \
# 		git commit -m "🔧 Auto-commit before deploy from $(CURRENT_BRANCH)"; \
# 	else \
# 		echo "✅ Working tree clean."; \
# 	fi

# deploy-staging:
# 	@$(MAKE) check-dirty
# 	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
# 	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
# 		echo "⚠️  Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
# 		git checkout $(STAGING_BRANCH); \
# 		git merge $(CURRENT_BRANCH); \
# 		git push origin $(STAGING_BRANCH); \
# 		git checkout $(CURRENT_BRANCH); \
# 	else \
# 		echo "✅ Already on $(STAGING_BRANCH). Just pushing changes..."; \
# 		git push origin $(STAGING_BRANCH); \
# 	fi
	
# 	@echo "✅ Staging deploy triggered via GitHub Actions."


# deploy-prod:
# 	@$(MAKE) check-dirty
# 	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
# 	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
# 		echo "🔁 Merging $(CURRENT_BRANCH) → $(STAGING_BRANCH)..."; \
# 		git checkout $(STAGING_BRANCH); \
# 		git merge $(CURRENT_BRANCH); \
# 	fi
# 	@echo "🚀 Merging $(STAGING_BRANCH) → $(MAIN_BRANCH)..."
# 	@git checkout $(MAIN_BRANCH)
# 	@git merge $(STAGING_BRANCH)
# 	@git push origin $(MAIN_BRANCH)
# 	@git checkout $(CURRENT_BRANCH)
	
# 	@echo "🎉 Production deploy triggered via GitHub Actions."



# 4. Auto Version Bump & Git Tagging for Production Deploys
#-------------------------------------------------------------------
# Define your branches
FEATURE_BRANCH = feature/ci-cd-enhancements
STAGING_BRANCH ?= staging
MAIN_BRANCH ?= main

# Get current git branch dynamically
CURRENT_BRANCH := $(shell git symbolic-ref --short HEAD 2>/dev/null)

VERSION_FILE := VERSION
INDEX_HTML := public/index.html  # Update this if index.html is in another directory

.PHONY: deploy-staging deploy-prod check-dirty bump-version

check-dirty:
	@echo "🔍 Checking for uncommitted changes..."
	@if ! git diff --quiet || ! git diff --cached --quiet; then \
		echo "📦 Uncommitted changes found. Committing them..."; \
		git add .; \
		git commit -m "🔧 Auto-commit before deploy from $(CURRENT_BRANCH)"; \
	else \
		echo "✅ Working tree clean."; \
	fi

bump-version:
	@echo "🔢 Current version: $$(cat $(VERSION_FILE))"
	@current_version=$$(cat $(VERSION_FILE)); \
	IFS='.' read -r major minor patch <<< $$current_version; \
	new_version="$$major.$$minor.$$((patch+1))"; \
	echo "⬆️  Bumping version to $$new_version"; \
	echo "$$new_version" > $(VERSION_FILE); \
	\
	# Inject new version into index.html \
	sed -i "s/app version [0-9]\+\.[0-9]\+\.[0-9]\+/app version $$new_version/" $(INDEX_HTML); \
	echo "📝 Updated version in $(INDEX_HTML)"

deploy-staging:
	@$(MAKE) check-dirty
	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
		echo "⚠️  Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
		git checkout $(STAGING_BRANCH); \
		git merge $(CURRENT_BRANCH); \
		git push origin $(STAGING_BRANCH); \
		git checkout $(CURRENT_BRANCH); \
	else \
		echo "✅ Already on $(STAGING_BRANCH). Just pushing changes..."; \
		git push origin $(STAGING_BRANCH); \
	fi
	
	@echo "✅ Staging deploy triggered via GitHub Actions."

deploy-prod:
	@$(MAKE) bump-version
	@$(MAKE) check-dirty
	@echo "🔍 Current branch: $(CURRENT_BRANCH)"
	@if [ "$(CURRENT_BRANCH)" != "$(STAGING_BRANCH)" ]; then \
		echo "🔁 Merging $(CURRENT_BRANCH) → $(STAGING_BRANCH)..."; \
		git checkout $(STAGING_BRANCH); \
		git merge $(CURRENT_BRANCH); \
	fi
	@echo "🚀 Merging $(STAGING_BRANCH) → $(MAIN_BRANCH)..."
	@git checkout $(MAIN_BRANCH)
	@git merge $(STAGING_BRANCH)
	@git push origin $(MAIN_BRANCH)
	@git checkout $(CURRENT_BRANCH)
	
	@echo "🎉 Production deploy triggered via GitHub Actions."







