#!/usr/bin/bash

export LC_NUMERIC=en_US.UTF-8

fa=0.9
fb=1.1

model="sun"
fdata="/tmp/data-${model}.tmp"
datadir="$PWD/data"
bindir="$PWD/magexp/bin"
prog=m4-tol
model_data=${model}.lua
# probablt=prob-e-mu.lua
probablt=survprob.lua

mod="in"
par="par1"

Ep1=-3
Ep2=7

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

[[ ! -e "${bindir}/${model_data}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные модели, которые хранятся в файле '${model_data}'"
  exit 6
}

[[ ! -e "${bindir}/${probablt}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные по вероятности, которые хранятся в файле '${probablt}'"
  exit 7
}

(( $# != 3 )) && 
{
  echo "ОШИБКА: сценарий требует 3 аргумента: маркер параметра, количество шагов по энергии, количество шагов параметра"
  echo "Пример: "
  echo "  $0 A|eta 50 5"
  exit 2
}

case $1 in
  "A")
    par="par1"
    ;;
  "eta")
    par="par2"
    fa=0.95
    fb=1.05
    ;;
  *)
    echo "ОШИБКА: нераспознанный маркер: $1"
    exit 3
    ;;
esac

Ne="$2"
Np="$3"

(( Np/2 != (Np-1)/2 )) &&
{
  echo "ОШИБКА: количество шагов для параметра профиля должно быть нечетным, Np=${Np}"
  exit 4
}

E1="$(echo "E1=math.exp(${Ep1}*math.log(10)); print(string.format('%3.2e',E1))" | lua)"
E2="$(echo "E1=math.exp(${Ep2}*math.log(10)); print(string.format('%3.2e',E1))" | lua)"
tdir=${datadir}/${model}_${mod}_${par}/"NexNp=${Ne}x${Np}/E${E1}_${E2}"
mkdir -p "${tdir}"

# (fa=0.9; fb=1.1; Nf=191; python -c "import numpy; [print(el) for el in numpy.linspace(${fa}, ${fb}, ${Nf})]")
# (LC_NUMERIC=en_US.UTF-8; fa=0.9; fb=1.1; Nf=191; i=0; for f in $(seq ${fa} $(echo "scale=20; fa=${fa}; fb=${fb}; nf=${Nf}; dfk=(fb-fa)/(nf-1); print(dfk)" | bc) ${fb}); do { printf "%s_%03d\n" ${f} ${i}; echo "i=${i}; ((i++));}; done)

cd "${bindir}"
cnt=0
for ex in $(seq ${fa} $(echo "scale=20 ; fa=${fa} ; fb=${fb} ; nf=${Np} ; print((fb-fa)/(nf-1))" | bc) ${fb})
do
  printf -v datf "%s/${model}_${mod}_${par}_id%03d.dat" "${tdir}" ${cnt}
  echo -n "" > "${datf}"
  for i in $(seq 0 1 $((Ne-1)))
  do
    ./${prog} ${model_data} -c "Ep1=${Ep1};Ep2=${Ep2};d=(Ep2-Ep1)/(${Ne}-1);E=math.exp((${Ep1}+${i}*d)*math.log(10));${par}=${ex}*${par}" ${probablt} > "${fdata}"
    dat=($(grep -v '^#' "${fdata}"))
    pr=$(echo "$(grep "${par}\s*=" sun.lua); ${par}=${ex}*${par}; print(${par})" | lua)
    echo "${dat[0]}  ${dat[1]}  ${dat[2]} ${pr} ${ex}" >> "${datf}"
  done
  ((cnt++))
done
# vim: ts=2 et tw=120
