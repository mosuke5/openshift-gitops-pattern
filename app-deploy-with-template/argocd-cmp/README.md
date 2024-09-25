## reposerver

```yaml
apiVersion: argoproj.io/v1beta1
kind: ArgoCD
metadata:
  name: argocd
  namespace: gitops-test
spec:
  ...
  repo:
    sidecarContainers:
      - name: my-plugin
        command: [/var/run/argocd/argocd-cmp-server]
        image: image-registry.openshift-image-registry.svc:5000/openshift/cli
        volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          - mountPath: /home/argocd/cmp-server/config/plugin.yaml
            subPath: plugin.yaml
            name: cmp-plugin
    volumes:
      - configMap:
          name: my-plugin-config
        name: cmp-plugin
```