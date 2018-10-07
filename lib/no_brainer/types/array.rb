require 'no_brainer/document'

module NoBrainer
  class Array
    %i(nobrainer_cast_user_to_model nobrainer_cast_model_to_db nobrainer_cast_db_to_model).each do |method|
      redefine_singleton_method(method) do |values|
        ::Array.wrap(values).map do |value|
          if value.class.respond_to?(method)
            value.class.__send__(method, value)
          else
            value
          end
        end
      end
    end

    def self.of(object_type = nil)
      NoBrainer::TypedArray.of(object_type)
    end
  end
  Document::Types::Array = Array

  class TypedArray < ::Array
    def self.of(object_type)
      return object_type.const_get('Array', !:inherited)  if object_type.const_defined?('Array', !:inherited)
      klass = ::Class.new(TypedArray) do
        define_singleton_method(:object_type) { object_type }
      end
      object_type.const_set('Array', klass)
    end

    def self.nobrainer_cast_user_to_model(values)
      values = Array(values).map do |value|
        value = object_type.nobrainer_cast_user_to_model(value)  if object_type.respond_to?(:nobrainer_cast_user_to_model)
        unless value.is_a?(object_type)
          raise NoBrainer::Error::InvalidType, type: object_type.name, value: value
        end
        value
      end
      new(values)
    end

    def self.nobrainer_cast_model_to_db(values)
      values = Array(values)
      if object_type.respond_to?(:nobrainer_cast_model_to_db)
        values.map { |value| object_type.nobrainer_cast_model_to_db(value) }
      else
        values
      end
    end

    def self.nobrainer_cast_db_to_model(values)
      values = Array(values)
      if object_type.respond_to?(:nobrainer_cast_db_to_model)
        values.map { |value| object_type.nobrainer_cast_db_to_model(value) }
      else
        values
      end
    end
  end
end

