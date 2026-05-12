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


def _plotDat(E, d0, d1, d2, figtitle, labs, figname):
  """
  Plot data.
  """

  fig, ax = plt.subplots(layout = 'constrained')

  ax.set_title(figtitle)

  ax.set_xscale('log')

  ax.plot(E, d0, r'.', label=labs[0])
  ax.plot(E, d1, r'.', label=labs[1])
  ax.plot(E, d2, r'.', label=labs[2])
  
  ax.grid(True)

  hdl, lgs = ax.get_legend_handles_labels()
  ax.legend(hdl, lgs)

  fig.align_labels()

  fig.savefig(figname)


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

  _labs=(r"\(\nu_{e}\to\nu_{e}\)", r"\(\nu_{\mu}\to\nu_{e}\)", r"\(\nu_{\tau}\to\nu_{e}\)")

  _plotDat(E, r0, r1, r2,
           r"Relative probabilities detecting \(\nu_{e}\) for initial \(X\)",
           _labs,
           "plot-relProb-X-e.pdf")

  _plotDat(E, e0, e1, e2,
           r"Probabilities detecting \(\nu_{e}\) for initial \(X\)",
           _labs,
           "plot-Prob-X-e.pdf")



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

  _labs = (r"\(\nu_{e}\to\nu_{\mu}\)", r"\(\nu_{\mu}\to\nu_{\mu}\)", r"\(\nu_{\tau}\to\nu_{\mu}\)")

  _plotDat(E, r0, r1, r2,
           r"Relative probabilities detecting \(\nu_{\mu}\) for initial \(X\)",
           _labs,
           "plot-relProb-X-mu.pdf")

  _plotDat(E, e0, e1, e2,
           r"Probabilities detecting \(\nu_{\mu}\) for initial \(X\)",
           _labs,
           "plot-Prob-X-mu.pdf")


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
