# frozen_string_literal: true

class ReadOnlyStruct < Struct
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