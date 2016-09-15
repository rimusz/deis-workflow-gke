Install Deis Workflow PaaS on to GKE without fuss
========================

It allows to install [Deis Workflow PaaS](https://deis.com/workflow/) on to GKE with persistent [Object Storage](https://deis.com/docs/workflow/installing-workflow/configuring-object-storage/) set to Google Cloud Storage and Registry to [gcr.io](https://cloud.google.com/container-registry/)
and has an option to set PostgreSQL database to off-cluster use.
How to install
----------


Clone repository:

```
$ git clone https://github.com/rimusz/deis-workflow-gke
```

How it works
------------

```
$ ./install_workflow_2_gke.sh
Usage: install_workflow_2_gke.sh install [eu] | upgrade [eu] | deis | helmc | cluster
```

You will be able:

- install - by defautl sets Object Storage to US region, use `eu` flag for EU region
- upgrade - upgrades to the latest Workflow version (use the same region as was for install)
- deis - fetches the latest Workflow `deis` cli
- helmc - fetches the latest [Helm Classic](https://github.com/helm/helm-classic) cli
- cluster - shows cluster GKE name

Also if you rename/copy `postgres_settings.tpl` file to `postgres_settings`, then you can set [PostgreSQL](https://deis.com/docs/workflow/installing-workflow/configuring-postgres/) database to off-cluster.
As Google Cloud Platform does not have hosted Postgres, you can use [compose.io](https://www.compose.com/postgresql) one, which supports GCP deployment.

What the [install](https://deis.com/docs/workflow/installing-workflow/) will do:

- Gets GKE cluster name which is used to create GCS buckets and Helm chart
- Download lastest `helmc` cli version
- Download lastest `deis` cli version
- Add Deis Chart repository
- Fetch latest Workflow chart
- Set storage to GCS
- Set Registry to grc.io
- If `postgres_settings` file found sets PostgeSQL database to off-cluster 
- Generate chart
- Install Workflow
- Show `deis-router` external IP

What the [upgrade](https://deis.com/docs/workflow/managing-workflow/upgrading-workflow/) will do:

- Download lastest `helmc` cli version
- Download lastest `deis` cli version
- Fetch latest Workflow chart
- Fetch current database credentials
- Fetch builder component ssh keys
- Set Storage to GCS
- Set Registry to grc.io
- If `postgres_settings` file found sets PostgeSQL database to off-cluster 
- Generate chart for the new release
- Uninstall old version Workflow
- Install new version Workflow

### have fun with Deis Workflow PaaS of deploying your 12 Factor Apps !!!

## Contributing

`deis-workflow-gke` is an [open source](http://opensource.org/osd) project, released under
the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0),
hence contributions and suggestions are gladly welcomed!
