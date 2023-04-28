# frozen_string_literal: true

require "footgauntlet/utils/configuration_factory"
require "test_helper"

describe ConfigurationFactory do
  Configuration = ConfigurationFactory.create(:required, default: 1)

  describe "#initialize" do
    describe "when omitting a required attr" do
      it "raises a `MissingRequiredAttributesError`" do
        _ { Configuration.new { } }.must_raise(
          Configuration::MissingRequiredAttributesError
        )
      end
    end

    describe "when omitting a default attr" do
      it "gives it a default value" do
        config = Configuration.new { |config| config.required = 2 }
        assert_equal(1, config.default)
      end
    end
  end
end