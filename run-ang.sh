#!/usr/bin/bash

# This script must be run in top of working directory!


# configure parameters:
# - model :: used model, possible values: sun|sn[|earth]
# - prob :: computed probability: e-e, e-mu, e-tau, mu-e, mu-mu, mu-tau[, tau-e, tau-mu, tau-tau]
# - NEparts :: number of magnitude parts (energy), might be ODD number!
# - Nfparts :: number of factor parts, must be ODD number!
# - E1,E2 :: low and high energy: in MeV, use scientific format, eg 1.03e4
# - born :: where be born: in|out
# - mixAng :: mixing angle: s12|s13|s23
# - fa, fb :: the variation factors, fraction from orinigal, eg 0.9 and 1.1 (default).

declare -A Pr

Pr=(
  ["e-e"]="prob-e-e.lua"
  ["e-mu"]="prob-e-mu.lua"
  ["mu-e"]="prob-mu-e.lua"
  ["mu-mu"]="prob-mu-mu.lua"
)

# configurable parameters:
model="sun"
prob="e-mu"
NEparts=101
Nfparts=101
born="in"
mixAng="s12"
E1="1.00e-3"
E2="1.00e7"
fa=0.9
fb=1.1
xtheta=0.5

[[ -n $1 ]] &&
{
  [[ -f $1 ]] &&
  {
    # shellcheck disable=SC1090
    source "$1"
  }
}

# internal parameters:
datadir="$PWD/data"
bindir="$PWD/magexp/bin"
prog=m4-tol
prb=${Pr["${prob}"]}
model_data=${model}-${born}.lua
Ne="${NEparts}"
Nf="${Nfparts}"

[[ -z ${prb} ]] &&
{
  echo "ОШИБКА: указан неверный переход: '${prob}'."
  exit 7
}

instance="instance-$(date +'%Y-%m-%dT%H:%M:%S%z')"
tdir="${datadir}/${model}_${born}_${mixAng}/NexNf=${Ne}x${Nf}/E${E1}_${E2}/${prob}"

if [ ! -d "${datadir}" ]; then
  mkdir "${datadir}"
fi

if [ ! -d "${bindir}" ]; then
  echo "ОШИБКА: нет каталога '${bindir}'"
  exit 1
fi


if [ ! -e "${bindir}/${prog}" ]; then
  echo "ОШИБКА: нет расчетной программы ${prog}"
  exit 2
fi

[[ ! -e "${bindir}/${model_data}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные модели, которые хранятся в файле '${model_data}'"
  exit 3
}

[[ ! -e "${bindir}/${prb}" ]] &&
{
  echo "ОШИБКА: программе '${prog} нужны данные по расчёту вероятности, которые хранятся в файле '${prb}'"
  exit 4
}

(( Nf/2 != (Nf-1)/2 )) &&
{
  echo "ОШИБКА: количество шагов для фактора угла должно быть нечетным, Nf=${Nf}"
  exit 4
}

cd "${bindir}" ||
{
  echo "ОШИБКА: невозможно перейти в каталог '${bindir}'"
  exit 5
}

if ! command -v b3sum >/dev/null 2>&1; then
  echo "ОШИБКА: для работы сценария нужно программа b3sum!"
  exit 7
fi

# (fa=0.9; fb=1.1; Nf=191; python -c "import numpy; [print(el) for el in numpy.linspace(${fa}, ${fb}, ${Nf})]")
# (LC_NUMERIC=en_US.UTF-8; fa=0.9; fb=1.1; Nf=191; i=0; for f in $(seq ${fa} $(echo "scale=20; fa=${fa}; fb=${fb}; nf=${Nf}; dfk=(fb-fa)/(nf-1); print(dfk)" | bc) ${fb}); do { printf "%s_%03d\n" ${f} ${i}; echo "i=${i}; ((i++));}; done)

[[ ${born} == "out" ]] &&
{
  tdir="${tdir}/${xtheta}"
}

mkdir -p "${tdir}"

# write run job file.
cat > "/tmp/${instance}.run" << EOC
# ######################################################################################################################
# configurable parameters:
model="${model}"
born="${born}"
mixAng="${mixAng}"
prob="${prob}"
NEparts=${NEparts}
Nfparts=${Nfparts}
E1="${E1}"
E2="${E2}"
fa=${fa}
fb=${fb}
xtheta=${xtheta}
EOC

IFS=' ' read -ra hs <<< "$(b3sum "/tmp/${instance}.run")"
frun="/tmp/${hs[0]}"

[[ -e ${frun} ]] &&
{
  echo "ОШИБКА: сценарий уже запущен!"
  exit 6
}

# ### About a bit weird '/../../' part below. The code above cd'ed into bindir, so when the script is run, the PWD =
# ### bindir. The code below assumes that bindir is strictly inside 'magexp' and it is only one level deeper.
cat >> "/tmp/${instance}.run" <<EOC
# INSTANCE: ${instance}
# ######################################################################################################################
# internal parameters:
prog="${prog}"
prb="${prb}"
model_data="${model_data}"
datadir="\${PWD}/../../data"
Ne="${NEparts}"
Nf="${Nfparts}"
instance="${instance}"
hash="${hs[0]}"
fdata="/tmp/data-${hs[0]}.tmp"
frun="${frun}"
tdir="\${datadir}/${model}_${born}_${mixAng}/NexNf=${Ne}x${Nf}/E${E1}_${E2}/${prob}"
EOC

cat >> "/tmp/${instance}.run" << 'EOR'
# ######################################################################################################################
# RUN:
cnt=0

[[ -e ${frun} ]] &&
{
  echo "ОШИБКА: возможно сценарий уже запущен с заданными параметрами (см. '${tdir}/HASH.run'), т.к. есть файл контроля запуска: '${frun}'"
  exit 11
}

[[ ${born} == "out" ]] &&
{
  tdir="${tdir}/${xtheta}"
}

export LC_NUMERIC=en_US.UTF-8

echo "${cnt}" > "${frun}"

for ex in $(seq ${fa} "$(echo "scale=20 ; fa=${fa} ; fb=${fb} ; nf=${Nf} ; print((fb-fa)/(nf-1))" | bc)" ${fb})
do
  printf -v datf "%s/${model}_${born}_${mixAng}_id%03d.dat" "${tdir}" ${cnt}
  echo -n "" > "${datf}"
  for i in $(seq 0 1 $((Ne-1)))
  do
    ./${prog} ${model_data} -c "Ep1=math.log(${E1})/math.log(10);Ep2=math.log(${E2})/math.log(10);d=(Ep2-Ep1)/(${Ne}-1);E=math.exp((Ep1+${i}*d)*math.log(10));${mixAng}=${ex}*${mixAng};xtheta=${xtheta}" "${prb}" > "${fdata}" || {
      echo "ОШИБКА: выполнение '${prog}' завершилось с ошибкой, параметры запуска в файле '${tdir}/${instance}.run'"
      exit 12
    }
    read -ra dat <<< "$(grep -v '^#' ${fdata})"
    ang=$(grep "#*ex.*${mixAng}" "${fdata}" | sed -e 's@.*=@@')
    echo "${dat[0]}  ${dat[1]}  ${dat[2]} ${ang} ${ex}" >> "${datf}"
  done
  ((cnt++))
  echo "${cnt}" > "${frun}"
done
rm "${fdata}"
rm "${frun}"
# vim: syn=sh tw=120 ts=2 et
EOR

chmod +x "/tmp/${instance}.run"
mv "/tmp/${instance}.run" "${tdir}/${hs[0]}.run"
"${tdir}/${hs[0]}.run"

# vim: ts=2 et tw=120
