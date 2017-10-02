require 'pp'
load 'hidden_layer.rb'

class NeuralNet
  INPUT_SIZE = 5
  NUM_HIDDEN_LAYERS = 2

  def initialize(training_data)
    @training_data = training_data
    @hidden_layers = generate_hidden_layers
    @output_layer = generate_output_layer
  end

  def train(epochs)
    last_result = nil
    epochs.times do
      # results = []
      error_sum = []
      @training_data.each do |training_datum|
        last_result = run(training_datum[:input])
        last_expected = training_datum[:output]


        # pp '----'
        # pp last_result
        # pp last_expected

        error_sum << @output_layer.compute_error(training_datum[:output]).reduce(:+)

        [*@hidden_layers, @output_layer].reverse_each do |hidden_layer|
          # pp '***********'
          # pp hidden_layer
          # pp last_expected
          error_vector = hidden_layer.compute_error(last_expected)
          hidden_layer.train(error_vector)
          last_expected = hidden_layer.values
        end
      end
      # pp error_sum.reduce(:+)
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
      Array.new(NUM_HIDDEN_LAYERS) do
        HiddenLayer.new(INPUT_SIZE, INPUT_SIZE)
      end
    end

    def generate_output_layer
      HiddenLayer.new(1, INPUT_SIZE)
    end
end
