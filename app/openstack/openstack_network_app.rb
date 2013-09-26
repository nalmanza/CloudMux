require 'sinatra'
require 'fog'

class OpenstackNetworkApp < ResourceApiBase

	before do
        if(params[:cred_id].nil?)
            halt [BAD_REQUEST]
        else
            cloud_cred = get_creds(params[:cred_id])
            if cloud_cred.nil?
                halt [NOT_FOUND, "Credentials not found."]
            else
                options = cloud_cred.cloud_attributes
                begin
                    @network = Fog::Network::OpenStack.new(options)
                    halt [BAD_REQUEST] if @network.nil?
                rescue Fog::Errors::NotFound => error
                    halt [NOT_FOUND, error.to_s]
                end
            end
        end
    end

	#
	# Networks
	#
  ##~ sapi = source2swagger.namespace("openstack_network")
  ##~ sapi.swaggerVersion = "1.1"
  ##~ sapi.apiVersion = "1.0"
  ##~ sapi.models["Network"] = {:id => "Network", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["Subnet"] = {:id => "Subnet", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["Port"] = {:id => "Port", :properties => {:id => {:type => "string"}}}
  ##~ sapi.models["FloatingIP"] = {:id => "FloatingIP", :properties => {:id => {:type => "string"}}}
    
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Networks (Openstack cloud)"
  ##~ op.nickname = "describe_networks"  
  ##~ op.errorResponses.add :reason => "Success, list of networks returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  get '/networks' do
        begin
            response = @network.list_networks.body["networks"]
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Network (Openstack cloud)"
  ##~ op.nickname = "create_network"
  ##~ sapi.models["CreateNetwork"] = {:id => "CreateNetwork", :properties => {:name => {:type => "string"}, :tenant_id => {:type => "int"}, :admin_state_up => {:type => "boolean"}, :shared => {:type => "boolean"}}}  
  ##~ op.parameters.add :name => "network", :description => "Network to create", :dataType => "CreateNetwork", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, network created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  post '/networks' do
        json_body = body_to_json(request)
		if(json_body.nil?)
			[BAD_REQUEST]
		else
			begin
				response = @network.networks.create(json_body["network"])
				[OK, response.to_json]
			rescue => error
				handle_error(error)
			end
		end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/networks/:id"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Network"
  ##~ op.set :httpMethod => "DELETE"
  ##~ op.summary = "Delete Network (Openstack cloud)"
  ##~ op.nickname = "delete_network"
  ##~ op.parameters.add :name => "id", :description => "Network id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
  ##~ op.errorResponses.add :reason => "Success, network deleted", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
  delete '/networks/:id' do
        begin
			response = @network.networks.destroy(params[:id])
			[OK, response.to_json]
		rescue => error
			handle_error(error)
		end
	end
	
	#
	# Subnets
	#
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Subnet"
  ##~ op.set :httpMethod => "GET"
  ##~ op.summary = "Describe Subnets (Openstack cloud)"
  ##~ op.nickname = "describe_subnets"  
  ##~ op.errorResponses.add :reason => "Success, list of subnets returned", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
	get '/subnets' do
        begin
            response = @network.list_subnets.body["subnets"]
    		[OK, response.to_json]
        rescue => error
            handle_error(error)
        end
	end
	
  ##~ a = sapi.apis.add
  ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets"
  ##~ a.description = "Manage Network resources on the cloud (Openstack)"
  ##~ op = a.operations.add
  ##~ op.responseClass = "Subnet"
  ##~ op.set :httpMethod => "POST"
  ##~ op.summary = "Create Subnet (Openstack cloud)"
  ##~ op.nickname = "create_subnet"
  ##~ sapi.models["CreateSubnet"] = {:id => "CreateSubnet", :properties => {:network_id => {:type => "string"}, :cidr => {:type => "string"}, :ip_version => {:type => "string"}, :gateway_ip => {:type => "string"}, :allocation_pools => {:type => "string"}}}  
  ##~ op.parameters.add :name => "subnet", :description => "Subnet to create", :dataType => "CreateSubnet", :allowMultiple => false, :required => true, :paramType => "body"  
  ##~ op.errorResponses.add :reason => "Success, subnet created", :code => 200
  ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
  ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/subnets' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.subnets.create(json_body["subnet"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/subnets/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Subnet"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Subnet (Openstack cloud)"
    ##~ op.nickname = "delete_subnet"
    ##~ op.parameters.add :name => "id", :description => "Subnet id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, subnet deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/subnets/:id' do
        begin
            response = @network.subnets.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Ports
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Ports (Openstack cloud)"
    ##~ op.nickname = "describe_ports"  
    ##~ op.errorResponses.add :reason => "Success, list of ports returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/ports' do
        begin
            response = @network.list_ports.body["ports"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create Port (Openstack cloud)"
    ##~ op.nickname = "create_port"
    ##~ sapi.models["CreatePort"] = {:id => "CreatePort", :properties => {:network_id => {:type => "string"}, :name => {:type => "string"}, :admin_state_up => {:type => "boolean"}}}  
    ##~ op.parameters.add :name => "port", :description => "Port to create", :dataType => "CreatePort", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, port created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/ports' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.ports.create(json_body["port"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/ports/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "Port"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete Port (Openstack cloud)"
    ##~ op.nickname = "delete_port"
    ##~ op.parameters.add :name => "id", :description => "Port id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, port deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/ports/:id' do
        begin
            response = @network.ports.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end

    #
    # Floating IPs
    #
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "GET"
    ##~ op.summary = "Describe Floating IPs (Openstack cloud)"
    ##~ op.nickname = "describe_floating_ips"  
    ##~ op.errorResponses.add :reason => "Success, list of Floating IPs returned", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    get '/floating_ips' do
        begin
            response = @network.list_floating_ips.body["floating_ips"]
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "POST"
    ##~ op.summary = "Create FloatingIP (Openstack cloud)"
    ##~ op.nickname = "create_floating_ip"
    ##~ sapi.models["CreateFloatingIP"] = {:id => "CreateFloatingIP", :properties => {:name => {:type => "string"}}}  
    ##~ op.parameters.add :name => "floating_ip", :description => "FloatingIP to create", :dataType => "CreateFloatingIP", :allowMultiple => false, :required => true, :paramType => "body"  
    ##~ op.errorResponses.add :reason => "Success, Floating IP created", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    post '/floating_ips' do
        json_body = body_to_json(request)
        if(json_body.nil?)
            [BAD_REQUEST]
        else
            begin
                response = @network.floating_ips.create(json_body["floating_ip"])
                [OK, response.to_json]
            rescue => error
                handle_error(error)
            end
        end
    end
    
    ##~ a = sapi.apis.add
    ##~ a.set :path => "/api/v1/cloud_management/openstack/network/floating_ips/:id"
    ##~ a.description = "Manage Network resources on the cloud (Openstack)"
    ##~ op = a.operations.add
    ##~ op.responseClass = "FloatingIP"
    ##~ op.set :httpMethod => "DELETE"
    ##~ op.summary = "Delete FloatingIP (Openstack cloud)"
    ##~ op.nickname = "delete_floating_ip"
    ##~ op.parameters.add :name => "id", :description => "FloatingIP id to destroy", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "path"  
    ##~ op.errorResponses.add :reason => "Success, Floating IP deleted", :code => 200
    ##~ op.errorResponses.add :reason => "Invalid Parameters", :code => 400
    ##~ op.parameters.add :name => "cred_id", :description => "Cloud credential to use", :dataType => "string", :allowMultiple => false, :required => true, :paramType => "query"
    delete '/floating_ips/:id' do
        begin
            response = @network.floating_ips.destroy(params[:id])
            [OK, response.to_json]
        rescue => error
            handle_error(error)
        end
    end
end