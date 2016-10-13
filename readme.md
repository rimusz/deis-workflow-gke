Install and upgrade Deis Workflow PaaS in GKE without fuss
========================

It allows to install [Deis Workflow PaaS](https://deis.com/workflow/) on to GKE with persistent [Object Storage](https://deis.com/docs/workflow/installing-workflow/configuring-object-storage/) set to [Google Cloud Storage](https://cloud.google.com/storage/) and Docker Registry to [gcr.io](https://cloud.google.com/container-registry/)
and has an option to set PostgreSQL database to [off-cluster](https://deis.com/docs/workflow/installing-workflow/configuring-postgres/#provisioning-off-cluster-postgres) use.
How to install
----------


Clone repository:

```
$ git clone https://github.com/rimusz/deis-workflow-gke
```

**Note:** You need to get GCP [Service Account key](https://cloud.google.com/compute/docs/access/service-accounts) which has write access to GCS and GCR, so Workflow will be able to access them. Please name that file as `service_account_key.json`.


How it works
------------

```
$ ./install_workflow_2_gke.sh
Usage: install_workflow_2_gke.sh install [eu] | upgrade [eu] | deis | helmc | cluster
```

You will be able:

- install - by defautl sets Object Storage to US region, use `eu` flag for EU region
- upgrade - upgrades to the latest Workflow version (you must use the same region as was for install)
- deis - fetches the latest Workflow `deis` cli
- helmc - fetches the latest [Helm Classic](https://github.com/helm/helm-classic) cli
- cluster - shows cluster GKE name

Also if you rename/copy `postgres_settings.tpl` file to `postgres_settings`, then you can set PostgreSQL database to [off-cluster](https://deis.com/docs/workflow/installing-workflow/configuring-postgres/#provisioning-off-cluster-postgres).
As Google Cloud Platform does not have hosted Postgres, you can use [compose.io](https://www.compose.com/postgresql) hosted one, which supports GCP deployment or install it with [Helm](http://helm.sh) [PostgreSQL](https://github.com/bitnami/charts/tree/master/postgresql) chart.

What the [install](https://deis.com/docs/workflow/installing-workflow/) will do:

- Gets GKE cluster name which is used to create GCS buckets and Helm chart
- Downloads lastest `helmc` cli version
- Downloads lastest `deis` cli version
- Adds Deis Chart repository
- Fetches latest Workflow chart
- Sets storage to GCS
- Sets Registry to grc.io
- If `postgres_settings` file found sets PostgeSQL database to off-cluster 
- Generates chart
- Installs Workflow
- Shows `deis-router` external IP

What the [upgrade](https://deis.com/docs/workflow/managing-workflow/upgrading-workflow/) will do:

- Downloads lastest `helmc` cli version
- Downloads lastest `deis` cli version
- Fetches latest Workflow chart
- Fetches current database credentials
- Fetches builder component ssh keys
- Sets Storage to GCS
- Sets Registry to grc.io
- If `postgres_settings` file found sets PostgeSQL database to off-cluster 
- Generates chart for the new release
- Uninstalls old version Workflow
- Installs new version Workflow

### have fun with Deis Workflow PaaS of deploying your 12 Factor Apps !!!

## Contributing

`deis-workflow-gke` is an [open source](http://opensource.org/osd) project, released under
the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0),
hence contributions and suggestions are gladly welcomed!
