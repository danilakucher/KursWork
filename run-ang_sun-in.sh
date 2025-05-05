#!/usr/bin/bash

export LC_NUMERIC=en_US.UTF-8

fk=(0.9 0.95 1.0 1.05 1.1)
fa=0.9
fb=1.1

model="sun"
fdata="/tmp/data-${model}.tmp"
datadir="$PWD/data"
bindir="$PWD/magexp/bin"
prog=m4-tol
model_file=${model}.lua
prob_file=survprob.lua

mod="in"
mang="s12"

Ep1=-3
Ep2=7
N=50

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

[[ ! -e "${bindir}/${prob_file}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные модели, которые хранятся в файле '${prob_file}'"
  exit 7
}

(( $# != 3 )) && 
{
  echo "ОШИБКА: сценарий требует 3 аргумента: маркер угла, количество шагов по энергии, количество шагов фактора угла"
  echo "Пример: "
  echo "  $0 s12|s13 50 5"
  exit 2
}

case $1 in
  "s12")
    mang="s12"
    ;;
  "s13")
    mang="s13"
    ;;
  *)
    echo "ОШИБКА: нераспознанный маркер: $1"
    exit 3
    ;;
esac

Ne="$2"
Nf="$3"

(( Nf/2 != (Nf-1)/2 )) &&
{
  echo "ОШИБКА: количество шагов для фактора угла должно быть нечетным, Nf=${Nf}"
  exit 4
}

tdir=${datadir}/${model}_${mod}_${mang}/"NexNf=${Ne}x${Nf}"
mkdir -p "${tdir}"

# (fa=0.9; fb=1.1; Nf=191; python -c "import numpy; [print(el) for el in numpy.linspace(${fa}, ${fb}, ${Nf})]")
# (LC_NUMERIC=en_US.UTF-8; fa=0.9; fb=1.1; Nf=191; i=0; for f in $(seq ${fa} $(echo "scale=20; fa=${fa}; fb=${fb}; nf=${Nf}; dfk=(fb-fa)/(nf-1); print(dfk)" | bc) ${fb}); do { printf "%s_%03d\n" ${f} ${i}; echo "i=${i}; ((i++));}; done)

cd "${bindir}"
cnt=0
for ex in $(seq ${fa} $(echo "scale=20 ; fa=${fa} ; fb=${fb} ; nf=${Nf} ; print((fb-fa)/(nf-1))" | bc) ${fb})
do
	printf -v datf "%s/${model}_${mod}_${mang}_id%03d.dat" "${tdir}" ${cnt}
	echo -n "" > "${datf}"
	for i in $(seq 0 1 $((Ne-1)))
	do
		./${prog} ${model_file} -c "Ep1=${Ep1};Ep2=${Ep2};d=(Ep2-Ep1)/(${N}-1);E=math.exp((${Ep1}+${i}*d)*math.log(10));${mang}=${ex}*${mang}" ${prob_file} > "${fdata}"
		dat=($(grep -v '^#' "${fdata}"))
		ang=$(grep "#*ex.*${mang}" "${fdata}" | sed -e 's@.*=@@')
		echo "${dat[0]}  ${dat[1]}  ${dat[2]} ${ang} ${ex}" >> "${datf}"
	done
  ((cnt++))
done
