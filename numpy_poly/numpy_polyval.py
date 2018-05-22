#! /usr/bin/env python3

# Reference site:https://docs.scipy.org/doc/numpy-1.13.0/reference/generated/numpy.polynomial.polynomial.polyval.html#numpy.polynomial.polynomial.polyval
#%%
import numpy as np
from numpy.polynomial.polynomial import polyval

#%%
print(polyval(1,[1,2,3]))

#%%
a = np.arange(4).reshape(2,2)
print(a)
polyval(a,[1,2,3])

#%%
coef = np.arange(4).reshape(2,2)
coef
polyval([1,2],coef,tensor=True)
print("tensor=False")
polyval([1,2],coef,tensor=False)
