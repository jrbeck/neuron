require 'pp'
load 'data_generator.rb'
load 'sample_data.rb'
load 'sample_normalizer.rb'
load 'neural_net.rb'
load 'monkey_trainer.rb'
load 'monkey_player.rb'

class NN
  TRAINING_EPOCHS = 200
  HIDDEN_LAYER_SIZES = [3].freeze
  LEARNING_RATE = 0.25
  NORMALIZE = true

  def initialize
  end

  def monkey_test
    monkey_trainer = MonkeyTrainer.new
    # monkey_trainer.connect
    pp monkey_trainer.generate_training_data
    # monkey_trainer.disconnect
  end

  def monkey_play
# state = {:input_size=>2,
#  :output_size=>1,
#  :hidden_layer_sizes=>[4, 4],
#  :learning_rate=>0.2,
#  :hidden_layers=>
#   [{:neurons=>
#      [{:weights=>[3.517431951023803, -3.1331455339832397]},
#       {:weights=>[-0.24607003449896633, 5.723503869202239]},
#       {:weights=>[-1.2528651991483428, 1.4598271093846316]},
#       {:weights=>[1.761849440182539, -0.8824084551804674]}]},
#    {:neurons=>
#      [{:weights=>
#         [-3.3143419429172916,
#          2.094207503448846,
#          1.302494577350814,
#          -1.8305384325999055]},
#       {:weights=>
#         [0.26271739817054984,
#          0.42757909510264763,
#          0.7917930796226486,
#          -0.05040772184974377]},
#       {:weights=>
#         [0.49272955220952275,
#          0.22198651100481898,
#          0.8783174290251247,
#          -0.4027346969639195]},
#       {:weights=>
#         [2.9347817796453515,
#          -3.604430275109283,
#          -1.5801349667130375,
#          -0.3953351509842066]}]}],
#  :output_layer=>
#   {:neurons=>
#     [{:weights=>
#        [4.791016275944713,
#         0.12008864179513946,
#         0.08995951772799934,
#         -5.716579975773272]}]}}
#
# normalizer_extremes = {:input=>{:low=>62.123, :high=>486.851},
#  :output=>{:low=>0.2042660599999389, :high=>0.848380622928409}}

state = {:input_size=>2,
 :output_size=>2,
 :hidden_layer_sizes=>[4, 3],
 :learning_rate=>0.3,
 :hidden_layers=>
  [{:neurons=>
     [{:weights=>[-0.6870821023384082, 2.351812772518145]},
      {:weights=>[4.777953070022533, 0.3586540905664427]},
      {:weights=>[0.6181631631475201, 4.600095473038721]},
      {:weights=>[2.1348982336948565, -1.676155496561501]}]},
   {:neurons=>
     [{:weights=>
        [1.42392495923198,
         -1.5621647621570722,
         1.957571069781991,
         -0.8819464855426091]},
      {:weights=>
        [1.1345986243328474,
         -1.1275598945136371,
         1.5985767547263576,
         -0.036570549370846035]},
      {:weights=>
        [-1.8631391630653122,
         3.4288949320385846,
         -1.9558843135789559,
         1.1415932374972935]}]}],
 :output_layer=>
  {:neurons=>
    [{:weights=>[2.0094054824533885, 1.5608435492450288, -4.127830367787505]},
     {:weights=>
       [-2.4873066759832905, -1.8760892427937796, -5.398947582708872]}]}}
# SAMPLE NORMALIZER EXTREMES --------------------------
normalizer_extremes = {:input=>
  [{:low=>50.659, :high=>499.355, :range=>448.696},
   {:low=>50.069, :high=>498.517, :range=>448.448}],
 :output=>
  [{:low=>0.16922513153845087,
    :high=>1.5637717862865594,
    :range=>1.3945466547481087},
   {:low=>200.0, :high=>200.0, :range=>0.0}]}


    monkey_player = MonkeyPlayer.new(state, normalizer_extremes)
    monkey_player.play(10)
  end

  def run
    # @training_data = SampleData.training_data
    # @testing_data = SampleData.testing_data

    data_generator = DataGenerator.new
    @training_data = data_generator.training_data(1000)
    @testing_data = data_generator.testing_data(15)

    # load 'monkey_data.rb'
    # @training_data = MonkeyData.training_data
    # @testing_data = MonkeyData.testing_data


    if NORMALIZE
      @sample_normalizer = SampleNormalizer.new(samples: @training_data + @testing_data)
      training_data = @sample_normalizer.normalize_all(@training_data)
      testing_data = @sample_normalizer.normalize_all(@testing_data)
    else
      @sample_normalizer = SampleNormalizer.new
      training_data = @training_data
      testing_data = @testing_data
    end

    neural_net_options = {
      input_size: @training_data.first[:input].length,
      output_size: @training_data.first[:output].length,
      hidden_layer_sizes: HIDDEN_LAYER_SIZES,
      learning_rate: LEARNING_RATE
    }

    errors = configured_run(training_data, TRAINING_EPOCHS, testing_data, neural_net_options)

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
    puts "NORMALIZE: #{NORMALIZE}"
    errors = []
    testing_data.each do |testing_datum|
      pp '============================================='
      forward_propagation_output = neural_net.forward_propagate(testing_datum[:input])
      error = neural_net.compute_error(testing_datum[:output]).map { |error| error * error }.reduce(:+)
      errors << error

      pp testing_datum[:input]
      if NORMALIZE
        pp "test: #{@sample_normalizer.denormalize(testing_datum[:output], :output).map { |value| value.round(2) }}"
        pp "nn: #{@sample_normalizer.denormalize(forward_propagation_output, :output).map { |value| value.round(2) }}"
      else
        pp "test: #{testing_datum[:output].map { |value| value.round(2) }}"
        pp "nn: #{forward_propagation_output.map { |value| value.round(2) }}"
      end
      pp "error: #{error}"
      pp '------------------------'
    end

    puts 'NEURAL NET STATE --------------------------'
    pp neural_net.state

    puts 'SAMPLE NORMALIZER EXTREMES --------------------------'
    pp @sample_normalizer.sample_extremes
    errors
  end
end

nn = NN.new

case ARGV[0]
when 'train'
  nn.monkey_test
when 'play'
  nn.monkey_play
else
  nn.run
end
