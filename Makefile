# Some defaults
AWS ?= aws
AWS_REGION ?= eu-west-1
AWS_PROFILE ?= default

AWS_CMD := $(AWS) --profile $(AWS_PROFILE) --region $(AWS_REGION)

DEPLOYMENT_NAME ?= default
TAGS ?= Key=DeploymentName,Value=$(DEPLOYMENT_NAME)
PARAMETERS ?= \
	ParameterKey=DeploymentName,ParameterValue=$(DEPLOYMENT_NAME)

define stack_template =

validate-$(basename $(notdir $(1))): $(1)
	 $(AWS_CMD) cloudformation validate-template\
		--template-body file://$(1)

create-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation create-stack \
		--stack-name $(basename $(notdir $(1)))-$(DEPLOYMENT_NAME) \
		--tags $(TAGS) \
		--parameters $(PARAMETERS) \
		--template-body file://$(1) \
		--capabilities CAPABILITY_NAMED_IAM

update-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation update-stack \
		--stack-name $(basename $(notdir $(1)))-$(DEPLOYMENT_NAME) \
		--tags $(TAGS) \
		--parameters $(PARAMETERS) \
		--template-body file://$(1) \
		--capabilities CAPABILITY_NAMED_IAM

delete-$(basename $(notdir $(1))): $(1)
	$(AWS_CMD) cloudformation delete-stack \
		--stack-name $(basename $(notdir $(1)))-$(DEPLOYMENT_NAME)

endef

$(foreach template, $(wildcard templates/*.yaml), $(eval $(call stack_template,$(template))))
