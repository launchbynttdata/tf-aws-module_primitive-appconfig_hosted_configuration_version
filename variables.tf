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

# -----------------------------------------------------------------------------
# Required
# -----------------------------------------------------------------------------

variable "application_id" {
  description = "AppConfig application ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,7}$", var.application_id))
    error_message = "application_id must match ^[a-z0-9]{4,7}$."
  }
}

variable "configuration_profile_id" {
  description = "AppConfig configuration profile ID."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{4,7}$", var.configuration_profile_id))
    error_message = "configuration_profile_id must match ^[a-z0-9]{4,7}$."
  }
}

variable "content" {
  description = "Hosted configuration content. For feature flags this should be a valid AWS.AppConfig.FeatureFlags JSON document."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.content) >= 1
    error_message = "content must not be empty."
  }
}
variable "content_type" {
  description = "Content type of the hosted configuration version, such as application/json."
  type        = string

  validation {
    condition     = length(var.content_type) >= 1 && length(var.content_type) <= 255
    error_message = "content_type must be between 1 and 255 characters."
  }
}

# -----------------------------------------------------------------------------
# Optional
# -----------------------------------------------------------------------------

variable "description" {
  description = "Description of the AppConfig hosted configuration version. Must be at most 1024 characters."
  type        = string
  default     = null

  validation {
    condition     = var.description == null ? true : length(var.description) <= 1024
    error_message = "Description must be at most 1024 characters."
  }
}

variable "region" {
  description = "AWS Region where this resource is managed. Defaults to the provider-configured Region."
  type        = string
  default     = null
}
