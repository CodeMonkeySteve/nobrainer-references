require 'nobrainer'
require 'no_brainer/types/reference'
require 'no_brainer/types/array'
require 'no_brainer/types/numeric'
require 'no_brainer/references/eager_loader'

module NoBrainer
  # autoload :TypedArray, :Reference

  module Document
    module References
      extend ActiveSupport::Concern

      module ClassMethods
        def references_one(name, model: nil, store_as: nil, **opts)
          name = name.to_s
          store_as ||= "#{name}_id"
          model ||= name.classify.constantize
          # if model.is_a?(String)
          #   name = model
          #   model = ->{ const_get(model) }
          # end
          field name.to_sym, type: Reference.to(model), store_as: store_as, **opts
        end

        def references_many(name, model: nil, store_as: nil, **opts)
          name = name.to_s
          store_as ||= "#{name.singularize}_ids"
          model ||= name.singularize.classify.constantize
          # if class_name.is_a?(String)
          #   name = class_name
          #   class_name = ->{ const_get(name) }
          # end
          field name.to_sym, type: Array.of(Reference.to(model)), store_as: store_as, **opts
        end

        def referenced_by(name, field: nil, model: nil)
          name = name&.to_s
          model ||= name.classify.constantize
          field = model.fields[field.to_s]  if field.is_a?(String) || field.is_a?(Symbol)
          field ||= model.fields[self.name] || model.fields[self.name.pluralize]
          unless field
            raise ArgumentError, "Can't find Reference for #{self.name} in #{name}, specify :field"
          end

          @referrers ||= Hash.new { |h, k|  h[k] = [] ; h }
          @referrers[model] << field

          if name
            in_array = field[:type] < Array
            expr = { model.lookup_field_alias(field.name).send(in_array ? :include : :eq) => self.id }
            define_method name.to_sym do
              model.where(expr)
            end
          end
        end
      end
    end
  end
end
