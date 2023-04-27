# frozen_string_literal: true

class ReadOnlyStruct < Struct
  # This is mostly supplanted in newer Ruby with the `Data` builtin that makes
  # a value struct with no setters and frozen state. However, `Data` made it
  # hard to memoize pure derivations using ivars because of the frozen state so
  # I had to fall back to this thing.
  class << self
    def new(*)
      super(*, keyword_init: true).tap do |klass|
        klass.undef_method :[]=
        klass.members.each do |member|
          klass.undef_method :"#{member}="
        end
      end
    end
  end
end