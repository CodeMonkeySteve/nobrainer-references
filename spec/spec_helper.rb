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
