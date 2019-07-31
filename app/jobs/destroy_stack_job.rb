class DestroyStackJob < DockerApiJob
  queue_as :default

  def perform(challenge)
    containers = docker_get_containers(challenge)
    networks = docker_get_networks(challenge)

    # If stack hasn't exceeded its lifetime, then it probably has it's own
    # delayed job to clean it up
    if get_age(containers.first) > challenge['lifespan'].to_f

      user_id = challenge['user_id']
      User.find(user_id).update_attribute(:container_id, '')
      User.find(user_id).update_attribute(:stack_expiry, DateTime.now)
      User.find(user_id).update_attribute(:problem_id, -1)
      delete_stack(containers, networks)

    end
  end

  private
    def get_age(container)
      if container
        ((Time.now() - Time.parse(container['CreatedAt'])) / 60) + 10
      else
        return Float::INFINITY
      end
    end

end
