#!/bin/bash -e

if ! command -v docker-compose > /dev/null; then
  echo "The script require docker-compose to be installed on your machine."
  exit 1
fi

echo -e "

  _____                _  ____        _       _____  ______  _____ _______
 |  __ \              | |/ __ \      | |     |  __ \|  ____|/ ____|__   __|
 | |__) |___  __ _  __| | |  | |_ __ | |_   _| |__) | |__  | (___    | |
 |  _  // _ \/ _| |/ _| | |  | | '_ \| | | | |  _  /|  __|  \___ \   | |
 | | \ \  __/ (_| | (_| | |__| | | | | | |_| | | \ \| |____ ____) |  | |
 |_|  \_\___|\__,_|\__,_|\____/|_| |_|_|\__, |_|  \_\______|_____/   |_|
                                         __/ |
"

echo -e "This tool will help you to bootstrap PoC of a local ROR cluster connected to a remote Elastic cloud cluster.
Please, follow the instructions below ...\n"

read -p "Are you ready? Enter anything to continue ..."

echo -e "\nCertificates for SSL transport will be generated.
A connection between local ROR cluster and remote Elastic cluster will use two-way SSL.
ROR needs CA of the Elastic Cloud cluster, and the Elastic Cloud cluster needs ROR CA.
ROR cluster is going to have one node 'ror-es01'"

echo -e "
***********************************************************************
***                                                                 ***
***          DOWNLOADING ELASTIC CLOUD CLUSTER CA FILE              ***
***                                                                 ***
***********************************************************************
"

echo -e "To download your Elastic cloud cluster CA file, please:
1. go to https://cloud.elastic.co/home
2. pick one of your deployments and click \"Manage deployments\"
3. go to \"Security\" tab
4. in \"CA certificates\" section you should find a CA cert that you should download
"

while true; do
  read -p "Enter the downloaded CA file absolute path: " elasticCloudCaFilePath
  if [ -z $elasticCloudCaFilePath ]; then
    echo "It cannot be empty. Please try again ..."
    continue
  fi
  if [ -f $elasticCloudCaFilePath ]; then
    mkdir -p certs-generator/input
    cat $elasticCloudCaFilePath > certs-generator/input/elastic-cloud-ca.cer
    break
  else
    echo "The CA file cannot be found. Please try again ..."
    continue
  fi
done

echo -e "instances:
  - name: \"ror-es01\" #{node name}
    cn:
      - \"ror-es01.node.ror-cluster.ror-test\" #{node name}.node.{cluster name}.{scope}
    dns:
      - \"localhost\"
    ip:
      - \"127.0.0.1\"
" > certs-generator/input/ror-cluster-instances.yml

echo -e "
***********************************************************************
***                                                                 ***
***          GENERATING ROR CERTIFICATES AND ROR CA                 ***
***                                                                 ***
***********************************************************************
"

read -p "We have everything we need to generate ROR certificates and ROR CA. Enter anything to continue ..."

rm -rf certs
cd certs-generator
./run.sh > /dev/null 2>&1
cp -R output ../certs
./clean.sh > /dev/null 2>&1
cd ..

echo -e "\nCertificates and CA are generated:"
echo "$(pwd)/certs"
ls -l certs | grep -v '^total'

echo -e "
***********************************************************************
***                                                                 ***
***          ADDING TRUSTED ENVIRONMENT IN ELASTIC CLOUD            ***
***                                                                 ***
***********************************************************************
"

echo -e "Now, we have to tell Elastic Cloud cluster that our cluster is trusted:
0. we assume that you are still in the \"Security\" tab
1. in \"Trusted environments\" section click \"Add trusted environment\"
2. Pick \"Self-managed\" option and click \"Next\":
3. You will see a new page where you should configure a new trusted environment:
  a. in \"Add trusted CA certificate\" - drag and drop ROR CA cert from '$(pwd)/certs/ca/ca.crt'
  b. in \"Select trusted clusters\" - tick \"Trust clusters whose Common Name follows the Elastic pattern\", enter 'ror-test' as Scope ID and tick \"All deployments\"
  c. in \"Name your environment\" - pick your environment name (eg. my-local-ror-cluster)
4. Click \"Create trust\"
5. On the next page, click \"Done\". ROR cluster is added as the trusted environment.
\n"

read -p "When all steps are done, please enter anything to continue ..."

echo -e "
***********************************************************************
***                                                                 ***
***          CONFIGURING ELASTIC CLOUD AS THE REMOTE CLUSTER        ***
***                                                                 ***
***********************************************************************
"

echo -e "We're almost there. The last thing we need to do is configuring Elastic Cloud cluster as a remote cluster
in our nodes settings. To do that we need to have a Proxy Address and Server Name:
0. we assume that you are now in the \"Security\" tab
1. in \"Remote cluster parameters\" section you will find the \"Proxy address\" (click it to copy)
2. in \"Remote cluster parameters\" section you will find also the \"Server name\"' (click it to copy)
"

while true; do
  read -p "Enter \"Proxy address\": " proxyAddress
  if [ -z $proxyAddress ]; then
    echo "\"Proxy address\" cannot be empty. Please try again ..."
    continue
  fi

  export ES_CLOUD_PROXY_ADDRESS=$proxyAddress
  break
done

while true; do
  read -p "Enter \"Server name\": " serverName
  if [ -z $serverName ]; then
    echo "\"Server name\" cannot be empty. Please try again ..."
    continue
  fi

  export ES_CLOUD_SERVER_NAME=$serverName
  break
done

echo "
Great. This is all we need to run the ROR cluster ..."

echo -e "
***********************************************************************
***                                                                 ***
***          RUNNING THE ROR CLUSTER                                ***
***                                                                 ***
***********************************************************************
"

source ../utils/collect-info-about-ror-es-kbn.sh

docker-compose up -d --build --remove-orphans --force-recreate
docker-compose logs -f > ror-cluster.log 2>&1 &

echo -e "\nEverything is done. Elastic cluster is configured to be a remote cluster for the ROR local cluster.\n"

echo -e "
***********************************************************************
***                                                                 ***
***          TIME TO PLAY!!!                                        ***
***                                                                 ***
***********************************************************************
"

echo -e "You can access ROR KBN here: https://localhost:15601 (regular user: 'user1:test' or admin user: 'admin:admin')\n\n
Now, you can configure ROR settings and try to search remote cluster data (ES Cloud cluster is visible from local ROR cluster as 'escloud')."
