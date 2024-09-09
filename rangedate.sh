

valid_input() {
	date -d "$1" +"%Y%m%d" >/dev/null 2>&1
}

#check if data exists
check_date() {
	local input_date=$1
	local yesterday=$(date -d "yesterday" +"%Y%m%d")
	if [[ $input_date -ge $yesterday ]]; then
		return 1
	else
		return 0
	fi 
}

process_date() {
	local INPUT_DATE=$1
	local YEAR=${INPUT_DATE:0:4}
	local MONTH_NUM=${INPUT_DATE:4:2}
	local DAY=${INPUT_DATE:6:2}
	local MONTH_NAME=$(date -d "${YEAR}-${MONTH_NUM}-01" +%B)
#creates variables for directories
	local BASE_DIR=~/HHC_Production
	local MONTH_YEAR=${MONTH_NAME}${YEAR}
	local DATA_DIR=$BASE_DIR/$MONTH_YEAR
	local PID_DIR=$BASE_DIR/${YEAR}_PID/$MONTH_NAME
	local TEMPS_DIR=$BASE_DIR/${YEAR}_Temps/$MONTH_NAME
	local DAY_DIR=${MONTH_NUM}${DAY}
	local DEST_DIR=$DATA_DIR/$DAY_DIR

#creates directories for day/months/years that don't exist yet
	mkdir -p $DATA_DIR
	mkdir -p $PID_DIR
	mkdir -p $TEMPS_DIR
	mkdir -p $DEST_DIR

#copy data over
	local NEXT_DAY=$(date -d "${YEAR}-${MONTH_NUM}-${DAY} +1 day" +%m%d)
	local SOURCE_DIR=/data/exp/IceCube/${YEAR}/internal-system/blanketcont/$NEXT_DAY/
	local FLAT_TAR="${SOURCE_DIR}*.tar"
	cp -r $FLAT_TAR $DEST_DIR

#convert data
	cd $DEST_DIR
	tar -xvf $FLAT_TAR
	local BZ2_FILE=$(ls *.tar.bz2)
	bzip2 -d $BZ2_FILE
	local TAR_FILE=$(ls | grep -E '.*\.tar$' | grep -v '.*\.flat.tar')
	tar -xvf $TAR_FILE

#confirm Temps data
	local CSV_LENGTH=$(more LOGS/Temps/*.CSV | wc -l)
	if [[ $CSV_LENGTH -ne 1441 ]]; then 
		echo "Unexpected CSV file length: $CSV_LINES. Abort mission."
		exit 1
	fi 

#confirm PID data
	local PID_CSVL=$(more LOGS/PID_Data/*.CSV | wc -l)
	if [[ PID_CSVL -ne 1441 ]]; then
		echo "Unexpected CSV file length: $CSV_LINES. Abort mission."
		exit 1
	fi

#Stage PID Data for Transfer
	cd $DATA_DIR
	local PID_CSV="${DAY_DIR}/LOGS/PID_Data/*.CSV"
	find $PID_CSV -type f -exec cp {} $PID_DIR \;

#Stage Temps Data for Transfer
	local TEMPS_CSV="${DAY_DIR}/LOGS/Temps/*.CSV"
	find $TEMPS_CSV -type f -exec cp {} $TEMPS_DIR \;

	echo "Successfully transferred all files woot woot!"
	echo "PID Files"
	ls $PID_DIR
	echo "Temps Files"
	ls $TEMPS_DIR
}

read -p ":) ENTER START DATE (YYYYMMDD-YYYYMMDD): " DATE_RANGE

START_DATE=$(echo $DATE_RANGE | cut -d'-' -f1)
END_DATE=$(echo $DATE_RANGE | cut -d'-' -f2)

if [[ ! $START_DATE =~ ^[0-9]{8}$ || ! $END_DATE =~ ^[00-9]{8}$ ]]; then
	echo "Uh oh: I don't like your input >:( Use the format YYYYMMDD-YYYYMMDD"
	exit 1
fi

if ! valid_input $START_DATE || ! valid_input $END_DATE; then
	echo "Invalid date range. Please enter a valid range."
	exit 1
fi

CURRENT_DATE=$START_DATE

while [[ $CURRENT_DATE -le $END_DATE ]]; do
	if ! check_date $CURRENT_DATE; then
		echo "There is no data for $CURRENT_DATE yet"
	else
		process_date $CURRENT_DATE
	fi
	CURRENT_DATE=$(date -d "$CURRENT_DATE +1 day" +"%Y%m%d")
done
