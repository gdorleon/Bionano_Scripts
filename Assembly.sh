#!/bin/bash

# Use of Assembly.sh for De Novo Assembly
# Ce Script fait un merge sur des bnx filtrés à 150kb puis faire un Assemblage sur le fichier bnx résultant du merge


#USE: ./runBNG denovo [-t <toolsDir>] [-s <scriptsDir>] [-b <bnx>] [-T <nthreads>] [-j <njobs>] [-z <genome_size>] [-o <outDir>]\n";
# 
# --------------------------------------------------------------------------------------------------------
# Les paramètres:  
#                  -t       Path pour les tools RefAligner et RefAssembler
#                  -s       Path pour les scritps
#                  -b       Fichier bnx
#                  -o       Repertoire de sortie


#                  -T       Nombre de Threads
#                  -j       Nombre de Jobs
#                  -z       Size du génome en Mb


#                  -i       Nombre d'itérations -- 3 par défaut           ( OPTIONEL)
#                  -l       Min Length --       150 par défaut            ( OPTIONEL)
#                  -m       Minimum label sur la molécule -- 8 par défaut ( OPTIONEL)



#                  -m       Référence .cmap --- nul par défaut            ( OPTIONEL)
#                  -p	    Faux Positif (/100Kb) -- 1.5 par défaut       ( OPTIONEL)
#	               -n	    Faux Négatif (%/100) --  0.15 par défaut      ( OPTIONEL)
#                  -d	    ScalingSD (Kb^1/2) --  0.0 par défaut         ( OPTIONEL)
#                  -f	    SiteSD (Kb)--        0.2 par défaut           ( OPTIONEL)
#                  -R	    RelativeSD -- 0.03 par défaut                 ( OPTIONEL)
#                  -L	    Large jobs maximum memory (GB)--128 par défaut( OPTIONEL)
#                  -S	    Small jobs maximum memory (GB)--7.5 par défaut( OPTIONEL)

# --------------------------------------------------------------------------------------------------------

# -----P-Value - Elle dépend de la taille du génome - option z
#      Si la taille du génome est inférieure ou égale à 100 Mb, la P-value prendra la valeur 1e-7
#      Si la taille du génome est supérieure à 100 Mb et moins que 1000 Mb, la P-value prendra la valeur 1e-9
#      Dans tous les autres cas, c'est-à-dire pour une taille de génome égale ou supérieure à 1000, P-value prendra la valeur 1e-10




# --------------------------------------------------------------------------------------------------------

   tools=/home/cnrgv/Bionano/TOOLS            # PATH pour les tools RefAligner et RefAssembler (Disponible ici http://www.bnxinstall.com/RefalignerAssembler)

   scripts=/home/cnrgv/Bionano/scripts        # PATH pour les scripts ( Disponible  ici :http://www.bnxinstall.com/Scripts)

   outfolder=/home/cnrgv/Desktop/Flow/Data    # Dossier de sortie

  
   
     
   BNX=$outfolder/BNX                         # Dossier des fichies BNX, il peut etre aussi un seul fichier 
   
   RefAligner=$tools/RefAligner               # PATH pour RefAligner

   liste=$outfolder/Tmp/Liste.txt                       # Liste des fichiers pour le "Merge"
   
   



#----------------------------------------------
echo 
echo ......
echo Creating the list file..
sleep 1 


ls $outfolder/Tmp/*Filtred150kb.bnx > $liste # je liste les fichiers filtrés dans "Liste" pour faire le merge

#==----------------Merge--------------------==

# Merge des bnx filtrés pour avoir un seul fichier bnx final.

echo Merging bnx files ..
sleep 1

./runBNG bnxmerge -l $liste -t 2 -m 2 -p Merge150kb -R $RefAligner -o $outfolder/Tmp

rm -rf $outfolder/Tmp/Mer*.stdout $outfolder/Tmp/merge*.txt $outfolder/Tmp/*.idmap

echo ...
echo "Merge Terminé"
sleep 2
echo "-------------------------------------------------------"
echo "De novo Assembly..."
sleep 2
#------------------------------------------------------------
#------------------------------------------------------------

echo "-------------------------------------------------------"
echo  "Voulez-vous faire l'assemblage avec tous les fichiers de la liste ?"
echo  "Choisir:  |  Y pour continuer |  Autre touche pour annuler" 
read -p "" -n 1 -r
echo   
if [[ $REPLY =~ ^[Yy]$ ]]

then
echo ...
echo "Assemblage avec tous les fichiers de votre liste en cours..."
sleep 2

# ==------------------- De novo Assembly ------------------==

echo "Creating folder for Denovo output .."
sleep 1

if [ ! -d $outfolder/Denovo_Fichiers ]; # Tester si le dossier existe et le crée

then

mkdir $outfolder/Denovo_Fichiers

fi

echo ..
echo 


for file in $outfolder/Tmp/Merge150kb.bnx

do

./runBNG denovo -t $tools -s $scripts -b $file -i 1 -T 2 -j 2 -z 200 -o $outfolder/Denovo_Fichiers

done
fi
echo 
echo ....
