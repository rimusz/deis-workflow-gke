#!/bin/bash

install() {
  # get k8s cluster name
  cluster

  # get lastest macOS helmc cli version
  install_helmc

  # get lastest macOS deis cli version
  install_deis

  # add Deis Chart repo
  echo "Adding Deis Chart repository ... "
  helmc repo add deis https://github.com/deis/charts
  # get the latest version of all Charts from all repos
  echo " "
  echo "Get the latest version of all Charts from all repos ... "
  helmc up

  # get latest Workflow version
  echo " "
  echo "Getting latest Deis Workflow version ..."
  WORKFLOW_RELEASE=$(ls ~/.helmc/cache/deis | grep workflow-v2. | grep -v -e2e | sort -rn | head -1 | cut -d'-' -f2)
  echo "Got Deis Workflow ${WORKFLOW_RELEASE} ..."

  # delete the old folder if such exists
  rm -rf ~/.helmc/workspace/charts/workflow-${WORKFLOW_RELEASE}-${K8S_NAME} > /dev/null 2>&1

  # fetch Deis Workflow Chart to your helmc's working directory
  echo " "
  echo "Fetching Deis Workflow Chart to your helmc's working directory ..."
  helmc fetch deis/workflow-${WORKFLOW_RELEASE} workflow-${WORKFLOW_RELEASE}-${K8S_NAME}

  ####
  # set env vars
  # so we do not have to edit generate_params.toml in chart’s tpl folder
  # set storage to GCS
  STORAGE_TYPE=gcs
  GCS_KEY_JSON=$(cat service_account_key.json)
  GCS_REGISTRY_BUCKET=${K8S_NAME}-deis-registry
  GCS_DATABASE_BUCKET=${K8S_NAME}-deis-database
  GCS_BUILDER_BUCKET=${K8S_NAME}-deis-builder
  # set off-cluster registry
  REGISTRY_LOCATION=gcr
  GCR_KEY_JSON=$(cat service_account_key.json)
  if [[ "$1" == "eu" ]]
  then
    GCR_HOSTNAME="eu.gcr.io"
  else
    GCR_HOSTNAME=""
  fi
  #
  export STORAGE_TYPE GCS_KEY_JSON GCS_REGISTRY_BUCKET GCS_DATABASE_BUCKET GCS_BUILDER_BUCKET REGISTRY_LOCATION GCR_KEY_JSON GCR_HOSTNAME
  ###
  if [[ "$1" == "eu" ]]
  then
    # create GCS buckets in EU region
    echo " "
    echo "Creating GCS buckets in EU region..."
    gsutil mb -l eu gs://${GCS_REGISTRY_BUCKET}
    gsutil mb -l eu gs://${GCS_DATABASE_BUCKET}
    gsutil mb -l eu gs://${GCS_BUILDER_BUCKET}
  fi
  ####

  # set off-cluster Postgres
  set_database

  # generate manifests
  echo " "
  echo "Generating Workflow ${WORKFLOW_RELEASE}-${K8S_NAME} manifests ..."
  helmc generate -x manifests -f workflow-${WORKFLOW_RELEASE}-${K8S_NAME}

  # install Workflow
  echo " "
  echo "Installing Workflow ..."
  helmc install workflow-${WORKFLOW_RELEASE}-${K8S_NAME}

  # Waiting for Deis Workflow to be ready
  wait_for_workflow
  #

  # get router's external IP
  echo " "
  echo "Fetching Router's LB external IP:"
  LB_IP=$(kubectl --namespace=deis get svc | grep [d]eis-router | awk '{ print $3 }')
  echo "$LB_IP"

  echo " "
  echo "Workflow install ${WORKFLOW_RELEASE} is done ..."
  echo " "
}

upgrade() {
  # get k8s cluster name
  cluster

  # get lastest macOS helmc cli version
  install_helmc

  # get lastest macOS deis cli version
  install_deis

  # get the latest version of all Charts from all repos
  echo " "
  echo "Get the latest version of all Charts from all repos ... "
  helmc up
  echo " "

  # Fetch the current database credentials
  echo " "
  echo "Fetching the current database credentials ..."
  kubectl --namespace=deis get secret database-creds -o yaml > ~/tmp/active-deis-database-secret-creds.yaml

  # Fetch the builder component ssh keys
  echo " "
  echo "Fetching the builder component ssh keys ..."
  kubectl --namespace=deis get secret builder-ssh-private-keys -o yaml > ~/tmp/active-deis-builder-secret-ssh-private-keys.yaml

  # export environment variables for the previous and latest Workflow versions
  export PREVIOUS_WORKFLOW_RELEASE=$(cat ~/tmp/active-deis-builder-secret-ssh-private-keys.yaml | grep chart.helm.sh/version: | awk '{ print $2 }')
  export DESIRED_WORKFLOW_RELEASE=$(ls ~/.helmc/cache/deis | grep workflow-v2. | grep -v -e2e | sort -rn | head -1 | cut -d'-' -f2)

  # delete the old chart folder if such exists
  rm -rf ~/.helmc/workspace/charts/workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME} > /dev/null 2>&1

  # Fetching the new chart copy from the chart cache into the helmc workspace for customization
  echo " "
  echo "Fetching Deis Workflow Chart to your helmc's working directory ..."
  helmc fetch deis/workflow-${DESIRED_WORKFLOW_RELEASE} workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME}

  ####
  # set env vars
  # so we do not have to edit generate_params.toml in chart’s tpl folder
  # set storage to GCS
  STORAGE_TYPE=gcs
  GCS_KEY_JSON=$(cat service_account_key.json)
  GCS_REGISTRY_BUCKET=${K8S_NAME}-deis-registry
  GCS_DATABASE_BUCKET=${K8S_NAME}-deis-database
  GCS_BUILDER_BUCKET=${K8S_NAME}-deis-builder
  # set off-cluster registry
  DEIS_REGISTRY_LOCATION=gcr
  GCR_KEY_JSON=$(cat service_account_key.json)
  if [[ "$2" == "eu" ]]
  then
    GCR_HOSTNAME=eu.gcr.io
  else
    GCR_HOSTNAME=""
  fi

  # export values as environment variables
  export STORAGE_TYPE GCS_KEY_JSON GCS_REGISTRY_BUCKET GCS_DATABASE_BUCKET GCS_BUILDER_BUCKET REGISTRY_LOCATION GCR_KEY_JSON GCR_HOSTNAME
  ####

  # set off-cluster Postgres
  set_database

  # Generate templates for the new release
  echo " "
  echo "Generating Workflow ${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME} manifests ..."
  helmc generate -x manifests workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME}

  # Copy your active database secrets into the helmc workspace for the desired version
  cp -f ~/tmp/active-deis-database-secret-creds.yaml \
    $(helmc home)/workspace/charts/workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME}/manifests/deis-database-secret-creds.yaml

  # Copy your active builder ssh keys into the helmc workspace for the desired version
  cp -f ~/tmp/active-deis-builder-secret-ssh-private-keys.yaml \
    $(helmc home)/workspace/charts/workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME}/manifests/deis-builder-secret-ssh-private-keys.yaml

  # Uninstall Workflow
  echo " "
  echo "Uninstalling Workflow ${PREVIOUS_WORKFLOW_RELEASE} ... "
  helmc uninstall workflow-${PREVIOUS_WORKFLOW_RELEASE}-${K8S_NAME} -n deis

  sleep 3

  # Install of latest Workflow release
  echo " "
  echo "Installing Workflow ${DESIRED_WORKFLOW_RELEASE} ... "
  helmc install workflow-${DESIRED_WORKFLOW_RELEASE}-${K8S_NAME}

  # Waiting for Deis Workflow to be ready
  wait_for_workflow

  echo " "
  echo "Workflow upgrade to ${DESIRED_WORKFLOW_RELEASE} is done ..."
  echo " "

}

set_database() {
if [[ ! -f postgres_settings ]]
then
  echo " "
  echo "No postgres_settings file found !!! "
  echo "PostgreSQL database will be set to on-cluster ..."
else
  echo " "
  echo "postgres_settings file found !!!"
  echo "PostgreSQL database will be set to off-cluster ..."
  DATABASE_LOCATION="off-cluster"
  # import values from file
  source postgres_settings
  # export values as environment variables
  export DATABASE_LOCATION DATABASE_HOST DATABASE_PORT DATABASE_NAME DATABASE_USERNAME DATABASE_PASSWORD
fi
}

cluster() {
  # get k8s cluster name
  echo " "
  echo "Fetching GKE cluster name ..."
  K8S_NAME=$(kubectl config current-context)
  echo "GKE cluster name is ${K8S_NAME} ..."
  echo " "
}

install_deis() {
  # get lastest macOS deis cli version
  echo "Downloading latest version of Workflow deis cli ..."
  curl -o ~/bin/deis https://storage.googleapis.com/workflow-cli/deis-latest-darwin-amd64
  chmod +x ~/bin/deis
  echo " "
  echo "Installed deis cli to ~/bin ..."
  echo " "
}

install_helmc() {
  # get lastest macOS helmc cli version
  echo "Downloading latest version of helmc cli ..."
  curl -o ~/bin/helmc https://storage.googleapis.com/helm-classic/helmc-latest-darwin-amd64
  chmod +x ~/bin/helmc
  echo " "
  echo "Installed helmc cli to ~/bin ..."
  echo " "
}

wait_for_workflow() {
  echo " "
  echo "Waiting for Deis Workflow to be ready... but first, coffee! "
  spin='-\|/'
  i=1
  until kubectl --namespace=deis get po | grep [d]eis-builder- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  until kubectl --namespace=deis get po | grep [d]eis-registry- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  until kubectl --namespace=deis get po | grep [d]eis-database- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  until kubectl --namespace=deis get po | grep [d]eis-registry- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  until kubectl --namespace=deis get po | grep [d]eis-router- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  until kubectl --namespace=deis get po | grep [d]eis-controller- | grep "1/1"  >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
  echo " "
}

usage() {
    echo "Usage: install_workflow_2_gke.sh install [eu] | upgrade [eu] | deis | helmc | cluster"
}

case "$1" in
        install)
                install $2
                ;;
        upgrade)
                upgrade $2
                ;;
        deis)
                install_deis
                ;;
        helmc)
                install_helmc
                ;;
        cluster)
                cluster
                ;;
        *)
                usage
                ;;
esac
