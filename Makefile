# Some defaults
AWS ?= aws
AWS_REGION ?= eu-west-1
AWS_PROFILE ?= default

AWS_CMD := $(AWS) --profile $(AWS_PROFILE) --region $(AWS_REGION)

DEPLOYMENT_NAME ?= default
TAGS ?= Key=DeploymentName,Value=$(DEPLOYMENT_NAME)
PARAMETERS ?= \
	ParameterKey=DeploymentName,ParameterValue=$(DEPLOYMENT_NAME)

# A helper to turn template file name to stack name. It does the following:
# - Strip white spaces introduced in function call
# - Strip sagemaker- prefix from the name
# - Append user name to the notebook-instance stack name
# - Prefix result with sagemaker-$(DEPLOYMENT_NAME)
# Results:
# - sagemaker-$(DEPLOYMENT_NAME)-iam
# - sagemaker-$(DEPLOYMENT_NAME)-infra
# - sagemaker-$(DEPLOYMENT_NAME)-notebook-instance-$(USER)
define tmpl2name
	sagemaker-$(DEPLOYMENT_NAME)-$(subst notebook-instance,notebook-instance-$(USER),$(subst sagemaker-,,$(strip $(1))))
endef

define stack_template =

debug-$(basename $(notdir $(1))): $(1)

validate-$(basename $(notdir $(1))): $(1)
	 $(AWS_CMD) cloudformation validate-template\
		--template-body file://$(1)

create-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation create-stack \
		--stack-name $(call tmpl2name, $(basename $(notdir $(1)))) \
		--tags $(TAGS) \
		--parameters $(PARAMETERS) \
		--template-body file://$(1) \
		--capabilities CAPABILITY_NAMED_IAM

update-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation update-stack \
		--stack-name $(call tmpl2name, $(basename $(notdir $(1)))) \
		--tags $(TAGS) \
		--parameters $(PARAMETERS) \
		--template-body file://$(1) \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(call tmpl2name, $(basename $(notdir $(1)))) \

endef

$(foreach template, $(wildcard templates/*.yaml), $(eval $(call stack_template,$(template))))
