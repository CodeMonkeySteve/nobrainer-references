require 'no_brainer/document'

module NoBrainer
  class Reference < SimpleDelegator
    def self.to(model_type)
      raise ArgumentError, "Expected NoBrainer::Document type, got #{model_type.inspect}"  unless model_type < Document
      return model_type.const_get('Reference', !:inherit)  if model_type.const_defined?('Reference', !:inherit)

      klass = ::Class.new(Reference) do
        define_singleton_method(:model_type) { model_type }
      end
      model_type.const_set('Reference', klass)
    end

    attr_reader :id

    def initialize(id, object = nil)
      @id = id
      __setobj__(object)
    end

    def __getobj__
      super || __setobj__(self.class.model_type.find(id))
    end

    def self.nobrainer_cast_user_to_model(value)
      case value
        when Reference
          unless value.class.model_type == model_type
            raise NoBrainer::Error::InvalidType, "Expected Reference to #{model_type}, got #{value}"
          end
          value
        when model_type
          new(value.id, value)
        else
          raise NoBrainer::Error::InvalidType
      end
    end

    def self.nobrainer_cast_model_to_db(value)
      value.id
    end

    def self.nobrainer_cast_db_to_model(value)
      new(value)
    end
  end

  Document::Types::Reference = Reference
end