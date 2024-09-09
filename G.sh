#!  /usr/local/bin/bash
#============================================================================
# Features List
#
# -) No Argument Input 
# -) Help Option
# -) UniProtKB Database Searching
# -) Wrong Argument or no returned search
# -) Only one returned sequence (Multiple Alignment not possible)
# -) Fasta Header Editing
# -) If multiple sequence from same species
# -) Clustalw multiple aligntment
# -) Clustalw phylogenetic tree
# -) Housekeeping Features (Deletes intermediary files)
# -) Dendroscope Visualisation
#
#============================================================================
source ~binftools/setup-env.sh  
GENE=$1 # GENE = Query Search 


#============================================================================
# No Argument and info option 
# Error message when script is launched with no arugments
# if -info argument then displays info and help option 
#if [ $# -eq 0];
if [[ $GENE == '' ]]
then 
    echo "=============================================="
    echo "           No GENE Query Entered              "
    echo
    echo "              Synthax Example:                "
    echo
    echo "              /uniTree.sh GENE                "
    echo
    echo "              /uniTree.sh HPSE                "
    echo
    echo "          Only Accepts One Argument           "
    echo
    echo
    echo "         For More information Enter:          "
    echo
    echo "              /uniTree.sh -info               "
    echo "=============================================="
    echo
    echo
    exit 1
elif [[ $GENE == '-info' ]]
then
    echo "=============================================="
    echo "             !!  uniTree  !!                  "
    echo
    echo "    A Mammalian Multiple Sequence Alignment   "
    echo "     and Phylogenetic Tree Builder Script     "
    echo
    echo "           Uses UniProtKB Databse             "
    echo "             ( .fasta format )                "
    echo
    echo "                Clustal W                     "
    echo "     Multiple Sequence Alignment Algortihm    "
    echo "                   And                        " 
    echo "       Phylogenetic Tree Constructur          "
    echo "               ( .ph output )                 "
    echo
    echo
    echo "      Uses Dendroscope Visualisation Tool     "
    echo "               ( .ph input )                  "
    echo "=============================================="
    echo
    echo
    exit 1


fi

#============================================================================
# Uniprot database retriveal feature:
# Using https://www.uniprot.org/uniprot/?query=gene%3AHPSE+taxonomy%3A%22Mammalia+%5B40674%5D%22+AND+reviewed%3Ayes&sort=score
# changing the example gene HPSE into target '$GENE' and adding format = fasta
echo "=============================================="
echo "        Searching For $GENE Sequences         "
echo "=============================================="
echo
echo

wget -O raw$GENE.fasta 'https://www.uniprot.org/uniprot/?query=gene%3A'$GENE'+taxonomy%3A%22Mammalia+%5B40674%5D%22+AND+reviewed%3Ayes&sort=score&format=fasta'


#============================================================================
# Empty Search Feature:
# If Query Search returns no results, exits program
seqNumber=`grep -o OS= raw$GENE.fasta | wc -w`
if [[ -s "raw$GENE.fasta" ]];   
then
    echo
    echo
    echo "=============================================="
    echo "              Search Succesful                "
    echo
    echo "           Retrieved $seqNumber Sequences     "
    echo "=============================================="
else   
    echo
    echo
    echo "=============================================="
    echo "         Query Search Returned Empty          "
    echo
    echo "      Check Spelling or Change Gene Query     "
    echo "=============================================="  
    
    echo
    echo
    echo "=============================================="
    echo "       Thank you for using UniTree.sh         "
    echo "=============================================="
    rm raw$GENE.fasta
    exit 1 
fi  

#============================================================================
# If Only One Sequence retrieved, multiple sequence aligntment is not possible
# exits program
#
if [[ $seqNumber == 1 ]]; 
then
  echo
  echo
  echo "=============================================="
  echo "          Only One Sequence Retrieved         "
  echo "            from UniProtKB Database           "
  echo 
  echo "          Multiple Sequence Alignment         "
  echo "               Is Not Possible                "
  echo "=============================================="
  echo
  echo
  echo "=============================================="
  echo "       Thank you for using UniTree.sh         "
  echo "=============================================="
rm raw$GENE.fasta
exit 1 
fi
  

#============================================================================
# Header Edit Feature:
# Edit the .fasta file using sed to only show the species name and 
# fills whitespace with _ to allow full display in tree
echo
echo
echo "=============================================="
echo "            Editing Fasta Header              "
echo "=============================================="

sed -e 's/.*OS=/>/' -e 's/ OX=.*$//' -e 's/\s\+/_/g' <raw$GENE.fasta> edited1$GENE.fasta



#============================================================================
# Duplicate Species feature:
# Edit the .fasta file to accomodate multiple sequence from same species
# e.g if there are 3 sequence from mus musculus
# then mus_musculus mus_musculus_2 mus_musculus_3

awk 'cnt[$0]++{$0=$0"_"cnt[$0]} 1' edited1$GENE.fasta > edited$GENE.fasta

rm edited1$GENE.fasta

     
     



#============================================================================
# Multiple Alignment Feature:
# Uses Clustalw to align the edited .fasta file
echo
echo
echo "=============================================="
echo "       Allinging Sequence with ClutsalW       "
echo "=============================================="

clustalw edited$GENE.fasta -align
 
#============================================================================
# Phlylogenetic tree Feature:
# Uses Clustalw to create a phylogenetic tree .py file
echo
echo
echo "=============================================="
echo "        Creating Phlylogenetic Tree           "
echo "=============================================="

clustalw -INFILE=edited$GENE.aln -TREE -OUTPUTTREE=phylip 

#============================================================================
# Housekeeping Feature
# Deletes any intermediary files created 
mv edited$GENE.ph $GENE.tree
rm edited$GENE.*
rm raw$GENE.fasta



#============================================================================
# Additional Feature: Dendroscope Visualisation 
# Ask for user input to visualise the .py ouputfile using dendroscope
# Automatically prompts up at the end of the program
echo
echo
echo "=============================================="
echo "Visualize phylogenetic tree using Dendroscope?"
echo
echo "               Enter: (yes\no)                "
echo
read visual
echo "=============================================="
echo
echo

if [[ $visual == 'yes' ]]; 
then
  echo
  echo
  echo "=============================================="
  echo "             OPENING DENDROSCOPE              "
  echo "=============================================="
  
  dendroscope -x "launch file=$GENE.tree" 
fi

echo
echo
echo "=============================================="
echo "       Thank you for using UniTree.sh         "
echo "         Output File :  $GENE.tree            "
echo "=============================================="



