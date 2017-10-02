load 'neuron.rb'

class HiddenLayer
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

  def compute_error(expected_vector)
    # pp '==========='
    # pp expected_vector
    # pp values
    error_vector = Array.new(@neurons.size, 0)
    expected_vector.each do |expected_value|
      @neurons.each_with_index do |neuron, index|
        error_vector[index] += expected_value - neuron.value
      end
    end
    error_vector
  end

  def train(error_vector)
    # pp '-----'
    # pp values
    # pp error_vector
    # adjustment = dot(training_set_inputs.T, error * self.__sigmoid_derivative(output))

    @neurons.each_with_index do |neuron, index|
      adjustment = error_vector[index] * @input_vector[index] * neuron.activation_function_derivative(neuron.value)
      neuron.weights.each_with_index do |weight, weight_index|
        neuron.weights[weight_index] += adjustment
      end
    end
  end
end
