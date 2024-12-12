# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'active_support/concern'

require 'no_brainer/types/reference'
require 'no_brainer/references/eager_loader'

module NoBrainer
  module Document
    module References
      extend ActiveSupport::Concern

      module ClassMethods
        def references_one(name, model: nil, store_as: nil, inverse: nil, **opts)
          name = name.to_s
          store_as ||= "#{name}_id"
          model ||= name.classify.constantize
          if model.is_a?(String)
            name = model
            model = ->{ const_get(name) }
          end

          field name.to_sym, type: Reference.to(model), store_as: store_as, **opts
        end

        def references_many(name, model: nil, store_as: nil, inverse: nil, **opts)
          name = name.to_s
          store_as ||= "#{name.singularize}_ids"
          model ||= name.singularize.classify.constantize
          if model.is_a?(String)
            name = model
            model = ->{ const_get(name) }
          end

          field name.to_sym, type: Array.of(Reference.to(model)), store_as: store_as, **opts
        end
      end
    end
  end
end
