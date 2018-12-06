CloudFormation templates for setting up Amazon SageMaker notebook instances.

## Features

* CloudFormation templates for setting up infrastructure needed to use Amazon Sagemaker
  securely in a multi-tenant environment.
* CloudFormation templates that allow users to manage their own Amazon SageMaker
  resources in a secure fashion.

## Usage

### Simple Deployment

```bash
# Once as Admin
make create-sagemaker-iam

# Once as with the role created in the iam stack
make create-sagemaker-notebook-instance
```

This creates a default deployment of the setup.

### Multi-Tenant Deployment
More complex multi-tenant deployment can be done as follows:
```bash
make create-sagemaker-iam DEPLOYMENT=engineers
make create-sagemaker-iam DEPLOYMENT=scientists
```

Each deployment creates a separate user role which is only allowed to manage
SageMaker resources of the same deployment. You can spin up a SageMaker notebook
with the respective user role as follows:

```bash
# With the engineer-user-role
make create-sagemaker-notebook-instance DEPLOYMENT=engineers

# With the scientist-user-role
make create-sagemaker-notebook-instance DEPLOYMENT=scientists
```

In this kind of a setup engineers are not able to access the SageMaker
resource of the scientists and vice versa.

### Cleanup
To tear down the resources, run the following (set DEPLOYMENT variable as
in the earlier or omit it to clean the default deployment):

```bash
make delete-sagemaker-notebook-instance
make delete-sagemaker-iam
```

## Implementation

The templates in this repository can be divided into two categories:

* Admin templates - Templates that set up the infrastructure required to let users
  use Amazon SageMaker on an AWS account.
* User templates - Templates users can use to provision personal Amazon SageMaker
  environments that follow AWS security best practices.

At the moment this repository includes the following CloudFormation templates:

* IAM - Locked down IAM roles for multi-tenant deployment of Amazon SageMaker
  in a single AWS account.
* Notebook Instance - Basic template for setting up an Amazon SageMaker
  notebook instance.

### IAM

The IAM template defines two roles
* SageMaker User Role
* SageMaker Notebook Role

**The SageMaker User Role** grants users rights to provision their own SageMaker
notebook instances. The role has been stripped down to only grant the necessary
privileges required to manage SageMaker resources of a single deployment.

**The SageMaker Notebook Role** grants the notebook instances permission to access
other AWS resources. At the moment the access is extremely limited. This should be
modified to support your use cases.

## Issues

* It's not possible to limit which VPCs / Subnets the user attaches these
  notebook instances to as the `ec2:CreateNetworkInterface` action doesn't
  support resource-level permissions or condition keys. Hence, the user
  can launch the notebook to any VPC / subnet, and associate any existing
  security group with the notebook instance. This could allow users to
  access services that authorize access from the user-chosen subnet or
  security group.

## Ideas / TODO

* Setup CodeCommit for sharing notebooks across all notebook instances of a
  deployment.
* Provide easy-to-use command for connecting the notebook instance to an EMR
  cluster.
* Templates & access for other SageMaker resources (training jobs, models, tuning
  and endpoints).
