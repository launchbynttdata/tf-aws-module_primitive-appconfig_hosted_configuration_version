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

# AppConfig injects _createdAt and _updatedAt into FeatureFlags JSON on create/read.
# Terraform then sees byte-for-byte drift against var.content on every refresh; because
# content is ForceNew, plans repeatedly replace this resource and cascade into dependents
# (for example aws_appconfig_deployment). See hashicorp/terraform-provider-aws#20273.
#
# ignore_changes suppresses false-positive metadata drift. replace_triggered_by ties
# replacement to var.content via terraform_data so intentional updates still create a
# new version. Out-of-band content changes (console, CLI) are not reconciled.
resource "terraform_data" "content" {
  input = var.content
}

resource "aws_appconfig_hosted_configuration_version" "hosted_configuration_version" {
  application_id           = var.application_id
  configuration_profile_id = var.configuration_profile_id
  content                  = var.content
  content_type             = var.content_type
  description              = var.description
  region                   = var.region

  lifecycle {
    ignore_changes = [content]

    replace_triggered_by = [
      terraform_data.content,
    ]
  }
}
