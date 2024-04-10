#!/usr/bin/env bash
source code/global.sh

# Subset sex chromosomes to disco/repro

mkdir -p genetics
mkdir -p genetics/filter1
mkdir -p genetics/filter2
mkdir -p genetics/filter3
mkdir -p genetics/disco2/
mkdir -p genetics/repro2/
mkdir -p scripts/M10
mkdir -p logs/M10
mkdir -p runtimes/M10

for i in "X" "XY"; do
i2=$i
token="M10a${i2}"
file="scripts/M10/${token}.run"
if [ ! -f $(pwd)/genetics/disco1/chr${i2}.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/M10/$token.o -e $(pwd)/logs/M10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/filter3/chr${i2}.bgen -s $(pwd)/genetics/filter3/chr${i2}.sample -og $(pwd)/genetics/disco1/chr${i2}.bgen -os $(pwd)/genetics/disco1/chr${i2}.sample -incl-samples $(pwd)/data/disco.txt; cd genetics/disco1; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/M10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep M10a | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "M10a done"

for i in "X" "XY"; do
i2=$i
token="M10b${i2}"
file="scripts/M10/${token}.run"
if [ ! -f $(pwd)/genetics/disco2/chr${i2}.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#\$ -N $token" >> $file
echo "#\$ -cwd -V" >> $file
echo "#\$ -o $(pwd)/logs/M10/$token.o -e $(pwd)/logs/M10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/disco1/chr${i2}.bgen -s $(pwd)/genetics/disco1/chr${i2}.sample -hwe 7 -maf 0.001 1 -info 0.3 1 -og $(pwd)/genetics/disco2/chr${i2}.bgen -os $(pwd)/genetics/disco2/chr${i2}.sample; cd genetics/disco2; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/M10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep M10b | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "M10b done"

for i in "X" "XY"; do
i2=$i
token="M10c${i2}"
file="scripts/K10/${token}.run"
if [ ! -f $(pwd)/genetics/repro2/chr${i2}.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#\$ -N $token" >> $file
echo "#\$ -cwd -V" >> $file
echo "#\$ -o $(pwd)/logs/M10/$token.o -e $(pwd)/logs/M10/$token.e" >> $file
echo "cat genetics/disco2/chr${i2}.info | tail -n +11 | cut -f 2 | sort | uniq > genetics/disco2/chr${i2}.rsids" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/filter3/chr${i2}.bgen -s $(pwd)/genetics/filter3/chr${i2}.sample -og $(pwd)/genetics/repro2/chr${i2}.bgen -os $(pwd)/genetics/repro2/chr${i2}.sample -incl-samples $(pwd)/data/repro.txt -incl-rsids $(pwd)/genetics/disco2/chr${i2}.rsids; cd genetics/repro2; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/K10/$token" >> $file
chmod u+x $file
chmod g+x $file
sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep M10c | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "M10c done"
