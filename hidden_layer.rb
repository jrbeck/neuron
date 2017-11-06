load 'neuron.rb'

class HiddenLayer
  attr_accessor :neurons

  def initialize(size, input_size)
    @neurons = Array.new(size) { Neuron.new(input_size) }
  end

  def compute(input_vector)
    @input_vector = input_vector
    @neurons.map do |neuron|
      neuron.compute(input_vector)
    end
  end

  def values
    @neurons.map(&:value)
  end

  def compute_output_layer_error_vector(expected_vector)
    error_vector = []
    @neurons.each_with_index do |neuron, index|
      error = expected_vector[index] - neuron.value

      error_vector << error
      neuron.delta = error * neuron.activation_function_derivative(neuron.value)
    end
    error_vector
  end

  def compute_error_vector(next_layer)
    error_vector = []
    @neurons.each_with_index do |neuron, index|
      error = 0.0
      next_layer.neurons.each do |next_layer_neuron|
        error += next_layer_neuron.weights[index] * next_layer_neuron.delta
      end

      error_vector << error
      neuron.delta = error * neuron.activation_function_derivative(neuron.value)
    end
    error_vector
  end
end
