ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# カバレッジ測定
require 'simplecov'
require 'simplecov-rcov'
require 'rake'
include Rake::DSL
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails' do
  add_filter '/lib/'
  add_filter '/spec/'
end

# migrate
ActiveRecord::Migration.maintain_test_schema!

# support 読み込み
Dir[Rails.root.join("spec/supports/*.rb")].each { |f| require f }

FactoryGirl.definition_file_paths << File.expand_path("#{Rails.root}/spec/v1/factories", __FILE__)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  #FactoryGirlのクラスメソッドを使いやすく
  config.include FactoryGirl::Syntax::Methods
  #失敗時点で全テスト中断
  config.fail_fast = false
  #データベースをクリーンに保つ
  config.use_transactional_fixtures = true
  #アノニマスコントローラー
  config.infer_base_class_for_anonymous_controllers = false
  #テストの順番をランダムにする。要。
  config.order = :random
  #配置ディレクトリに応じてspecタイプを自動判別
  config.infer_spec_type_from_file_location!

  config.expect_with :rspec do |expectations|
    #カスタムマッチャチェインをdescriptionに出力
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:all) do
    FactoryGirl.reload
  end

  config.include RSpecHtmlMatchers
end