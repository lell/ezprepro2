#!/usr/bin/env bash
source code/global.sh

# Subset to genotyped + phenotyped subjects 

mkdir -p genetics
mkdir -p data
mkdir -p genetics/filter1
mkdir -p scripts/A10
mkdir -p logs/A10
mkdir -p runtimes/A10

if [ "$#" -ne 1 ]; then
    echo "Subject IDs must be provided."
    exit
fi

sort $1 > data/subjects1
cut -f1 -d' ' $FAM | sort > data/sorted
comm -1 -2 data/subjects1 data/sorted > data/subjects2

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/filter1/chr${i2}.bgen ]; then
token="A10${i2}"
file="scripts/A10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -A win.prj -p long" >> $file
echo "#SBATCH -c 4" >> $file
echo "#SBATCH -o $(pwd)/logs/A10/$token.o -e $(pwd)/logs/A10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g $BGEN/ukb_imp_chr${i}_v3.bgen -s $SAMPLE -ofiletype bgen_v1.1 -og $(pwd)/genetics/filter1/chr${i2}.bgen -os $(pwd)/genetics/filter1/chr${i2}.sample -incl-samples $(pwd)/data/subjects2; cd genetics/filter1; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/A10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep A10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "A10 done"
