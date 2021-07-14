#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/msp/tlscacerts/tlsca.books.com-cert.pem
export PEER0_sellerorg_CA=${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/ca.crt
export PEER0_buyerorg_CA=${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/ca.crt
export PEER0_logisticorg_CA=${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/ca.crt
export PEER0_bankorg_CA=${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="sellerorgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_sellerorg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/sellerorg.books.com/users/Admin@sellerorg.books.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="buyerorgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_buyerorg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/buyerorg.books.com/users/Admin@buyerorg.books.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="logisticorgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_logisticorg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/logisticorg.books.com/users/Admin@logisticorg.books.com/msp
    export CORE_PEER_ADDRESS=localhost:6051

  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_LOCALMSPID="bankorgMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_bankorg_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/bankorg.books.com/users/Admin@bankorg.books.com/msp
    export CORE_PEER_ADDRESS=localhost:5051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.sellerorg.books.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.buyerorg.books.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.logisticorg.books.com:6051
  elif [ $USING_ORG -eq 4 ]; then
    export CORE_PEER_ADDRESS=peer0.bankorg.books.com:5051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
