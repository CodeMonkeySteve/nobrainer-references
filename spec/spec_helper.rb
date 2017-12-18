require 'rubygems'
require 'bundler'
Bundler.require(:default)

SPEC_ROOT = File.expand_path File.dirname(__FILE__)
Dir["#{SPEC_ROOT}/support/**/*.rb"].each { |f| require f unless File.basename(f) =~ /^_/ }

RSpec.configure do |config|
  config.order = :random
  config.color = true
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  if ENV['TRACE']
    config.before do
      $trace_file = File.open(ENV['TRACE'], 'w')
      TracePoint.new(:call, :raise) do |tp|
        $trace_file.puts "#{tp.event} #{tp.path} #{tp.method_id}:#{tp.lineno}"
      end.enable
    end
  end
end

# class ObjectSpy
#   def initialize(obj)
#     @_obj = obj
#   end
#
#   def respond_to_missing?(method, private)
#     @_obj.respond_to?(method)
#   end
#
#   def method_missing(method, *args, &block)
#     puts "#{@_obj}.#{method}(#{args.join(', ')})"
#     @_obj.__send__(method, *args, &block)
#   end
# end
