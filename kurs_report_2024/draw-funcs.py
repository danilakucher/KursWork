#!/usr/bin/python

import numpy as np
import matplotlib.pyplot as plt

labs = {
  'r1': r'$(\Re{\Psi_{1}^{(1)}}-\Re{\Psi_{1}^{(2)}})/\Re{\Psi_{1}^{(1)}}$',
  'i1': r'$(\Im{\Psi_{1}^{(1)}}-\Im{\Psi_{1}^{(2)}})/\Im{\Psi_{1}^{(1)}}$',
  'r2': r'$(\Re{\Psi_{2}^{(1)}}-\Re{\Psi_{2}^{(2)}})/\Re{\Psi_{2}^{(1)}}$',
  'i2': r'$(\Im{\Psi_{2}^{(1)}}-\Im{\Psi_{2}^{(2)}})/\Im{\Psi_{2}^{(1)}}$',
  'r3': r'$(\Re{\Psi_{3}^{(1)}}-\Re{\Psi_{3}^{(2)}})/\Re{\Psi_{3}^{(1)}}$',
  'i3': r'$(\Im{\Psi_{3}^{(1)}}-\Im{\Psi_{3}^{(2)}})/\Im{\Psi_{3}^{(1)}}$',
  'a1': r'$|\Psi_{1}^{(1)}|^{2}-|\Psi_{1}^{(2)}|^{2}/|\Psi_{1}^{(1)}|^{2}$',
  'a2': r'$|\Psi_{2}^{(1)}|^{2}-|\Psi_{2}^{(2)}|^{2}/|\Psi_{2}^{(1)}|^{2}$',
  'a3': r'$|\Psi_{3}^{(1)}|^{2}-|\Psi_{3}^{(2)}|^{2}/|\Psi_{3}^{(1)}|^{2}$',
  'ph1': r'$(\phi_{1}^{(1)}-\phi_{1}^{(2)})/\phi_{1}^{(1)}$',
  'ph2': r'$(\phi_{2}^{(1)}-\phi_{2}^{(2)})/\phi_{2}^{(1)}$',
  'ph3': r'$(\phi_{3}^{(1)}-\phi_{3}^{(2)})/\phi_{3}^{(1)}$',
  'c1': r'$\sum_{n}\Psi_{n}^2-1$'
}


def draw1b(x, y, labx = 'x', laby = 'y', title = 'data'):
  """
  Draw data and add label for axes.
  """

  fig, ax = plt.subplots()

  ax.plot(x,y)
  ax.set_title(title)
  ax.set_xlabel(labx)
  ax.set_ylabel(laby)


def draw3d(x, y1, y2, yb, yt, laby, title = "data"):
  """
  Draw data with default legend.
  """

  fig, ax = plt.subplots()

  l1, = ax.plot(x, (y1-y2)/y1, '.')
  ax.set_ylim(yb, yt)
  ax.set_title(title)
  ax.set_xlabel(r'$\xi$')
  ax.set_ylabel(laby)
