load 'neuron.rb'

class HiddenLayer
  attr_accessor :neurons

  def initialize(size: nil, input_size: nil, saved_state: nil)
    if saved_state
      load_state(saved_state)
    else
      @neurons = Array.new(size) { Neuron.new(num_inputs: input_size) }
    end
  end

  def state
    { neurons: @neurons.map(&:state) }
  end

  def load_state(saved_state)
    @neurons = []
    saved_state[:neurons].each do |neuron_state|
      @neurons << Neuron.new(saved_state: neuron_state)
    end
  end

  def randomize
    @neurons.each(&:randomize)
  end

  def compute(input_vector)
    @input_vector = input_vector
    @neurons.map do |neuron|
      neuron.compute(input_vector)
    end
  end

  def compute2(input_vector)
    puts '---+++----'
    # pp input_vector

    @input_vector = input_vector
    output = @neurons.map do |neuron|
      neuron.compute(input_vector)
    end
    pp output
    output
  end

  def values
    @neurons.map(&:value)
  end

  def compute_simple_error(expected_vector)
    [].tap do |error_vector|
      @neurons.each_with_index do |neuron, index|
        error = expected_vector[index] - neuron.value
        error_vector << error
      end
    end
  end

  def compute_output_layer_error_vector(expected_vector)
    [].tap do |error_vector|
      @neurons.each_with_index do |neuron, index|
        error = expected_vector[index] - neuron.value

        error_vector << error
        neuron.delta = error * neuron.activation_function_derivative(neuron.value)
      end
    end
  end

  def compute_error_vector(next_layer)
    [].tap do |error_vector|
      @neurons.each_with_index do |neuron, index|
        error = 0.0
        next_layer.neurons.each do |next_layer_neuron|
          error += next_layer_neuron.weights[index] * next_layer_neuron.delta
        end

        error_vector << error
        neuron.delta = error * neuron.activation_function_derivative(neuron.value)
      end
    end
  end
end
