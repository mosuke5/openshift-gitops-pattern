# GitOps Pattern

## Configuration Management

- Namespace  
    Kustomize を導入し、マニフェストの差分をディレクトリ構成により管理
- OCP クラスタ  
    ディレクトリ構成 / Kustomize Component により管理

### Direcotry Path Pettern (`dir-path`)

- マニフェストの差分を OCP クラスタ x Namespace ごとのパスで管理
- クラスタレベルの設定変更は各 Namespace ごとに設定が必要 

### Component Pettern (`components`)

- 各クラスタ固有の設定を Kustomize Component で管理
- 各クラスタ固有の設定と Namespace の設定を分離できる

## App Deploy with OpenShift Template

### ArgoCD Config Management Plugin Pettern

ArgoCD の Config Management Plugin により OpenShift Template によるマニフェスト生成処理を追加

### Kustomize Plugin Pettern

kustomize generator plugin により OpenShift Template によるマニフェスト生成処理を追加