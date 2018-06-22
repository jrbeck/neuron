load 'layer.rb'

class NeuralNet
  DEFAULT_ACTIVATION_FUNCTION = :sigmoid

  def initialize(layer_sizes)
    fail if layer_sizes.length < 2
    @state = {}

    @state[:layers] = []
    layer_sizes.each_cons(2) do |layer_info|
      layer_definition = {
        input_size: layer_info[0],
        output_size: layer_info[1],
        activation_function: @state[:layers].size == 0 ? :identity : DEFAULT_ACTIVATION_FUNCTION
        # activation_function: DEFAULT_ACTIVATION_FUNCTION
      }
      @state[:layers] << Layer.new(layer_definition)
    end
  end

  def forward_propagate(inputs)
    last_layer_output = inputs.clone
    @state[:layers].each do |layer|
      last_layer_output = layer.forward_propagate(last_layer_output)
    end
    @output_vector = last_layer_output
  end

  def backward_propagate(target_outputs)
    compute_sensitivities(target_outputs)
    update_weights
  end

  private
    def compute_sensitivities(target_outputs)
      @output_layer_sensitivities = []
      error = 0

      @output_vector.each_with_index do |output_value, index|
        diff = output_value - target_outputs[index]
        error += diff * diff
        @output_layer_sensitivities << 2.0 * diff
      end

      # pp error

      next_layer_sensitivities = @output_layer_sensitivities
      @state[:layers].reverse.each do |layer|
        next_layer_sensitivities = layer.compute_sensitivities(next_layer_sensitivities)
      end
    end

    def update_weights
      @state[:layers].each_cons(2) do |layers|
        layers[0].update_weights(layers[1].sensitivities)
      end
      @state[:layers].last.update_weights(@output_layer_sensitivities)
    end

end
