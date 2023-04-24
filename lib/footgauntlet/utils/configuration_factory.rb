# frozen_string_literal: true

module ConfigurationFactory
  class << self
    def create(*required, **optional)
      Class.new do |klass|
        klass.const_set(:MissingRequiredAttributesError,
          missing_attrs_error_klass = Class.new(RuntimeError)
        )

        required.each do |attr|
          attr_reader(attr)

          define_method(:"#{attr}=") do |value|
            @missing_attrs.delete(attr)
            instance_variable_set(:"@#{attr}", value)
          end
        end

        optional.each do |attr, default|
          attr_writer(attr)

          define_method(attr) do
            ivar = :"@#{attr}"
            instance_variable_get(ivar) ||
            instance_variable_set(ivar, default)
          end 
        end

        define_method(:initialize) do |&block|
          @missing_attrs = required.to_set
          block.call(self)

          unless @missing_attrs.empty?
            error_message = "missing attrs: #{@missing_attrs.join(", ")}"
            raise  missing_attrs_error_klass, error_message
          end
        end
      end
    end
  end
end