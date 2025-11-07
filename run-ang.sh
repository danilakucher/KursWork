#!/usr/bin/bash

# configure parameters:
# - model :: used model
# - prob :: computed probability: e-e, etc
# - NEparts :: number of magnitude parts (energy)
# - Nfparts :: number of factor parts 
# - E1,E2 :: low and high energy
# - born :: where be born
# - mixAng :: mixing angle: s12, etc

export LC_NUMERIC=en_US.UTF-8

fa=0.9
fb=1.1

declare -A Pr

Pr=(
  ["e-e"]="survprob.lua"
  ["e-mu"]="prob-e-mu.lua"
  ["mu-e"]="prob-mu-e.lua"
  ["mu-mu"]="surv-mu.lua"
)

model="sun"
fdata="/tmp/data-${model}.tmp"
datadir="$PWD/data"
bindir="$PWD/magexp/bin"
prog=m4-tol
prob="e-mu"
NEparts=101
Nfparts=101

born="in"
mixAng="s12"

E1="1.00e-3"
E2="1.00e7"

if [ ! -d "${datadir}" ]; then
  mkdir "${datadir}"
fi

if [ ! -d "${bindir}" ]; then
  echo "ОШИБКА: нет каталога '${bindir}'"
  exit 1
fi


if [ ! -e "${bindir}/${prog}" ]; then
  echo "ОШИБКА: нет расчетной программы ${prog}"
  exit 5
fi

[[ -n $1 ]] &&
{
  [[ -f $1 ]] &&
  {
    source "$1"
  }
}

prb=Pr["${prob}"]
model_data=${model}.lua

[[ ! -e "${bindir}/${prb}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные модели, которые хранятся в файле '${prb}'"
  exit 7
}

Ne="${NEparts}"
Nf="${Nfparts}"

(( Nf/2 != (Nf-1)/2 )) &&
{
  echo "ОШИБКА: количество шагов для фактора угла должно быть нечетным, Nf=${Nf}"
  exit 4
}

tdir=${datadir}/${model}_${born}_${mixAng}/"NexNf=${Ne}x${Nf}"
mkdir -p "${tdir}"

# (fa=0.9; fb=1.1; Nf=191; python -c "import numpy; [print(el) for el in numpy.linspace(${fa}, ${fb}, ${Nf})]")
# (LC_NUMERIC=en_US.UTF-8; fa=0.9; fb=1.1; Nf=191; i=0; for f in $(seq ${fa} $(echo "scale=20; fa=${fa}; fb=${fb}; nf=${Nf}; dfk=(fb-fa)/(nf-1); print(dfk)" | bc) ${fb}); do { printf "%s_%03d\n" ${f} ${i}; echo "i=${i}; ((i++));}; done)

cd "${bindir}"
cnt=0
for ex in $(seq ${fa} $(echo "scale=20 ; fa=${fa} ; fb=${fb} ; nf=${Nf} ; print((fb-fa)/(nf-1))" | bc) ${fb})
do
  printf -v datf "%s/${model}_${born}_${mixAng}_id%03d.dat" "${tdir}" ${cnt}
  echo -n "" > "${datf}"
  for i in $(seq 0 1 $((Ne-1)))
  do
    ./${prog} ${model_data} -c "Ep1=math.log(${E1})/math.log(10);Ep2=math.log(${E2})/math.log(10);d=(Ep2-Ep1)/(${Ne}-1);E=math.exp((Ep1+${i}*d)*math.log(10));${mixAng}=${ex}*${mixAng}" ${prb} > "${fdata}"
    dat=($(grep -v '^#' "${fdata}"))
    ang=$(grep "#*ex.*${mixAng}" "${fdata}" | sed -e 's@.*=@@')
    echo "${dat[0]}  ${dat[1]}  ${dat[2]} ${ang} ${ex}" >> "${datf}"
  done
  ((cnt++))
done
# vim: ts=2 et tw=120
