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
#
# ======================================================================
function __help () {
    cat << HELP
Addsmbuser

Add Samba User:
...
HELP
}

# ======================================================================
#
# function getmaxuid
#
# ======================================================================
function getmaxuid () {
    #IDNUM=$(ldapsearch -H ldaps://your-ldap-domain -D "cn=Manager,dc=domain,dc=com" -W | awk '/uidNumber: / {print $2}' | sort | tail -n 1)
    IDNUM=10032
    echo -ne ${IDNUM}
}

# ======================================================================
#
# getusername
#
# ======================================================================
function getusername () {
    GN=${1}
    SN=${2}
    if [[ -z ${SN} ]]; then
	USERNAME=$(echo ${GN}|sed 's/[^a-zA-Z0-9]//g'|tr [A-Z] [a-z])
    else
	FI=$(echo ${GN}|cut -c1|sed 's/[^a-zA-Z0-9]//g'|tr [A-Z] [a-z])
	SN=$(echo ${SN}|sed 's/[^a-zA-Z0-9]//g'|tr [A-Z] [a-z])
	USERNAME=${FI}${SN}
    fi
    echo -ne ${USERNAME}
}

# ======================================================================
#
# Getdomain
#
# ======================================================================
function getdomain () {
    #sed to strip spaces would be better
    DOMAIN=$(grep workgroup /etc/samba/smb.conf|cut -d= -f2|cut -d\  -f2) 
    echo -ne ${DOMAIN}
}

# ======================================================================
#
# Addusers
#
# ======================================================================
function addusers () {
    DEBUG=$1
    IDNUM=$(getmaxuid)
    DOMAIN=$(getdomain)
    INPUTFILE=userlist
    
    while IFS='' read -r -u 3  LINE || [[ -n "$LINE" ]]
    do
	GN="$(echo ${LINE} | cut -d\; -f1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	SN="$(echo ${LINE} | cut -d\; -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
       	IN="$(echo ${LINE} | cut -d\; -f3 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	NICK="$(echo ${LINE} | cut -d\; -f4 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	DESC="$(echo ${LINE} | cut -d\; -f5 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	TITLE="$(echo ${LINE} | cut -d\; -f6 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	COMPANY="$(echo ${LINE} | cut -d\; -f7 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	DEPT="$(echo ${LINE} |cut -d\; -f8 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	OFFICE="$(echo ${LINE} |cut -d\; -f9 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	EMAIL="$(echo ${LINE} | cut -d\; -f10 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	WEBSITE="$(echo ${LINE} | cut -d\; -f11 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	PHONE="$(echo ${LINE} | cut -d\; -f12 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	GECOS="$(echo ${LINE} | cut -d\; -f13 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	PASSWORD="$(echo ${LINE} | cut -d\; -f14 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
	IDNUM1="$(echo ${LINE} | cut -d\; -f15)"

	IDNUM=${IDNUM1:-IDNUM}	
	if [[ -n ${NICK} ]]; then
	    USERNAME=$(echo ${NICK}|sed 's/[^a-zA-Z0-9]//g'|tr [A-Z] [a-z])
	else
	    USERNAME=$(getusername ${GN} ${SN})
	fi
       	GROUPNAME=${USERNAME}_g
    
	HPATH="\\\\aphrodite\\users\\${USERNAME}"
	PPATH="\\\\aphrodite\\profile\\${USERNAME}"
#	SPATH=$(echo ${LINE}|cut -d, -f1)
	DLTR="H:"

	FQDN=$(domainname -f |cut -d. -f3-)	
	EMAIL="${USERNAME}@${FQDN}"

	echo "USER  = ${USERNAME}"
	echo "GROUP = ${GROUPNAME}"
	echo "IDNUM = ${IDNUM}"
	echo "Domain = ${DOMAIN}"
	echo "HPATH = ${HPATH}"
	echo "DLTR = ${DLTR}"
	echo "PPATH = ${PPATH}"
	echo "1.  Given Name   : ${GN}"
	echo "2.  Surname      : ${SN}"
	echo "3.  Initial      : ${IN}"
	echo "4.  Nickname     : ${NICK}"
	echo "5.  Description  : ${DESC}"
	echo "6.  Title        : ${TITLE}"
	echo "7.  Organization : ${COMPANY}"
	echo "8.  Org Unit     : ${DEPT}"
	echo "9.  Email        : ${EMAIL}"
	echo "10. Website      : ${WEBSITE}"
	echo "11. Address      : ${OFFICE}"
	echo "12. Phone        : ${PHONE}"
	echo "13. GECOS        : ${GECOS}"
	echo "14. Password     : ${PASSWORD}"


	

#	read -p "Continue? (Y/N): " confirm &&
#	    [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] ||
#		exit 1

	[[ -n ${SN} ]] && OPTS="--surname=${SN}"
	[[ -n ${IN} ]] && OPTS="${OPTS} --initials=${IN}"
	[[ -n ${PPATH} ]] && OPTS="${OPTS} --profile-path=${PPATH}"
	[[ -n ${DRIVELTR} ]] && OPTS="${OPTS} --home-drive=${DRIVELTR}"
	[[ -n ${HPATH} ]] && OPTS="${OPTS} --home-directory=${HPATH}"
	[[ -n ${SPATH} ]] && OPTS="${OPTS} --script-path=${SPATH}"
	[[ -n ${TITLE} ]] && OPTS="${OPTS} --job-title=${TITLE}"
	[[ -n ${DEPT} ]] && OPTS="${OPTS} --department=${DEPT}"
	[[ -n ${COMPANY} ]] && OPTS="${OPTS} --company=${COMPANY}"
	#[[ -n ${DESC} ]] && OPTS="${OPTS} --description=${DESCRIPTION}"
	[[ -n ${EMAIL} ]] && OPTS="${OPTS} --mail-address=${EMAIL}"
	[[ -n ${WEBSITE} ]] && OPTS="${OPTS} --internet-address=${WEBSITE}"
	[[ -n ${PHONE} ]] && OPTS="${OPTS} --telephone-number=${PHONE}"
	[[ -n ${OFFICE} ]] && OPTS="${OPTS} --physical-delivery-office=${OFFICE}"
	[[ -n ${GECOS} ]] && OPTS="${OPTS} --gecos=${GECOS}"
	
	if [[ "${DEBUG}" != "true" ]]; then
	    sudo samba-tool group \
		add ${GROUPNAME} \
		--gid-number ${IDNUM} \
		--nis-domain=${DOMAIN} \
		-U Administrator

	    echo "sudo samba-tool user create ${USERNAME} ${PASSWORD} --given-name=${GN} --nis-domain=${DOMAIN} --unix-home=/home/${USERNAME} --uid-number=${IDNUM} --gid-number=${IDNUM} --login-shell=/bin/bash ${OPTS} -U Administrator"

	   sudo samba-tool user \
		create ${USERNAME} ${PASSWORD} \
		--given-name=${GN} \
		--nis-domain=${DOMAIN} \
		--unix-home=/home/${DOMAIN}/${USERNAME} \
		--uid-number=${IDNUM} \
		--gid-number=${IDNUM} \
		--login-shell=/bin/bash \
		${OPTS} -U Administrator
	fi

	unset USERNAME
	unset GROUPNAME
	unset GN
	unset SN
	unset IN
	unset NICK
	unset DESC
	unset TITLE
	unset COMPANY
	unset DEPT
	unset EMAIL
	unset WEBSITE
	unset OFFICE
	unset PHONE
	unset GECOS
	unset PASSWORD
	unset OPTS
	unset SURNAME
	unset INITIALS
	unset PROFILEPATH
	unset DLTR
	unset HDIR
	unset SPATH
	unset IDNUM1

	IDNUM=$(( $IDNUM + 1 ))
    done 3< ${INPUTFILE}
}
    
# ======================================================================
#
# Main
#
# ======================================================================
function main () {
    while [ -n "$1" ]
    do
	case $1 in
	    --test|-t)
		TEST=true
		shift 1
		;;
	    *)
		__help
		exit
		;;
	esac
    done
    addusers $TEST
}

main "$@"
