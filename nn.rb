require 'pp'
load 'data_generator.rb'
load 'sample_data.rb'
load 'neural_net.rb'

class NN
  def initialize
    @training_data = SampleData.training_data
    @testing_data = SampleData.testing_data
    @data_extremes = data_extremes(@training_data + @testing_data)
  end

  def run
    normalized_training_data = normalize_samples(@training_data, @data_extremes)
    normalized_testing_data = normalize_samples(@testing_data, @data_extremes)

    errors = []

    neural_net_options = {
      input_size: @training_data.first[:input].length,
      output_size: @training_data.first[:output].length,
      hidden_layer_sizes: [4],
      learning_rate: 0.5
    }
    errors << configured_run(normalized_training_data, 1000, normalized_testing_data, neural_net_options)

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
      neural_net.forward_propogate(testing_datum[:input])
      errors << neural_net.compute_error(testing_datum[:output]).map { |error| error * error }.reduce(:+)
    end

    errors
  end

  private
    def data_extremes(samples)
      {}.tap do |extremes|
        samples.each do |sample|
          sample.keys.each do |key|
            extremes[key] ||= Array.new(sample[key].length) { { low: 1000000, high: -1000000 } }
            sample[key].each_with_index do |value, index|
              extremes[key][index][:low] = value if extremes[key][index][:low] > value
              extremes[key][index][:high] = value if extremes[key][index][:high] < value
            end
          end
        end
      end
    end

    def normalize_samples(samples, extremes)
      samples.map do |sample|
        {}.tap do |normalized_sample|
          sample.keys.each do |key|
            normalized_sample[key] = []
            sample[key].each_with_index do |value, index|
              range = extremes[key][index][:high] - extremes[key][index][:low]
              normalized_sample[key] << (value - extremes[key][index][:low]) / range
            end
          end
        end
      end
    end

    def denormalize_samples(samples, extremes)
      samples.map do |sample|
        {}.tap do |denormalized_sample|
          sample.keys.each do |key|
            denormalized_sample[key] = []
            sample[key].each_with_index do |value, index|
              range = extremes[key][index][:high] - extremes[key][index][:low]
              denormalized_sample[key] << (value * range) + extremes[key][index][:low]
            end
          end
        end
      end
    end

    def denormalize_output(output, extremes)
      [].tap do |denormalized_output|
        output.each_with_index do |value, index|
          range = extremes[:output][index][:high] - extremes[:output][index][:low]
          denormalized_output << (value * range) + extremes[:output][index][:low]
        end
      end
    end
end

nn = NN.new
nn.run
