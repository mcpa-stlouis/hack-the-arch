class DockerApiJob < ApplicationJob
  require "uri"
  require "net/http"
  require "base64"

  @@api_version = "v1.37"
  @@socket_path = "/var/run/docker.sock"

  protected
    # Get all services
    def docker_get_hta_services()
      filter = Hash.new(0)
      filter['label'] = ["hackthearch"]
      query = URI.encode_www_form('filters' => filter.to_json)

      res = docker_get_request("/services?#{query}")

      if res.code == '200'
        return JSON(res.body)
      end
      raise Exception.new("HTTP #{res.code} communicating with Docker!")
    end

    # Returns array of services for assessment
    def docker_get_services(assessment)
      filter = Hash.new(0)
      filter['label'] = ["user_id=#{assessment['user_id']}"]
      query = URI.encode_www_form('filters' => filter.to_json)

      res = docker_get_request("/services?#{query}")

      if res.code == '200'
        return JSON(res.body)
      end
      raise Exception.new("HTTP #{res.code} communicating with Docker!")
    end

    # Returns networks JSON object for assessment
    def docker_get_networks(assessment)
      filter = Hash.new(0)
      filter['label'] = ["user_id=#{assessment['user_id']}"]
      query = URI.encode_www_form('filters' => filter.to_json)

      res = docker_get_request("/networks?#{query}")

      if res.code == '200'
        return JSON(res.body)
      end
      raise Exception.new("HTTP #{res.code} communicating with Docker!")
    end

    def delete_stack(services, networks)

      services.each do |service|
        docker_delete_service(service['ID'])
      end

      networks.each do |network|
        docker_delete_network(network['Id'])
      end
    end

    def docker_delete_service(id)
      res = docker_delete_request("/services/#{id}")
      unless res.code == '200'
        raise Exception.new("Issue deleting service #{id}")
      end
    end

    def docker_delete_network(id)
      res = docker_delete_request("/networks/#{id}")
      unless res.code == '204' or res.code == '404'
        raise Exception.new("Issue deleting network #{id}")
      end
    end

    def docker_get_request(uri)
      sock = Net::BufferedIO.new(UNIXSocket.new(@@socket_path))
      request = Net::HTTP::Get.new("/#{@@api_version}#{uri}")
      request["Host"] = "localhost"
      request.exec(sock, "1.1", uri)

      begin
        response = Net::HTTPResponse.read_new(sock)
      end while response.kind_of?(Net::HTTPContinue)
      response.reading_body(sock, request.response_body_permitted?) { }

      response
    end

    def docker_post_request(path, params)
      sock = Net::BufferedIO.new(UNIXSocket.new(@@socket_path))
      request = Net::HTTP::Post.new("/#{@@api_version}#{path}",
                                    'Content-Type' => 'application/json')
      request["Host"] = "localhost"

      if File.exist?("/run/secrets/REGISTRY_AUTH")
        request["X-Registry-Auth"] = File.read("/run/secrets/REGISTRY_AUTH")
      end

      # If auth token exists, use it:
      auth = "/run/secrets/REGISTRY_AUTH"
      if File.exist?(auth) || File.symlink?(auth)
        request["X-Registry-Auth"] = Base64.encode64(File.read(auth, 'r'))
      end

      request.body = params
      request.exec(sock, "1.1", path)

      begin
        response = Net::HTTPResponse.read_new(sock)
      end while response.kind_of?(Net::HTTPContinue)
      response.reading_body(sock, request.response_body_permitted?) { }

      response
    end

    def docker_delete_request(path)
      sock = Net::BufferedIO.new(UNIXSocket.new(@@socket_path))
      request = Net::HTTP::Delete.new("/#{@@api_version}#{path}")
      request["Host"] = "localhost"
      request.exec(sock, "1.1", path)

      begin
        response = Net::HTTPResponse.read_new(sock)
      end while response.kind_of?(Net::HTTPContinue)
      response.reading_body(sock, request.response_body_permitted?) { }

      response
    end

end
