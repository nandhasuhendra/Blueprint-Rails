# frozen_string_literal: true

# Template Name: Blueprint Rails
# Author: Nandha Suhendra
# Instructions: $ rails new myapp -d <sqlite3, postgresql, mysql> -m <template.rb, https://github.com/nandhasuhendra/Blueprint-Rails/template.rb>

require 'fileutils'
require 'shellwords'

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def source_path
  if __FILE__.match?(%r{\Ahttps?://})
    require 'tmpdir'

    source_paths.unshift(tempdir = Dir.mktmpdir('Blueprint-Rails-'))

    at_exit { FileUtils.remove_entry(tempdir) }

    git clone: [
      '--quiet',
      'https://github.com/nandhasuhendra/Blueprint-Rails.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{Blueprint-Rails/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_5?
  Gem::Requirement.new('>= 5.2.0', '< 6.0.0.beta1').satisfied_by? rails_version
end

def rails_6?
  Gem::Requirement.new('>= 6.0.0.beta1', '< 7').satisfied_by? rails_version
end

def stop_spring
  run 'spring stop'
end

def set_application_name
  if rails_5?
    environment 'config.application_name = Rails.application.class.parent_name'
  else
    environment 'config.application_name = Rails.application.class.module_parent_name'
  end
end

def set_filter_params
  gsub_file 'config/initializers/filter_parameter_logging.rb', /\[:password\]/ do
    '%w[password secret session cookie csrf]'
  end
end

def set_localtime
  gsub_file 'config/application.rb',
            "config.time_zone = 'Singapore'",
            'config.active_record.default_timezone = :local'

  insert_into_file 'config/application.rb', before: /^  end/ do
    <<~'RUBY'
      # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
      config.active_job.queue_adapter = :sidekiq
    RUBY
  end
end

def add_gems
  gsub_file 'Gemfile', /^gem\s+["']coffee-rails["'].*$/, ''
  gsub_file 'Gemfile', /^gem\s+["']sass-rails["'].*$/, ''
  gsub_file 'Gemfile', /^gem\s+["']byebug["'].*$/, ''

  gem 'devise', '~> 4.7', '>= 4.7.1'
  gem 'draper', '~> 4.0', '>= 4.0.1'
  gem 'friendly_id', '~> 5.3'
  gem 'kaminari', '~> 1.2', '>= 1.2.1'
  gem 'name_of_person', '~> 1.1'
  gem 'sidekiq', '~> 6.0', '>= 6.0.3'
  gem 'slim-rails', '~> 3.2'

  gem_group :development, :test do
    gem 'annotate', '>= 3.1.1'
    gem 'brakeman', '~> 4.9'
    gem 'factory_bot_rails', '~> 6.1'
    gem 'faker', '~> 2.14'
    gem 'pry-rails', '~> 0.3.9'
    gem 'pry-byebug', '~> 3.9'
    gem 'rspec-rails', '~> 4.0', '>= 4.0.1'
    gem 'rubocop', '~> 0.89.1'
    gem 'rubocop-performance', require: false
    gem 'rubocop-rails', require: false
  end

  gem_group :test do
    gem 'database_cleaner', '~> 1.8', '>= 1.8.5'
  end

  gem 'webpacker', '~> 5.1', '>= 5.1.1' if rails_5?
end

def add_webpack
  # Rails 6+ comes with webpacker by default, so we can skip this step
  return if rails_6?

  # Our application layout already includes the javascript_pack_tag,
  # so we don't need to inject it
  rails_command 'webpacker:install'
end

def add_javascript
  # Install javascript libraries
  run 'yarn add local-time bootstrap@4.5.3 jquery popper.js'

  if rails_5?
    run 'yarn add turbolinks @rails/actioncable@pre @rails/actiontext@pre @rails/activestorage@pre @rails/ujs@pre'
  end

  # Configure webpacker
  content = <<~JS
    const webpack = require('webpack')
    const alias = require("./alias")

    environment.plugins.append('Provide', new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery',
      Popper: ['popper.js', 'default'],
      Rails: '@rails/ujs'
    }))

    environment.config.merge(alias)
  JS

  insert_into_file 'config/webpack/environment.js', content + "\n", before: 'module.exports = environment'

  # Add stylesheets to application.js
  run 'mkdir -p app/javascript/stylesheets'
  append_to_file('app/javascript/packs/application.js', 'import "stylesheets/application"')
end

def add_sidekiq
  environment 'config.active_job.queue_adapter = :sidekiq'

  insert_into_file 'config/routes.rb',
                   "require 'sidekiq/web'\n\n",
                   before: 'Rails.application.routes.draw do'

  content = <<~RUBY
    authenticate :user, lambda { |u| u.strict?  } do
      mount Sidekiq::Web => '/sidekiq'
    end
  RUBY

  insert_into_file 'config/routes.rb', "#{content}\n\n", after: "Rails.application.routes.draw do\n"
end

def add_users
  # install Devise
  generate 'devise:install'

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000}",
              env: 'development'

  route "root to: 'home#index'"

  # Create Devise User
  generate :devise, 'User',
           'first_name',
           'last_name',
           'strict:boolean'

  # Set admin default to false
  in_root do
    migration = Dir.glob('db/migrate/*').max_by { |f| File.mtime(f) }
    gsub_file migration, /:strict/, ':strict, default: false'
  end

  # Update Devise initializers
  if Gem::Requirement.new('> 5.2').satisfied_by? rails_version
    gsub_file 'config/initializers/devise.rb',
              /  # config.secret_key = .+/,
              '  config.secret_key = Rails.application.credentials.secret_key_base'
  end

  gsub_file 'config/initializers/devise.rb',
            /  # config.email_regexp= .+/,
            '  config.email_regexp = \A[^@\s]+@[^@\s]+\z/'

  gsub_file 'config/initializers/devise.rb',
            /  # config.password_length = .+/,
            '  config.password_length = 8..128'

  # name_of_person gem
  append_to_file('app/models/user.rb', "\nhas_person_name\n", after: 'class User < ApplicationRecord')
end

def add_friendly_id
  generate 'friendly_id'
end

def add_annotate
  generate 'annotate:install'
end

def add_draper
  generate 'draper:install'
end

def add_kaminari
  generate 'kaminari:config'
end

def add_active_storage
  rails_command 'active_storage:install'
end

def add_rspec
  generate 'rspec:install'
end

def copy_templates
  remove_file 'app/views/layouts/application.html.erb'
  remove_file 'app/assets/stylesheets/application.css'

  copy_file '.foreman'
  copy_file '.rubocop.yml'
  copy_file 'Procfile'
  copy_file 'Procfile.dev'

  directory 'app',    force: true
  directory 'config', force: true
  directory 'spec',   force: true
end

# Main setup
source_path
add_gems

after_bundle do
  stop_spring

  set_application_name
  set_filter_params
  set_localtime

  add_webpack
  add_javascript
  add_sidekiq
  add_active_storage
  add_users
  add_friendly_id
  add_annotate
  add_draper
  add_rspec

  copy_templates

  # Add everything to Git
  unless ENV['SKIP_GIT']
    git :init
    git add: '.'
    git commit: " -m 'Initial commit'  "
  end

  say
  say 'Your app successfully created with Blueprint Rails! 👍', :blue
  say
  say 'To get started with your new app:'
  say "cd #{app_name}", :green
  say
  say '# Update config/database.yml with your database credentials'
  say
  say 'rails db:create && rails db:migrate'
  say
  say 'install foreman if you wanna using it'
  say 'gem install foreman', :yellow
  say 'foreman start', :green
  say
  say 'Or running with default rails server:'
  say '$ rails server', :green
end
