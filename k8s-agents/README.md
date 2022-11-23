# tf-aws-activeactive-agents k8s-agents

This manual is dedicated to create AWS EKS kubernetes cluster with tfc-agents

## Requirements

- Hashicorp terraform recent version installed
[Terraform installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- git installed
[Git installation manual](https://git-scm.com/download/mac)

- Amazon AWS account credentials saved in .aws/credentials file
[Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- Provisioned with github.com/antonakv/tf-aws-activeactive-agents Terraform Enterprise active-active
[https://github.com/antonakv/tf-aws-activeactive-agents](https://github.com/antonakv/tf-aws-activeactive-agents.git)

- Manually created agent token set as agent_token variable in the tf-aws-activeactive-agents state
Proceed to the https://YOUR_TFE_INSTANCE/app/ORGANISATION_NAME/settings/agents/new for new token creation

## Preparation 

- Change folder to k8s-agents

```bash
cd k8s-agents
```

- Create file terraform.tfvars with following contents

```
k8s_desired_agents = 3
tfc_agent_image    = "aakulov2/tfc-agent:2211221521"
agent_token        = "terraform_agent_token_created_manually"
```

## Run terraform code

- In the same folder you were before, run 

```bash
terraform init
```

Sample result

```
% terraform init                
Initializing modules...
Downloading registry.terraform.io/terraform-aws-modules/eks/aws 18.30.2 for eks...
- eks in .terraform/modules/eks
- eks.eks_managed_node_group in .terraform/modules/eks/modules/eks-managed-node-group
- eks.eks_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data
- eks.fargate_profile in .terraform/modules/eks/modules/fargate-profile
Downloading registry.terraform.io/terraform-aws-modules/kms/aws 1.0.2 for eks.kms...
- eks.kms in .terraform/modules/eks.kms
- eks.self_managed_node_group in .terraform/modules/eks/modules/self-managed-node-group
- eks.self_managed_node_group.user_data in .terraform/modules/eks/modules/_user_data

Initializing the backend...

Initializing provider plugins...
- terraform.io/builtin/terraform is built in to Terraform
- Finding hashicorp/tls versions matching ">= 3.0.0"...
- Finding hashicorp/cloudinit versions matching ">= 2.0.0"...
- Finding hashicorp/kubernetes versions matching ">= 2.10.0, ~> 2.14.0"...
- Finding hashicorp/aws versions matching ">= 3.72.0, ~> 4.39.0"...
- Finding hashicorp/local versions matching "~> 2.2.3"...
- Installing hashicorp/kubernetes v2.14.0...
- Installed hashicorp/kubernetes v2.14.0 (signed by HashiCorp)
- Installing hashicorp/aws v4.39.0...
- Installed hashicorp/aws v4.39.0 (signed by HashiCorp)
- Installing hashicorp/local v2.2.3...
- Installed hashicorp/local v2.2.3 (signed by HashiCorp)
- Installing hashicorp/tls v4.0.4...
- Installed hashicorp/tls v4.0.4 (signed by HashiCorp)
- Installing hashicorp/cloudinit v2.2.0...
- Installed hashicorp/cloudinit v2.2.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

- Run the `terraform apply`

Expected result:

```

```
