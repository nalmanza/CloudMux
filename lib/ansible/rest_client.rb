require 'rest-client'
require 'json'

# [TODO] Use Logging module; ie lib/salt/rest_client
ANSIBLE_DEBUG=false

if ANSIBLE_DEBUG
  RestClient.log = "/home/thethethe/Development/MomentumSI/CloudMux/rest_log"
end
# quicker than setting up vcr
def dprint(str)
  if ANSIBLE_DEBUG
    print str
  end
end

class Ansible
  class Client
    def initialize(url, user, password)
      dprint "post /api/v1/authtoken"
      resp = RestClient.post(url+"/api/v1/authtoken/", {:username=>user,
       :password=>password})
      dprint resp
      auth_token = JSON.parse(resp)["token"]
      @rest = RestClient::Resource.new(
        "#{url}/",
        :headers => {:accept=>"application/json",
        "Authorization"=>"Token " +auth_token})
    end


    def get_me
      dprint "get /api/v1/me"
      resp = @rest['/api/v1/me'].get
      dprint resp
      JSON.parse(resp)["results"]
    end

    # [XXX] All of these requests return paged results - no support
    # for that as of yet.
    def get_job_templates
      dprint "get /api/v1/job_templates"
      resp = @rest['/api/v1/job_templates'].get
      dprint resp
      # ruby's implicit return
      JSON.parse(resp)["results"]
    end

    def post_job_templates_run(job_template_ids, host)
     success = true
     job_template_ids.each{ |job_template_id|
        data = {
          :name => "CloudMux triggered job %d for host %s" % [job_template_id, host],
          :job_type => 'run',
          :limit => host}
        url = '/api/v1/job_templates/%d/jobs' % job_template_id
        dprint "post %s" % url
        resp = @rest[url].post(data)
        #[TODO] add error handling for all these calls
        job_id = JSON.parse(resp)['id']
        url = '/api/v1/jobs/%d/start/' % job_id
        resp = @rest[url].post({})
        dprint resp
        # check if failed
        dprint 'get /api/v1/jobs/%d'
        resp = @rest['/api/v1/jobs/%d/' %job_id].get
        dprint resp
        if JSON.parse(resp)['failed'] == true
          success = false
        end
      }
      if success
        return true
      end
      false
    end

    def get_inventories
      dprint "/api/v1/inventories"
      resp = @rest['/api/v1/inventories'].get
      dprint resp
      JSON.parse(resp)["results"]
    end

    # [TODO] change  to 'post_hosts'
    def post_inventories(name,description, organization=1,variables='')
      dprint "/api/v1/hosts"
      resp = @rest['/api/v1/hosts'].post({
        :name => name,
        :description => description,
        :organization => organization,
        :variables => variables
      })
      dprint resp

      #[XXX] Theoretical what this is at this point - need to see 
      # actual response
      JSON.parse(resp)["results"]
    end

    def get_hosts(name=nil)
      url = '/api/v1/hosts' 
      if name
        url = url+'?name=%s' % URI.encode(name)  
      #elsif id
      #  url = '/api/v1/hosts/%s' %id
      end
      dprint url
      resp = @rest[url].get
      dprint resp
      #if id
      #  JSON.parse(resp)
      #end
      JSON.parse(resp)["results"]
    end

    def post_hosts(name,description, variables='')
      resp = get_hosts(name=name)
      host = resp[0]
      if not host 
        resp = @rest['/api/v1/hosts/'].post({
          :name => name,
          :description => description,
          :inventory => '1', # [XXX] same inventory
          :variables => variables
        })
        dprint "post /api/v1/hosts"
        dprint resp
      	host = JSON.parse(resp)
        dprint "post /api/v1/%d/groups"
        resp = @rest['/api/v1/hosts/%d/groups' % host['id']].post({:id=>'1'})
        dprint resp
      end
      host
    end

    def delete_hosts(host_id)
      dprint "delete /api/v1/hosts/%d"
      resp = @rest['/api/v1/hosts/'+host_id].delete
      dprint resp
      JSON.parse(resp)["results"]
    end

    def post_groups(name,description, inventory,variables='')
      dprint "post /api/v1/groups"
      resp = @rest['/api/v1/groups'].post({
        :name => name,
        :description => description,
        :inventory => '1',
        :variables => variables
      })
      dprint resp
      JSON.parse(resp)["results"]
    end

    def get_organizations
      resp = @rest['/api/v1/organizations'].get
      JSON.parse(resp)["results"]
    end

    def post_organizations(name,description, inventory,variables)
      resp = @rest['/api/v1/organizations'].post({
        :name => name,
        :description => description })
      JSON.parse(resp)["results"]
    end

    def get_users
      dprint "get /api/v1/users"
      resp = @rest['/api/v1/users'].get
      dprint resp
      JSON.parse(resp)["results"]
    end

    def post_users(username, first_name, last_name, email, password)
      dprint "post /api/v1/users"
      resp = @rest['/api/v1/users'].post(
        :username => username,
        :first_name => first_name,
        :last_name => last_name,
        :email => email,
        :password => password)
      dprint resp
      JSON.parse(resp)["results"]
    end

    def get_users_credentials(user_id)
      dprint "get /api/v1/users/%d/credentials"
      resp = @rest['/api/v1/users/'+user_id+'/credentials'].get
      dprint resp
      JSON.parse(resp)["results"]
    end

    def post_users_credentials(user_id, name, ssh_username, ssh_password, ssh_key_data,
      ssh_key_unlock, sudo_username, sudo_password)
      dprint "post /api/v1/users/%d/credentials"
      resp = @rest['/api/v1/users/'+user_id+'/credentials'].post(
        name,
        ssh_username,
        ssh_password,
        ssh_key_data,
        ssh_key_unlock,
        sudo_username,
        sudo_password)
      dprint resp
      JSON.parse(resp)["results"]
    end

    def post_users_credentials_remove(user_id, credentials_id)
      dprint "post /api/v1/users/%d/credentials"
      resp = @rest['/api/v1/users/'+user_id+'/credentials'].post(
        :id => credentials_id,
        :disassociate => true)
      dprint resp
      JSON.parse(resp)["results"]
    end

  end
end

def queue_ansible(qitem)
  stack_name = qitem.data
  #
  # ansible creds
  # [XXX] We still need a method for deriving the account ID outside the user's control 
  acc = Account.find(qitem.account_id)
  cloud_acc = CloudAccount.where({:org_id => acc.org_id}).first;
  config = cloud_acc.config_managers.select{
    |c| c['type'] == 'ansible'}[0]
  if config
    url = config.protocol + "://" + config.host + ":" + config.port
    ansible = Ansible::Client.new(url, 
     config.auth_properties['ansible_user'], 
     config.auth_properties['ansible_pass'])
  end
  # Fog AWS cursors
  cloud_cred = Account.find_cloud_credential q.cred_id
  cf = Fog::AWS::CloudFormation.new({
   :aws_access_key_id => cloud_cred.access_key, 
   :aws_secret_access_key => cloud_cred.secret_key})
  ec =  Fog::Compute::AWS.new({
   :aws_access_key_id => cloud_cred.access_key, 
   :aws_secret_access_key => cloud_cred.secret_key})
  resp = cf.describe_stack_resources({'StackName'=>stack_name})
  resources = resp.body["StackResources"]
  complete = false
  if (qitem.action)
    instance_name,jobs = qitem.action.split(':')
    jobs = jobs.split(' ')
    hosts = {}
    resources.each do |r|
    if r['LogicalResourceId'] == instance_name and r['ResourceStatus'] == "CREATE_COMPLETE" and r['ResourceType'] == "AWS::EC2::Instance"
      instance_id = r['PhysicalResourceId']
      if instance_id
        instance = ec.describe_instances({'instance-id'=>instance_id}).body
        public_ip = instance['reservationSet'].first['instancesSet'].first['ipAddress']
        # we have an ip now, register it on ansible 
  
        if not hosts[public_ip]
          hosts[public_ip] = hosts[public_ip] ? hosts[public_ip] : ansible.post_hosts(public_ip, instance_name + " EC2 Instance") 
          if not hosts[public_ip]
            qitem.errors[Time.now] = "Failed to register host with Ansible %s %s:%s" % [stack_name, jobs, instance_name,public_ip]
            qitem.save!
          end
        end
        complete = ansible.post_job_templates_run(jobs, public_ip) 
        if not complete
          qitem.errors[Time.now] = "Ansible Job %s failed to run on %s %s:%s" % [stack_name, jobs, instance_name,public_ip]
          qitem.save!
        end
      end
    end
  end
  if complete
    qitem.complete = Time.now
    qitem.save!
  end
end
end
