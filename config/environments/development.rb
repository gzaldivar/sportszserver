Sportzserver::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Devise configuration
  config.action_mailer.default_url_options = { :host => '192.168.1.87:3000' }
  config.action_mailer.perform_deliveries = true

#  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.delivery_method = :smtp #:smtp
  config.action_mailer.smtp_settings = {
    :enable_starttls_auto => true,
    :address => 'smtp.gmail.com',
    :port => '587',
    :authentication => :plain,
    :domain => 'gmail.com',
    :user_name => 'spsites01@gmail.com',
    :password => 'bryan101'
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  #Paypal
  config.after_initialize do
    ActiveMerchant::Billing::Base.mode = :test
    paypal_options = {
      login: "gzaldivar-facilitator_api1.icloud.com",
      password: "1388935614",
      signature: "AHUvrj4LS85hez4e0oNOt.ng8k.sApA9qsWrgVikPTlU8RdriVeo8t3a"
    }
    ::EXPRESS_GATEWAY = ActiveMerchant::Billing::PaypalExpressGateway.new(paypal_options)
  end

  Sportzserver::Application.config.streamingurl = 'http://eazesportzstreaming.s3-website-us-east-1.amazonaws.com'
  Sportzserver::Application.config.streamingbucket = 'eazesportzstreaming'
end
