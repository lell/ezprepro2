#!/usr/bin/env bash
source code/global.sh

# Sex chromosomes

mkdir -p genetics
mkdir -p genetics/filter1
mkdir -p genetics/filter2
mkdir -p genetics/filter3
mkdir -p genetics/disco2/
mkdir -p genetics/repro2/
mkdir -p scripts/L10
mkdir -p logs/L10
mkdir -p runtimes/L10

for i in "X" "XY"; do
i2=$i
token="L10${i2}"
file="scripts/L10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/L10/$token.o -e $(pwd)/logs/L10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g /well/ukbb-wtchg/v3/imputation/ukb_imp_chr${i}_v3.bgen -s ${SAMPLE_SEX}_chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/filter3/chr${i2}.bgen -os $(pwd)/genetics/filter3/chr${i2}.sample -incl-samples $(pwd)/data/subjects2; cd genetics/filter3; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/L10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
sbatch $file
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep L10 | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "L10 done"
