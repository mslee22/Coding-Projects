#data input prompt for a date in the format YYYYMMDD
read -p ":) ENTER DATE (YYYYMMDD): " INPUT_DATE

if [[ ! $INPUT_DATE =~ ^[0-9]{8}$ ]]; then
	echo "Uh oh: I don't like your input >:( Use the format YYYYMMDD"
	exit 1
fi

#check if data exists
YESTERDAY=$(date -d "yesterday" +"%Y%m%d")
if [[ $INPUT_DATE -ge $YESTERDAY ]]; then 
	echo "There is no data for this day yet"
	exit 1
fi 


YEAR=${INPUT_DATE:0:4}
MONTH_NUM=${INPUT_DATE:4:2}
DAY=${INPUT_DATE:6:2}
MONTH_NAME=$(date -d "${YEAR}-${MONTH_NUM}-01" +%B)
#creates variables for directories
BASE_DIR=~/HHC_Production
MONTH_YEAR=${MONTH_NAME}${YEAR}
DATA_DIR=$BASE_DIR/$MONTH_YEAR
PID_DIR=$BASE_DIR/${YEAR}_PID/$MONTH_NAME
TEMPS_DIR=$BASE_DIR/${YEAR}_Temps/$MONTH_NAME
DAY_DIR=${MONTH_NUM}${DAY}
DEST_DIR=$DATA_DIR/$DAY_DIR

#Checks if the directory already exists
if [ -d "$DEST_DIR" ]; then
	read -p "Directory already exists, want to continue? (YES/NO): " DUP_DIR
	if [[ $DUP_DIR != "YES" ]]; then 
		echo "exiting"
		exit 1
	fi
fi

#creates directories for day/months/years that don't exist yet
mkdir -p $DATA_DIR
mkdir -p $PID_DIR
mkdir -p $TEMPS_DIR
mkdir -p $DEST_DIR

#copy data over
NEXT_DAY=$(date -d "${YEAR}-${MONTH_NUM}-${DAY} +1 day" +%m%d)
SOURCE_DIR=/data/exp/IceCube/${YEAR}/internal-system/blanketcont/$NEXT_DAY/
FLAT_TAR="${SOURCE_DIR}*.tar"
cp -r $FLAT_TAR $DEST_DIR

#convert data
cd $DEST_DIR
tar -xvf $FLAT_TAR
BZ2_FILE=$(ls *.tar.bz2)
bzip2 -d $BZ2_FILE
TAR_FILE=$(ls | grep -E '.*\.tar$' | grep -v '.*\.flat.tar')
tar -xvf $TAR_FILE

#confirm Temps data
CSV_LENGTH=$(more LOGS/Temps/*.CSV | wc -l)
if [[ $CSV_LENGTH -ne 1441 ]]; then 
	echo "Unexpected CSV file length: $CSV_LINES. Abort mission."
	exit 1
fi 

#confirm PID data
PID_CSVL=$(more LOGS/PID_Data/*.CSV | wc -l)
if [[ PID_CSVL -ne 1441 ]]; then
	echo "Unexpected CSV file length: $CSV_LINES. Abort mission."
	exit 1
fi

#Stage PID Data for Transfer
cd $DATA_DIR
PID_CSV="${DAY_DIR}/LOGS/PID_Data/*.CSV"
find $PID_CSV -type f -exec cp {} $PID_DIR \;

#Stage Temps Data for Transfer
TEMPS_CSV="${DAY_DIR}/LOGS/Temps/*.CSV"
find $TEMPS_CSV -type f -exec cp {} $TEMPS_DIR \;

echo "Successfully transferred all files woot woot!"
echo "PID Files"
ls $PID_DIR
echo "Temps Files"
ls $TEMPS_DIR
#add code to exclude date inputs from the future
