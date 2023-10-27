# Terraform-Cloudrun



このTerraformプロジェクトは、Google Cloud Run サービスのデプロイを自動化し、Google Service AccountとGitHubリポジトリからの継続的デプロイメントのためのGoogle Cloud Buildトリガーを利用します。

## 前提条件
- Terraformがインストールされている
- Google Cloud SDKがインストールされている
- Google Cloud Platformのアカウントがある
- GitHubのアカウント（リポジトリ）がある

## セットアップ
**Terraform変数の設定**: `.terraform.tfvars` ファイルを作成するか、Terraformのための環境変数をエクスポートします。
```hcl
project_id = "<YOUR_GCP_PROJECT_ID>"
region = "asia-northeast1"
service_name = "<YOUR_CLOUD_RUN_SERVICE_NAME>"
github_owner = "<YOUR_GITHUB_USERNAME_OR_ORG_NAME>"
github_repo = "<YOUR_GITHUB_REPO_NAME>"
```

## 使用方法

Google Cloud Runサービスをデプロイするには、以下のTerraformコマンドを実行します：
```sh
terraform init
terraform apply　-var-file=".terraform.tfvars"
```

## リソースの削除
デプロイしたリソースを削除するには、以下のコマンドを実行します：
```sh
terraform destroy　-var-file=".terraform.tfvars"
```

