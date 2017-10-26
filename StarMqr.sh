#!/bin/bash

# Utiliser ce script pour un workflow Bionano
# Ce script lance une statistique sur tous les fichiers bnx contenus dans le dossier $BNX
# Ensuite, il lance un mqr sur tous ces fichiers
# Ensuite, il applique un filtre de 100 et de 150 kb sur tous les bnx du dossier
# Ensuite, il fait une statistique sur tous les fichiers bnx après filtrage
# Et enfin, il met toutes ces statistiques dans un fichier Statistic_Final.csv

export PATH=$HOME/localperl/bin/:$PATH   # Je défini la version Perl v5.16.2 comme version par défaut


# --------------------------------------------------------------------------------------------------------

# LES VARIABLES À MODIFIER

   RefAligner=/home/cnrgv/Bionano/TOOLS/RefAligner                                   # PATH POUR REFALIGNER

   outfolder=/home/cnrgv/Desktop/Flow/Data                                           # DOSSIER DE SORTIE 

   cmap=/home/cnrgv/Desktop/Flow/Marouch_reads_3kb_Falcon_0.5_p_ctg_1020_BspQ1.cmap  # FICHIER DE RÉFÉRENCE CMAP 

   BNX=$outfolder/BNX/                                                               # Dossier contenant les fichiers BNX


# --------------------------------------------------------------------------------------------------------

echo
echo "Starting Workflow"
sleep 1
echo Creating subfolder 
echo ..
sleep 1

mkdir $outfolder/150kb
mkdir $outfolder/100kb

if [ ! -d $outfolder/CSV ]; # Tester si ../CSV existe et le crée
then
mkdir $outfolder/CSV
fi

echo Executing..
echo 
#==========================================================================================================================================================================
#Faire une stat sur tous les fichiers bnx || (Résultat dans ../CSV/Bnx_Stat.csv)

for b in  $BNX/*.bnx;
 do 
./runBNG bnxstats -b $b -p Mol -o $outfolder;
done


#==========================================================================================================================================================================
# Lancer un MQR sur tous les fichiers bnx contenus dans le dossier spécifié || ( Résultat dans ../CSV/MQR_Summary.csv)

for file in $BNX/*.bnx;
 do
./runBNG MQR -b $file -r $cmap -R $RefAligner -t 2 -m 2 -o $outfolder
 done

#=======================================================================



#=======================================================================
#==========================================================================================================================================================================
#Appliquer un filtre 150kb sur tous les bnx.

for file in $BNX/*.bnx
do 

./runBNG bnxfilter -b $file -t 2 -l 150 -m 2 -p Filtred150kb -R $RefAligner -o $outfolder/150kb

done



#==========================================================================================================================================================================
#Appliquer un filtre 100kb sur tous les bnx.

for file in $BNX/*.bnx
do 

./runBNG bnxfilter -b $file -t 2 -l 100 -m 2 -p Filtred -R $RefAligner -o $outfolder/100kb

done


#==========================================================================================================================================================================
# Statistique sur tous les bnx filtrés à 150 || (Résultat dans ../Data/CSV/Filtr_Stat.csv)


for b in  $outfolder/150kb/*.bnx;
 do 
./fil150.sh bnxstats -b $b -p Stat -o $outfolder
done


#==========================================================================================================================================================================
# Statistique sur tous les bnx filtrés à 100 || (Résultat dans ../Data/CSV/Filtr_Stat.csv)


for b in  $outfolder/100kb/*.bnx;
 do 
./fil100.sh bnxstats -b $b -p Stat -o $outfolder
done


#==========================================================================================================================================================================
# Rassembler tous les stats|| Résultat dans ../Data/CSV/Stat_Final.csv

echo 
echo 
sleep 2
echo "Creating statistique summary..."
sleep 2

paste $outfolder/CSV/HeaderBNX.csv $outfolder/CSV/Header100kb.csv $outfolder/CSV/Header150kb.csv $outfolder/CSV/HeaderMQR.csv > $outfolder/CSV/Header.csv

paste $outfolder/CSV/Bnx_Stat.csv $outfolder/CSV/Filtr100kb.csv $outfolder/CSV/Filtr150kb.csv $outfolder/CSV/MQR_Summary.csv > $outfolder/CSV/Body.csv

echo "Exporting to Statistic_Final.csv"
sleep 1
cat $outfolder/CSV/Header.csv $outfolder/CSV/Body.csv > $outfolder/CSV/Stat_Final.csv

# --------------------------------------------------------------------------------------------------------
# Nettoyage

if [ ! -d $outfolder/Tmp ]; # Tester si ..le dossier existe et le crée
then
mkdir $outfolder/Tmp
fi


rm -rf $outfolder/CSV/HeaderBNX.csv $outfolder/CSV/Header100kb.csv $outfolder/CSV/Header150kb.csv $outfolder/CSV/HeaderMQR.csv
rm -rf $outfolder/CSV/Bnx_Stat.csv $outfolder/CSV/Filtr100kb.csv $outfolder/CSV/MQR_Summary.csv
rm -rf $outfolder/CSV/Header.csv $outfolder/CSV/Body.csv
rm -rf $outfolder/100kb
mv -f  $outfolder/150kb/*.bnx $outfolder/Tmp
rm -rf $outfolder/150kb $outfolder/CSV/Filtr150kb.csv $outfolder/MQR-results*
rm -rf $outfolder/*.txt


#paste $outfolder/CSV/NBNX.csv  $outfolder/CSV/NFilter150.csv $outfolder/CSV/NFilter100.csv > $outfolder/CSV/Percent.csv
rm -rf $outfolder/CSV/NBNX.csv  $outfolder/CSV/NFilter150.csv $outfolder/CSV/NFilter100.csv
echo
echo "Done"


#==========================================================================================================================================================================
     
