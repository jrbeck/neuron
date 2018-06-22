class Neuron
  attr_reader :state

  def initialize(input_size)
    @state = {}
    @state[:input_size] = input_size
    @state[:weights] = Array.new(input_size) { 1.0 - (2.0 * rand) }
    # @state[:weights] = Array.new(input_size) { rand }
  end

  def compute(activated_inputs)
    fail 'incorrect input size' if activated_inputs.size != @state[:input_size]
    weighted_inputs = []
    @state[:input_size].times do |index|
      # sum = @state[:weights][index] # BIAS??
      # sum = 1 # BIAS??
      # sum = 0
      # activated_inputs.each do |activated_input|
      #   sum += activated_input * @state[:weights][index]
      # end
      # weighted_inputs << sum
      weighted_inputs << @state[:weights][index] * activated_inputs[index]
    end
    @output = weighted_inputs.reduce(:+)
  end

  def update_weights(activated_inputs, next_layer_sensitivity)
    activated_inputs.each_with_index do |activated_input, input_index|
      gradient_component = activated_input * next_layer_sensitivity
      @state[:weights][input_index] -= 0.01 * gradient_component
    end
  end

end
