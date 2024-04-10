#!/usr/bin/env bash
source code/global.sh

# Subset to chip SNPs (for kinship matrix generation)

mkdir -p genetics
mkdir -p genetics/filter3
mkdir -p scripts/C10
mkdir -p logs/C10
mkdir -p runtimes/C10

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/filter3/chr${i2}.bgen ]; then
    token="C10${i2}"
    file="scripts/C10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/C10/$token.o -e $(pwd)/logs/C10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g $(pwd)/genetics/filter2/chr${i2}.bgen -s $(pwd)/genetics/filter2/chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/filter3/chr${i2}.bgen -os $(pwd)/genetics/filter3/chr${i2}.sample -incl-rsids $CHIP; cd genetics/filter3; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/C10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done
sleep 10m;

while [ $(squeue -u $(whoami) | grep C10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "C10 done"
