class DataGenerator
  def training_data(num_samples = 1000)
    generate(num_samples)
  end

  def testing_data(num_samples = 10)
    generate(num_samples)
  end

  def generate(num_samples)
    samples = []
    num_samples.times do
      input = generate_input
      samples << {
        input: input,
        output: generate_output(input)
      }
    end
    samples
  end

  private
    # ------------------------------------------------------------------------------------------
    # BINARY -> DECIMAL (discrete output)
    # def generate_input
    #   input = Array.new(3) { rand(0..1).to_f }
    # end

    # def generate_output(input)
    #   output = Array.new(8, 0.0)
    #   output[input[0] + (2 * input[1]) + (4 * input[2])] = 1.0
    #   output
    # end

    # ------------------------------------------------------------------------------------------
    # BINARY -> DECIMAL (continuous output)
    # def generate_input
    #   input = Array.new(3) { rand(0..1).to_f }
    # end

    # def generate_output(input)
    #   [(input[0] + (2 * input[1]) + (4 * input[2])).to_f]
    # end

    # ------------------------------------------------------------------------------------------
    # SUM IS POSITIVE?
    # def generate_input
    #   input = Array.new(3) { rand - 0.5 }
    # end

    # def generate_output(input)
    #   sum = input.reduce(:+)
    #   if sum <= 0
    #     [0.0]
    #   else
    #     [1.0]
    #   end
    # end

    # ------------------------------------------------------------------------------------------
    # QUADRANT
    # def generate_input
    #   input = Array.new(2) { rand - 0.5 }
    # end

    # def generate_output(input)
    #   if input[0] >= 0
    #     if input[1] >= 0
    #       [1.0, 0.0, 0.0, 0.0]
    #     else
    #       [0.0, 1.0, 0.0, 0.0]
    #     end
    #   else
    #     if input[1] >= 0
    #       [0.0, 0.0, 1.0, 0.0]
    #     else
    #       [0.0, 0.0, 0.0, 1.0]
    #     end
    #   end
    # end

    # ------------------------------------------------------------------------------------------
    # MULTIPLY
    def generate_input
      input = Array.new(2) { rand(2..100).to_f }
    end

    def generate_output(input)
      output = [input.reduce(:*)]
    end
end
