#!/bin/bash

function createsellerorg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/sellerorg.books.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/sellerorg.books.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-sellerorg --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-sellerorg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-sellerorg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-sellerorg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-sellerorg.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-sellerorg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-sellerorg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-sellerorg --id.name sellerorgadmin --id.secret sellerorgadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-sellerorg -M "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/msp" --csr.hosts peer0.sellerorg.books.com --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-sellerorg -M "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls" --enrollment.profile tls --csr.hosts peer0.sellerorg.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/sellerorg.books.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/tlsca/tlsca.sellerorg.books.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/sellerorg.books.com/ca"
  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/peers/peer0.sellerorg.books.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/sellerorg.books.com/ca/ca.sellerorg.books.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-sellerorg -M "${PWD}/organizations/peerOrganizations/sellerorg.books.com/users/User1@sellerorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/sellerorg.books.com/users/User1@sellerorg.books.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://sellerorgadmin:sellerorgadminpw@localhost:7054 --caname ca-sellerorg -M "${PWD}/organizations/peerOrganizations/sellerorg.books.com/users/Admin@sellerorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/sellerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/sellerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/sellerorg.books.com/users/Admin@sellerorg.books.com/msp/config.yaml"
}

function createbuyerorg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/buyerorg.books.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/buyerorg.books.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-buyerorg --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-buyerorg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-buyerorg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-buyerorg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-buyerorg.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-buyerorg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-buyerorg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-buyerorg --id.name buyerorgadmin --id.secret buyerorgadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-buyerorg -M "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/msp" --csr.hosts peer0.buyerorg.books.com --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-buyerorg -M "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls" --enrollment.profile tls --csr.hosts peer0.buyerorg.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/buyerorg.books.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/tlsca/tlsca.buyerorg.books.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/buyerorg.books.com/ca"
  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/peers/peer0.buyerorg.books.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/buyerorg.books.com/ca/ca.buyerorg.books.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-buyerorg -M "${PWD}/organizations/peerOrganizations/buyerorg.books.com/users/User1@buyerorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/buyerorg.books.com/users/User1@buyerorg.books.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://buyerorgadmin:buyerorgadminpw@localhost:8054 --caname ca-buyerorg -M "${PWD}/organizations/peerOrganizations/buyerorg.books.com/users/Admin@buyerorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/buyerorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/buyerorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/buyerorg.books.com/users/Admin@buyerorg.books.com/msp/config.yaml"
}

function createlogisticorg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/logisticorg.books.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/logisticorg.books.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6054 --caname ca-logisticorg --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-logisticorg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-logisticorg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-logisticorg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-logisticorg.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-logisticorg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-logisticorg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-logisticorg --id.name logisticorgadmin --id.secret logisticorgadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-logisticorg -M "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/msp" --csr.hosts peer0.logisticorg.books.com --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-logisticorg -M "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls" --enrollment.profile tls --csr.hosts peer0.logisticorg.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/logisticorg.books.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/tlsca/tlsca.logisticorg.books.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/logisticorg.books.com/ca"
  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/peers/peer0.logisticorg.books.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/logisticorg.books.com/ca/ca.logisticorg.books.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-logisticorg -M "${PWD}/organizations/peerOrganizations/logisticorg.books.com/users/User1@logisticorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logisticorg.books.com/users/User1@logisticorg.books.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://logisticorgadmin:logisticorgadminpw@localhost:6054 --caname ca-logisticorg -M "${PWD}/organizations/peerOrganizations/logisticorg.books.com/users/Admin@logisticorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/logisticorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/logisticorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/logisticorg.books.com/users/Admin@logisticorg.books.com/msp/config.yaml"
}



function createbankorg() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/bankorg.books.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/bankorg.books.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:5054 --caname ca-bankorg --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-bankorg.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-bankorg.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-bankorg.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-5054-ca-bankorg.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-bankorg --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-bankorg --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-bankorg --id.name bankorgadmin --id.secret bankorgadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5054 --caname ca-bankorg -M "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/msp" --csr.hosts peer0.bankorg.books.com --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:5054 --caname ca-bankorg -M "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls" --enrollment.profile tls --csr.hosts peer0.bankorg.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/bankorg.books.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/tlsca/tlsca.bankorg.books.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/bankorg.books.com/ca"
  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/peers/peer0.bankorg.books.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/bankorg.books.com/ca/ca.bankorg.books.com-cert.pem"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:5054 --caname ca-bankorg -M "${PWD}/organizations/peerOrganizations/bankorg.books.com/users/User1@bankorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bankorg.books.com/users/User1@bankorg.books.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://bankorgadmin:bankorgadminpw@localhost:5054 --caname ca-bankorg -M "${PWD}/organizations/peerOrganizations/bankorg.books.com/users/Admin@bankorg.books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/bankorg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/bankorg.books.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/bankorg.books.com/users/Admin@bankorg.books.com/msp/config.yaml"
}


function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/books.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/books.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/books.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/msp" --csr.hosts orderer.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/books.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls" --enrollment.profile tls --csr.hosts orderer.books.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/msp/tlscacerts/tlsca.books.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/books.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/books.com/orderers/orderer.books.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/books.com/msp/tlscacerts/tlsca.books.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/books.com/users/Admin@books.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/books.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/books.com/users/Admin@books.com/msp/config.yaml"
}
