# test_samples = [
#   { input: [1, 1, 5, 5] },
#   { input: [3, 3, 3, 3] },
# ]
#
# test_input = [1, 2, 3, 4]
#
# sn = SampleNormalizer.new(samples: test_samples)
# x = sn.normalize(test_input, :input)
# y = sn.denormalize(x, :input)
#
# p x
# p y

class SampleNormalizer
  def initialize(samples: nil, extremes: nil)
    if samples
      samples.first.each_key do |key|
        sample_extremes[key] = find_extremes(samples, key)
      end
    elsif extremes
      @sample_extremes = extremes
    else
      @null_normalizer = true
    end
  end

  def normalize(values, key)
    return values if @null_normalizer

    # range = sample_extremes[key][:high] - sample_extremes[key][:low]
    [].tap do |normalized_values|
      values.each_with_index do |value, index|
        if sample_extremes[key][index][:range] == 0.0
          normalized_values << 0.0
        else
          normalized_values << (value - sample_extremes[key][index][:low]) / sample_extremes[key][index][:range]
        end
      end
    end
  end

  def denormalize(values, key)
    return values if @null_normalizer

    # range = sample_extremes[key][:high] - sample_extremes[key][:low]
    [].tap do |denormalized_values|
      values.each_with_index do |value, index|
        denormalized_values << (value * sample_extremes[key][index][:range]) + sample_extremes[key][index][:low]
      end
    end
  end

  def normalize_all(samples)
    return samples if @null_normalizer

    [].tap do |normalized_samples|
      samples.each do |sample|
        normalized_samples << {}.tap do |normalized_sample|
          sample_extremes.each_key do |key|
            normalized_sample[key] = normalize(sample[key], key)
          end
        end
      end
    end
  end

  def sample_extremes
    @sample_extremes ||= {}
  end

  private
    def find_extremes(samples, key)
      extremes = Array.new(samples.first[key].size) do
        { low: 10_000_000, high: -10_000_000 }
      end
      samples.each do |sample|
        sample[key].each_with_index do |value, index|
          extremes[index][:low] = value.to_f if value < extremes[index][:low]
          extremes[index][:high] = value.to_f if value > extremes[index][:high]
        end
      end
      compute_ranges(extremes)
      extremes
    end

    def compute_ranges(extremes)
      extremes.map do |extreme|
        extreme[:range] = extreme[:high] - extreme[:low]
      end
    end
end
