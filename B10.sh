#!/usr/bin/env bash
source code/global.sh

# Subset to white British ancestry

mkdir -p genetics
mkdir -p genetics/filter2
mkdir -p scripts/B10
mkdir -p logs/B10
mkdir -p runtimes/B10

paste -d' ' <(cut -f1 -d' ' $FAM) <(cut -f 22,24-63 -d' ' $SQC | tail -n+2) > data/side1
cat data/side1 | cut -f1,2 -d' ' | grep '1$' | cut -f1 -d' ' | sort > data/recent
comm -1 -2 <(sort data/subjects2) <(sort data/recent) > data/subjects3

for i in $(seq 1 22); do
  i2=$(printf "%02d" $i)
  if [ ! -f $(pwd)/genetics/filter2/chr${i2}.bgen ]; then
    token="B10${i2}"
    file="scripts/B10/${token}.run"
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/B10/$token.o -e $(pwd)/logs/B10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd); bin/qctool-v2 -g $(pwd)/genetics/filter1/chr${i2}.bgen -s $(pwd)/genetics/filter1/chr${i2}.sample -ofiletype bgen_v1.1 -og $(pwd)/genetics/filter2/chr${i2}.bgen -os $(pwd)/genetics/filter2/chr${i2}.sample -incl-samples $(pwd)/data/subjects3; cd genetics/filter2; ../../bin/bgenix -index -g chr${i2}.bgen; ../../bin/qctool-v2 -g chr${i2}.bgen -s chr${i2}.sample -snp-stats -osnp chr${i2}.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/B10/$token" >> $file
    chmod u+x $file
    chmod g+x $file
    sbatch $file
  fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep B10 | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "B10 done"
