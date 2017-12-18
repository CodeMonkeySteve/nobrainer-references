RSpec.configure do |config|
  config.around(:example, remove_const: true) do |example|
    const_before = Object.constants

    example.run

    const_after = Object.constants
    (const_after - const_before).each do |const|
      Object.send(:remove_const, const)
    end
  end
end