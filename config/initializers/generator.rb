# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.assets false
  g.template_engine :slim
  g.test_framework :rspec,
                   helper_specs: false,
                   view_specs: false,
                   cotroller_specs: false,
                   routing_specs: false
end
