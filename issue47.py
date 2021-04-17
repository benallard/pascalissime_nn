"""Back-propagation is being teached there

This time it's a linear Network with 6 input signals, 3 hidden neurones and 7 outputs signals.
"""
import random

import torch
from torch import nn

SCENARIOS = [
        ([1, 1, 1, 0, 0, 0], [.9, .9, .9, .1, .1, .1, .1]),
        ([0, 1, 0, 1, 1, 0], [.1, .1, .1, .9, .9, .9, .1]),
        ([1, 0, 0, 1, 0, 1], [.1, .1, .1, .9, .1, .9, .9])
]

LEARNING_RATE = 1.0
N_EPOCHS = 500

class Issue47(nn.Module):
    def __init__(self):
        super(Issue47, self).__init__()
        self.hidden = nn.Linear(6, 3)
        self.sig1 = nn.Sigmoid()
        self.output = nn.Linear(3, 7)
        self.sig2 = nn.Sigmoid()

    def forward(self, xb):
        xb = self.hidden(xb)
        xb = self.sig1(xb)
        xb = self.output(xb)
        xb = self.sig1(xb)
        return xb



model = Issue47()

loss = nn.MSELoss()
optimizer = torch.optim.SGD(model.parameters(), lr=LEARNING_RATE)

for epoch in range(N_EPOCHS):
    random.shuffle(SCENARIOS)
    totloss = 0
    for input, output in SCENARIOS:
        pred = model(torch.tensor(input, dtype=torch.float))

        l = loss(pred, torch.tensor(output, dtype=torch.float))
        totloss += l.item()

        l.backward()

        optimizer.step()

        optimizer.zero_grad()

    if epoch % 150 == 0:
        print(f'epoch: {epoch}, err: {totloss: 3f}')
    
    if totloss < 0.0005:
        break

print(dict(list(model.named_parameters())))
