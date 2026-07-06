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

output "id" {
  description = "The hosted configuration version ID."
  value       = module.hosted_configuration_version.id
}
output "arn" {
  description = "The ARN of the hosted configuration version."
  value       = module.hosted_configuration_version.arn
}
output "application_id" {
  description = "The application ID."
  value       = module.hosted_configuration_version.application_id
}
output "configuration_profile_id" {
  description = "The configuration profile ID."
  value       = module.hosted_configuration_version.configuration_profile_id
}
output "content_type" {
  description = "The content type."
  value       = module.hosted_configuration_version.content_type
}
output "version_number" {
  description = "The hosted configuration version number."
  value       = module.hosted_configuration_version.version_number
}
output "expected_content_type" {
  description = "Expected content type."
  value       = var.content_type
}

output "region" {
  description = "The AWS Region where the example resources are deployed."
  value       = data.aws_region.current.region
}

output "expected_kms_key_arn" {
  description = "Expected KMS key ARN."
  value       = aws_kms_key.appconfig.arn
}

output "expected_kms_key_identifier" {
  description = "Expected KMS key identifier."
  value       = aws_kms_key.appconfig.arn
}

output "expected_content" {
  description = "Expected hosted configuration content."
  value       = var.content
  sensitive   = true
}
