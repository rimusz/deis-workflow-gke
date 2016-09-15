Install Deis Workflow PaaS on to GKE without fuss 
========================

It allows to install [Deis Workflow PaaS](https://deis.com/workflow/) on to GKE with persistent [Object Storage](https://deis.com/docs/workflow/installing-workflow/configuring-object-storage/) set to Google Cloud Storage and Registry to [gcr.io](https://cloud.google.com/container-registry/)

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

What the [install](https://deis.com/docs/workflow/installing-workflow/) will do:

- Download lastest `helmc` cli version 
- Download lastest `deis` cli version 
- Add Deis Chart repository
- Fetch latest Workflow chart
- Set storage to GCS
- Set Registry to grc.io
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
- Generate chart for the new release
- Uninstall Workflow
- Install Workflow

### have fun!

### To-Do

Add an option to set off-cluster Postgres database (makes the Workflow upgarde evenmore slicker), which could be run in the same Kubernetes cluster, hosted at [compose.io](https://www.compose.com/postgresql) and etc.

## Contributing

`install_workflow_2_gke.sh` is an [open source](http://opensource.org/osd) project release under
the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0),
hence contributions and suggestions are gladly welcomed! 
