#make sure everything is okay 
#apply perl .\convdate.pl .\24XXXX00.CSV to all CSV files in the directory

DIRECTORY="./"
PERL_SCRIPT="./convdate.pl"

#go through each CSV file in directory
for FILE in $DIRECTORY*.CSV; do 
	BASENAME=$(basename "FILE")
	perl "$PERL_SCRIPT" "$FILE"
	echo "Successfully converted: $BASENAME"
done


echo "The code ran, don't know if anything happened, but it ran"
