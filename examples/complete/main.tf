// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "appconfig_kms" {
  statement {
    sid     = "EnableAccountAdministration"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }

  statement {
    sid    = "AllowAppConfigUse"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
    ]
    principals {
      type        = "Service"
      identifiers = ["appconfig.amazonaws.com"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "appconfig" {
  description         = "KMS key for AppConfig hosted configuration data"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.appconfig_kms.json
  tags                = merge(var.tags, { Name = module.resource_names["kms_key"].standard })
}



module "resource_names" {
  source  = "terraform.registry.launch.nttdata.com/module_library/resource_name/launch"
  version = "~> 2.0"

  for_each = var.resource_names_map

  logical_product_family  = var.logical_product_family
  logical_product_service = var.logical_product_service
  class_env               = var.class_env
  instance_env            = var.instance_env
  instance_resource       = var.instance_resource
  cloud_resource_type     = each.value.name
  maximum_length          = each.value.max_length

  region = join("", split("-", data.aws_region.current.region))
}

resource "aws_appconfig_application" "example" {
  name = module.resource_names["application"].standard
  tags = var.tags
}

resource "aws_appconfig_configuration_profile" "example" {
  application_id     = aws_appconfig_application.example.id
  name               = module.resource_names["configuration_profile"].standard
  location_uri       = "hosted"
  type               = "AWS.AppConfig.FeatureFlags"
  kms_key_identifier = aws_kms_key.appconfig.arn
  tags               = var.tags
}

module "hosted_configuration_version" {
  source = "../.."

  application_id           = aws_appconfig_application.example.id
  configuration_profile_id = aws_appconfig_configuration_profile.example.configuration_profile_id
  content                  = var.content
  content_type             = var.content_type
  description              = var.description
}
