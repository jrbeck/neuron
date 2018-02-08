require 'pp'

load 'hidden_layer.rb'

class NeuralNet
  DEFAULT_HIDDEN_LAYER_SIZES = [1].freeze
  DEFAULT_LEARNING_RATE = 0.123

  def initialize(options: nil, saved_state: nil)
    if saved_state
      load_state(saved_state)
    else
      configure(options)
    end
  end

  def configure(options)
    @input_size = options[:input_size]
    @output_size = options[:output_size]
    @hidden_layer_sizes = options[:hidden_layer_sizes] || DEFAULT_HIDDEN_LAYER_SIZES
    @learning_rate = options[:learning_rate] || DEFAULT_LEARNING_RATE
    @hidden_layers = generate_hidden_layers
    @output_layer = HiddenLayer.new(size: @output_size, input_size: @hidden_layer_sizes.last)
  end

  def load_state(saved_state)
    @input_size = saved_state[:input_size]
    @output_size = saved_state[:output_size]
    @hidden_layer_sizes = saved_state[:hidden_layer_sizes]
    @learning_rate = saved_state[:learning_rate]
    @hidden_layers = saved_state[:hidden_layers].map { |hidden_layer_state| HiddenLayer.new(saved_state: hidden_layer_state) }
    @output_layer = HiddenLayer.new(saved_state: saved_state[:output_layer])
  end

  def state
    {
      input_size: @input_size,
      output_size: @output_size,
      hidden_layer_sizes: @hidden_layer_sizes.clone,
      learning_rate: @learning_rate,
      hidden_layers: @hidden_layers.map(&:state),
      output_layer: @output_layer.state
    }
  end

  def randomize
    @hidden_layers.each(&:randomize)
  end

  def train(training_data, epochs, testing_data = nil)
    epochs.times do |epoch|
      training_data.each do |training_datum|
        forward_propagate(training_datum[:input])
        backward_propagate_error(training_datum[:output])
        update_weights(training_datum[:input])
      end

      if testing_data
        errors = []
        testing_data.each do |testing_datum|
          forward_propagate(testing_datum[:input])
          errors << compute_error(testing_datum[:output]).map { |error| error * error }.reduce(:+)
        end
        pp "#{epoch} - #{(errors.reduce(:+) / errors.length).round(6)}"
      end
    end
  end

  def compute_error(expected_vector)
    @output_layer.compute_simple_error(expected_vector)
  end

  def forward_propagate(input_vector)
    last_vector = input_vector
    @hidden_layers.each do |hidden_layer|
      last_vector = hidden_layer.compute(last_vector)
    end
    @output_layer.compute(last_vector)
  end

  # def forward_propagate2(input_vector)
  #   last_vector = input_vector
  #   @hidden_layers.each do |hidden_layer|
  #     last_vector = hidden_layer.compute2(last_vector)
  #   end
  #   @output_layer.compute2(last_vector)
  # end

  private
    def generate_hidden_layers
      last_hidden_layer_size = @input_size
      [].tap do |hidden_layers|
        @hidden_layer_sizes.each do |hidden_layer_size|
          hidden_layers << HiddenLayer.new(size: hidden_layer_size, input_size: last_hidden_layer_size)
          last_hidden_layer_size = hidden_layer_size
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
