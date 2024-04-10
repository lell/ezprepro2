#!/usr/bin/env bash
source code/global.sh

mkdir -p genetics/disco3/

mkdir -p genetics/disco3/
mkdir -p genetics/repro3/
mkdir -p scripts/N10
mkdir -p logs/N10
mkdir -p runtimes/N10

for i in "X" "XY"; do
i2=$i
token="N10b${i2}m"
file="scripts/N10/${token}.run"
if [ ! -f $(pwd)/genetics/disco3/chr${i2}m.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#SBATCH -J $token" >> $file
echo "#SBATCH -o $(pwd)/logs/N10/$token.o -e $(pwd)/logs/N10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd)" >> $file
echo "tail -n+3 genetics/disco2/chr${i2}.sample | cut -d' ' -f1,5 | grep \"1$\" | cut -f1 -d' ' > genetics/disco3/${i2}m" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/disco2/chr${i2}.bgen -s $(pwd)/genetics/disco2/chr${i2}.sample -incl-samples $(pwd)/genetics/disco3/${i2}m -og $(pwd)/genetics/disco3/chr${i2}m.bgen -os $(pwd)/genetics/disco3/chr${i2}m.sample; cd genetics/disco3; ../../bin/bgenix -index -g chr${i2}m.bgen; ../../bin/qctool-v2 -g chr${i2}m.bgen -s chr${i2}m.sample -snp-stats -osnp chr${i2}m.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/N10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
  sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep N10b | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "N10bm done"

for i in "X" "XY"; do
i2=$i
token="N10b${i2}f"
file="scripts/N10/${token}.run"
if [ ! -f $(pwd)/genetics/disco3/chr${i2}f.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#\$ -N $token" >> $file
echo "#\$ -cwd -V" >> $file
echo "#\$ -o $(pwd)/logs/N10/$token.o -e $(pwd)/logs/N10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd)" >> $file
echo "tail -n+3 genetics/disco2/chr${i2}.sample | cut -d' ' -f1,5 | grep \"2$\" | cut -f1 -d' ' > genetics/disco3/${i2}f" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/disco2/chr${i2}.bgen -s $(pwd)/genetics/disco2/chr${i2}.sample -incl-samples $(pwd)/genetics/disco3/${i2}f -og $(pwd)/genetics/disco3/chr${i2}f.bgen -os $(pwd)/genetics/disco3/chr${i2}f.sample; cd genetics/disco3; ../../bin/bgenix -index -g chr${i2}f.bgen; ../../bin/qctool-v2 -g chr${i2}f.bgen -s chr${i2}f.sample -snp-stats -osnp chr${i2}f.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/N10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
  sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep N10b | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "N10bf done"

for i in "X" "XY"; do
i2=$i
token="N10c${i2}m"
file="scripts/N10/${token}.run"
if [ ! -f $(pwd)/genetics/repro3/chr${i2}m.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#\$ -N $token" >> $file
echo "#\$ -cwd -V" >> $file
echo "#\$ -o $(pwd)/logs/N10/$token.o -e $(pwd)/logs/N10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd)" >> $file
echo "tail -n+3 genetics/repro2/chr${i2}.sample | cut -d' ' -f1,5 | grep \"1$\" | cut -f1 -d' ' > genetics/repro3/${i2}m" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/repro2/chr${i2}.bgen -s $(pwd)/genetics/repro2/chr${i2}.sample -incl-samples $(pwd)/genetics/repro3/${i2}m -og $(pwd)/genetics/repro3/chr${i2}m.bgen -os $(pwd)/genetics/repro3/chr${i2}m.sample; cd genetics/repro3; ../../bin/bgenix -index -g chr${i2}m.bgen; ../../bin/qctool2 -g chr${i2}m.bgen -s chr${i2}m.sample -snp-stats -osnp chr${i2}m.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/N10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
  sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep N10b | wc -l) -gt 0 ]; do
  sleep 1h;
done

echo "N10cm done"

for i in "X" "XY"; do
i2=$i
token="N10c${i2}f"
file="scripts/N10/${token}.run"
if [ ! -f $(pwd)/genetics/repro3/chr${i2}f.bgen ]; then
echo "#!/usr/bin/env bash" > $file
echo "#\$ -N $token" >> $file
echo "#\$ -cwd -V" >> $file
echo "#\$ -o $(pwd)/logs/N10/$token.o -e $(pwd)/logs/N10/$token.e" >> $file
echo "T1=\$(date \"+%s\");" >> $file
echo "cd $(pwd)" >> $file
echo "tail -n+3 genetics/repro2/chr${i2}.sample | cut -d' ' -f1,5 | grep \"2$\" | cut -f1 -d' ' > genetics/repro3/${i2}f" >> $file
echo "cd $(pwd); bin/qctool-v1.4 -g $(pwd)/genetics/repro2/chr${i2}.bgen -s $(pwd)/genetics/repro2/chr${i2}.sample -incl-samples $(pwd)/genetics/repro3/${i2}f -og $(pwd)/genetics/repro3/chr${i2}f.bgen -os $(pwd)/genetics/repro3/chr${i2}f.sample; cd genetics/repro3; ../../bin/bgenix -index -g chr${i2}f.bgen; ../../bin/qctool -g chr${i2}f.bgen -s chr${i2}f.sample -snp-stats -osnp chr${i2}f.info"  >> $file
echo "T2=\$(date \"+%s\")" >> $file;
echo "echo \$(expr \$T2 - \$T1)" >> $file
echo "cd ../../; echo \$(expr \$T2 - \$T1) > runtimes/N10/$token" >> $file
  chmod u+x $file
  chmod g+x $file
  sbatch $file
fi
done

sleep 10m;

while [ $(squeue -u $(whoami) | grep N10b | wc -l) -gt 0 ]; do
  sleep 10m;
done

echo "N10cf done"
