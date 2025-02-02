#!  /usr/local/bin/bash
#Written by Chan Yuet Yat (z5289835)

#############################################################################
#
#
#                                  Features
#
#   1. Print error message for no arguments/more than one arguments
#   2. Print error message for incorrect arguments
#   3. Give example input when argument amount is wrong
#   4. Retrieve from UniprotKB 
#   5. Failure retrieve
#   6. Two empty echo are present before and after each message 
#      to make message easier to read.
#   7. Print message for each step the script is doing
#############################################################################


source ~binftools/setup-env.sh 


#############################################################################
#                                                                           #
#                                                                           #
#                           Feature 1 & 2 & 3                               #
#                                                                           #
#                                                                           #
#############################################################################
#print error message if no arguments/more than one arguments
#else set the gene as variable GENE_NAME

if [ $# -eq 0 ] || [ $# -gt 1 ]
then
    echo
    echo
    echo "             Error Message:             "
    echo "     You have entered $# arguments!!    "
    echo "This programme only accepts 1 arguments."
    echo "----------------------------------------"
    echo "            Example Input:              "
    echo "          ./uniTree.sh EXAMPLE          "
    echo
    echo
    exit 1
else
#gene from argument=GENE_NAME
    GENE_NAME=$1
#end of if
fi
#############################################################################
#                                                                           #
#                                                                           #
#                            Feature 4                                      #
#                                                                           #
#                                                                           #
#############################################################################

#print searching message
echo
echo 
echo "     Searching Sequences for $GENE_NAME        "
echo "                                               "
echo "              ..............                   "
echo "                .........                      "
echo "                  .....                        "
echo "                   ...                         "
echo "                    .                          "
echo "                   ...                         "
echo "                  .....                        "
echo "                .........                      "
echo "              ..............                   "
echo
echo

#advanced search for ins gene gives https://www.uniprot.org/uniprot/?query=gene%3Ains+taxonomy%3A%22Mammalia+%5B40674%5D%22+AND+reviewed%3Ayes&sort=score
#replaced ins to $GENE_NAME and retrieved in fasta format file
wget -O UniprotSearch$GENE_NAME.fasta 'https://www.uniprot.org/uniprot/?query=gene%3A'$GENE_NAME'+taxonomy%3A%22Mammalia+%5B40674%5D%22+AND+reviewed%3Ayes&sort=score&format=fasta'

#if the file is not empty, successful search
if [[ -s "UniprotSearch$GENE_NAME.fasta" ]];
then
    echo
    echo
    echo "               Congratulations!!            "
    echo "                Search succeed              "              
    echo
    echo
#############################################################################
#                                                                           #
#                                                                           #
#                            Feature 5                                      #
#                                                                           #
#                                                                           #
#############################################################################

#return unsuccessful search message
else
    echo
    echo
    echo "               Bad news!                 "
    echo "             No search found             "
    echo
    echo
    #delete the empty file
    rm UniprotSearch$GENE_NAME.fasta
    exit 1
fi

#############################################################################
#                                                                           #
#                                                                           #
#                          Edit Header of the fasta seq                     #
#                                                                           #
#                                                                           #
#############################################################################

#Edit the header of the fasta sequences	so that they contain only the 
#species name

#print editing message
echo
echo 
echo "     Editing the header of the fasta sequences   "
echo "                                               "
echo "                ..............                   "
echo "                  .........                      "
echo "                   .....                        "
echo "                     ...                         "
echo "                      .                          "
echo "                     ...                         "
echo "                    .....                        "
echo "                  .........                      "
echo "                ..............                   "
echo
echo
#edit header
#first part replaces anything before 'OS=' on each linw with ">"
#second part replaces anything after 'OX=' n each linw with nothing, i.e. deleting
#third part replaces spaces with "-" to connect the name
sed -e 's/.*OS=/>/' -e 's/ OX=.*$//' -e 's/\s\+/-/g' <UniprotSearch$GENE_NAME.fasta> OnlyName$GENE_NAME.fasta

#if multiple sequence from the same species
#add number behind the species with a space saperated
#eg Homo-sapiens Homo-sapiens-2 Homo_sapiens-3
awk 'count[$0]++{$0=$0"-"count[$0]}5' OnlyName$GENE_NAME.fasta > OnlyNameWithNum$GENE_NAME.fasta

#remove OnlyName file
rm OnlyName$GENE_NAME.fasta

#############################################################################
#                                                                           #
#                                                                           #
#                    Run Multiple seq alignment program                     #
#                                                                           #
#                                                                           #
#############################################################################

echo
echo
echo "           Clustalw Sequence Alignment"
echo "                                               "
echo "              ..............                   "
echo "                .........                      "
echo "                  .....                        "
echo "                   ...                         "
echo "                    .                          "
echo "                   ...                         "
echo "                  .....                        "
echo "                .........                      "
echo "              ..............                   "
echo
echo

clustalw OnlyNameWithNum$GENE_NAME.fasta -align

#############################################################################
#                                                                           #
#                                                                           #
#              Build a phylogeneic tree using clustalw                      #
#                                                                           #
#                                                                           #
#############################################################################

echo
echo
echo "           Clustalw phylogenetic Tree "
echo "                                               "
echo "              ..............                   "
echo "                .........                      "
echo "                  .....                        "
echo "                   ...                         "
echo "                    .                          "
echo "                   ...                         "
echo "                  .....                        "
echo "                .........                      "
echo "              ..............                   "
echo
echo


clustalw -INFILE=OnlyNameWithNum$GENE_NAME.aln -TREE -OUTPUTTREE=phylip
#rename file
mv OnlyNameWithNum$GENE_NAME.ph $GENE_NAME.tree
#remove unwanted file
rm OnlyNameWithNum$GENE_NAME.aln
rm OnlyNameWithNum$GENE_NAME.dnd
rm OnlyNameWithNum$GENE_NAME.fasta
rm UniprotSearch$GENE_NAME.fasta
