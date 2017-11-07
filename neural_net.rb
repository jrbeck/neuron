require 'pp'
load 'hidden_layer.rb'

class NeuralNet

  def initialize(training_data, options = {})
    @num_hidden_layers = options[:num_hidden_layers] || 2
    @hidden_layer_size = options[:hidden_layer_size] || 3
    @learning_rate = options[:learning_rate] || 0.4

    @training_data = training_data
    @hidden_layers = generate_hidden_layers
    @output_layer = HiddenLayer.new(@training_data.first[:output].length, @hidden_layer_size)
  end

  def train(epochs)
    last_result = nil
    epochs.times do |epoch|
      pp "EPOCH #{epoch} ------------------------------------"
      error_sum = []
      @training_data.each do |training_datum|
        last_result = forward_propogate(training_datum[:input])
        error_sum << @output_layer.compute_output_layer_error_vector(training_datum[:output]).reduce(:+)
        backward_propagate_error(training_datum[:output])
        update_weights(training_datum[:input])
      end
      pp error_sum.reduce(:+)
    end
  end

  def compute_error(expected_vector)
    @output_layer.compute_simple_error(expected_vector)
  end

  def inspect
    pp @input_vector
    pp @hidden_layers
    pp @output_layer
  end

  def forward_propogate(input_vector)
    last_vector = input_vector
    @hidden_layers.each do |hidden_layer|
      last_vector = hidden_layer.compute(last_vector)
    end
    @output_layer.compute(last_vector)
  end

  private
    def generate_hidden_layers
      [].tap do |hidden_layers|
        hidden_layers << HiddenLayer.new(@hidden_layer_size, @training_data.first[:input].length)
        (@num_hidden_layers - 1).times do
          hidden_layers << HiddenLayer.new(@hidden_layer_size, @hidden_layer_size)
        end
      end
    end

    def backward_propagate_error(expected_output)
      @output_layer.compute_output_layer_error_vector(expected_output)
      last_layer = @output_layer
      @hidden_layers.reverse_each do |hidden_layer|
        hidden_layer.compute_error_vector(last_layer)
        last_layer = hidden_layer
      end
    end

    def update_weights(training_input)
      inputs = training_input
      [*@hidden_layers, @output_layer].each do |layer|
        layer.neurons.each do |neuron|
          inputs.each_with_index do |input, index|
            neuron.weights[index] += @learning_rate * neuron.delta * input
          end
          neuron.weights[-1] += @learning_rate * neuron.delta
        end

        # for next round
        inputs = layer.neurons.map(&:value)
      end
    end
end
