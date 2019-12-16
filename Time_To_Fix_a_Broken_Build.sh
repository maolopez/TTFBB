#!/bin/bash -x

#WARNING: This scripts requires "jq" (https://stedolan.github.io/jq/)
#WARNING This script requires "dateutils" (https://github.com/hroptatyr/dateutils) to be installed in your local dependencies.
#Jenkins Timestampers: System clock time format '<b>'HH:mm:ss'</b> ' Elapsed time format  '<b>'HH:mm:ss.S'</b> '

#set proxy
export http_proxy=http://oproxy.JencoMart.com:8080
export https_proxy=http://oproxy.JencoMart.com:8080

#query the Jenkins API for the Last Successful Build
SUCCESSFUL_BUILD_STRING=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/lastSuccessfulBuild/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."id",."duration",."timestamp"'`

#Split the Build Number, Build Duration and Time stamp into 3 variables
#trying to keep API call requests to the minimum
ssafename="$(echo $SUCCESSFUL_BUILD_STRING | sed 's/ /-/g')"
SBUILDNUMBER=`echo $ssafename | awk '{split($0,a,"-"); print a[1]}'`
SBUILDNUMBER="${SBUILDNUMBER%\"}"
SBUILDNUMBER="${SBUILDNUMBER#\"}"
SDURATION=`echo $ssafename | awk '{split($0,a,"-"); print a[2]}'`
STIMESTAMP=`echo $ssafename | awk '{split($0,a,"-"); print a[3]}'`
#----Put while loop here
            BUILDNUMBER=$SBUILDNUMBER
            SUCCESS_BUILD_STRING_RESULT=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."result"'`
            SUCCESS_BUILD_STRING_RESULT="${SUCCESS_BUILD_STRING_RESULT%\"}"
            SUCCESS_BUILD_STRING_RESULT="${SUCCESS_BUILD_STRING_RESULT#\"}"
            while [ "$SUCCESS_BUILD_STRING_RESULT" = "SUCCESS" ]
               do
                 SUCCESS_BUILD_STRING=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword |  /usr/local/bin/jq '."id",."duration",."timestamp"'`
                 s2safename="$(echo $SUCCESS_BUILD_STRING | sed 's/ /-/g')"
                 S2BUILDNUMBER=`echo $s2safename | awk '{split($0,a,"-"); print a[1]}'`
                 S2BUILDNUMBER="${S2BUILDNUMBER%\"}"
                 S2BUILDNUMBER="${S2BUILDNUMBER#\"}"
                 S2DURATION=`echo $s2safename | awk '{split($0,a,"-"); print a[2]}'`
                 STIMESTAMP=`echo $s2safename | awk '{split($0,a,"-"); print a[3]}'`
                 BUILDNUMBER=`expr $S2BUILDNUMBER - 1`
                 SUCCESS_BUILD_STRING_RESULT=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."result"'`
                 SUCCESS_BUILD_STRING_RESULT="${SUCCESS_BUILD_STRING_RESULT%\"}"
                 SUCCESS_BUILD_STRING_RESULT="${SUCCESS_BUILD_STRING_RESULT#\"}"
               done
#----
#DAte-Time management converting Epoch to date
RSDATESTAMP=`date "+$STIMESTAMP: %Y-%m-%d%nT:%H:%M:%S"`
RSTIMESTAMP=`echo $RSDATESTAMP`
RSDATESTAMP=`echo $RSDATETAMP| awk '{print $2}'`
RSTIMESTAMP=`echo $RSTIMESTAMP| awk -F "T:" '{print $2}'`

#Query the Jenkins API for the last Failed Build
LAST_FAILED_BUILD_STRING=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/lastFailedBuild/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."id",."duration",."timestamp"'`
#Split the Build Number, Build Duration and Time stamp into 3 variables while 
#trying to keep API call requests to the minimum
ffsafename="$(echo $LAST_FAILED_BUILD_STRING | sed 's/ /-/g')"
FFBUILDNUMBER=`echo $ffsafename | awk '{split($0,a,"-"); print a[1]}'`
FFBUILDNUMBER="${FFBUILDNUMBER%\"}"
FFBUILDNUMBER="${FFBUILDNUMBER#\"}"
FFDURATION=`echo $ffsafename | awk '{split($0,a,"-"); print a[2]}'`
FFTIMESTAMP=`echo $ffsafename | awk '{split($0,a,"-"); print a[3]}'`
#Date-Time Management converting Epoch to date
RFFDATESTAMP=`date "+$FFTIMESTAMP: %Y-%m-%d%nT:%H:%M:%S"`
RFFTIMESTAMP=`echo $RFFDATESTAMP`
RFFDATESTAMP=`echo $RFFDATESTAMP | awk '{print $2}'`
RFFTIMESTAMP=`echo $RFFTIMESTAMP| awk -F "T:" '{print $2}'`

#Obtain the TTFBB variables when last Failed Build is most recent that Last Successful Build

    if [[ ${STIMESTAMP} -lt ${FFTIMESTAMP} ]]; then
            echo "LATEST BUILD FAILED!, Please Fix it!";
            exit             
    else
            echo "LATEST BUILD IS SUCCESSFUL!";
            BUILDNUMBER=$FFBUILDNUMBER
            FAILED_BUILD_STRING_RESULT=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."result"'`
            FAILED_BUILD_STRING_RESULT="${FAILED_BUILD_STRING_RESULT%\"}"
            FAILED_BUILD_STRING_RESULT="${FAILED_BUILD_STRING_RESULT#\"}"
            while [ "$FAILED_BUILD_STRING_RESULT" = "FAILURE" ]
               do
                 FAILED_BUILD_STRING=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword |  /usr/local/bin/jq '."id",."duration",."timestamp"'`
                 fsafename="$(echo $FAILED_BUILD_STRING | sed 's/ /-/g')"
                 FBUILDNUMBER=`echo $fsafename | awk '{split($0,a,"-"); print a[1]}'`
                 FBUILDNUMBER="${FBUILDNUMBER%\"}"
                 FBUILDNUMBER="${FBUILDNUMBER#\"}"
                 FDURATION=`echo $fsafename | awk '{split($0,a,"-"); print a[2]}'`
                 FTIMESTAMP=`echo $fsafename | awk '{split($0,a,"-"); print a[3]}'`
                 BUILDNUMBER=`expr $FBUILDNUMBER - 1`
                FAILED_BUILD_STRING_RESULT=`curl -sk https://jenkins-Dev-gcp.apps.c1-ocp-dc1.DevJencoMart.com/job/Dev-gcp/job/Test/$BUILDNUMBER/api/json --user YourUserName:YourPassword | /usr/local/bin/jq '."result"'`
                FAILED_BUILD_STRING_RESULT="${FAILED_BUILD_STRING_RESULT%\"}"
                FAILED_BUILD_STRING_RESULT="${FAILED_BUILD_STRING_RESULT#\"}"
               done  
    fi

#Date-Time Management converting Epoch to date and TTFBB calculations
RFDATESTAMP=`date "+$FTIMESTAMP: %Y-%m-%d%nT:%H:%M:%S"`
RFTIMESTAMP=`echo $RFDATESTAMP`
RFDATESTAMP=`echo $RFDATESTAMP| awk '{print $2}'`
RFTIMESTAMP=`echo $RFTIMESTAMP| awk -F "T:" '{print $2}'`
echo "The latest Successful Build was Build Number: '$SBUILDNUMBER', Duration: '$SDURATION', Date: '$RSDATESTAMP', Time: '$RSTIMESTAMP' "
echo "The latest Failed Build was Build Number: '$FFBUILDNUMBER', Duration: '$FFDURATION', Date: '$RFFDATESTAMP', Time: '$RFFTIMESTAMP'"
echo "The first failure before the last Failed Build was Build Number: '$FBUILDNUMBER', Duration: '$FDURATION', Date: '$RFDATESTAMP', Time: '$RFTIMESTAMP'"
TIME_TO_FIX_A_BROKEN_BUILD_RAW=`expr $STIMESTAMP - $FTIMESTAMP`
TIME_TO_FIX_A_BROKEN_BUILD=$(echo $((TIME_TO_FIX_A_BROKEN_BUILD_RAW / 1000)))
echo "The Time to Fix a Broken Build is '$TIME_TO_FIX_A_BROKEN_BUILD' seconds"
exit
