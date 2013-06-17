$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'rspec'
require 'buff/ruby_engine'

def setup_rspec
  Dir[File.join(File.expand_path("../../spec/support/**/*.rb", __FILE__))].each { |f| require f }

  RSpec.configure do |config|
    config.expect_with :rspec do |c|
      c.syntax = :expect
    end

    config.mock_with :rspec
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.filter_run focus: true
    config.run_all_when_everything_filtered = true
  end
end

if Buff::RubyEngine.jruby?
  require 'varia_model'
  setup_rspec
else
  require 'spork'

  Spork.prefork { setup_rspec }
  Spork.each_run { require 'varia_model' }
end
