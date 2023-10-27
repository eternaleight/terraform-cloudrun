# Terraform-Cloudrun


## 概要
このTerraformプロジェクトは、Google Cloud Run サービスのデプロイを自動化し、Google Service AccountとGitHubリポジトリからの継続的デプロイメントのためのGoogle Cloud Buildトリガーを利用します。

## 前提条件
- Terraformがインストールされている
- Google Cloud SDKがインストールされている
- Google Cloud Platformのアカウントがある
- GitHubのアカウントがある

## セットアップ
1. **リポジトリのクローン**: このGitHubリポジトリをローカルマシンにクローンします。
```sh
git clone https://github.com/your_username/your_repository.git
cd your_repository
```

2. **Google Cloud SDKのセットアップ**: GCPアカウントを認証し、デフォルトのプロジェクトを設定します。
```sh
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

3. **サービスアカウントの作成**: GCPで新しいサービスアカウントを作成し、JSONキーファイルをダウンロードします。
```sh
gcloud iam service-accounts create cloud-run-service-account --display-name "Cloud Run Service Account"
gcloud iam service-accounts keys create service-account-key.json --iam-account cloud-run-service-account@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

4. **Terraform変数の設定**: `.terraform.tfvars` ファイルを作成するか、Terraformのための環境変数をエクスポートします。
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

## 使用方法
```sh
terraform destroy　-var-file=".terraform.tfvars"
```

