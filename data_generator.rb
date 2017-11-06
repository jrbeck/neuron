class DataGenerator
  def initialize(sample_size)
    @sample_size = sample_size
  end

  def generate
    samples = []
    @sample_size.times do
      input = generate_input
      samples << {
        input: input,
        output: generate_output(input)
      }
    end
    samples
  end

  private
    # BINARY -> DECIMAL
    # def generate_input
    #   input = Array.new(3) { rand(0..1).to_f }
    # end
    #
    # def generate_output(input)
    #   output = Array.new(8, 0.0)
    #   output[input[0] + (2 * input[1]) + (4 * input[2])] = 1.0
    #   output
    # end

    # SUM IS POSITIVE?
    def generate_input
      input = Array.new(3) { rand - 0.5 }
    end

    def generate_output(input)
      sum = input.reduce(:+)
      if sum <= 0
        [0.0]
      else
        [1.0]
      end
    end
end
