# frozen_string_literal: true

require 'no_brainer/document'

module NoBrainer
  class Reference < SimpleDelegator
    mattr_accessor :autosave
    self.autosave = true

    def self.to(model_type = nil, &model_type_proc)
      raise ArgumentError, "wrong number of arguments (given 2, expect 1)"  if model_type && model_type_proc
      raise ArgumentError, "wrong number of arguments (given 0, expect 1)"  unless model_type || model_type_proc
      if model_type.respond_to?(:call)
        model_type_proc = model_type
        model_type = nil
      end

      if model_type.const_defined?('Reference', !:inherited)
        return model_type.const_get('Reference', !:inherited)
      end

      ref_type = if model_type
        model_type = resolve_model_type(model_type)
        ::Class.new(Reference) { define_singleton_method(:model_type) { model_type } }
      else
        # lazy-load model class
        ::Class.new(Reference) { define_singleton_method(:model_type) { @model_type ||= resolve_model_type(model_type_proc) } }
      end
      model_type.const_set('Reference', ref_type)
    end

    def self.resolve_model_type(type)
      type = type.call  if type.respond_to?(:call)
      if type.const_defined?('Reference', !:inherited)
        return type.const_get('Reference', !:inherited)
      end
      unless type < Document
        raise TypeError, "Expected Document subclass, got #{type.inspect}"
      end
      type
    end
    private_class_method :resolve_model_type

    def self.name
      str = "Reference"
      str += "(#{model_type.name})"  if respond_to?(:model_type)
      str
    end

    attr_reader :id

    def initialize(id, object = nil)
      @id = id
      __setobj__(object)  unless object.nil?
    end

    def inspect
      "#<*#{self.class.model_type} " + (
        __hasobj__ ? __getobj__.inspectable_attributes.map { |k,v| "#{k}: #{v.inspect}" }.join(', ')
                   : "#{self.class.model_type.table_config.primary_key}: #{id.inspect}"
      ) +  ">"
    end

    def dup
      self.class.new(@id)
    end
    alias_method :deep_dup, :dup

    def __getobj__
      super do
        if @missing
          nil
        elsif @id
          model = self.class.model_type
          unless (obj = model.find?(@id))
            @missing = true
            raise NoBrainer::Error::MissingAttribute, "#{model} :#{model.pk_name}=>#{@id.inspect} not found"
          end
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
        when nil
          nil
        else
          raise NoBrainer::Error::InvalidType
      end
    end

    def self.nobrainer_cast_model_to_db(value)
      value&.save!  if value&.new_record? && self.autosave
      value&.id
    end

    def self.nobrainer_cast_db_to_model(value)
      value && new(value)
    end
  end

  Document::Types::Reference = Reference
end
