# Blueprint-Rails
A rapid Rails 6 application template for personal use.
- Tested Rails Version gem `'rails', '~> 6.0.3'`
- Tested Ruby Versions ruby `'2.7.1'`

Inspired heavily by [Jumpstart](https://github.com/excid3/jumpstart) from [Chris Oliver](https://twitter.com/excid3/) and [kickoff_tailwind](https://github.com/justalever/kickoff_tailwind) from [Justalever](https://twitter.com/justalever). Credits to him for a bunch here

**Included gems:**
  - [devise](https://github.com/heartcombo/devise)
  - [draper](https://github.com/drapergem/draper)
  - [friendly_id](https://github.com/norman/friendly_id)
  - [kaminari](https://github.com/kaminari/kaminari)
  - [name_of_person](https://github.com/basecamp/name_of_person)
  - [sidekiq](https://github.com/mperham/sidekiq)
  - [slim-rails](https://github.com/slim-template/slim-rails)
  - [annotate](https://github.com/ctran/annotate_models)
  - [brakeman](https://github.com/presidentbeef/brakeman)
  - [database_cleaner](https://github.com/DatabaseCleaner/database_cleaner)
  - [dotenv-rails](https://github.com/bkeepers/dotenv/)
  - [factory_bot_rails](https://github.com/thoughtbot/factory_bot_rails)
  - [faker](https://github.com/faker-ruby/faker)
  - [pry-rails](https://github.com/rweng/pry-rails/)
  - [pry-byebug](https://github.com/deivid-rodriguez/pry-byebug)
  - [rspec-rails](https://github.com/rspec/rspec-rails)
  - [rubocop](https://github.com/rubocop-hq/rubocop)
  - [rubocop-performance](https://github.com/rubocop-hq/rubocop-performance)
  - [rubocop-rails](https://github.com/rubocop-hq/rubocop-rails)

### Bulma CSS by default
With Rails 6 we have webpacker by default now. Bootstrap 4.5.3 installed using yarn package.

## How it works
##### Create a new rails app
```bash
$ rails new sample_app -d postgresql -m template.rb
or
$ rails new sample_app -d postgresql -m https://github.com/nandhasuhendra/Blueprint-Rails/template.rb (On progress)
```

##### Boot it up
```bash
$ rails server
```

##### Boot it Up (with foreman)
Run `foreman start`. Head to `locahost:5000` to see your app. You'll have hot reloading on `js` and `css` and `scss/sass` files by default. Feel free to configure to look for more to compile reload as your app scales.
