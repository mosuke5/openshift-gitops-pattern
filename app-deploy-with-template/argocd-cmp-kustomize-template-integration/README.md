# ArgoCD Config Management Pluginを利用したTemplateのデプロイ
ArgoCD の Config Management Plugin(CMP) を用いてKustomizeとOpenShift Templateを統合したデプロイする方法を示す。
本件を試す前に、[argocd-cmp](../argocd-cmp/) を先に試してから確認しましょう。

## 事前準備
- OpenShift GitOpsをインストール済みであること

## セットアップ
`gitops-test` namespaceにArgoCDインスタンスを起動し、CMPが利用するコンテナをサイドカーとして起動する。

```
$ oc new-project gitops-test
```

ArgoCDとArgoCD Applicationのセットアップ
```
$ oc apply -f argocd/

// argocd-repo-serverのコンテナが2つ起動していること
$ oc get pod
NAME                                  READY   STATUS      RESTARTS   AGE
argocd-application-controller-0       1/1     Running     0          1h 
argocd-dex-server-77c9844c7b-vxlsz    1/1     Running     0          1h 
argocd-redis-5dcb4b8449-gp467         1/1     Running     0          1h 
argocd-repo-server-69f687779c-5kwl6   2/2     Running     0          1h 
argocd-server-f4fbfb677-96n5p         1/1     Running     0          1h 
```

### 設定のポイント

#### プラグイン設定
`init`プロセスにて、OpenShift Templateを展開し、Kustomizeのディレクトリに保存する。
その後、`generate`プロセスにて、Kustomizeを用いてConfigMapとアプリケーションを同時にデプロイする構成である。

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-plugin-config
data:
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: kustomize-template-integration-plugin
    spec:
      version: v1.0
      init:
        command:
          - sh
          - -c
          - "oc process -f application-template/ -o yaml --local > base/generated-manifests/app.yaml"
      generate:
        command:
          - sh
          - -c
          - "oc kustomize overlays/$PARAM_CLUSTER_NAME/$PARAM_ENV_NAME"
      parameters:
        static:
          - name: cluster-name
            title: cluster-name
            required: true
          - name: env-name
            title: env-name
            required: true
```

#### アプリケーション
アプリケーションを作成するときには、デプロイするクラスタと環境名を指定する。

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-template-plugin-test
spec:
  project: default
  destination:
    namespace: gitops-test
    server: https://kubernetes.default.svc
  source:
    repoURL: https://github.com/mosuke5/openshift-gitops-pattern
    targetRevision: HEAD
    path: app-deploy-with-template/argocd-cmp-kustomize-template-integration
    plugin:
      name: kustomize-template-integration-plugin-v1.0
      parameters:
        - name: cluster-name
          string: cluster-pt
        - name: env-name
          string: ns-env-1
```
