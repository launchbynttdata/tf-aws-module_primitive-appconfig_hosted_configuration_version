# Terraform AWS Module: AppConfig Hosted Configuration Version (Primitive)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/License-CC_BY--NC--ND_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)

## Overview

This primitive module manages one AWS AppConfig hosted configuration version resource and exposes the commonly used Terraform provider arguments for composition by collection and reference architecture modules.

For `AWS.AppConfig.FeatureFlags` configuration profiles, AppConfig injects `_createdAt` and `_updatedAt` metadata into the stored JSON. The AWS provider compares that API response with `var.content` on refresh, which produces perpetual replace plans even when flag definitions are unchanged ([terraform-provider-aws#20273](https://github.com/hashicorp/terraform-provider-aws/issues/20273)). This module uses `terraform_data` and lifecycle rules so no-op plans stay empty while changes to `var.content` still create a new hosted configuration version. Content modified outside Terraform is not reconciled on apply.

## Usage

```hcl
module "example" {
  source = "terraform.registry.launch.nttdata.com/module_primitive/appconfig_hosted_configuration_version/aws"

  # See examples/complete for a deployable configuration.
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.10 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appconfig_hosted_configuration_version.hosted_configuration_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appconfig_hosted_configuration_version) | resource |
| [terraform_data.content](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | AppConfig application ID. | `string` | n/a | yes |
| <a name="input_configuration_profile_id"></a> [configuration\_profile\_id](#input\_configuration\_profile\_id) | AppConfig configuration profile ID. | `string` | n/a | yes |
| <a name="input_content"></a> [content](#input\_content) | Hosted configuration content. For feature flags this should be a valid AWS.AppConfig.FeatureFlags JSON document. | `string` | n/a | yes |
| <a name="input_content_type"></a> [content\_type](#input\_content\_type) | Content type of the hosted configuration version, such as application/json. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Description of the AppConfig hosted configuration version. Must be at most 1024 characters. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where this resource is managed. Defaults to the provider-configured Region. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_id"></a> [application\_id](#output\_application\_id) | The AppConfig application ID. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the hosted configuration version. |
| <a name="output_configuration_profile_id"></a> [configuration\_profile\_id](#output\_configuration\_profile\_id) | The AppConfig configuration profile ID. |
| <a name="output_content_type"></a> [content\_type](#output\_content\_type) | The content type. |
| <a name="output_description"></a> [description](#output\_description) | The hosted configuration version description. |
| <a name="output_id"></a> [id](#output\_id) | The hosted configuration version ID. |
| <a name="output_version_number"></a> [version\_number](#output\_version\_number) | The hosted configuration version number. |
<!-- END_TF_DOCS -->

## Module Development

### Pre-Requisites

The following commands should be available on your system:

- `asdf` or `mise`
- `make`
- `python3` (for pre-commit)

Additionally, your `git` user and email must be configured. Run the `make configure` command from the root of the repository to ensure that you meet these requirements.

### Pre-Commit hooks

The [.pre-commit-config.yaml](.pre-commit-config.yaml) file defines certain `pre-commit` hooks that are relevant to Terraform and Golang, as well as some common linting tasks. These will be configured for you when you run `make configure`.

### Local Validation

You should validate the changes you make to any module locally, prior to pushing your changes in a branch to GitHub.

1. Ensure that you have run `make configure` successfully.

2. Ensure you are signed into the appropriate cloud provider for the module under test in your current console session.

3. Run the Terraform and Golang linters with the following command:

```
make lint
```

4. Once you have satisfied the linters, the following command will build example infrastructure in your configured cloud, run the tests, and then tear down the infrastructure it created:

```
make test
```

The pre-commit validations, as well as the `make lint` and `make test` targets, will all be performed in CI. Running these validations locally prior to opening a PR helps ensure a smooth review and merge process.

### Review & Merge Process

Once your change has been tested locally and your branch pushed up, open a new Pull Request for your branch to the default branch of this repository.

The title of your Pull Request will determine the version bump for this change, and the title must be in [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification) format in order to merge.

Ensure your CI workflows are passing; seek approval from teammates and address any feedback; seek any explicit approvals required by the CODEOWNERS file. You may merge the PR as soon as all requirements are met, and a new release and tag will be automatically created for you.

### Automatic Updates

The shared configuration and workflow files in this repository are largely managed through the [launch-terraform-skeleton](https://github.com/launchbynttdata/launch-terraform-skeleton) repository. Outside of perhaps the `.gitignore` to account for specific files being generated by certain Terraform modules, there should not be much cause to update these files on a per-repo basis, and making changes to them individually is discouraged.

If desired, you can check for and run these updates locally in a branch if you have the `copier` tool installed. Some example commands are included below:

```
# Check for updates, optionally checking prerelease versions
copier check-update [--prereleases]

# Run an update, using default answers if there are any. We use tasks, which requires --trust to be set.
copier update --defaults --trust [--prereleases]

# Recopy from the source, and --overwrite all templated files in the process
copier recopy --defaults --trust --overwrite [--prereleases]
```

Automatic updates will run through a scheduled workflow, and if the post-update tests are successful, the Pull Request created will automatically merge. Conflicts in the update or failures to test may leave a Pull Request outstanding, which needs to be addressed by a Launch Engineer.
