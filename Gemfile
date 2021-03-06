require 'pathname'

source 'https://rubygems.org'

gemspec

SOURCE         = ENV.fetch('SOURCE', :git).to_sym
REPO_POSTFIX   = SOURCE == :path ? ''                                : '.git'
DATAMAPPER     = SOURCE == :path ? Pathname(__FILE__).dirname.parent : 'http://github.com/ar-dm'
DM_VERSION     = '~> 1.2'
DO_VERSION     = '~> 0.10.12'
RAILS_VERSION  = '~> 4.0'
DM_DO_ADAPTERS = %w[ sqlite postgres mysql oracle sqlserver ]
CURRENT_BRANCH = ENV.fetch('GIT_BRANCH', 'master')

# DataMapper dependencies
gem 'ardm-core',         DM_VERSION, SOURCE => "#{DATAMAPPER}/ardm-core#{REPO_POSTFIX}",         :branch => CURRENT_BRANCH
gem 'ardm-active_model', DM_VERSION, SOURCE => "#{DATAMAPPER}/ardm-active_model#{REPO_POSTFIX}", :branch => CURRENT_BRANCH

# Rails dependencies
gem 'actionpack', RAILS_VERSION, :require => 'action_pack'
gem 'railties',   RAILS_VERSION, :require => 'rails'

group :protected_attributes do
  gem 'protected_attributes'
end

group :datamapper do
  adapters = ENV['ADAPTER'] || ENV['ADAPTERS']
  adapters = adapters.to_s.tr(',', ' ').split.uniq - %w[ in_memory ]

  if (do_adapters = DM_DO_ADAPTERS & adapters).any?
    do_options = {}
    do_options[:git] = "#{DATAMAPPER}/do#{REPO_POSTFIX}" if ENV['DO_GIT'] == 'true'

    gem 'data_objects', DO_VERSION, do_options.dup

    do_adapters.each do |adapter|
      adapter = 'sqlite3' if adapter == 'sqlite'
      gem "do_#{adapter}", DO_VERSION, do_options.dup
    end

    gem 'ardm-do-adapter', DM_VERSION, SOURCE => "#{DATAMAPPER}/ardm-do-adapter#{REPO_POSTFIX}", :branch => CURRENT_BRANCH
  end

  gem 'ardm-migrations', DM_VERSION, SOURCE => "#{DATAMAPPER}/ardm-migrations#{REPO_POSTFIX}", :branch => CURRENT_BRANCH

  adapters.each do |adapter|
    gem "ardm-#{adapter}-adapter", DM_VERSION, SOURCE => "#{DATAMAPPER}/ardm-#{adapter}-adapter#{REPO_POSTFIX}", :branch => CURRENT_BRANCH
  end
end
