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


# Makefile with Auto-Switch Back
#------------------------------------------------------------
# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# # Auto-detect the current branch before switching
# CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: You must run this from a feature branch, not $(CURRENT_BRANCH)."; \
# 		exit 1; \
# 	fi
# 	@echo "✅ Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."
# 	git checkout $(STAGING_BRANCH)
# 	git pull origin $(STAGING_BRANCH)
# 	git merge $(CURRENT_BRANCH)
# 	git push origin $(STAGING_BRANCH)
# 	git checkout $(CURRENT_BRANCH)
# 	@echo "🚀 Staging deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."

# deploy-prod:
# 	@echo "✅ Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
# 	git checkout $(MAIN_BRANCH)
# 	git pull origin $(MAIN_BRANCH)
# 	git merge $(STAGING_BRANCH)
# 	git push origin $(MAIN_BRANCH)
# 	git checkout $(CURRENT_BRANCH)
# 	@echo "🚀 Production deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."



# # # Makefile with uncommitted check logic
# # #----------------------------------------------------
# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# # Auto-detect the current branch before switching
# CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: You must run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
# 		exit 1; \
# 	fi
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "❌ ERROR: You have uncommitted changes. Please commit or stash them before deploying."; \
# 		exit 1; \
# 	fi
# 	@echo "✅ Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."
# 	git checkout $(STAGING_BRANCH)
# 	git pull origin $(STAGING_BRANCH)
# 	git merge $(CURRENT_BRANCH)
# 	git push origin $(STAGING_BRANCH)
# 	git checkout $(CURRENT_BRANCH)
# 	@echo "🚀 Staging deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."

# deploy-prod:
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "❌ ERROR: You have uncommitted changes. Please commit or stash them before deploying."; \
# 		exit 1; \
# 	fi
# 	@echo "✅ Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
# 	git checkout $(MAIN_BRANCH)
# 	git pull origin $(MAIN_BRANCH)
# 	git merge $(STAGING_BRANCH)
# 	git push origin $(MAIN_BRANCH)
# 	git checkout $(CURRENT_BRANCH)
# 	@echo "🚀 Production deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."



# # # Makefile with uncommitted check logic and Autostash
# # #----------------------------------------------------

# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# # Auto-detect the current branch before switching
# CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: You must run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
# 		exit 1; \
# 	fi
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "💾 Detected uncommitted changes. Stashing..."; \
# 		git stash push -m "Auto-stash before staging deploy"; \
# 		TO_RESTORE_STASH=true; \
# 	else \
# 		TO_RESTORE_STASH=false; \
# 	fi; \
# 	echo "✅ Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
# 	git checkout $(STAGING_BRANCH); \
# 	git pull origin $(STAGING_BRANCH); \
# 	git merge $(CURRENT_BRANCH); \
# 	git push origin $(STAGING_BRANCH); \
# 	git checkout $(CURRENT_BRANCH); \
# 	if $$TO_RESTORE_STASH; then \
# 		echo "♻️ Restoring stashed changes..."; \
# 		git stash pop; \
# 	fi; \
# 	echo "🚀 Staging deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."

# deploy-prod:
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "💾 Detected uncommitted changes. Stashing..."; \
# 		git stash push -m "Auto-stash before production deploy"; \
# 		TO_RESTORE_STASH=true; \
# 	else \
# 		TO_RESTORE_STASH=false; \
# 	fi; \
# 	echo "✅ Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."; \
# 	git checkout $(MAIN_BRANCH); \
# 	git pull origin $(MAIN_BRANCH); \
# 	git merge $(STAGING_BRANCH); \
# 	git push origin $(MAIN_BRANCH); \
# 	git checkout $(CURRENT_BRANCH); \
# 	if $$TO_RESTORE_STASH; then \
# 		echo "♻️ Restoring stashed changes..."; \
# 		git stash pop; \
# 	fi; \
# 	echo "🚀 Production deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."



# # Local deploys
# #-----------------------------------------------------------------
# STAGING_BRANCH=staging
# MAIN_BRANCH=main

# # Auto-detect the current branch before switching
# CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

# .PHONY: deploy-staging deploy-prod

# deploy-staging:
# 	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: You must run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
# 		exit 1; \
# 	fi
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "💡 Uncommitted changes detected:"; \
# 		git status --short; \
# 		echo "💾 Stashing changes..."; \
# 		git stash push -m "Auto-stash before staging deploy"; \
# 		TO_RESTORE_STASH=true; \
# 	else \
# 		TO_RESTORE_STASH=false; \
# 	fi; \
# 	echo "✅ Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
# 	git checkout $(STAGING_BRANCH); \
# 	git pull origin $(STAGING_BRANCH); \
# 	git merge $(CURRENT_BRANCH); \
# 	git push origin $(STAGING_BRANCH); \
# 	git checkout $(CURRENT_BRANCH); \
# 	if $$TO_RESTORE_STASH; then \
# 		echo "♻️ Restoring stashed changes..."; \
# 		git stash pop; \
# 	fi; \
# 	echo "🚀 Staging deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."

# deploy-prod:
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "💡 Uncommitted changes detected:"; \
# 		git status --short; \
# 		echo "💾 Stashing changes..."; \
# 		git stash push -m "Auto-stash before production deploy"; \
# 		TO_RESTORE_STASH=true; \
# 	else \
# 		TO_RESTORE_STASH=false; \
# 	fi; \
# 	echo "✅ Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."; \
# 	git checkout $(MAIN_BRANCH); \
# 	git pull origin $(MAIN_BRANCH); \
# 	git merge $(STAGING_BRANCH); \
# 	git push origin $(MAIN_BRANCH); \
# 	git checkout $(CURRENT_BRANCH); \
# 	if $$TO_RESTORE_STASH; then \
# 		echo "♻️ Restoring stashed changes..."; \
# 		git stash pop; \
# 	fi; \
# 	echo "🚀 Production deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."


# .PHONY: deploy-local

# deploy-local:
# 	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
# 		echo "❌ ERROR: Run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
# 		exit 1; \
# 	fi
# 	@if ! git diff-index --quiet HEAD --; then \
# 		echo "💾 Detected uncommitted changes. Stashing..."; \
# 		git stash push -m "Auto-stash before local deploy"; \
# 		TO_RESTORE_STASH=true; \
# 	else \
# 		TO_RESTORE_STASH=false; \
# 	fi; \
# 	echo "🔄 Merging $(CURRENT_BRANCH) into a temporary local '$(STAGING_BRANCH)'..."; \
# 	git fetch origin $(STAGING_BRANCH); \
# 	git checkout -b temp-merge-test origin/$(STAGING_BRANCH); \
# 	git merge $(CURRENT_BRANCH); \
# 	echo "✅ Local merge successful."; \
# 	git checkout $(CURRENT_BRANCH); \
# 	git branch -D temp-merge-test; \
# 	if $$TO_RESTORE_STASH; then \
# 		echo "♻️ Restoring stashed changes..."; \
# 		git stash pop; \
# 	fi; \
# 	echo "🧪 Local deploy test complete. No remote changes made."





#  Semantic patch for version bump + tagging
#-----------------------------------------------------------------
STAGING_BRANCH=staging
MAIN_BRANCH=main

# Auto-detect the current branch before switching
CURRENT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

.PHONY: deploy-staging deploy-prod

deploy-staging:
	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
		echo "❌ ERROR: You must run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
		exit 1; \
	fi
	@if ! git diff-index --quiet HEAD --; then \
		echo "💡 Uncommitted changes detected:"; \
		git status --short; \
		echo "💾 Stashing changes..."; \
		git stash push -m "Auto-stash before staging deploy"; \
		TO_RESTORE_STASH=true; \
	else \
		TO_RESTORE_STASH=false; \
	fi; \
	echo "✅ Merging $(CURRENT_BRANCH) into $(STAGING_BRANCH)..."; \
	git checkout $(STAGING_BRANCH); \
	git pull origin $(STAGING_BRANCH); \
	git merge $(CURRENT_BRANCH); \
	git push origin $(STAGING_BRANCH); \
	git checkout $(CURRENT_BRANCH); \
	if $$TO_RESTORE_STASH; then \
		echo "♻️ Restoring stashed changes..."; \
		git stash pop; \
	fi; \
	echo "🚀 Staging deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."

deploy-prod:
	@if ! git diff-index --quiet HEAD --; then \
		echo "💡 Uncommitted changes detected:"; \
		git status --short; \
		echo "💾 Stashing changes..."; \
		git stash push -m "Auto-stash before production deploy"; \
		TO_RESTORE_STASH=true; \
	else \
		TO_RESTORE_STASH=false; \
	fi; \
	echo "✅ Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."; \
	git checkout $(MAIN_BRANCH); \
	git pull origin $(MAIN_BRANCH); \
	git merge $(STAGING_BRANCH); \
	git push origin $(MAIN_BRANCH); \
	git checkout $(CURRENT_BRANCH); \
	if $$TO_RESTORE_STASH; then \
		echo "♻️ Restoring stashed changes..."; \
		git stash pop; \
	fi; \
	echo "🚀 Production deploy triggered via GitHub Actions. Switched back to $(CURRENT_BRANCH)."


.PHONY: deploy-local

deploy-local:
	@if [ "$(CURRENT_BRANCH)" = "$(STAGING_BRANCH)" ] || [ "$(CURRENT_BRANCH)" = "$(MAIN_BRANCH)" ]; then \
		echo "❌ ERROR: Run this from a feature branch, not '$(CURRENT_BRANCH)'."; \
		exit 1; \
	fi
	@if ! git diff-index --quiet HEAD --; then \
		echo "💾 Detected uncommitted changes. Stashing..."; \
		git stash push -m "Auto-stash before local deploy"; \
		TO_RESTORE_STASH=true; \
	else \
		TO_RESTORE_STASH=false; \
	fi; \
	echo "🔄 Merging $(CURRENT_BRANCH) into a temporary local '$(STAGING_BRANCH)'..."; \
	git fetch origin $(STAGING_BRANCH); \
	git checkout -b temp-merge-test origin/$(STAGING_BRANCH); \
	git merge $(CURRENT_BRANCH); \
	echo "✅ Local merge successful."; \
	git checkout $(CURRENT_BRANCH); \
	git branch -D temp-merge-test; \
	if $$TO_RESTORE_STASH; then \
		echo "♻️ Restoring stashed changes..."; \
		git stash pop; \
	fi; \
	echo "🧪 Local deploy test complete. No remote changes made."


#Semantic versioning starts here
#-------------------------------------
# VERSION_FILE=VERSION
# INDEX_HTML=public/index.html

# release:
# 	@echo "🔖 Current version: $$(cat $(VERSION_FILE))"
# 	@ver=$$(cat $(VERSION_FILE)); \
# 	major=$$(echo $$ver | cut -d. -f1); \
# 	minor=$$(echo $$ver | cut -d. -f2); \
# 	patch=$$(echo $$ver | cut -d. -f3); \
# 	\
# 	new_patch=$$(($$patch + 1)); \
# 	new_version="$$major.$$minor.$$new_patch"; \
# 	\
# 	echo "⬆️ Bumping version to $$new_version"; \
# 	echo $$new_version > $(VERSION_FILE); \
# 	\
# 	# Replace version in index.html \
# 	sed -i.bak -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML); \
# 	rm -f $(INDEX_HTML).bak; \
# 	\
# 	# Commit and tag \
# 	git add $(VERSION_FILE) $(INDEX_HTML); \
# 	git commit -m "chore: bump version to $$new_version"; \
# 	git tag -a "v$$new_version" -m "Release version $$new_version"; \
# 	git push origin $(CURRENT_BRANCH); \
# 	git push origin "v$$new_version"; \
# 	echo "✅ Released version $$new_version"



# release Rule with Branch Protection
#---------------------------------
# .PHONY: release

# VERSION_FILE=VERSION
# INDEX_HTML=public/index.html

# release:
# 	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
# 	if echo "$$CURRENT_BRANCH" | grep -Eq '^(main|dev|feature/.+)' ; then \
# 		echo "❌ ERROR: 'make release' must only be run from the 'staging' branch."; \
# 		exit 1; \
# 	fi; \
# 	\
# 	echo "🔖 Current version: $$(cat $(VERSION_FILE))"; \
# 	ver=$$(cat $(VERSION_FILE)); \
# 	major=$$(echo $$ver | cut -d. -f1); \
# 	minor=$$(echo $$ver | cut -d. -f2); \
# 	patch=$$(echo $$ver | cut -d. -f3); \
# 	new_patch=$$(($$patch + 1)); \
# 	new_version="$$major.$$minor.$$new_patch"; \
# 	\
# 	echo "⬆️  Bumping version to $$new_version"; \
# 	echo "$$new_version" > $(VERSION_FILE); \
# 	\
# 	# Update version in index.html \
# 	sed -i '' -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML) || \
# 	sed -i -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML); \
# 	\
# 	git add $(VERSION_FILE) $(INDEX_HTML); \
# 	git commit -m "chore: bump version to $$new_version"; \
# 	git tag -a "v$$new_version" -m "Release version $$new_version"; \
# 	git push origin $$CURRENT_BRANCH; \
# 	git push origin "v$$new_version"; \
# 	echo "✅ Released version $$new_version from branch '$$CURRENT_BRANCH'"



# Enhanced Makefile with VERSION_TYPE support
#-------------------------
# .PHONY: release

# VERSION_FILE=VERSION
# INDEX_HTML=public/index.html
# VERSION_TYPE?=patch  # Default to patch

# release:
# 	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
# 	if echo "$$CURRENT_BRANCH" | grep -Eq '^(main|dev|feature/.+)' ; then \
# 		echo "❌ ERROR: 'make release' must only be run from the 'staging' branch."; \
# 		exit 1; \
# 	fi; \
# 	\
# 	echo "🔖 Current version: $$(cat $(VERSION_FILE))"; \
# 	ver=$$(cat $(VERSION_FILE)); \
# 	major=$$(echo $$ver | cut -d. -f1); \
# 	minor=$$(echo $$ver | cut -d. -f2); \
# 	patch=$$(echo $$ver | cut -d. -f3); \
# 	\
# 	case "$(VERSION_TYPE)" in \
# 		patch) \
# 			new_patch=$$(($$patch + 1)); \
# 			new_version="$$major.$$minor.$$new_patch"; \
# 			;; \
# 		minor) \
# 			new_minor=$$(($$minor + 1)); \
# 			new_version="$$major.$$new_minor.0"; \
# 			;; \
# 		major) \
# 			new_major=$$(($$major + 1)); \
# 			new_version="$$new_major.0.0"; \
# 			;; \
# 		*) \
# 			echo "❌ ERROR: Invalid VERSION_TYPE='$(VERSION_TYPE)'. Use 'patch', 'minor', or 'major'."; \
# 			exit 1; \
# 			;; \
# 	esac; \
# 	\
# 	echo "⬆️  Bumping version to $$new_version"; \
# 	echo "$$new_version" > $(VERSION_FILE); \
# 	\
# 	# Update version in index.html \
# 	sed -i '' -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML) || \
# 	sed -i -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML); \
# 	\
# 	git add $(VERSION_FILE) $(INDEX_HTML); \
# 	git commit -m "chore: bump version to $$new_version"; \
# 	git tag -a "v$$new_version" -m "Release version $$new_version"; \
# 	git push origin $$CURRENT_BRANCH; \
# 	git push origin "v$$new_version"; \
# 	echo "✅ Released version $$new_version from branch '$$CURRENT_BRANCH'"



#Updated Makefile with Branch-Version Type Constraints [Similar to UPPER Version]
#-----------------------------------------------
.PHONY: release

VERSION_FILE=VERSION
INDEX_HTML=public/index.html

release:
	@CURRENT_BRANCH=$$(git rev-parse --abbrev-ref HEAD); \
	\
	# Enforce release constraints per branch \
	if [ "$$CURRENT_BRANCH" = "staging" ] && [ "$(VERSION_TYPE)" != "patch" ]; then \
		echo "❌ ERROR: Only patch releases are allowed from 'staging'. Use VERSION_TYPE=patch."; \
		exit 1; \
	fi; \
	if [ "$$CURRENT_BRANCH" = "main" ] && [ "$(VERSION_TYPE)" = "patch" ]; then \
		echo "❌ ERROR: Patch releases must go through 'staging'. Use VERSION_TYPE=minor or major."; \
		exit 1; \
	fi; \
	if echo "$$CURRENT_BRANCH" | grep -Eq '^(dev|feature/.+)' ; then \
		echo "❌ ERROR: No releases allowed from '$$CURRENT_BRANCH'."; \
		exit 1; \
	fi; \
	\
	echo "🔖 Current version: $$(cat $(VERSION_FILE))"; \
	ver=$$(cat $(VERSION_FILE)); \
	major=$$(echo $$ver | cut -d. -f1); \
	minor=$$(echo $$ver | cut -d. -f2); \
	patch=$$(echo $$ver | cut -d. -f3); \
	new_patch=$$(($$patch + 1)); \
	new_version="$$major.$$minor.$$new_patch"; \
	\
	echo "⬆️  Bumping version to $$new_version"; \
	echo "$$new_version" > $(VERSION_FILE); \
	\
	# Update version in index.html \
	sed -i '' -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML) || \
	sed -i -E "s/app version [0-9]+\.[0-9]+\.[0-9]+/app version $$new_version/" $(INDEX_HTML); \
	\
	git add $(VERSION_FILE) $(INDEX_HTML); \
	git commit -m "chore: bump version to $$new_version"; \
	git tag -a "v$$new_version" -m "Release version $$new_version"; \
	git push origin $$CURRENT_BRANCH; \
	git push origin "v$$new_version"; \
	echo "✅ Released version $$new_version from branch '$$CURRENT_BRANCH'"


#production deploy and version bump with a single command
.PHONY: deploy-and-release

deploy-and-release:
	@echo "🚀 Deploying to production..."
	make deploy-prod

	@echo "🏷️  Bumping and tagging release version ($(VERSION_TYPE))..."
	make release VERSION_TYPE=$(VERSION_TYPE)

	@echo "🔁 Redeploying to ensure version is live..."
	make deploy-prod

