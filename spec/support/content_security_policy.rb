# frozen_string_literal: true

# Serves the dummy app under a strict, nonce-based Content Security Policy,
# the setup the Rails CSP initializer generator recommends.
RSpec.shared_context "with a nonce-based content security policy" do
  around do |example|
    env_config = Rails.application.env_config
    keys = %w[
      action_dispatch.content_security_policy
      action_dispatch.content_security_policy_nonce_generator
      action_dispatch.content_security_policy_nonce_directives
    ]
    original = env_config.slice(*keys)

    env_config["action_dispatch.content_security_policy"] = ActionDispatch::ContentSecurityPolicy.new do |policy|
      policy.default_src :self
      policy.img_src :self, :data, :blob
      policy.script_src :self
      policy.style_src :self, :unsafe_inline
    end
    env_config["action_dispatch.content_security_policy_nonce_generator"] = ->(_request) { SecureRandom.base64(16) }
    env_config["action_dispatch.content_security_policy_nonce_directives"] = %w[script-src]

    example.run
  ensure
    keys.each { |key| original.key?(key) ? env_config[key] = original[key] : env_config.delete(key) }
  end
end
