require 'csv'

require './lib/util/splitter_tdt'
require './lib/util/splitter_mb'
require './lib/util/normalization'

require './lib/util/matrix_math'
require './lib/util/generators'
require './lib/util/activations'
require './lib/util/costs'

require './lib/nn/nn'

class Main
  def train(data_x, data_y, batch_size, epochs, cost_function, optimizer, learning_rate, decay_rate, iterations, momentum, regularization_l2)
    nn = NN.new(data_x[0].size)
    nn.add_nn(16, 'leaky_relu')
    #nn.add_nn(64, 'leaky_relu', 0.7)
    nn.add_nn(1, 'leaky_relu')
    nn.compile(optimizer, cost_function, learning_rate, decay_rate, iterations, momentum, regularization_l2)
    tmp = nn.fit(data_x, data_y, batch_size, epochs)
    nn.save_weights('./weights.msh')
    nn.save_architecture('./arch.msh')
    tmp
  end

  def predict(data_x, data_y, batch_size, index_of_parameter)
    nn = NN.new(data_x[0].size)
    nn.load_architecture('./arch.msh')
    nn.load_weights('./weights.msh')
    nn.predict(data_x, data_y, batch_size, index_of_parameter)
  end
end

tmp = []
CSV.foreach('./dataset/winequality-white.csv', { :col_sep => ';' }) do |row|
  tmp << row
end

data_x = []
data_y = []
i = 0
while i < tmp.size
  data_x[i] = []
  j = 0
  while j < tmp[0].size
    if j == tmp[0].size - 1
      data_y << tmp[i][j].to_f
    else
      data_x[i][j] = tmp[i][j].to_f
    end
    j += 1
  end
  i += 1
end

#gen = Generators.new
#data_y = gen.one_hot_vector(data_y)

stdt = SpliterTDT.new(data_x, data_y)
train_set = stdt.train
dev_set = stdt.dev
test_set = stdt.dev

train_set_x = train_set[0]
train_set_y = train_set[1]

batch_size = 32

dev_set_x = dev_set[0]
dev_set_y = dev_set[1]
test_set_x = test_set[0]
test_set_y = test_set[1]

n = Normalization.new(true, train_set_x)
train_set_x = n.normalize_x(train_set_x)
dev_set_x = n.normalize_x(dev_set_x)

epochs = 10
optimizer = 'Adam'
cost_function = 'mse'
learning_rate = 0.001
regularization_l2 = 0.1
iterations = 20
decay_rate = 1
momentum = [0.9, 0.999, 10**-8]

main = Main.new
main.train(train_set_x, train_set_y, batch_size, epochs, cost_function, optimizer, learning_rate, decay_rate, iterations, momentum, regularization_l2)

index_of_parameter = 5
t = main.predict(dev_set_x, dev_set_y, batch_size, index_of_parameter)
