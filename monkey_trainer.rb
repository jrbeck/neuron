require 'pp'
require 'socket'

load 'monkey_client.rb'

class MonkeyTrainer
  def initialize
    @monkey_client = MonkeyClient.new
  end

  def generate_training_data(hits_target = 100)
    @monkey_client.connect
    @monkey_client.enter_training(fast: true)

    results = []
    hits = 0
    while hits < hits_target
      target_info = @monkey_client.get_target_info
      # angle = prng.rand(3.14 * 0.25) + (3.14 * 0.25)
      # force = 50.0 # prng.rand(50.0) + 50.0
      # force = prng.rand(50.0) + 50.0
      angle = prng.rand(3.14)
      force = 200.0
      shot_response = @monkey_client.send_shot_info(angle, force)
      if shot_response == 'HIT'
        hits += 1
        p "#{hits} / #{hits_target} --------------------"
        pp({ input: target_info, output: [angle, force] })
        # results << { input: target_info, output: [angle] }
        results << { input: target_info, output: [angle, force] }
      end
      @monkey_client.send_reset
    end

    @monkey_client.disconnect
    save_results results
    results
  end

  private
    def prng
      @prng ||= Random.new
    end

    def save_results(results)
      return unless results.size >= 10
      test_data_size = results.size / 10
      training_data_size = results.size - test_data_size

      File.open('monkey_data.rb', 'w') do |file|
        file.write "class MonkeyData\n"

        file.write "  def self.testing_data\n"
        file.write "    [\n"
        test_data_size.times do |i|
          file.write "      #{results[i]},\n"
        end
        file.write "    ]\n"
        file.write "  end\n"

        file.write "\n"

        file.write "  def self.training_data\n"
        file.write "    [\n"
        training_data_size.times do |i|
          file.write "      #{results[i + test_data_size]},\n"
        end
        file.write "    ]\n"
        file.write "  end\n"

        file.write "end\n"
      end
    end
end
