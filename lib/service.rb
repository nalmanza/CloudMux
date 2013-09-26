__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__)))

$LOAD_PATH.unshift __LIB_DIR__ unless
  $LOAD_PATH.include?(__LIB_DIR__) ||
  $LOAD_PATH.include?(File.expand_path(__LIB_DIR__))

module Service
  unless const_defined?(:VERSION)
    VERSION = '1.0'
  end
end

# external gem dependencies
require 'base64'
require 'json'
require 'uri'
require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'
require 'mongo'
require 'mongoid'
require 'bcrypt'

# internal libraries
require_relative 'cfdoc'
require_relative 'core'
require_relative 'service/service_config'

require_relative 'service/model/link'
require_relative 'service/representer/link_representer'
require_relative 'service/representer/query_representer'
require_relative 'service/model/query'
require_relative 'service/model/error'
require_relative 'service/model/import_results'
require_relative 'service/representer/import_results_representer'
require_relative 'service/representer/report_representer'

require_relative 'service/model/audit_log'
require_relative 'service/model/cloud_resource'
require_relative 'service/model/permission'
require_relative 'service/model/cloud_credential'
require_relative 'service/model/cloud_account'
require_relative 'service/model/cloud_account_query'
require_relative 'service/model/cloud_mapping'
require_relative 'service/model/cloud_service'
require_relative 'service/model/price'
require_relative 'service/model/cloud'
require_relative 'service/model/cloud_query'
require_relative 'service/model/config_manager'
require_relative 'service/representer/audit_log_representer'
require_relative 'service/representer/cloud_resource_representer'
require_relative 'service/representer/permission_representer'
require_relative 'service/representer/update_permission_representer'
require_relative 'service/representer/permissions_representer'
require_relative 'service/representer/cloud_credential_representer'
require_relative 'service/representer/update_cloud_credential_representer'
require_relative 'service/representer/cloud_mapping_representer'
require_relative 'service/representer/update_cloud_mapping_representer'
require_relative 'service/representer/cloud_service_representer'
require_relative 'service/representer/update_cloud_service_representer'
require_relative 'service/representer/price_representer'
require_relative 'service/representer/update_price_representer'
require_relative 'service/representer/cloud_account_representer'
require_relative 'service/representer/cloud_account_query_representer'
require_relative 'service/representer/update_cloud_account_representer'
require_relative 'service/representer/cloud_representer'
require_relative 'service/representer/update_cloud_representer'
require_relative 'service/representer/cloud_query_representer'
require_relative 'service/representer/update_config_manager_representer'
require_relative 'service/model/policy_rule'
require_relative 'service/model/group_policy'
require_relative 'service/representer/group_policy_representer'

require_relative 'service/model/account'
require_relative 'service/representer/account_subscription_representer'
require_relative 'service/representer/project_membership_representer'
require_relative 'service/representer/account_representer'
require_relative 'service/representer/account_summary_representer'
require_relative 'service/representer/update_account_representer'
require_relative 'service/model/country'
require_relative 'service/model/subscription'

require_relative 'service/model/environment'
require_relative 'service/representer/environment_representer'
require_relative 'service/representer/update_environment_representer'
require_relative 'service/model/version'
require_relative 'service/representer/version_representer'
require_relative 'service/model/member'
require_relative 'service/representer/member_representer'
require_relative 'service/representer/update_member_representer'
require_relative 'service/model/group_membership'
require_relative 'service/representer/group_membership_representer'

require_relative 'service/model/group'
require_relative 'service/representer/group_representer'
require_relative 'service/representer/update_group_representer'
require_relative 'service/model/group_project'
require_relative 'service/representer/group_project_representer'

require_relative 'service/model/provisioned_instance'
require_relative 'service/model/provisioned_version'
require_relative 'service/representer/update_provisioned_version_representer'
require_relative 'service/representer/provisioned_instance_representer'
require_relative 'service/representer/provisioned_version_representer'
require_relative 'service/representer/provisioned_version_summary_representer'
require_relative 'service/representer/update_provisioned_instance_representer'
require_relative 'service/representer/provisioned_instances_representer'

require_relative 'service/model/variant'
require_relative 'service/representer/update_variant_representer'
require_relative 'service/representer/variant_representer'

require_relative 'service/model/embedded_project'
require_relative 'service/representer/embedded_project_representer'
require_relative 'service/representer/update_embedded_project_representer'

require_relative 'service/model/project'
require_relative 'service/model/project_query'

require_relative 'service/representer/project_representer'
require_relative 'service/representer/update_project_representer'
require_relative 'service/representer/project_query_representer'
require_relative 'service/model/node'
require_relative 'service/model/node_link'
require_relative 'service/model/element'
require_relative 'service/model/project_version'
require_relative 'service/representer/element_representer'
require_relative 'service/representer/node_link_representer'
require_relative 'service/representer/node_representer'
require_relative 'service/representer/project_version_representer'
require_relative 'service/representer/node_representer'
require_relative 'service/representer/update_node_representer'
require_relative 'service/representer/element_representer'
require_relative 'service/representer/update_element_representer'
require_relative 'service/representer/elements_representer'
require_relative 'service/representer/nodes_representer'

require_relative 'service/model/org'
require_relative 'service/model/subscriber'
require_relative 'service/representer/update_org_representer'
require_relative 'service/representer/subscriber_representer'
require_relative 'service/representer/add_subscriber_representer'
require_relative 'service/representer/subscription_representer'
require_relative 'service/representer/org_representer'
require_relative 'service/representer/update_subscription_representer'
require_relative 'service/representer/error_representer'
require_relative 'service/model/category'
require_relative 'service/util/http_status_codes'
require_relative 'service/model/country_query'
require_relative 'service/representer/country_representer'
require_relative 'service/representer/country_query_representer'
require_relative 'service/representer/category_representer'
require_relative 'service/representer/category_summary_representer'
require_relative 'service/representer/update_category_representer'
require_relative 'service/model/category_query'
require_relative 'service/representer/category_query_representer'

require_relative 'service/model/stack'
require_relative 'service/model/offering'
require_relative 'service/model/portfolio'
require_relative 'service/model/assembly'

require_relative 'auth'