$:.unshift File.expand_path File.dirname(__FILE__) + '../lib'
require 'dm-core/spec/setup'
require 'dm-core/spec/lib/adapter_helpers'
require 'dm-core/spec/lib/spec_helper'
require 'dm-core/spec/lib/pending_helpers'
require 'dm-rails/railtie'

DataMapper::Spec.setup
DataMapper.finalize

RSpec.configure do |config|

  config.extend(DataMapper::Spec::Adapters::Helpers)
  config.include(DataMapper::Spec::PendingHelpers)

  config.after :all do
    DataMapper::Spec.cleanup_models
  end

end
