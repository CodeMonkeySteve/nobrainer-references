require 'no_brainer/document'

module NoBrainer
  class Reference < SimpleDelegator
    def self.to(model_type = nil, &model_type_proc)
      raise ArgumentError, "wrong number of arguments (given 2, expect 1)"  if model_type && model_type_proc
      raise ArgumentError, "wrong number of arguments (given 0, expect 1)"  unless model_type || model_type_proc
      if model_type.respond_to?(:call)
        model_type_proc = model_type
        model_type = nil
      end
      if model_type
        model_type = resolve_model_type(model_type)
        ::Class.new(Reference) { define_singleton_method(:model_type) { model_type } }
      else
        # lazy-load model class
        ::Class.new(Reference) { define_singleton_method(:model_type) { @model_type ||= resolve_model_type(model_type_proc) } }
      end
    end

    def self.resolve_model_type(type)
      type = type.call  if type.respond_to?(:call)
      if type.const_defined?('Reference', !:inherited)
        return type.const_get('Reference', !:inherited)
      end
      raise TypeError, "Expected Document subclass, got #{type.inspect}"  unless type < Document
      type.const_set('Reference', self)
      type
    end
    private_class_method :resolve_model_type

    attr_reader :id

    def initialize(id, object = nil)
      @id = id
      __setobj__(object)
    end

    def __getobj__
      super do
        if @id && (obj = self.class.model_type.find(@id))
          __setobj__(obj)
        elsif block_given?
          yield
        end
      end
    end

    def __hasobj__
      defined? @delegate_sd_obj
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
