logical_product_family  = "launch"
logical_product_service = "appcfg"
class_env               = "dev"
instance_env            = 1
instance_resource       = 1
resource_names_map      = { application = { name = "appcfgapp", max_length = 64 }, configuration_profile = { name = "appcfgprofile", max_length = 64 } }
tags                    = { environment = "test", module = "appconfig_hosted_configuration_version" }
