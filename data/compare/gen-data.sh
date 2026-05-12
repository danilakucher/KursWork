#!/usr/bin/bash

# This script must be run in data/compare directory!

_ec=0
SUCCESS=$((_ec++))
EC_NORD=$((_ec++))
EC_NOPRG=$((_ec++))
EC_NOPRB=$((_ec++))
EC_NOIC=$((_ec++))
EC_NOMODEL=$((_ec++))
EC_CDFAILED=$((_ec++))
EC_PROGFLD=$((_ec++))

# configure parameters:
# - model :: used model, possible values: sun|sn[|earth]
# - prob :: computed probability: e-e, e-mu, e-tau, mu-e, mu-mu, mu-tau[, tau-e, tau-mu, tau-tau]
# - NEparts :: number of magnitude parts (energy), might be ODD number!
# - Nfparts :: number of factor parts, must be ODD number!
# - E1,E2 :: low and high energy: in MeV, use scientific format, eg 1.03e4
# - born :: where be born: in|out
# - mixAng :: mixing angle: s12|s13|s23
# - fa, fb :: the variation factors, fraction from orinigal, eg 0.9 and 1.1 (default).

declare -A probs
declare -A iconds

probs=(
  ["e-e"]="prob-e-e.lua"
  ["e-mu"]="prob-e-mu.lua"
  ["mu-e"]="prob-mu-e.lua"
  ["mu-mu"]="prob-mu-mu.lua"
  ["tau-e"]="prob-tau-e.lua"
  ["tau-mu"]="prob-tau-mu.lua"
)

iconds=(
  ["e"]="e-ic.lua"
  ["mu"]="mu-ic.lua"
  ["tau"]="tau-ic.lua"
)

RUNDIR=../../magexp/bin
DATADIR=../../data/compare

prog="m4-tol"

model="sun"
xtheta=0.1
NEparts=521
E1="1.00e-3"
E2="1.00e7"

model_data="${model}-out.lua"

_err()
{
  echo "ОШИБКА: $*"
}

if [[ ! -d ${RUNDIR} ]]; then
  _err "сценарию требует каталог ${RUNDIR}!"
  exit ${EC_NORD}
fi

if [[ ! -e ${RUNDIR}/${prog} ]]; then
  _err "сценарию требуется программа ${prog} в каталоге ${RUNDIR}!"
  exit ${EC_NOPRG}
fi

for k in "${!probs[@]}"
do
  if [[ ! -e ${RUNDIR}/${probs[${k}]} ]]; then
    _err "сценарию требует файл ${probs[${k}]} для расчёта вероятности, он должен быть в каталоге ${RUNDIR}"
    exit ${EC_NOPRB}
  fi
done

for k in "${!iconds[@]}"
do
  if [[ ! -e ${RUNDIR}/${iconds[${k}]} ]]; then
    _err "сценарию требует файл ${iconds[${k}]} для расчёта вероятности, он должен быть в каталоге ${RUNDIR}"
    exit ${EC_NOIC}
  fi
done

if [[ ! -e ${RUNDIR}/${model_data} ]]; then
  _err "сценарию требуется файл ${model_data} с данными модели."
  exit ${EC_NOMODEL}
fi

cd "${RUNDIR}" ||
{
  _err "невозможно перейти в каталог '${RUNDIR}'"
  exit ${EC_CDFAILED}
}

fdata="/tmp/data.tmp"

_Xe=("e-e" "mu-e" "tau-e")
_Xmu=("e-mu" "mu-mu" "tau-mu")

for chan in "${_Xe[@]}"
do
  ic_data="${chan/-*}-ic.lua"
  prb=${probs["${chan}"]}
  datf="${DATADIR}/${chan}.dat"
  for i in $(seq 0 1 $((NEparts-1)))
  do
    ./${prog} ${model_data} -c "Ep1=math.log(${E1})/math.log(10);Ep2=math.log(${E2})/math.log(10);d=(Ep2-Ep1)/(${NEparts}-1);E=math.exp((Ep1+${i}*d)*math.log(10));xtheta=${xtheta}" "${ic_data}" "${prb}" > "${fdata}" || {
      _err "выполнение '${prog}' завершилось с ошибкой"
      exit ${EC_PROGFLD}
    }
    read -ra dat <<< "$(grep -v '^#' ${fdata})"
    echo "${dat[0]}  ${dat[1]}  ${dat[2]}" >> "${datf}"
  done
done

for chan in "${_Xmu[@]}"
do
  ic_data="${chan/-*}-ic.lua"
  prb=${probs["${chan}"]}
  datf="${DATADIR}/${chan}.dat"
  echo "# E  prob" > "${datf}"
  for i in $(seq 0 1 $((NEparts-1)))
  do
    ./${prog} ${model_data} -c "Ep1=math.log(${E1})/math.log(10);Ep2=math.log(${E2})/math.log(10);d=(Ep2-Ep1)/(${NEparts}-1);E=math.exp((Ep1+${i}*d)*math.log(10));xtheta=${xtheta}" "${ic_data}" "${prb}" > "${fdata}" || {
      _err "выполнение '${prog}' завершилось с ошибкой"
      exit ${EC_PROGFLD}
    }
    read -ra dat <<< "$(grep -v '^#' ${fdata})"
    echo "${dat[1]}  ${dat[2]}" >> "${datf}"
  done
done

exit ${SUCCESS}
# vim: ts=2 et tw=120
