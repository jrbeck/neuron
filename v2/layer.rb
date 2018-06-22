load 'neuron.rb'

class Layer
  attr_reader :sensitivities

  def initialize(layer_definition)
    @state = {}
    @state[:activation_function] = layer_definition[:activation_function]
    @state[:neurons] = Array.new(layer_definition[:output_size]) { Neuron.new(layer_definition[:input_size]) }
  end

  def forward_propagate(inputs)
    @inputs = inputs.clone
    @activated_inputs = inputs.map do |input|
      compute_activation_function(input)
    end

    [].tap do |outputs|
      @state[:neurons].each do |neuron|
        outputs << neuron.compute(@activated_inputs)
      end
    end
  end

  def compute_sensitivities(next_layer_sensitivities)
    @sensitivities = []

    @inputs.each_with_index do |input, input_index|
      input_sensitivities = []
      @state[:neurons].each_with_index do |neuron, output_index|
        input_sensitivities << neuron.state[:weights][input_index] * next_layer_sensitivities[output_index]
      end

      @sensitivities << compute_activation_function_derivative(input) * input_sensitivities.reduce(:+)
    end
    @sensitivities
  end

  def update_weights(next_layer_sensitivities)
    @state[:neurons].each_with_index do |neuron, output_index|
      neuron.update_weights(@activated_inputs, next_layer_sensitivities[output_index])
    end
  end

  private
    def compute_activation_function(value)
      case @state[:activation_function]
      when :identity
        value
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

    def compute_activation_function_derivative(value)
      case @state[:activation_function]
      when :identity
        1
      when :sigmoid
        # value * (1.0 - value)
        (1.0 / (1.0 + Math.exp(-value))) * (1.0 - (1.0 / (1.0 + Math.exp(-value))))
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


end
