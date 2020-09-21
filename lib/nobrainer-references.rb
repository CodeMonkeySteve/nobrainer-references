require 'active_support/dependencies/autoload'

require 'nobrainer'
require 'no_brainer/types/array'
require 'no_brainer/types/numeric'
require 'no_brainer/document/references'
require 'no_brainer/document/embeddable'

module NoBrainer
  autoload :Array, :Reference

  module Document
    autoload :References
  end
end
