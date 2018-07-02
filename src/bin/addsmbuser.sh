#!/bin/bash

GROUPLIST="hoid_g bdarklighter gdarklighter jkholin mcauthun morpheus_g palpatine thrawn trinity ealvere ssanche lmandragoran etrekand tmerrilyn pababra "
USER_LIST="hoid biggs gavin jasnah matrim morpheus palpatine thrawn trinity egwane suian lan elaine thom perrin"
IDNUM_LIST="10024 10025 10026 10027 10028 10029 10030 10031 10032 10033"
SNLIST="hoid darklighter darklighter kholin cauthun morpheus palpatine thrawn trinity alvere sanche mandragoran trekand merrilyn ababra"
INLIST="hh bd gd jk mc mm tt tt ea ss lm et tm pa"

GPS=($GROUPLIST)
USERS=($USER_LIST)
IDNUMS=($IDNUM_LIST)
INS=($INLIST)
SNS=($SNLIST)

echo ${GPS}
NUM=${#GPS[*]}
X=0

echo "Num = ${NUM}"

while [[ ${X} -lt ${NUM} ]]  
do
    GP=${GPS[${X}]}
    USR=${USERS[${X}]}
    IDNUM=${IDNUMS[${X}]}
    IN=${INS[${X}]}
    SN=${SNS[${X}]}
    echo "GROUP = ${GP}"
    echo "USER  = ${USR}"
    echo "IDNUM = ${IDNUM}"
    echo "Surname = ${SN}"
    echo "Initials = ${IN}"

    sudo samba-tool group add ${GP} --gid-number ${IDNUM} --nis-domain=Olympus -U Administrator
    sudo samba-tool user create ${USR} --nis-domain=olympus --surname=${SN} --given-name=${USR} --initials=${IN} --unix-home=/home/samba/users/${GP} --uid-number=${IDNUM} --login-shell=/bin/bash --gid-number=${IDNUM} -U Administrator

    X=($X+1)
done
    
