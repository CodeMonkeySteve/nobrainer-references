class Numeric
  def self.nobrainer_cast_user_to_model(value)
    if value.is_a?(Numeric)
      value
    elsif value.respond_to?(:to_f)
      value.to_f
    else
      value.to_i
    end
  end
end