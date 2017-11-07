class Neuron
  attr_accessor :value, :weights, :zed, :delta

  def initialize(num_inputs)
    initialize_weights(num_inputs)
    @value = nil
  end

  def compute(input_vector)
    fail 'Invalid input_vector size' if input_vector.length != @weights.length
    @zed = dot(input_vector, @weights)
    @value = activation_function(@zed)
  end

  def activation_function_derivative(value)
    # sigmoid derivative
    value * (1.0 - value)
  end

  private
    def initialize_weights(num_inputs)
      @weights = Array.new(num_inputs) { rand }
    end

    def dot(vector_a, vector_b)
      sum = 0
      vector_a.each_with_index do |element, index|
        sum += vector_b[index] * element
      end
      sum
    end

    def hadamard(vector_a, vector_b)
      vector_a.map do |element, index|
        element * vector_b[index]
      end
    end

    def activation_function(value)
      # sigmoid
      1.0 / (1.0 + Math.exp(-value))
    end
end
