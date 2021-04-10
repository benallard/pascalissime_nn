"""In this issue, a static network is build to showcase NN
The netword is about 8 x 8 neurons, with as much in the input layer
as the input signal is, and same for output.
"""

import torch
from torch import nn

SIGNAL = [0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.15, 0.20, 0.25,
        0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.65, 0.70, 0.75,
        0.80, 0.80, 0.80, 0.80, 0.80, 0.80, 0.83, 0.80, 0.70, 0.90,
        0.80, 0.80, 0.60, 0.90, 0.40, 0.60, 0.30, 0.10, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.10, 0.25, 0.30, 0.10, 0.20, 0.20, 0.20,
        0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20, 0.20,
]

LAYERS = 7

class Issue46(nn.Module):
    def __init__(self, n_layers):
        super(Issue46, self).__init__()
        self.layers = [nn.Linear(len(SIGNAL), len(SIGNAL)) for i in range(n_layers)]

    def forward(self, xb):
        for layer in self.layers:
            xb = layer(xb)
        return xb

model = Issue46(LAYERS)
out = model.forward(torch.tensor(SIGNAL))
print(out)
