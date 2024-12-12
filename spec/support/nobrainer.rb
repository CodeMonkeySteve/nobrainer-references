RSpec.configure do |config|
  config.before(:suite) do
    NoBrainer.sync_schema
    NoBrainer.purge!
  end

  config.after(:suite) do
    NoBrainer.drop!
  end
end

NoBrainer.configure do |config|
  config.app_name = 'nobrainer_refs'
  config.environment = :test
  end
