source 'https://rubygems.org'

# Base
gem 'rails', '4.2.0'
gem 'mysql2'

gem 'haml-rails'
gem 'html2haml'

gem 'rest-client'

#アカウント管理
gem 'authlogic'
gem 'scrypt', '~>   1.2.1'

# 定数管理
gem 'rails_config'

# SQL関係
gem 'squeel'

# サーバー
gem 'unicorn'
gem 'unicorn-worker-killer'

# その他
gem 'pry-rails'
gem 'rb-readline'
gem 'validates_email_format_of'

# ダミー作成にも使う
group :test, :development do
  gem 'faker', '~>  1.1.2'
  gem 'factory_girl_rails', '~>   4.2.1'
end

# テスト
group :test do
  gem 'spring'
  gem 'test-queue'

  #gem 'rspec', '~>  3.1.0'
  #gem 'rspec-rails', '~>  3.1.0'
  gem 'rspec', '~>  3.1.0'
  gem 'rspec-rails', '~>  3.1.0'
  gem 'rspec-html-matchers'
  gem 'database_cleaner', '~> 1.3.0'
  gem 'launchy', '~>  2.3.0'
  gem 'selenium-webdriver'
  gem 'simplecov'
  gem 'simplecov-rcov'
  gem 'spring-commands-rspec'
end