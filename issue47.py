"""Back-propagation is being teached there

This time it's a linear Network with 6 input signals, 3 hidden neurones and 7 outputs signals.
"""

import torch
from torch import nn

SCENARIOS = [
        ([1, 1, 1, 0, 0, 0], [.9, .9, .9, .1, .1, .1, .1]),
        ([0, 1, 0, 1, 1, 0], [.1, .1, .1, .9, .9, .9, .1]),
        ([1, 0, 0, 1, 0, 1], [.1, .1, .1, .9, .1, .9, .9])
]

class Issue47(nn.Model):
    def __init__(self):
        super(Issue47, self).__init__()
        self.hidden = nn.Linear(6, 3)
        self.sig1 = torch.sigmoid()
        self.output = nn.Linear(3, 7)
        self.sig2 = torch.sigmoid()

    def forward(self, xb):
        xb = self.hidden(xb)
        xb = self.sig1(xb)
        xb = self.output(xb)
        xb = self.sig1(xb)
        return xb


