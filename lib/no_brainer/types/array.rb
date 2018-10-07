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

    def self.of(object_type = nil, &object_type_proc)
      NoBrainer::TypedArray.of(object_type, &object_type_proc)
    end
  end
  Document::Types::Array = Array

  class TypedArray < ::Array
    def self.of(object_type = nil, &object_type_proc)
      if object_type.nil? == object_type_proc.nil?
        raise ArgumentError, "Expected either Object or block"
      end

      if object_type
        object_type = resolve_object_type(object_type)
        ::Class.new(TypedArray) { define_singleton_method(:object_type) { object_type } }
      else
        # lazy-load object class
        ::Class.new(TypedArray) { define_singleton_method(:object_type) { @object_type ||= resolve_object_type(object_type_proc) } }
      end
    end

    def self.resolve_object_type(type)
      type = type.call  if type.respond_to?(:call)
      if type.const_defined?('Array', !:inherited)
        return type.const_get('Array', !:inherited)
      end
      type.const_set('Array', self)
      type
    end
    private_class_method :resolve_object_type

    def self.nobrainer_cast_user_to_model(values)
      cast_type = object_type.respond_to?(:nobrainer_cast_user_to_model) && object_type
      values = Array(values).map do |value|
        value = cast_type.nobrainer_cast_user_to_model(value)  if cast_type
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

