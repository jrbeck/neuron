load 'monkey_client.rb'

class MonkeyPlayer
  def initialize(state, normalizer_extremes)
    @neural_net = NeuralNet.new(saved_state: state)
    @sample_normalizer = SampleNormalizer.new(extremes: normalizer_extremes)

    @monkey_client = MonkeyClient.new
    @monkey_client.connect
    @monkey_client.enter_training
  end

  def play(num_rounds)
    num_rounds.times do
      target_info = @monkey_client.get_target_info
      normalized_target_info = @sample_normalizer.normalize(target_info, :input)
      nn_ouput = @neural_net.forward_propagate(normalized_target_info)
      denormalized_nn_output = @sample_normalizer.denormalize(nn_ouput, :output)
      angle = denormalized_nn_output[0]
      force = denormalized_nn_output[1]
      shot_response = @monkey_client.send_shot_info(angle, force)
      pp shot_response

      @monkey_client.send_reset
    end

    @monkey_client.disconnect
  end
end
