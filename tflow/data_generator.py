import numpy as np

class DataGenerator:
  def training_data(self, num_samples=1000):
    return self.generate(num_samples)

  def testing_data(self, num_samples=10):
    return self.generate(num_samples)

  def generate(self, num_samples):
    samples = []
    for i in range(num_samples):
      input = self.generate_input()
      sample = { 'input': input, 'output': self.generate_output(input) }
      samples.append(sample)
    return samples

  def samples_to_keras(self, samples):
    data = []
    labels = []
    for sample in samples:
      data.append(sample['input'])
      labels.append(sample['output'])
    return np.array(data), np.array(labels)
    

  # QUADRANT
  def generate_input(self):
    return np.random.random(2) - [0.5, 0.5]

  def generate_output(self, input):
    if input[0] >= 0:
      if input[1] >= 0:
        return [1.0, 0.0, 0.0, 0.0]
      else:
        return [0.0, 0.0, 0.0, 1.0]
    else:
      if input[1] >= 0:
        return [0.0, 1.0, 0.0, 0.0]
      else:
        return [0.0, 0.0, 1.0, 0.0]
