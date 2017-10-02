require 'pp'
load 'data_generator.rb'
load 'neural_net.rb'

class NN
  def initialize
    training_data = DataGenerator.new(1000).generate
    @neural_net = NeuralNet.new(training_data)
  end

  def run
    puts 'Training ...'
    @neural_net.train(200)
    puts 'Result:'
    @neural_net.inspect

    puts 'Trying it out!'
    10.times do
      test_data = DataGenerator.new(1).generate
      pp test_data
      pp @neural_net.run(test_data[0][:input])
    end
  end
end

nn = NN.new
nn.run
