# Change this to your feature branch name
FEATURE_BRANCH=feature/ci-cd-enhancements
STAGING_BRANCH=staging
MAIN_BRANCH=main

.PHONY: deploy-staging deploy-prod

deploy-staging:
	@echo "Merging $(FEATURE_BRANCH) into $(STAGING_BRANCH)..."
	git checkout $(STAGING_BRANCH)
	git pull origin $(STAGING_BRANCH)
	git merge $(FEATURE_BRANCH)
	git push origin $(STAGING_BRANCH)
	@echo "✅ Staging deploy triggered via GitHub Actions."

deploy-prod:
	@echo "Merging $(STAGING_BRANCH) into $(MAIN_BRANCH)..."
	git checkout $(MAIN_BRANCH)
	git pull origin $(MAIN_BRANCH)
	git merge $(STAGING_BRANCH)
	git push origin $(MAIN_BRANCH)
	@echo "🚀 Production deploy triggered via GitHub Actions."
