#!/bin/bash

# CONFIG OPTIONS
ROOT_CA="Derber"
CA_LIST="root network identity component"
NET_LIST="olympus"
USERS="geoff"

function genreq () {
    CID=$1
    #NET=${"":$2}
    echo ${NET}
    if [[ ! -f "ca/${NET}${CID}.csr" ]] &&
	   [[ ! -f "ca/${NET}${CID}/private/${CID}.key" ]]; then
	echo "gen ca/${NET}${CID}.csr"
	echo "gen ca/${NET}${CID}/private/${CID}.key"
#    openssl req -new \
#	-config cnf/${NET}${CID}.conf \
#	-out ca/${NET}${CID}.csr \
#	-keyout ca/${CA}-ca/private/${CA}-ca.key
    else
	echo "Files exist"
    fi
}

function gencerts () {
    CA=$1
    PREVCA=$2
    NET=$3
    openssl ca ${METHOD} \
	-config cnf/${NET}${PREVCA}-ca.conf \
	-in ca/${NET}${CA}-ca.csr \
	-out ca/${NET}${CA}-ca.crt \
	-extensions ${LVL}_ca_ext \
	-enddate 20301231235959Z
}

function gencrl (){
    openssl ca -gencrl \
	    -config cnf/${NET}${CA}-ca.conf \
	    -out crl/${NET}${CA}-ca.crl
}

function gencrl_der () {
    openssl crl \
	    -in crl/network-ca.crl \
	    -out crl/network-ca.crl \
	    -outform der
 }

function prep_dirs () {
     	mkdir -p ca/${NET}${CA}-ca/{private|db} crl/${NET} certs/${NET}
	chmod 700 ca/${NET}${CA}-ca/private

	cp /dev/null ca/${NET}${CA}-ca/db/${CA}-ca.db{.attr}
	echo 01 > ca/${NET}${CA}-ca/db/${CA}-ca.{crt|crl}.srl
}

function genpem () {
	if [[ "${CA}" != "root" ]]; then
	    cat ca/${NET}${CA}-ca.crt ca/${PREVCA}-ca.crt > \
		ca/${NET}${CA}-ca-chain.pem
	fi
}

function genpkcs12 () {
    openssl pkcs12 -export \
    -name "Fred Flintstone (Blue Identity)" \
    -caname "Blue Identity CA" \
    -caname "Blue Network CA" \
    -caname "Blue Root CA" \
    -inkey certs/fred-id.key \
    -in certs/fred-id.crt \
    -certfile ca/identity-ca-chain.pem \
    -out certs/fred-id.p12
}

function revcert () {
    openssl ca \
    -config etc/identity-ca.conf \
    -revoke ca/identity-ca/02.pem \
    -crl_reason superseded
}

function gender () {
    openssl x509 \
    -in ca/root-ca.crt \
    -out ca/root-ca.cer \
    -outform der
}

function genpkcs7 () {
    openssl crl2pkcs7 -nocrl \
    -certfile ca/identity-ca-chain.pem \
    -out ca/identity-ca-chain.p7c \
    -outform der
}

function cleanold () {
    rm -rf crl ca certs
}

function main () {
    for NETWORK in ${NET_LIST}; do
	for CA in ${CA_LIST}; do
	    CID="${CA}-ca"
	    case $CA in
		root)
		    genreq $CID
		    PREVCA="root"
		    METHOD="-selfsign"
		    LVL="root"
		    NET=""
		    ;;
		network)
		    UP=""
		    PREVCA="root"
		    METHOD=""
		    LVL="intermediate"
		    NET="${NETWORK}/"
		    ;;
		*)
		    UP="${NETWORK}/"
		    PREV="${NETWORK}/network"
		    METHOD=""
		    LVL="signing"
		    NET="${NETWORK}/"
		    ;;
	    esac

	    echo "CA  = ${CA}"
	    echo "NET = ${NET}"
	done
    done
}

main $@
