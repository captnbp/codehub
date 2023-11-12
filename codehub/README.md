<!--- app-name: Codehub -->

# Codehub

Codehub is a mix of Jupyterhub and code-server to allow you to spawn one code-server workspace per user.

Trademarks: This software listing is packaged by Benoît Pourre. The respective trademarks mentioned in the offering are owned by the respective companies, and use of them does not imply any affiliation or endorsement.

[Overview of JupyterHub](https://jupyter.org/hub)
[Overview of Code-Server](https://github.com/coder/code-server)

## TL;DR

```console
$ helm install my-release oci://registry-1.docker.io/captnbp/codehub
```

## Introduction

This chart bootstraps a Codehub Deployment in a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.20+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## Verifying Signed Codehub Images

Codehub images are signed using [Cosign](https://docs.sigstore.dev/cosign/overview/)!

To verify a public image, [install cosign](https://docs.sigstore.dev/cosign/installation/) and use the provided public key:

```bash
$ cat cosign.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE1er+5JMY/P0+R8wiW3HSjGUohoMf
GEVe7kEAkv1mARM+NyeR5Cd2PpEZnlmNhb2jvyWczfAyj09oA/H47VCQnA==
-----END PUBLIC KEY-----

$ cosign verify -key ./cosign.pub docker.io/captnbp/code-server:4.18.0-r0
```

You can also set the following Kyverno Cluster Policy :

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-codehub-images
spec:
  background: false
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  failurePolicy: Fail
  rules:
    - match:
        any:
          - resources:
              kinds:
                - Pod
      name: check-image
      verifyImages:
        - attestors:
            - count: 1
              entries:
                - keys:
                    publicKeys: |-
                      -----BEGIN PUBLIC KEY-----
                      MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE1er+5JMY/P0+R8wiW3HSjGUohoMf
                      GEVe7kEAkv1mARM+NyeR5Cd2PpEZnlmNhb2jvyWczfAyj09oA/H47VCQnA==
                      -----END PUBLIC KEY-----
                    signatureAlgorithm: sha256
          imageReferences:
            - lab.frogg.it:5050/doca/*
            - lab.frogg.it:5050/captnbp/*
            - docker.io/captnbp/*
          mutateDigest: true
          required: true
          verifyDigest: true
```

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm install my-release oci://registry-1.docker.io/captnbp/codehub
```

These commands deploy Codehub on the Kubernetes cluster in the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` helm release:

```console
$ helm uninstall my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]`  |
| `global.storageClass`     | Global StorageClass for Persistent Volume(s)    | `""`  |

### Common parameters

| Name                     | Description                                                                             | Value           |
| ------------------------ | --------------------------------------------------------------------------------------- | --------------- |
| `kubeVersion`            | Override Kubernetes version                                                             | `""`            |
| `nameOverride`           | String to partially override common.names.fullname (will maintain the release name)     | `""`            |
| `fullnameOverride`       | String to fully override common.names.fullname                                          | `""`            |
| `clusterDomain`          | Kubernetes Cluster Domain                                                               | `cluster.local` |
| `commonLabels`           | Labels to add to all deployed objects                                                   | `{}`            |
| `commonAnnotations`      | Annotations to add to all deployed objects                                              | `{}`            |
| `extraDeploy`            | Array of extra objects to deploy with the release                                       | `[]`            |
| `diagnosticMode.enabled` | Enable diagnostic mode (all probes will be disabled and the command will be overridden) | `false`         |
| `diagnosticMode.command` | Command to override all containers in the the deployment(s)/daemonset(s)                | `["sleep"]`     |
| `diagnosticMode.args`    | Args to override all containers in the the deployment(s)/daemonset(s)                   | `["infinity"]`  |

### Hub deployment parameters

| Name                                                    | Description                                                                                                              | Value                 |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------- |
| `hub.image.registry`                                    | Hub image registry                                                                                                       | `docker.io`           |
| `hub.image.repository`                                  | Hub image repository                                                                                                     | `bitnami/jupyterhub`  |
| `hub.image.tag`                                         | Hub image tag (immutable tags are recommended)                                                                           | `4.0.2-debian-11-r58` |
| `hub.image.digest`                                      | Hub image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                      | `""`                  |
| `hub.image.pullPolicy`                                  | Hub image pull policy                                                                                                    | `IfNotPresent`        |
| `hub.image.pullSecrets`                                 | Hub image pull secrets                                                                                                   | `[]`                  |
| `hub.baseUrl`                                           | Hub base URL                                                                                                             | `/`                   |
| `hub.auth.dummy.enabled`                                | Enable Hub Dummy authenticator                                                                                           | `true`                |
| `hub.auth.dummy.adminUser`                              | Hub Dummy authenticator admin user                                                                                       | `user`                |
| `hub.auth.dummy.password`                               | Hub Dummy authenticator password                                                                                         | `""`                  |
| `hub.auth.oauth.enabled`                                | Enable Hub oauth authenticator                                                                                           | `false`               |
| `hub.auth.oauth.clientId`                               | Client ID for Hub oauth authenticator                                                                                    | `""`                  |
| `hub.auth.oauth.clientSecret`                           | Client Secret for Hub oauth authenticator                                                                                | `""`                  |
| `hub.auth.oauth.oauthCallbackUrl`                       | Hub oauth authenticator                                                                                                  | `""`                  |
| `hub.auth.oauth.authorizeUrl`                           | Authorize URL for Hub oauth authenticator                                                                                | `""`                  |
| `hub.auth.oauth.tokenUrl`                               | Token URL for Hub oauth authenticator                                                                                    | `""`                  |
| `hub.auth.oauth.userdataUrl`                            | Userdata URL for Hub oauth authenticator                                                                                 | `""`                  |
| `hub.auth.oauth.loginService`                           | Login Service for Hub oauth authenticator                                                                                | `""`                  |
| `hub.auth.oauth.usernameKey`                            | Username key for Hub oauth authenticator                                                                                 | `""`                  |
| `hub.auth.oauth.claimGroupsKey`                         | Claim Groups key for Hub oauth authenticator                                                                             | `""`                  |
| `hub.auth.oauth.allowedGroups`                          | Hub authenticator allowed Groups                                                                                         | `[]`                  |
| `hub.auth.oauth.adminGroups`                            | Hub authenticator admin Groups                                                                                           | `[]`                  |
| `hub.auth.oauth.adminUsers`                             | Hub authenticator admin Users                                                                                            | `[]`                  |
| `hub.auth.gitlab.enabled`                               | Enable Hub Gitlab authenticator                                                                                          | `true`                |
| `hub.auth.gitlab.gitlabUrl`                             | Gitlab url for Hub Gitlab authenticator                                                                                  | `https://gitlab.com`  |
| `hub.auth.gitlab.allowedGitlabGroups`                   | Gitlab group whitelisted IDs for Hub Gitlab authenticator                                                                | `[]`                  |
| `hub.auth.gitlab.allowedProjectIds`                     | Gitlab allowed project IDs for Hub Gitlab authenticator                                                                  | `[]`                  |
| `hub.auth.gitlab.clientId`                              | Client ID for Hub Gitlab authenticator                                                                                   | `""`                  |
| `hub.auth.gitlab.clientSecret`                          | Client Secret for Hub Gitlab authenticator                                                                               | `""`                  |
| `hub.auth.gitlab.adminUsers`                            | Hub authenticator admin Users                                                                                            | `[]`                  |
| `hub.existingConfigmap`                                 | Configmap with Hub init scripts (replaces the scripts in templates/hub/configmap.yml)                                    | `""`                  |
| `hub.existingSecret`                                    | Secret with hub configuration (replaces the hub.configuration value) and proxy token                                     | `""`                  |
| `hub.command`                                           | Override Hub default command                                                                                             | `[]`                  |
| `hub.args`                                              | Override Hub default args                                                                                                | `[]`                  |
| `hub.extraEnvVars`                                      | Add extra environment variables to the Hub container                                                                     | `[]`                  |
| `hub.extraEnvVarsCM`                                    | Name of existing ConfigMap containing extra env vars                                                                     | `""`                  |
| `hub.extraEnvVarsSecret`                                | Name of existing Secret containing extra env vars                                                                        | `""`                  |
| `hub.containerPorts.http`                               | Hub container port                                                                                                       | `8081`                |
| `hub.startupProbe.enabled`                              | Enable startupProbe on Hub containers                                                                                    | `true`                |
| `hub.startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                   | `10`                  |
| `hub.startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                          | `10`                  |
| `hub.startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                         | `3`                   |
| `hub.startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                       | `30`                  |
| `hub.startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                       | `1`                   |
| `hub.livenessProbe.enabled`                             | Enable livenessProbe on Hub containers                                                                                   | `true`                |
| `hub.livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                  | `10`                  |
| `hub.livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                         | `10`                  |
| `hub.livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                        | `3`                   |
| `hub.livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                      | `30`                  |
| `hub.livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                      | `1`                   |
| `hub.readinessProbe.enabled`                            | Enable readinessProbe on Hub containers                                                                                  | `true`                |
| `hub.readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                 | `10`                  |
| `hub.readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                        | `10`                  |
| `hub.readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                       | `3`                   |
| `hub.readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                     | `30`                  |
| `hub.readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                     | `1`                   |
| `hub.customStartupProbe`                                | Override default startup probe                                                                                           | `{}`                  |
| `hub.customLivenessProbe`                               | Override default liveness probe                                                                                          | `{}`                  |
| `hub.customReadinessProbe`                              | Override default readiness probe                                                                                         | `{}`                  |
| `hub.resources.limits`                                  | The resources limits for the Hub containers                                                                              | `{}`                  |
| `hub.resources.requests`                                | The requested resources for the Hub containers                                                                           | `{}`                  |
| `hub.containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                     | `true`                |
| `hub.containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                               | `1001`                |
| `hub.containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                            | `true`                |
| `hub.containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                              | `false`               |
| `hub.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                  | `false`               |
| `hub.containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                | `false`               |
| `hub.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                       | `["ALL"]`             |
| `hub.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                         | `RuntimeDefault`      |
| `hub.podSecurityContext.enabled`                        | Enabled Hub pods' Security Context                                                                                       | `true`                |
| `hub.podSecurityContext.fsGroup`                        | Set Hub pod's Security Context fsGroup                                                                                   | `1001`                |
| `hub.lifecycleHooks`                                    | LifecycleHooks for the Hub container to automate configuration before or after startup                                   | `{}`                  |
| `hub.hostAliases`                                       | Add deployment host aliases                                                                                              | `[]`                  |
| `hub.podLabels`                                         | Add extra labels to the Hub pods                                                                                         | `{}`                  |
| `hub.podAnnotations`                                    | Add extra annotations to the Hub pods                                                                                    | `{}`                  |
| `hub.podAffinityPreset`                                 | Pod affinity preset. Ignored if `hub.affinity` is set. Allowed values: `soft` or `hard`                                  | `""`                  |
| `hub.podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `hub.affinity` is set. Allowed values: `soft` or `hard`                             | `soft`                |
| `hub.nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `hub.affinity` is set. Allowed values: `soft` or `hard`                            | `""`                  |
| `hub.nodeAffinityPreset.key`                            | Node label key to match. Ignored if `hub.affinity` is set                                                                | `""`                  |
| `hub.nodeAffinityPreset.values`                         | Node label values to match. Ignored if `hub.affinity` is set                                                             | `[]`                  |
| `hub.affinity`                                          | Affinity for pod assignment.                                                                                             | `{}`                  |
| `hub.nodeSelector`                                      | Node labels for pod assignment.                                                                                          | `{}`                  |
| `hub.tolerations`                                       | Tolerations for pod assignment.                                                                                          | `[]`                  |
| `hub.topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template | `[]`                  |
| `hub.priorityClassName`                                 | Priority Class Name                                                                                                      | `""`                  |
| `hub.schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                | `""`                  |
| `hub.terminationGracePeriodSeconds`                     | Seconds Hub pod needs to terminate gracefully                                                                            | `""`                  |
| `hub.updateStrategy.type`                               | Update strategy - only really applicable for deployments with RWO PVs attached                                           | `RollingUpdate`       |
| `hub.updateStrategy.rollingUpdate`                      | Hub deployment rolling update configuration parameters                                                                   | `{}`                  |
| `hub.extraVolumes`                                      | Optionally specify extra list of additional volumes for Hub pods                                                         | `[]`                  |
| `hub.extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for Hub container(s)                                            | `[]`                  |
| `hub.initContainers`                                    | Add additional init containers to the Hub pods                                                                           | `[]`                  |
| `hub.sidecars`                                          | Add additional sidecar containers to the Hub pod                                                                         | `[]`                  |
| `hub.pdb.create`                                        | Deploy Hub PodDisruptionBudget                                                                                           | `false`               |
| `hub.pdb.minAvailable`                                  | Set minimum available hub instances                                                                                      | `""`                  |
| `hub.pdb.maxUnavailable`                                | Set maximum available hub instances                                                                                      | `""`                  |

### Hub RBAC parameters

| Name                                              | Description                                                            | Value  |
| ------------------------------------------------- | ---------------------------------------------------------------------- | ------ |
| `hub.serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                   | `true` |
| `hub.serviceAccount.name`                         | Override Hub service account name                                      | `""`   |
| `hub.serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created | `true` |
| `hub.serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                   | `{}`   |
| `hub.rbac.create`                                 | Specifies whether RBAC resources should be created                     | `true` |
| `hub.rbac.rules`                                  | Custom RBAC rules to set                                               | `[]`   |

### Hub Traffic Exposure Parameters

| Name                                      | Description                                                      | Value       |
| ----------------------------------------- | ---------------------------------------------------------------- | ----------- |
| `hub.networkPolicy.enabled`               | Deploy Hub network policies                                      | `true`      |
| `hub.networkPolicy.allowInterspaceAccess` | Allow communication between pods in different namespaces         | `true`      |
| `hub.networkPolicy.extraIngress`          | Add extra ingress rules to the NetworkPolicy                     | `{}`        |
| `hub.networkPolicy.extraEgress`           | Add extra ingress rules to the NetworkPolicy                     | `""`        |
| `hub.service.type`                        | Hub service type                                                 | `ClusterIP` |
| `hub.service.ports.http`                  | Hub service HTTP port                                            | `8081`      |
| `hub.service.nodePorts.http`              | NodePort for the HTTP endpoint                                   | `""`        |
| `hub.service.sessionAffinity`             | Control where client requests go, to the same pod or round-robin | `None`      |
| `hub.service.sessionAffinityConfig`       | Additional settings for the sessionAffinity                      | `{}`        |
| `hub.service.clusterIP`                   | Hub service Cluster IP                                           | `""`        |
| `hub.service.loadBalancerIP`              | Hub service Load Balancer IP                                     | `""`        |
| `hub.service.loadBalancerSourceRanges`    | Hub service Load Balancer sources                                | `[]`        |
| `hub.service.externalTrafficPolicy`       | Hub service external traffic policy                              | `Cluster`   |
| `hub.service.annotations`                 | Additional custom annotations for Hub service                    | `{}`        |
| `hub.service.extraPorts`                  | Extra port to expose on Hub service                              | `[]`        |

### Hub Metrics parameters

| Name                                           | Description                                                                                 | Value          |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------- | -------------- |
| `hub.metrics.authenticatePrometheus`           | Use authentication for Prometheus                                                           | `false`        |
| `hub.metrics.serviceMonitor.enabled`           | If the operator is installed in your cluster, set to true to create a Service Monitor Entry | `true`         |
| `hub.metrics.serviceMonitor.namespace`         | Namespace which Prometheus is running in                                                    | `""`           |
| `hub.metrics.serviceMonitor.path`              | HTTP path to scrape for metrics                                                             | `/hub/metrics` |
| `hub.metrics.serviceMonitor.interval`          | Interval at which metrics should be scraped                                                 | `30s`          |
| `hub.metrics.serviceMonitor.scrapeTimeout`     | Specify the timeout after which the scrape is ended                                         | `""`           |
| `hub.metrics.serviceMonitor.labels`            | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus       | `{}`           |
| `hub.metrics.serviceMonitor.selector`          | Prometheus instance selector labels                                                         | `{}`           |
| `hub.metrics.serviceMonitor.relabelings`       | RelabelConfigs to apply to samples before scraping                                          | `[]`           |
| `hub.metrics.serviceMonitor.metricRelabelings` | MetricRelabelConfigs to apply to samples before ingestion                                   | `[]`           |
| `hub.metrics.serviceMonitor.honorLabels`       | Specify honorLabels parameter to add the scrape endpoint                                    | `false`        |
| `hub.metrics.serviceMonitor.jobLabel`          | The name of the label on the target service to use as the job name in prometheus.           | `""`           |

### Proxy deployment parameters

| Name                                                      | Description                                                                                                              | Value                             |
| --------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------------------------------- |
| `proxy.image.registry`                                    | Proxy image registry                                                                                                     | `docker.io`                       |
| `proxy.image.repository`                                  | Proxy image repository                                                                                                   | `bitnami/configurable-http-proxy` |
| `proxy.image.tag`                                         | Proxy image tag (immutable tags are recommended)                                                                         | `4.6.0-debian-11-r17`             |
| `proxy.image.digest`                                      | Proxy image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag                    | `""`                              |
| `proxy.image.pullPolicy`                                  | Proxy image pull policy                                                                                                  | `IfNotPresent`                    |
| `proxy.image.pullSecrets`                                 | Proxy image pull secrets                                                                                                 | `[]`                              |
| `proxy.image.debug`                                       | Activate verbose output                                                                                                  | `false`                           |
| `proxy.secretToken`                                       | Proxy secret token (used for communication with the Hub)                                                                 | `""`                              |
| `proxy.command`                                           | Override Proxy default command                                                                                           | `[]`                              |
| `proxy.args`                                              | Override Proxy default args                                                                                              | `[]`                              |
| `proxy.extraEnvVars`                                      | Add extra environment variables to the Proxy container                                                                   | `[]`                              |
| `proxy.extraEnvVarsCM`                                    | Name of existing ConfigMap containing extra env vars                                                                     | `""`                              |
| `proxy.extraEnvVarsSecret`                                | Name of existing Secret containing extra env vars                                                                        | `""`                              |
| `proxy.containerPort.api`                                 | Proxy api container port                                                                                                 | `8001`                            |
| `proxy.containerPort.metrics`                             | Proxy metrics container port                                                                                             | `8002`                            |
| `proxy.containerPort.http`                                | Proxy http container port                                                                                                | `8000`                            |
| `proxy.startupProbe.enabled`                              | Enable startupProbe on Proxy containers                                                                                  | `true`                            |
| `proxy.startupProbe.initialDelaySeconds`                  | Initial delay seconds for startupProbe                                                                                   | `10`                              |
| `proxy.startupProbe.periodSeconds`                        | Period seconds for startupProbe                                                                                          | `10`                              |
| `proxy.startupProbe.timeoutSeconds`                       | Timeout seconds for startupProbe                                                                                         | `3`                               |
| `proxy.startupProbe.failureThreshold`                     | Failure threshold for startupProbe                                                                                       | `30`                              |
| `proxy.startupProbe.successThreshold`                     | Success threshold for startupProbe                                                                                       | `1`                               |
| `proxy.livenessProbe.enabled`                             | Enable livenessProbe on Proxy containers                                                                                 | `true`                            |
| `proxy.livenessProbe.initialDelaySeconds`                 | Initial delay seconds for livenessProbe                                                                                  | `10`                              |
| `proxy.livenessProbe.periodSeconds`                       | Period seconds for livenessProbe                                                                                         | `10`                              |
| `proxy.livenessProbe.timeoutSeconds`                      | Timeout seconds for livenessProbe                                                                                        | `3`                               |
| `proxy.livenessProbe.failureThreshold`                    | Failure threshold for livenessProbe                                                                                      | `30`                              |
| `proxy.livenessProbe.successThreshold`                    | Success threshold for livenessProbe                                                                                      | `1`                               |
| `proxy.readinessProbe.enabled`                            | Enable readinessProbe on Proxy containers                                                                                | `true`                            |
| `proxy.readinessProbe.initialDelaySeconds`                | Initial delay seconds for readinessProbe                                                                                 | `10`                              |
| `proxy.readinessProbe.periodSeconds`                      | Period seconds for readinessProbe                                                                                        | `10`                              |
| `proxy.readinessProbe.timeoutSeconds`                     | Timeout seconds for readinessProbe                                                                                       | `3`                               |
| `proxy.readinessProbe.failureThreshold`                   | Failure threshold for readinessProbe                                                                                     | `30`                              |
| `proxy.readinessProbe.successThreshold`                   | Success threshold for readinessProbe                                                                                     | `1`                               |
| `proxy.customStartupProbe`                                | Override default startup probe                                                                                           | `{}`                              |
| `proxy.customLivenessProbe`                               | Override default liveness probe                                                                                          | `{}`                              |
| `proxy.customReadinessProbe`                              | Override default readiness probe                                                                                         | `{}`                              |
| `proxy.resources.limits`                                  | The resources limits for the Proxy containers                                                                            | `{}`                              |
| `proxy.resources.requests`                                | The requested resources for the Proxy containers                                                                         | `{}`                              |
| `proxy.containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                     | `true`                            |
| `proxy.containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                               | `1001`                            |
| `proxy.containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                            | `true`                            |
| `proxy.containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                              | `false`                           |
| `proxy.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                  | `false`                           |
| `proxy.containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                | `false`                           |
| `proxy.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                       | `["ALL"]`                         |
| `proxy.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                         | `RuntimeDefault`                  |
| `proxy.podSecurityContext.enabled`                        | Enabled Proxy pods' Security Context                                                                                     | `true`                            |
| `proxy.podSecurityContext.fsGroup`                        | Set Proxy pod's Security Context fsGroup                                                                                 | `1001`                            |
| `proxy.lifecycleHooks`                                    | Add lifecycle hooks to the Proxy deployment                                                                              | `{}`                              |
| `proxy.hostAliases`                                       | Add deployment host aliases                                                                                              | `[]`                              |
| `proxy.podLabels`                                         | Add extra labels to the Proxy pods                                                                                       | `{}`                              |
| `proxy.podAnnotations`                                    | Add extra annotations to the Proxy pods                                                                                  | `{}`                              |
| `proxy.podAffinityPreset`                                 | Pod affinity preset. Ignored if `proxy.affinity` is set. Allowed values: `soft` or `hard`                                | `""`                              |
| `proxy.podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `proxy.affinity` is set. Allowed values: `soft` or `hard`                           | `soft`                            |
| `proxy.nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `proxy.affinity` is set. Allowed values: `soft` or `hard`                          | `""`                              |
| `proxy.nodeAffinityPreset.key`                            | Node label key to match. Ignored if `proxy.affinity` is set                                                              | `""`                              |
| `proxy.nodeAffinityPreset.values`                         | Node label values to match. Ignored if `proxy.affinity` is set                                                           | `[]`                              |
| `proxy.affinity`                                          | Affinity for pod assignment. Evaluated as a template.                                                                    | `{}`                              |
| `proxy.nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template.                                                                 | `{}`                              |
| `proxy.tolerations`                                       | Tolerations for pod assignment. Evaluated as a template.                                                                 | `[]`                              |
| `proxy.topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template | `[]`                              |
| `proxy.priorityClassName`                                 | Priority Class Name                                                                                                      | `""`                              |
| `proxy.schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                | `""`                              |
| `proxy.terminationGracePeriodSeconds`                     | Seconds Proxy pod needs to terminate gracefully                                                                          | `""`                              |
| `proxy.updateStrategy.type`                               | Update strategy - only really applicable for deployments with RWO PVs attached                                           | `RollingUpdate`                   |
| `proxy.updateStrategy.rollingUpdate`                      | Proxy deployment rolling update configuration parameters                                                                 | `{}`                              |
| `proxy.extraVolumes`                                      | Optionally specify extra list of additional volumes for Proxy pods                                                       | `[]`                              |
| `proxy.extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for Proxy container(s)                                          | `[]`                              |
| `proxy.initContainers`                                    | Add additional init containers to the Proxy pods                                                                         | `[]`                              |
| `proxy.sidecars`                                          | Add additional sidecar containers to the Proxy pod                                                                       | `[]`                              |
| `proxy.pdb.create`                                        | Deploy Proxy PodDisruptionBudget                                                                                         | `false`                           |
| `proxy.pdb.minAvailable`                                  | Set minimum available proxy instances                                                                                    | `""`                              |
| `proxy.pdb.maxUnavailable`                                | Set maximum available proxy instances                                                                                    | `""`                              |

### Proxy RBAC Parameters

| Name                                                | Description                                                            | Value   |
| --------------------------------------------------- | ---------------------------------------------------------------------- | ------- |
| `proxy.serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                   | `true`  |
| `proxy.serviceAccount.name`                         | Override Hub service account name                                      | `""`    |
| `proxy.serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created | `false` |
| `proxy.serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                   | `{}`    |

### Proxy Traffic Exposure Parameters

| Name                                             | Description                                                                                                                      | Value                    |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| `proxy.networkPolicy.enabled`                    | Deploy Proxy network policies                                                                                                    | `true`                   |
| `proxy.networkPolicy.allowInterspaceAccess`      | Allow communication between pods in different namespaces                                                                         | `true`                   |
| `proxy.networkPolicy.extraIngress`               | Add extra ingress rules to the NetworkPolicy                                                                                     | `""`                     |
| `proxy.networkPolicy.extraEgress`                | Add extra egress rules to the NetworkPolicy                                                                                      | `""`                     |
| `proxy.service.api.type`                         | API service type                                                                                                                 | `ClusterIP`              |
| `proxy.service.api.ports.http`                   | API service HTTP port                                                                                                            | `8001`                   |
| `proxy.service.api.nodePorts.http`               | NodePort for the HTTP endpoint                                                                                                   | `""`                     |
| `proxy.service.api.sessionAffinity`              | Control where client requests go, to the same pod or round-robin                                                                 | `None`                   |
| `proxy.service.api.sessionAffinityConfig`        | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `proxy.service.api.clusterIP`                    | Hub service Cluster IP                                                                                                           | `""`                     |
| `proxy.service.api.loadBalancerIP`               | Hub service Load Balancer IP                                                                                                     | `""`                     |
| `proxy.service.api.loadBalancerSourceRanges`     | Hub service Load Balancer sources                                                                                                | `[]`                     |
| `proxy.service.api.externalTrafficPolicy`        | Hub service external traffic policy                                                                                              | `Cluster`                |
| `proxy.service.api.annotations`                  | Additional custom annotations for Hub service                                                                                    | `{}`                     |
| `proxy.service.api.extraPorts`                   | Extra port to expose on Hub service                                                                                              | `[]`                     |
| `proxy.service.metrics.type`                     | Metrics service type                                                                                                             | `ClusterIP`              |
| `proxy.service.metrics.ports.http`               | Metrics service port                                                                                                             | `8002`                   |
| `proxy.service.metrics.nodePorts.http`           | NodePort for the HTTP endpoint                                                                                                   | `""`                     |
| `proxy.service.metrics.sessionAffinity`          | Control where client requests go, to the same pod or round-robin                                                                 | `None`                   |
| `proxy.service.metrics.sessionAffinityConfig`    | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `proxy.service.metrics.clusterIP`                | Hub service Cluster IP                                                                                                           | `""`                     |
| `proxy.service.metrics.loadBalancerIP`           | Hub service Load Balancer IP                                                                                                     | `""`                     |
| `proxy.service.metrics.loadBalancerSourceRanges` | Hub service Load Balancer sources                                                                                                | `[]`                     |
| `proxy.service.metrics.externalTrafficPolicy`    | Hub service external traffic policy                                                                                              | `Cluster`                |
| `proxy.service.metrics.annotations`              | Additional custom annotations for Hub service                                                                                    | `{}`                     |
| `proxy.service.metrics.extraPorts`               | Extra port to expose on Hub service                                                                                              | `[]`                     |
| `proxy.service.public.type`                      | Public service type                                                                                                              | `LoadBalancer`           |
| `proxy.service.public.ports.http`                | Public service HTTP port                                                                                                         | `80`                     |
| `proxy.service.public.nodePorts.http`            | NodePort for the HTTP endpoint                                                                                                   | `""`                     |
| `proxy.service.public.sessionAffinity`           | Control where client requests go, to the same pod or round-robin                                                                 | `None`                   |
| `proxy.service.public.sessionAffinityConfig`     | Additional settings for the sessionAffinity                                                                                      | `{}`                     |
| `proxy.service.public.clusterIP`                 | Hub service Cluster IP                                                                                                           | `""`                     |
| `proxy.service.public.loadBalancerIP`            | Hub service Load Balancer IP                                                                                                     | `""`                     |
| `proxy.service.public.loadBalancerSourceRanges`  | Hub service Load Balancer sources                                                                                                | `[]`                     |
| `proxy.service.public.externalTrafficPolicy`     | Hub service external traffic policy                                                                                              | `Cluster`                |
| `proxy.service.public.annotations`               | Additional custom annotations for Hub service                                                                                    | `{}`                     |
| `proxy.service.public.extraPorts`                | Extra port to expose on Hub service                                                                                              | `[]`                     |
| `proxy.ingress.enabled`                          | Set to true to enable ingress record generation                                                                                  | `false`                  |
| `proxy.ingress.apiVersion`                       | Force Ingress API version (automatically detected if not set)                                                                    | `""`                     |
| `proxy.ingress.ingressClassName`                 | IngressClass that will be be used to implement the Ingress (Kubernetes 1.18+)                                                    | `""`                     |
| `proxy.ingress.pathType`                         | Ingress path type                                                                                                                | `ImplementationSpecific` |
| `proxy.ingress.hostname`                         | Set ingress rule hostname                                                                                                        | `codehub.local`          |
| `proxy.ingress.path`                             | Path to the Proxy pod                                                                                                            | `/`                      |
| `proxy.ingress.annotations`                      | Additional annotations for the Ingress resource. To enable certificate autogeneration, place here your cert-manager annotations. | `{}`                     |
| `proxy.ingress.tls`                              | Enable TLS configuration for the host defined at `ingress.hostname` parameter                                                    | `false`                  |
| `proxy.ingress.selfSigned`                       | Create a TLS secret for this ingress record using self-signed certificates generated by Helm                                     | `false`                  |
| `proxy.ingress.extraHosts`                       | An array with additional hostname(s) to be covered with the ingress record                                                       | `[]`                     |
| `proxy.ingress.extraPaths`                       | An array with additional arbitrary paths that may need to be added to the ingress under the main host                            | `[]`                     |
| `proxy.ingress.extraTls`                         | The tls configuration for additional hostnames to be covered with this ingress record.                                           | `[]`                     |
| `proxy.ingress.secrets`                          | Custom TLS certificates as secrets                                                                                               | `[]`                     |
| `proxy.ingress.extraRules`                       | Additional rules to be covered with this ingress record                                                                          | `[]`                     |

### Proxy Metrics parameters

| Name                                             | Description                                                                                 | Value      |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------- | ---------- |
| `proxy.metrics.serviceMonitor.enabled`           | If the operator is installed in your cluster, set to true to create a Service Monitor Entry | `true`     |
| `proxy.metrics.serviceMonitor.namespace`         | Namespace which Prometheus is running in                                                    | `""`       |
| `proxy.metrics.serviceMonitor.path`              | HTTP path to scrape for metrics                                                             | `/metrics` |
| `proxy.metrics.serviceMonitor.interval`          | Interval at which metrics should be scraped                                                 | `30s`      |
| `proxy.metrics.serviceMonitor.scrapeTimeout`     | Specify the timeout after which the scrape is ended                                         | `""`       |
| `proxy.metrics.serviceMonitor.labels`            | Additional labels that can be used so ServiceMonitor will be discovered by Prometheus       | `{}`       |
| `proxy.metrics.serviceMonitor.selector`          | Prometheus instance selector labels                                                         | `{}`       |
| `proxy.metrics.serviceMonitor.relabelings`       | RelabelConfigs to apply to samples before scraping                                          | `[]`       |
| `proxy.metrics.serviceMonitor.metricRelabelings` | MetricRelabelConfigs to apply to samples before ingestion                                   | `[]`       |
| `proxy.metrics.serviceMonitor.honorLabels`       | Specify honorLabels parameter to add the scrape endpoint                                    | `false`    |
| `proxy.metrics.serviceMonitor.jobLabel`          | The name of the label on the target service to use as the job name in prometheus.           | `""`       |

### Image puller deployment parameters

| Name                                                            | Description                                                                                                              | Value            |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------ | ---------------- |
| `imagePuller.enabled`                                           | Deploy ImagePuller daemonset                                                                                             | `true`           |
| `imagePuller.command`                                           | Override ImagePuller default command                                                                                     | `[]`             |
| `imagePuller.args`                                              | Override ImagePuller default args                                                                                        | `[]`             |
| `imagePuller.extraEnvVars`                                      | Add extra environment variables to the ImagePuller container                                                             | `[]`             |
| `imagePuller.extraEnvVarsCM`                                    | Name of existing ConfigMap containing extra env vars                                                                     | `""`             |
| `imagePuller.extraEnvVarsSecret`                                | Name of existing Secret containing extra env vars                                                                        | `""`             |
| `imagePuller.customStartupProbe`                                | Override default startup probe                                                                                           | `{}`             |
| `imagePuller.customLivenessProbe`                               | Override default liveness probe                                                                                          | `{}`             |
| `imagePuller.customReadinessProbe`                              | Override default readiness probe                                                                                         | `{}`             |
| `imagePuller.resources.limits`                                  | The resources limits for the ImagePuller containers                                                                      | `{}`             |
| `imagePuller.resources.requests`                                | The requested resources for the ImagePuller containers                                                                   | `{}`             |
| `imagePuller.containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                                     | `true`           |
| `imagePuller.containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                               | `1001`           |
| `imagePuller.containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                                            | `true`           |
| `imagePuller.containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                              | `false`          |
| `imagePuller.containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                                  | `false`          |
| `imagePuller.containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                                | `false`          |
| `imagePuller.containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                                       | `["ALL"]`        |
| `imagePuller.containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                                         | `RuntimeDefault` |
| `imagePuller.podSecurityContext.enabled`                        | Enabled ImagePuller pods' Security Context                                                                               | `true`           |
| `imagePuller.podSecurityContext.fsGroup`                        | Set ImagePuller pod's Security Context fsGroup                                                                           | `1001`           |
| `imagePuller.lifecycleHooks`                                    | Add lifecycle hooks to the ImagePuller deployment                                                                        | `{}`             |
| `imagePuller.hostAliases`                                       | Add deployment host aliases                                                                                              | `[]`             |
| `imagePuller.podLabels`                                         | Pod extra labels                                                                                                         | `{}`             |
| `imagePuller.podAnnotations`                                    | Annotations for ImagePuller pods                                                                                         | `{}`             |
| `imagePuller.podAffinityPreset`                                 | Pod affinity preset. Ignored if `imagePuller.affinity` is set. Allowed values: `soft` or `hard`                          | `""`             |
| `imagePuller.podAntiAffinityPreset`                             | Pod anti-affinity preset. Ignored if `imagePuller.affinity` is set. Allowed values: `soft` or `hard`                     | `soft`           |
| `imagePuller.nodeAffinityPreset.type`                           | Node affinity preset type. Ignored if `imagePuller.affinity` is set. Allowed values: `soft` or `hard`                    | `""`             |
| `imagePuller.nodeAffinityPreset.key`                            | Node label key to match. Ignored if `imagePuller.affinity` is set                                                        | `""`             |
| `imagePuller.nodeAffinityPreset.values`                         | Node label values to match. Ignored if `imagePuller.affinity` is set                                                     | `[]`             |
| `imagePuller.affinity`                                          | Affinity for pod assignment. Evaluated as a template.                                                                    | `{}`             |
| `imagePuller.nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template.                                                                 | `{}`             |
| `imagePuller.tolerations`                                       | Tolerations for pod assignment. Evaluated as a template.                                                                 | `[]`             |
| `imagePuller.topologySpreadConstraints`                         | Topology Spread Constraints for pod assignment spread across your cluster among failure-domains. Evaluated as a template | `[]`             |
| `imagePuller.priorityClassName`                                 | Priority Class Name                                                                                                      | `""`             |
| `imagePuller.schedulerName`                                     | Use an alternate scheduler, e.g. "stork".                                                                                | `""`             |
| `imagePuller.terminationGracePeriodSeconds`                     | Seconds ImagePuller pod needs to terminate gracefully                                                                    | `""`             |
| `imagePuller.updateStrategy.type`                               | Update strategy - only really applicable for deployments with RWO PVs attached                                           | `RollingUpdate`  |
| `imagePuller.updateStrategy.rollingUpdate`                      | ImagePuller deployment rolling update configuration parameters                                                           | `{}`             |
| `imagePuller.extraVolumes`                                      | Optionally specify extra list of additional volumes for ImagePuller pods                                                 | `[]`             |
| `imagePuller.extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for ImagePuller container(s)                                    | `[]`             |
| `imagePuller.initContainers`                                    | Add additional init containers to the ImagePuller pods                                                                   | `[]`             |
| `imagePuller.sidecars`                                          | Add additional sidecar containers to the ImagePuller pod                                                                 | `[]`             |

### Singleuser deployment parameters

| Name                                                                       | Description                                                                                                 | Value                                                                        |
| -------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `singleuser.profiles[0].image.registry`                                    | Single User image registry                                                                                  | `docker.io`                                                                  |
| `singleuser.profiles[0].image.repository`                                  | Single User image repository                                                                                | `captnbp/code-server`                                                        |
| `singleuser.profiles[0].image.tag`                                         | Single User image tag (immutabe tags are recommended)                                                       | `4.18.0-r0`                                                                  |
| `singleuser.profiles[0].image.digest`                                      | Single User image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`                                                                         |
| `singleuser.profiles[0].image.pullPolicy`                                  | Single User image pull policy                                                                               | `IfNotPresent`                                                               |
| `singleuser.profiles[0].image.pullSecrets`                                 | Single User image pull secrets                                                                              | `[]`                                                                         |
| `singleuser.profiles[0].name`                                              | Single User name                                                                                            | `Code-Server`                                                                |
| `singleuser.profiles[0].description`                                       | Single User description                                                                                     | `https://lab.frogg.it/doca/codehub-container-images/-/tree/main/code-server` |
| `singleuser.profiles[0].notebookDir`                                       | Notebook directory (it will be the same as the PVC volume mount)                                            | `/home/coder`                                                                |
| `singleuser.profiles[0].allowPrivilegeEscalation`                          | Controls whether a process can gain more privileges than its parent process                                 | `false`                                                                      |
| `singleuser.profiles[0].command`                                           | Override Single User default command                                                                        | `[]`                                                                         |
| `singleuser.profiles[0].extraEnvVars`                                      | Extra environment variables that should be set for the user pods                                            | `[]`                                                                         |
| `singleuser.profiles[0].containerPort`                                     | Single User container port                                                                                  | `8888`                                                                       |
| `singleuser.profiles[0].resources.limits`                                  | The resources limits for the Singleuser containers                                                          | `{}`                                                                         |
| `singleuser.profiles[0].resources.requests`                                | The requested resources for the Singleuser containers                                                       | `{}`                                                                         |
| `singleuser.profiles[0].extraResources.limits`                             | The resources limits for the Singleuser containers                                                          | `{}`                                                                         |
| `singleuser.profiles[0].extraResources.requests`                           | The requested resources for the Singleuser containers                                                       | `{}`                                                                         |
| `singleuser.profiles[0].containerSecurityContext.enabled`                  | Enabled containers' Security Context                                                                        | `true`                                                                       |
| `singleuser.profiles[0].containerSecurityContext.runAsUser`                | Set containers' Security Context runAsUser                                                                  | `1000`                                                                       |
| `singleuser.profiles[0].containerSecurityContext.runAsNonRoot`             | Set container's Security Context runAsNonRoot                                                               | `true`                                                                       |
| `singleuser.profiles[0].containerSecurityContext.privileged`               | Set container's Security Context privileged                                                                 | `false`                                                                      |
| `singleuser.profiles[0].containerSecurityContext.readOnlyRootFilesystem`   | Set container's Security Context readOnlyRootFilesystem                                                     | `false`                                                                      |
| `singleuser.profiles[0].containerSecurityContext.allowPrivilegeEscalation` | Set container's Security Context allowPrivilegeEscalation                                                   | `false`                                                                      |
| `singleuser.profiles[0].containerSecurityContext.capabilities.drop`        | List of capabilities to be dropped                                                                          | `["ALL"]`                                                                    |
| `singleuser.profiles[0].containerSecurityContext.seccompProfile.type`      | Set container's Security Context seccomp profile                                                            | `RuntimeDefault`                                                             |
| `singleuser.profiles[0].podSecurityContext.enabled`                        | Enabled Single User pods' Security Context                                                                  | `true`                                                                       |
| `singleuser.profiles[0].podSecurityContext.fsGroup`                        | Set Single User pod's Security Context fsGroup                                                              | `1000`                                                                       |
| `singleuser.profiles[0].podLabels`                                         | Extra labels for Single User pods                                                                           | `{}`                                                                         |
| `singleuser.profiles[0].podAnnotations`                                    | Annotations for Single User pods                                                                            | `{}`                                                                         |
| `singleuser.profiles[0].nodeSelector`                                      | Node labels for pod assignment. Evaluated as a template.                                                    | `{}`                                                                         |
| `singleuser.profiles[0].tolerations`                                       | Tolerations for pod assignment. Evaluated as a template.                                                    | `[]`                                                                         |
| `singleuser.profiles[0].priorityClassName`                                 | Single User pod priority class name                                                                         | `""`                                                                         |
| `singleuser.profiles[0].lifecycleHooks`                                    | Add lifecycle hooks to the Single User deployment to automate configuration before or after startup         | `{}`                                                                         |
| `singleuser.profiles[0].extraVolumes`                                      | Optionally specify extra list of additional volumes for Single User pods                                    | `[]`                                                                         |
| `singleuser.profiles[0].extraVolumeMounts`                                 | Optionally specify extra list of additional volumeMounts for Single User container(s)                       | `[]`                                                                         |
| `singleuser.profiles[0].initContainers`                                    | Add additional init containers to the Single User pod                                                       | `[]`                                                                         |

### Single User RBAC parameters

| Name                                                     | Description                                                            | Value  |
| -------------------------------------------------------- | ---------------------------------------------------------------------- | ------ |
| `singleuser.serviceAccount.create`                       | Specifies whether a ServiceAccount should be created                   | `true` |
| `singleuser.serviceAccount.name`                         | Override Single User service account name                              | `""`   |
| `singleuser.serviceAccount.automountServiceAccountToken` | Allows auto mount of ServiceAccountToken on the serviceAccount created | `true` |
| `singleuser.serviceAccount.annotations`                  | Additional custom annotations for the ServiceAccount                   | `{}`   |

### Single User Persistence parameters

| Name                                  | Description                                                | Value               |
| ------------------------------------- | ---------------------------------------------------------- | ------------------- |
| `singleuser.persistence.enabled`      | Enable persistent volume creation on Single User instances | `true`              |
| `singleuser.persistence.storageClass` | Persistent Volumes storage class                           | `""`                |
| `singleuser.persistence.accessModes`  | Persistent Volumes access modes                            | `["ReadWriteOnce"]` |
| `singleuser.persistence.size`         | Persistent Volumes size                                    | `20Gi`              |

### Traffic exposure parameters

| Name                                                | Description                                              | Value   |
| --------------------------------------------------- | -------------------------------------------------------- | ------- |
| `singleuser.networkPolicy.enabled`                  | Deploy Single User network policies                      | `true`  |
| `singleuser.networkPolicy.allowInterspaceAccess`    | Allow communication between pods in different namespaces | `true`  |
| `singleuser.networkPolicy.allowCloudMetadataAccess` | Allow Single User pods to access Cloud Metada endpoints  | `false` |
| `singleuser.networkPolicy.extraIngress`             | Add extra ingress rules to the NetworkPolicy             | `""`    |
| `singleuser.networkPolicy.extraEgress`              | Add extra egress rules to the NetworkPolicy              | `""`    |

### Auxiliary image parameters

| Name                         | Description                                                                                               | Value              |
| ---------------------------- | --------------------------------------------------------------------------------------------------------- | ------------------ |
| `auxiliaryImage.registry`    | Auxiliary image registry                                                                                  | `docker.io`        |
| `auxiliaryImage.repository`  | Auxiliary image repository                                                                                | `bitnami/os-shell` |
| `auxiliaryImage.tag`         | Auxiliary image tag (immutabe tags are recommended)                                                       | `11-debian-11-r90` |
| `auxiliaryImage.digest`      | Auxiliary image digest in the way sha256:aa.... Please note this parameter, if set, will override the tag | `""`               |
| `auxiliaryImage.pullPolicy`  | Auxiliary image pull policy                                                                               | `IfNotPresent`     |
| `auxiliaryImage.pullSecrets` | Auxiliary image pull secrets                                                                              | `[]`               |

### JupyterHub database parameters

| Name                                         | Description                                                             | Value                |
| -------------------------------------------- | ----------------------------------------------------------------------- | -------------------- |
| `postgresql.enabled`                         | Switch to enable or disable the PostgreSQL helm chart                   | `true`               |
| `postgresql.auth.username`                   | Name for a custom user to create                                        | `bn_jupyterhub`      |
| `postgresql.auth.password`                   | Password for the custom user to create                                  | `""`                 |
| `postgresql.auth.database`                   | Name for a custom database to create                                    | `bitnami_jupyterhub` |
| `postgresql.auth.existingSecret`             | Name of existing secret to use for PostgreSQL credentials               | `""`                 |
| `postgresql.architecture`                    | PostgreSQL architecture (`standalone` or `replication`)                 | `standalone`         |
| `postgresql.service.ports.postgresql`        | PostgreSQL service port                                                 | `5432`               |
| `externalDatabase.host`                      | Database host                                                           | `""`                 |
| `externalDatabase.port`                      | Database port number                                                    | `5432`               |
| `externalDatabase.user`                      | Non-root username for JupyterHub                                        | `postgres`           |
| `externalDatabase.password`                  | Password for the non-root username for JupyterHub                       | `""`                 |
| `externalDatabase.database`                  | JupyterHub database name                                                | `jupyterhub`         |
| `externalDatabase.existingSecret`            | Name of an existing secret resource containing the database credentials | `""`                 |
| `externalDatabase.existingSecretPasswordKey` | Name of an existing secret key containing the database credentials      | `""`                 |


Specify each parameter using the `--set key=value[,key=value]` argument to `helm install`. For example,

```console
$ helm install my-release \
  --set proxy.livenessProbe.successThreshold=5 \
    my-repo/codehub
```

The above command sets the `proxy.livenessProbe.successThreshold` to `5`.

Alternatively, a YAML file that specifies the values for the parameters can be provided while installing the chart. For example,

```bash
$ helm install my-release -f values.yaml my-repo/codehub
```

## Configuration and installation details

### Configure authentication

The chart configures the Hub [DummyAuthenticator](https://github.com/jupyterhub/dummyauthenticator) by default, with the password set in the `hub.password` (auto-generated if not set) chart parameter and `user` as the administrator user. In order to change the authentication mechanism, change the `hub.config.JupyterHub` section inside the `hub.configuration` value.

Refer to the [chart documentation for a configuration example](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/configuration/configure-authentication).

### Configure the Single User instances

As explained in the [documentation](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/get-started/understand-default-configuration/), the Hub is responsible for deploying the Single User instances. The configuration of these instances is passed to the Hub instance via the `hub.configuration` chart parameter. The chart's `singleuser` section can be used to generate the `hub.configuration` value.

For more information, including how to provide a secret or a custom ConfigMap, refer to the [chart documentation on configuring Single User instances](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/configuration/configure-single-user-instances/).

### Restrict traffic using NetworkPolicies

The Bitnami JupyterHub chart enables NetworkPolicies by default. This restricts the communication between the three main components: the Proxy, the Hub and the Single User instances. There are two elements that were left open on purpose:

- Ingress access to the Proxy instance HTTP port: by default, it is open to any IP, as it is the entry point to the JupyterHub instance. This behavior can be changed by tweaking the `proxy.networkPolicy.extraIngress` value.
- Hub egress access: As the Hub requires access to the Kubernetes API, the Hub can access to any IP by default (depending on the Kubernetes platform, the Service IP ranges can vary and so there is no easy way to detect the Kubernetes API internal IP). This behavior can be changed by tweaking the `hub.networkPolicy.extraEgress` value.

### Use sidecars and init containers

If additional containers are needed in the same pod (such as additional metrics or logging exporters), they can be defined using the `proxy.sidecars`, `hub.sidecars` or `singleuser.sidecars` config parameters. Similarly, extra init containers can be added using the `hub.initContainers`, `proxy.initContainers` and `singleuser.initContainers` parameters.

Refer to the chart documentation for more information on, and examples of, configuring and using [sidecars and init containers](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/configuration/configure-sidecar-init-containers/).

### Configure Ingress

This chart provides support for Ingress resources for the JupyterHub proxy component. If an Ingress controller, such as nginx-ingress or traefik, that Ingress controller can be used to serve WordPress.

To enable Ingress integration, set `proxy.ingress.enabled` to `true`. The `proxy.ingress.hostname` property can be used to set the host name. The `proxy.ingress.tls` parameter can be used to add the TLS configuration for this host. It is also possible to have more than one host, with a separate TLS configuration for each host.

Learn more about [configuring and using Ingress in the chart documentation](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/configuration/configure-ingress/).

### Configure TLS secrets

This chart facilitates the creation of TLS secrets for use with the Ingress controller (although this is not mandatory). There are four common use cases:

* Helm generates/manages certificate secrets based on the parameters.
* User generates/manages certificates separately.
* Helm creates self-signed certificates and generates/manages certificate secrets.
* An additional tool (like [cert-manager](https://github.com/jetstack/cert-manager/)) manages the secrets for the application.

Refer to the [chart documentation for more information on working with TLS](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/administration/enable-tls-ingress/).

### Set pod affinity

This chart allows you to set your custom affinity using the `hub.affinity` and `proxy.affinity` parameters. Refer to the [chart documentation on pod affinity](https://docs.bitnami.com/kubernetes/infrastructure/jupyterhub/configuration/configure-pod-affinity).

## License

MIT License

Copyright (c) 2022 Benoît Pourre

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
