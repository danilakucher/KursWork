#!/usr/bin/python

import sys
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt

plt.rcParams["text.usetex"] = True
plt.rcParams["text.latex.preamble"] = (
  r"\usepackage[conf=matplotlib]{isu-th3}"
)


data = {
  'e-e':    "e-e/sun_out_par1.dat",
  'mu-e':   "mu-e/sun_out_s12.dat", # sun_out_s13.dat has the same data, almost...
  'tau-e':  "tau-e/sun_out_par1.dat",
  'e-mu':   "e-mu/sun_out_par1.dat",
  'mu-mu':  "mu-mu/sun_out_s12.dat",
  'tau-mu': "tau-mu/sun_out_par1.dat"
}


def _plotXe():
  """
  Plot graphs of relative probability of passing X through Sun while detecting
  e.
  """

  _chan = ["e-e", "mu-e", "tau-e"]

  # File MUST exist.
  for ch in _chan:
    if not Path(data[ch]).exists:
      print(f"[ERROR] required data file '{data[ch]}' is missing.")
      sys.exit(1)

  X0 = np.loadtxt(data[_chan[0]], unpack=True)
  X1 = np.loadtxt(data[_chan[1]], unpack=True)
  X2 = np.loadtxt(data[_chan[2]], unpack=True)

  e0 = X0[2]
  e1 = X1[2]
  e2 = X2[2]
  sm = e0 + e1 + e2
  r0 = e0/sm
  r1 = e1/sm
  r2 = e2/sm

  E = X0[1]

  fig, ax = plt.subplots(layout = 'constrained')

  ax.set_title("Relative probability for passing X while detecting e")

  ax.set_xscale('log')

  ax.plot(E, r0, r'.', label=r"\(\nu_{e}\to\nu_{e}\)")
  ax.plot(E, r1, r'.', label=r"\(\nu_{\mu}\to\nu_{e}\)")
  ax.plot(E, r2, r'.', label=r"\(\nu_{\tau}\to\nu_{e}\)")
  
  ax.grid(True)

  hdl, lgs = ax.get_legend_handles_labels()
  ax.legend(hdl, lgs)

  fig.align_labels()

  fig.savefig(r"plot-relProb-X-e.pdf")


def _plotXmu():
  """
  Plot graphs of relative probability of passing X through Sun while detecting
  mu.
  """

  _chan = ["e-mu", "mu-mu", "tau-mu"]

  # File MUST exist.
  for ch in _chan:
    if not Path(data[ch]).exists:
      print(f"[ERROR] required data file '{data[ch]}' is missing.")
      sys.exit(1)

  X0 = np.loadtxt(data[_chan[0]], unpack=True)
  X1 = np.loadtxt(data[_chan[1]], unpack=True)
  X2 = np.loadtxt(data[_chan[2]], unpack=True)

  e0 = X0[2]
  e1 = X1[2]
  e2 = X2[2]
  sm = e0 + e1 + e2
  r0 = e0/sm
  r1 = e1/sm
  r2 = e2/sm

  E = X0[1]

  fig, ax = plt.subplots(layout = 'constrained')

  ax.set_title("Relative probability for passing X while detecting e")

  ax.set_xscale('log')

  ax.plot(E, r0, r'.', label=r"\(\nu_{e}\to\nu_{\mu}\)")
  ax.plot(E, r1, r'.', label=r"\(\nu_{\mu}\to\nu_{\mu}\)")
  ax.plot(E, r2, r'.', label=r"\(\nu_{\tau}\to\nu_{\mu}\)")
  
  ax.grid(True)

  hdl, lgs = ax.get_legend_handles_labels()
  ax.legend(hdl, lgs)

  fig.align_labels()

  fig.savefig(r"plot-relProb-X-mu.pdf")


def main():
  """
  Process data files, plot graphs.
  """

  # plot X-e
  _plotXe()

  # plot X-mu
  _plotXmu()


if __name__ == "__main__":
  try:
    main()
  except KeyboardInterrupt:
    sys.exit("Interrupted by user")
