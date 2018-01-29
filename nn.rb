require 'pp'
load 'data_generator.rb'
load 'sample_data.rb'
load 'neural_net.rb'
load 'monkey_trainer.rb'
load 'monkey_data.rb'

class NN
  TRAINING_EPOCHS = 1000

  def initialize
    # @training_data = SampleData.training_data
    # @testing_data = SampleData.testing_data

    # data_generator = DataGenerator.new
    # @training_data = data_generator.training_data(1000)
    # @testing_data = data_generator.testing_data(10)

    @training_data = MonkeyData.training_data
    @testing_data = MonkeyData.testing_data

    @output_extremes = output_extremes(@training_data + @testing_data)
  end


  def monkey_test
    monkey_trainer = MonkeyTrainer.new
    monkey_trainer.connect
    pp monkey_trainer.generate_training_data
    monkey_trainer.disconnect
  end



  def run
    normalized_training_data = normalize_samples(@training_data, @output_extremes)
    normalized_testing_data = normalize_samples(@testing_data, @output_extremes)

    # normalized_training_data = @training_data
    # normalized_testing_data = @testing_data

    errors = []

    neural_net_options = {
      input_size: @training_data.first[:input].length,
      output_size: @training_data.first[:output].length,
      hidden_layer_sizes: [3],
      learning_rate: 0.5
    }
    errors << configured_run(normalized_training_data, TRAINING_EPOCHS, normalized_testing_data, neural_net_options)

    # puts 'Errors ...'
    # errors.each do |error|
    #   pp error.reduce(:+) / error.length
    #   pp '-----'
    # end
  end

  def configured_run(training_data, training_epochs, testing_data, neural_net_options)
    neural_net = NeuralNet.new(options: neural_net_options)
    initial_neural_net_state = neural_net.state

    puts "Training ... (#{training_epochs} epochs)"
    neural_net.train(training_data, training_epochs, testing_data)

    puts 'Testing ...'
    errors = []
    testing_data.each do |testing_datum|
      forward_propagation_output = neural_net.forward_propagate(testing_datum[:input])

      pp testing_datum[:input]
      pp denormalize_output(testing_datum[:output], @output_extremes).map { |value| value.round(2) }
      pp denormalize_output(forward_propagation_output, @output_extremes).map { |value| value.round(2) }
      pp '------------------------'
      errors << neural_net.compute_error(testing_datum[:output]).map { |error| error * error }.reduce(:+)
    end

    pp neural_net.state

    errors
  end

  private
    def output_extremes(samples)
      { low: 10000000, high: -10000000 }.tap do |extremes|
        samples.each do |sample|
          sample[:output].each do |value|
            extremes[:low] = value if extremes[:low] > value
            extremes[:high] = value if extremes[:high] < value
          end
        end
      end
    end

    def normalize_samples(samples, extremes)
      samples.map do |sample|
        {}.tap do |normalized_sample|
          normalized_sample[:input] = sample[:input]
          normalized_sample[:output] = []

          sample[:output].each do |value|
            range = extremes[:high] - extremes[:low]
            normalized_sample[:output] << (value - extremes[:low]) / range
          end
        end
      end
    end

    def denormalize_samples(samples, extremes)
      samples.map do |sample|
        {}.tap do |denormalized_sample|
          denormalized_sample[:input] = sample[:input]
          denormalized_sample[:output] = denormalize_output(sample[:output], extremes)
        end
      end
    end

    def denormalize_output(output, extremes)
      [].tap do |denormalized_output|
        output.each do |value|
          range = extremes[:high] - extremes[:low]
          denormalized_output << (value * range) + extremes[:low]
        end
      end
    end
end

nn = NN.new
nn.run
# nn.monkey_test
