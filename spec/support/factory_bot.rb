# frozen_string_literal: true

require 'factory_bot'

RSpec.configure do |config|
  config.include(FactoryBot::Syntax::Methods)

  config.before(:suite) do
    # FactoryBot.lint
  end

  config.append_after(:each) do
    FactoryBot.rewind_sequences
  end
end
