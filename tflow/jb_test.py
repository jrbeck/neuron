import tensorflow as tf
from tensorflow import keras

import numpy as np

import data_generator as dg

data_generator = dg.DataGenerator()
training_samples = data_generator.training_data(1000)
num_test_samples = 10
testing_samples = data_generator.testing_data(num_test_samples)

input_dim = len(training_samples[0]['input'])
num_classes = 4

# optimizer = 'rmsprop'
optimizer = keras.optimizers.SGD(0.1, 0.9, nesterov=True)

model = keras.Sequential()
# model.add(keras.layers.Dense(16))
# model.add(keras.layers.Activation('relu'))
model.add(keras.layers.Dense(4, activation='relu', input_dim=input_dim))
# model.add(keras.layers.Dropout(0.5))
# model.add(keras.layers.Dense(8, activation='relu'))
# model.add(keras.layers.Dropout(0.5))
model.add(keras.layers.Dense(num_classes, activation='sigmoid'))
model.compile(optimizer=optimizer,
              loss='categorical_crossentropy',
              metrics=['accuracy'])

training_data, training_labels = data_generator.samples_to_keras(training_samples)
# training_labels = keras.utils.to_categorical(training_labels, num_classes=num_classes)

testing_data, testing_labels = data_generator.samples_to_keras(testing_samples)
# testing_labels = keras.utils.to_categorical(testing_labels, num_classes=num_classes)

model.fit(training_data, training_labels, epochs=10, batch_size=32)

print(model.get_weights())

score = model.evaluate(testing_data, testing_labels, batch_size=128)
print(model.metrics_names)
print(score)

predictions = model.predict(testing_data)
for i in range(num_test_samples):
  print(i)
  print(np.round(testing_samples[i]['output'], decimals=3))
  print(np.round(predictions[i], decimals=3))