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
    nomalized_training_data = normalize_samples(@training_data, @data_extremes)
    @neural_net = NeuralNet.new(nomalized_training_data)

    puts 'Training ...'
    @neural_net.train(100)

    puts 'Trying it out!'
    normalized_testing_data = normalize_samples(@testing_data, @data_extremes)

    errors = []
    normalized_testing_data.each do |normalized_test_datum|
      forward_propogation_output = @neural_net.forward_propogate(normalized_test_datum[:input]).map { |output| output.round(5) }
      errors << @neural_net.compute_error(normalized_test_datum[:output]).reduce(:+)

      pp denormalize_output(normalized_test_datum[:output], @data_extremes)
      pp denormalize_output(forward_propogation_output, @data_extremes)
      pp '-----'
    end

    pp 'Errors:'
    pp errors
    pp errors.reduce(:+)
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
