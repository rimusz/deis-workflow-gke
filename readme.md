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

- [install](https://deis.com/docs/workflow/installing-workflow/) : by defautl set Object Storage US region, use `eu` flag for EU region
- [upgrade](https://deis.com/docs/workflow/managing-workflow/upgrading-workflow/) : upgrades to the latest Workflow version (use the same region as was for install)
- deis - fetches the latest Workflow `deis` cli
- helmc - fetches the latest [Helm Classic](https://github.com/helm/helm-classic) cli
- cluster - shows cluster GKE name

### have fun!


## Contributing

`install_workflow_2_gke.sh` is an [open source](http://opensource.org/osd) project release under
the [Apache License, Version 2.0](http://opensource.org/licenses/Apache-2.0),
hence contributions and suggestions are gladly welcomed! 
