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
    def generate_input
      Array.new(5) { rand(0..9) }
    end

    def generate_output(input)
      [input.reduce(:+)]
    end
end
