class Neuron
  attr_accessor :value, :weights, :zed, :delta

  def initialize(num_inputs: nil, saved_state: nil)
    @activation_function = :sigmoid
    # @activation_function = :softplus
    # @activation_function = :relu
    # @activation_function = :tanh

    if saved_state
      @weights = saved_state[:weights].clone
    else
      @weights = Array.new(num_inputs) { rand }
    end

    @value = nil
  end

  def state
    { weights: @weights.clone }
  end

  def randomize
    @weights = Array.new(@weights.length) { rand }
  end

  def compute(input_vector)
    fail 'Invalid input_vector size' if input_vector.length != @weights.length
    @zed = dot(input_vector, @weights)
    @value = compute_activation_function(@zed)
  end

  def compute_activation_function_derivative(value)
    case @activation_function
    when :sigmoid
      value * (1.0 - value)
      # (1.0 / (1.0 + Math.exp(-value))) * (1.0 - (1.0 / (1.0 + Math.exp(-value))))
    when :softplus
      1.0 / (1.0 + Math.exp(-value))
    when :relu
      value <= 0 ? 0 : 1
    when :tanh
      1.0 - (Math.tanh(value) * Math.tanh(value))
    else
      fail 'Invalid activation function'
    end
  end

  private
    def dot(vector_a, vector_b)
      sum = 0
      vector_a.each_with_index do |element, index|
        sum += vector_b[index] * element
      end
      sum
    end

    # def hadamard(vector_a, vector_b)
    #   vector_a.map do |element, index|
    #     element * vector_b[index]
    #   end
    # end

    def compute_activation_function(value)
      case @activation_function
      when :sigmoid
        1.0 / (1.0 + Math.exp(-value))
      when :softplus
        Math.log(1.0 + Math.exp(value))
      when :relu
        value <= 0 ? 0 : value
      when :tanh
        Math.tanh(value)
      else
        fail 'Invalid activation function'
      end
    end
end
