require 'pp'
load 'neural_net.rb'
load '../data_generator.rb'

class Driver
  LAYER_SIZES = [3, 6, 4, 8]

  def initialize
    @neural_net = NeuralNet.new(LAYER_SIZES)
  end

  def run
    data_generator = DataGenerator.new
    @training_data = data_generator.training_data(1)
    # @testing_data = data_generator.testing_data(5)

    pp @training_data

    pp @neural_net.forward_propagate(@training_data.sample[:input])
    # p '-' * 20
    # pp @neural_net
  end


  def train
    data_generator = DataGenerator.new

    learning_rate = 0.01
    gradient_min = 0.001
    num_training_epochs = 1000

    training_data = data_generator.training_data(1000)

    # data = training_data.sample
    # pp data[:output]
    # pp @neural_net.forward_propagate(data[:input])

    num_training_epochs.times do
      data = training_data.sample
      # pp data
      @neural_net.forward_propagate(data[:input])
      @neural_net.backward_propagate(data[:output])
    end

    data = training_data.sample
    pp data[:output]
    pp @neural_net.forward_propagate(data[:input])

  end

end


# Driver.new.run
Driver.new.train
