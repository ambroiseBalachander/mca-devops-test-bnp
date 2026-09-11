# Kubernetes Jenkins

## Deploy

```shell
helm upgrade --install \
  --namespace jenkins --create-namespace \
  jenkins oci://ghcr.io/jenkinsci/helm-charts/jenkins \
  --values values.yaml
```

## Access

Expose the port `8080` of the service `jenkins` of the namespace `jenkins`.

E.g. with a simple port-forward:

1. Launch the port-forward:

    ```shell
    kubectl --namespace jenkins port-forward svc/jenkins 8888:8080
    ```

2. Open http://localhost:8888/

## Build container image

There is an agent labelled "buildah" with [buildah](https://buildah.io/) available in a `buildah` container.

Build with buildah:

```shell
buildah build --tag <imageName> .
```

Publish with buildah on Docker Hub:

```shell
buildah push --creds <username>:<password> <imageName> docker://<username>/<imageName>
```
