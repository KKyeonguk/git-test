import numpy as np
import torch

a = torch.FloatTensor([1, 2, 3])
b = torch.FloatTensor([[1, 2, 3]])
c = torch.FloatTensor([[1, 2], [3, 4]])
d = torch.FloatTensor([[[1, 2], [3, 4]]])

print(a)
print(b)
print(c)
print(d)

print("Dim Of a : ", a.ndim)
print("Shape Of a : ", a.shape)

print("Dim Of b : ", b.ndim)
print("Shape Of b : ", b.shape)

print("Dim Of c : ", c.ndim)
print("Shape Of c : ", c.shape)

print("Dim Of d : ", d.ndim)
print("Shape Of d : ", d.shape)
