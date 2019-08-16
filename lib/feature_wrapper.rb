# frozen_string_literal: true

require 'unleash'
require 'unleash/context'

class FeatureWrapper
  def self.enabled?(key, user: nil, thing: nil, default_enabled: false)
    unleash_server_url = ENV['GITLAB_FEATURE_FLAG_SERVER_URL']
    instance_id = ENV['GITLAB_FEATURE_FLAG_INSTANCE_ID']
    app_name = Rails.env

    if unleash_server_url
      key_string = key.to_s

      unleash = Unleash::Client.new({
        url: unleash_server_url,
        instance_id: instance_id,
        app_name: app_name
      })

      unleash_context = Unleash::Context.new

      unleash_context.user_id = user.email if user

      unleash.is_enabled?(key_string, unleash_context)
    else
      Feature.enabled?(key, thing, default_enabled: default_enabled)
    end
  end
end
