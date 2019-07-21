class CreateStackJob < DockerApiJob
  queue_as :default

  # Takes hash: challenge
  #   user_id
  #   problem_id
  #   network
  #   containers
  #   lifespan
  def perform(challenge)
    check_existing(challenge)
    create_stack(challenge)
  end

  private
    def check_existing(challenge)
      containers = docker_get_containers(challenge)
      networks = docker_get_networks(challenge)

      if networks.length > 0 or containers.length > 0
        user_id = challenge['user_id']
        User.find(user_id).update_attribute(:container_id, '')
        User.find(user_id).update_attribute(:stack_expiry, DateTime.now)
        User.find(user_id).update_attribute(:problem_id, -1)
        delete_stack(containers, networks)
      end
    end

    def create_stack(challenge)
      # Start with network (Name: problem_id-user_id)
      network = JSON(challenge['network'])
      network['Name'] = "hta-#{challenge['problem_id']}-#{challenge['user_id']}"
      network['Labels'] = {
        "user_id" => "#{challenge['user_id']}",
        "problem_id" => "#{challenge['problem_id']}",
        "lifetime" => "#{challenge['lifespan']}"
      }
      res = docker_post_request('/networks/create', network.to_json)
      network_id = JSON(res.body)["Id"]

      if res.code != '201'
        raise Exception.new("Couldn't create challenge network.")
      end

      # Then build containers
      containers = JSON(challenge['containers'])
      containers.each do |container|
        container['Labels'] = {
          "user_id" => "#{challenge['user_id']}",
          "problem_id" => "#{challenge['problem_id']}",
          "lifetime" => "#{challenge['lifespan']}"
        }

        # Make sure the container is reachable by its designed name
        container['Networks'] = [{ 
          "Target": network_id,
          "Aliases": [
            container['Name'],
            container['Name'].gsub("-","."),
          ]
        }]

        # find entrypoint
        is_entry = false
        if container['Name'].downcase == "entrypoint"
          is_entry = true
        end

        # Add user_id to container name for identification
        container_name = container['Name']
        container['Name'] = "hta-#{container_name}-#{challenge['user_id']}"

        res = docker_post_request('/services/create', container.to_json)
        if res.code != '201'
          raise Exception.new("Couldn't create challenge containers.")
        end

        # If container is entry point, assign to user
        if is_entry
          id = JSON(res.body)["ID"]
          User.find(challenge['user_id']).update_attribute(:container_id, id)
          User.find(challenge['user_id']).update_attribute(:stack_expiry, DateTime.now + Integer(challenge['lifespan']).minutes)
          User.find(challenge['user_id']).update_attribute(:problem_id, challenge['problem_id'])
        end
      end
    end

end
