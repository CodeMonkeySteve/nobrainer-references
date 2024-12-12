# frozen_string_literal: true

require 'active_support/dependencies/autoload'
require 'nobrainer'
require 'no_brainer/document/references'

module NoBrainer
  autoload :Array, :Reference

  module Document
    include References
  end
end
