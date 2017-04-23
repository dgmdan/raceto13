require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Runspool
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Need this for logs on heroku
    config.logger = ActiveSupport::Logger.new(STDOUT)

    # Mail sending
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
        address:              ENV['SMTP_HOST'],
        port:                 ENV['SMTP_PORT'],
        user_name:            ENV['SMTP_USER'],
        password:             ENV['SMTP_PASSWORD'],
        authentication:       :plain,
        enable_starttls_auto: false,
        ssl:                  true
    }

    # Enable web console
    config.web_console.whitelisted_ips = ENV['WEB_CONSOLE_IPS']
    config.web_console.development_only = false
  end
end
