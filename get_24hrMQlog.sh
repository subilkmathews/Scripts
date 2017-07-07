#!/usr/bin/ksh
#********************** Queue connection script***************************************#
# Author:              Subil Mathews                                                            #
# Purpose:             Check whether there were any errors reported for last 24 hours           #
#                              for a given queue manager                                        #
#***********************************************************************************************#
#************************************** Revision History ***************************************#
#       Date            Revision                                        Responsible Party       #
#       ____            ________                                        _________________       #
#       06/28/2017       Initial Creation for MQ 7.5.0.1 on Linux        Subil Mathews          #
#   This scripts checks the error files for a  Queue Queue_Manager and FDC files                #
#***********************************End Revision History ***************************************#

#set -x
qmgrname=$1
echo "making sure all required temp folders exists"
echo ""

mkdir -p /var/mqm/tmp
echo "finding the queue manager error log location"
echo ""
dspmqfls -m $qmgrname -t q SYSTEM.DEFAULT.LOCAL.QUEUE | grep qmgrs > /var/mqm/tmp/1.txt
                dir=`cut -d '/' -f1-5 /var/mqm/tmp/1.txt`
                                #echo Queue manager directory is $dir
                rm /var/mqm/tmp/1.txt
                sleep 1
errordir=$dir/errors
#find files modified last 24 hrs

echo "Finding files modified in last 24 hours"
sleep 1
find $dir/errors -mtime -1 -ls | grep AMQ | cut -d '/' -f7 > /var/mqm/tmp/AMQERROR.txt
find /var/mqm/errors/ -mtime -1 -ls | grep AMQ | cut -d '/' -f5 > /var/mqm/tmp/AMQFDC.txt
sleep 1

#patterns="error
#queue
#channel
#administrator"

date > /var/mqm/tmp/AMQERRlog.out
date > /var/mqm/tmp/24hrmqlog.out


#awk -v dt="$dt" '$0 ~ dt && /error|administrator|fail|warning|channel|ssl|ending/' $i

for i  in `cat /var/mqm/tmp/AMQERROR.txt` ; do

echo $i

grep -A 4 -B 5 -E 'error|administrator|fail|warn|channel|ssl|end|205|203|201|202|204|206|207|208|209|210|211|212|222|223|224|225|610|611|612' $errordir/$i >> /var/mqm/tmp/AMQERRlog.out
echo "<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>> " >> /var/mqm/tmp/AMQERRlog.out
echo " " >> /var/mqm/tmp/AMQERRlog.out
done
#filter out the error logs with 2 dates
day=$(date +%d);let "day -=1"; month=$(date +%m); year=$(date +%Y);echo $month/$day/$year ; sed  -n '/'"$month"'\/'"$day"'\/'"$year"'/,$p'  /var/mqm/tmp/AMQERRlog.out >> /var/mqm/tmp/24hrmqlog.out
day=$(date +%d); month=$(date +%m); year=$(date +%Y);echo $month/$day/$year ; sed  -n '/'"$month"'\/'"$day"'\/'"$year"'/,$p'  /var/mqm/tmp/AMQERRlog.out >> /var/mqm/tmp/24hrmqlog.out 
file2=/var/mqm/tmp/AMQFDC.txt

if [ ! -s "$file2" ];
then
echo " There is no queue manager FDC files within last 24 hours "
else

for i in `cat /var/mqm/tmp/AMQFDC.txt` ; do
echo $i

grep -A 1 -B 1 -E 'Probe|qmgrs' -m10  /var/mqm/errors/$i > /var/mqm/tmp/FDClog.out

done
fi;

echo "Completed processing FDC files"

file1=/var/mqm/tmp/AMQERROR.txt
file3=/var/mqm/tmp/24hrmqlog.out 
file4=/var/mqm/tmp/FDClog.out

if [ ! -s "$file3" ];
then
echo " There is no queue manager log files within last 24 hours for the queue manager $1"
else 
awk '!x[$0]++' $file3 > new24hrmqlog.out

cat  new24hrmqlog.out

rm new24hrmqlog.out
fi;

echo ""
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>."
echo ""

if [ ! -e "$file4" ];
then
echo "Completed"
else 
cat /var/mqm/tmp/FDClog.out
fi;
echo ""
echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>."
echo ""
