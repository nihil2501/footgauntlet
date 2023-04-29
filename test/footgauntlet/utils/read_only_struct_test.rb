# frozen_string_literal: true

require "footgauntlet/utils/read_only_struct"
require "test_helper"

describe ReadOnlyStruct do
  Person = ReadOnlyStruct.new(:name, :hobby)

  before do
    @person = Person.new(name: "Oren",  hobby: "Electronic music")
  end

  describe "attr reader" do
    it "gets the value" do
      assert_equal(
        "Electronic music",
        @person.hobby
      )
    end
  end

  describe "attr writer" do
    it "raises a `NoMethodError`" do
      _ { @person.name = "Alice" }.must_raise(
        NoMethodError
      )
    end
  end

  describe "generic attr writer" do
    it "raises a `NoMethodError`" do
      _ { @person[:name] = "Alice" }.must_raise(
        NoMethodError
      )
    end
  end
end
