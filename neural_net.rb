require 'pp'
load 'hidden_layer.rb'

class NeuralNet
  NUM_HIDDEN_LAYERS = 2
  HIDDEN_LAYER_SIZE = 8
  LEARNING_RATE = 0.5

  def initialize(training_data)
    @training_data = training_data
    @hidden_layers = generate_hidden_layers
    @output_layer = generate_output_layer
  end

  def train(epochs)
    last_result = nil
    epochs.times do |epoch|
      pp "EPOCH #{epoch} ------------------------------------"
      error_sum = []
      @training_data.each do |training_datum|
        last_result = run(training_datum[:input])
        error_sum << @output_layer.compute_output_layer_error_vector(training_datum[:output]).reduce(:+)
        backward_propagate_error(training_datum[:output])
        update_weights(training_datum[:input])
      end
      pp error_sum.reduce(:+)
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
          neuron.weights[index] += LEARNING_RATE * neuron.delta * input
        end
        neuron.weights[-1] += LEARNING_RATE * neuron.delta
      end

      # for next round
      inputs = layer.neurons.map(&:value)
    end
  end

  def run(input_vector)
    last_vector = input_vector
    @hidden_layers.each do |hidden_layer|
      last_vector = hidden_layer.compute(last_vector)
    end
    @output_layer.compute(last_vector)
  end

  def inspect
    pp @input_vector
    pp @hidden_layers
    pp @output_layer
  end

  private
    def generate_hidden_layers
      [].tap do |hidden_layers|
        hidden_layers << HiddenLayer.new(HIDDEN_LAYER_SIZE, @training_data.first[:input].length)
        (NUM_HIDDEN_LAYERS - 1).times do
          hidden_layers << HiddenLayer.new(HIDDEN_LAYER_SIZE, HIDDEN_LAYER_SIZE)
        end
      end
    end

    def generate_output_layer
      HiddenLayer.new(@training_data.first[:output].length, HIDDEN_LAYER_SIZE)
    end
end
