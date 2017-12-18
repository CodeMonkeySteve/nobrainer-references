require 'nobrainer'
require 'no_brainer/types/array'
require 'no_brainer/types/reference'

module NoBrainer
  autoload :TypedArray, :Reference

  module Document::References
    module References
      def references_one(model)
        # ...
      end

      def references_many(model)
        # ...
      end

      def referenced_by(model)
        # ...
      end
    end

    extend References
  end
end
