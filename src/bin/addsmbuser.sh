#!/bin/bash
# ======================================================================
#
# Add Smb User
#
# Geoff S Derber
#
#
# ======================================================================

# ======================================================================
#
# function getmaxuid
function getmaxuid () {
    #IDNUM=$(ldapsearch -H ldaps://your-ldap-domain -D "cn=Manager,dc=domain,dc=com" -W | awk '/uidNumber: / {print $2}' | sort | tail -n 1)
    IDNUM=10026
    echo -ne ${IDNUM}
}

function getusername () {
    GN=${1}
    SN=${2}
    if [[ -z ${SN} ]]; then
	USERNAME=${GN}
    else
	FI=$(echo ${GN}|cut -c1|tr [A-Z] [a-z]}
	USERNAME=${FI}${SN}
    fi
    echo -ne ${USERNAME}
}

function getdomain () {
    DOMAIN=$(grep workgroup /etc/samba/smb.conf|cut -d= -f2|cut -d\  -f2) #sed to strip spaces would be better
    echo -ne ${DOMAIN}
}

function addusers () {
    IDNUM=$(getmaxuid)
    DOMAIN=${DOMAIN}
    INPUTFILE=userlist
    
    while IFS='' read -r LINE || [[ -n "$LINE" ]]
    do
	GN=$(echo ${LINE}|cut -d, -f1)
	SN=$(echo ${LINE}|cut -d, -f2)
       	IN=$(echo ${LINE}|cut -d, -f3)
	NICK=$(echo ${LINE}|cut -d, -f4)

	if [[ -n ${NICK} ]]; then
	    USERNAME=${NICK}
	else
	    USERNAME=$(getusername)
	fi
       	GROUPNAME=${USERNAME}_g
    
	PPATH=$(echo ${LINE}|cut -d, -f1)
	SPATH=$(echo ${LINE}|cut -d, -f1)
	DLTR=$(echo ${LINE}|cut -d, -f1)

	[[ -n ${SN} ]] && SURNAME="--surname=${SN}"
	[[ -n ${IN} ]] && INITIALS="--initials=${IN}"
	[[ -n ${PPATH} ]] && PROFILEPATH="--profile-path=${PPATH}"
	[[ -n ${DRIVELTR} ]] && DLTR="--home-drive=${DRIVELTR}"
	[[ -n ${HPATH} ]] && HDIR="--home-directory=${HPATH}"
	[[ -n ${SPATH} ]] && SPATH="--script-path=${SPATH}"
	[[ -n ${TITLE} ]] && TITLE="--job-title=${TITLE}"
	[[ -n ${DEPT} ]] && DEPT="--department=${DEPT}"
	[[ -n ${COMPANY} ]] && COMPANY="--company=${COMPANY}"
	[[ -n ${DESC} ]] && DESC="--description=${DESCRIPTION}"
	[[ -n ${EMAIL} ]] && EMAIL="--mail-address=${EMAIL}"
	[[ -n ${WEBSITE} ]] && WEBSITE="--internet-address=${WEBSITE}"
	[[ -n ${PHONE} ]] && PHONE="--telephone-number=${PHONE}"
	[[ -n ${OFFICE} ]] && OFFICE="--physical-delivery-office=${OFFICE}"
	[[ -n ${GECOS} ]] && GECOS="--gecos=${GECOS}"

	OPT="${SURNAME} ${INITIALS} ${PROFILEPATH} ${DLTR} ${HDIR} ${SPATH} ${TITLE} ${DEPT} ${COMPANY} ${DESC} ${EMAIL} ${WEBSITE} ${PHONE} ${OFFICE} ${GECOS}"

	echo "GROUP = ${GROUPNAME}"
	echo "USER  = ${USERNAME}"
	echo "IDNUM = ${IDNUM}"

	sudo samba-tool group \
	     add ${GROUPNAME} \
	     --gid-number ${IDNUM} \
	     --nis-domain=${DOMAIN} \
	     -U Administrator
	
	sudo samba-tool user \
	     create ${USERNAME} \
	     --given-name=${GN} \
	     --nis-domain=${DOMAIN} \
	     --unix-home=/home/${USERNAME} \
	     --uid-number=${IDNUM} \
	     --gid-number=${IDNUM} \
	     --login-shell=/bin/bash \
	     ${OPTS} -U Administrator

	IDNUM=($IDNUM+1)
    done < ${INPUTFILE}
}
    
function main () {
    addusers
}

main $@
