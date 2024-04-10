#!/usr/bin/env bash
source code/global.sh

# Apply SNP filters

mkdir -p scripts/K10
mkdir -p logs/K10
mkdir -p runtimes/K10 
mkdir -p genetics/disco2 
mkdir -p genetics/repro2 


for i in $(seq 1 22); do
i2=$(printf "%02d" $i)
if [ ! -f $(pwd)/genetics/disco2/chr${i2}.bgen ]; then
token="K10d${i2}"
file="scripts/K10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/K10/$token.o -e $(pwd)/logs/K10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/disco1/chr${i2}.bgen -s $(pwd)/genetics/disco1/chr${i2}.sample -og $(pwd)/genetics/disco2/chr${i2}.bgen -os $(pwd)/genetics/disco2/chr${i2}.sample -hwe 7 -maf 0.001 1 -info 0.3 1; cd genetics/disco2; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/K10/$token" >> $file
chmod u+x $file
chmod g+x $file
sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep K10d | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "K10d done"

for i in $(seq 1 22); do
i2=$(printf "%02d" $i)
if [ ! -f $(pwd)/genetics/repro2/chr${i2}.bgen ]; then
token="K10r${i2}"
file="scripts/K10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/K10/$token.o -e $(pwd)/logs/K10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cat genetics/disco2/chr${i2}.info | tail -n +11 | cut -f 2 | sort | uniq > genetics/disco2/chr${i2}.rsids" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/repro1/chr${i2}.bgen -s $(pwd)/genetics/repro1/chr${i2}.sample -og $(pwd)/genetics/repro2/chr${i2}.bgen -os $(pwd)/genetics/repro2/chr${i2}.sample -incl-rsids $(pwd)/genetics/disco2/chr${i2}.rsids; cd genetics/repro2; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/K10/$token" >> $file
chmod u+x $file
chmod g+x $file
sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep K10r | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "K10r done"
