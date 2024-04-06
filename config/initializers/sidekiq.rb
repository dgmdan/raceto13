# frozen_string_literal: true

rails_root = Rails.root || "#{File.dirname(__FILE__)}/../.."
Rails.env || 'development'
redis_config = YAML.load_file("#{rails_root}/config/redis.yml")
redis_config.merge! redis_config.fetch(Rails.env, {})
redis_config.symbolize_keys!
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12" }
  schedule_file = 'config/sidekiq_schedule.yml'
  Sidekiq::Cron::Job.load_from_hash! YAML.load_file(schedule_file) if File.exist?(schedule_file) && Sidekiq.server?
end
Sidekiq.configure_client do |config|
  config.redis = { url: "redis://#{redis_config[:host]}:#{redis_config[:port]}/12" }
end
