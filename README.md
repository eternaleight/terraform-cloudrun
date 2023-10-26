# Terraform-Cloudrun



以下のTerraform設定は、指定された仕様に基づいてGoogle Cloud Run サービスを作成します。設定項目には、コンテナポート、メモリ、CPU、リクエストタイムアウト、インスタンスあたりの最大同時リクエスト数、自動スケーリングの設定などが含まれます。

```hcl
variable "project_id" {}
variable "region" {}
variable "service_name" {}
variable "github_owner" {}
variable "github_repo" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.service_name}"
        ports {
          container_port = 8001
        }
      }
      service_account_name = google_service_account.cloud_run_service_account.email

      container_concurrency = 80
      timeout_seconds       = 300
      memory                = "128Mi"
      cpu                   = "1"
    }
  }

  autogenerate_revision_name = true
  traffic {
    percent         = 100
    latest_revision = true
  }

  scaling {
    min_instance_count = 0
    max_instance_count = 1
  }
}

resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

resource "google_cloudbuild_trigger" "github_trigger" {
  name = "github-trigger"
  description = "Trigger for GitHub commits"
  
  github {
    owner = var.github_owner
    name = var.github_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

resource "google_project_iam_member" "cloud_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "allUsers"
}
```

`cloudbuild.yaml` ファイルも前回の説明通りに設定してください。

最後に、`terraform.tfvars` ファイルに必要な変数を設定して、Terraformを実行します。

```hcl
project_id = "<YOUR_GCP_PROJECT_ID>"
region = "asia-northeast1"
service_name = "<YOUR_CLOUD_RUN_SERVICE_NAME>"
github_owner = "<YOUR_GITHUB_USERNAME_OR_ORG_NAME>"
github_repo = "<YOUR_GITHUB_REPO_NAME>"
```

実行コマンド:

```sh
terraform init
terraform apply -var-file="terraform.tfvars"
```

この設定でCloud Run サービスが作成され、GitHubリポジトリのコードがデプロイされるようになります。









<br>
<br>


## githubからデプロイ設定 

GitHubから直接Cloud Runにデプロイするには、Cloud BuildとGitHubの連携が必要です。以下はそのための一連の手順です。

### 1. Terraformファイルの準備

まず、Cloud RunサービスとCloud Buildトリガーを作成するTerraformファイルを準備します。

```hcl
variable "project_id" {}
variable "region" {}
variable "service_name" {}
variable "github_owner" {}
variable "github_repo" {}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = var.region

  template {
    spec {
      containers {
        image = "gcr.io/${var.project_id}/${var.service_name}"
        
        ports {
          container_port = 8001
        }

        resources {
          limits = {
            memory = "128Mi"
            cpu    = "1"
          }
        }
      }
      service_account_name = google_service_account.cloud_run_service_account.email
      container_concurrency = 80
      timeout_seconds = 300
    }
  }

  autogenerate_revision_name = true
  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "autoscaling.knative.dev/minScale" = "0"
      "autoscaling.knative.dev/maxScale" = "1"
    }
  }
}

resource "google_service_account" "cloud_run_service_account" {
  account_id   = "cloud-run-service-account"
  display_name = "Cloud Run Service Account"
}

resource "google_cloudbuild_trigger" "github_trigger" {
  name = "github-trigger"
  description = "Trigger for GitHub commits"
  
  github {
    owner = var.github_owner
    name = var.github_repo
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

```

### 2. `cloudbuild.yaml` ファイルの作成

次に、Cloud Buildの設定ファイル `cloudbuild.yaml` を作成します。このファイルはGitHubリポジトリのルートに配置し、ビルドとデプロイの手順を定義します。

```yaml
steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-t', 'gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA', '.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA']
- name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
  args: ['run', 'deploy', '$REPO_NAME', '--image', 'gcr.io/$PROJECT_ID/$REPO_NAME:$COMMIT_SHA', '--region', 'asia-northeast1']
  env:
  - 'CLOUDSDK_COMPUTE_REGION=asia-northeast1'
  - 'CLOUDSDK_CORE_DISABLE_PROMPTS=1'
```

このファイルは、Dockerイメージをビルドし、それをGoogle Container Registryにプッシュし、最後にCloud Runにデプロイします。

### 3. Terraformの実行

最後に、Terraformを実行してリソースを作成します。

```sh
terraform init
terraform apply -var-file="terraform.tfvars"
```

`terraform.tfvars` ファイルには以下のように変数を設定します。

```hcl
project_id = "<YOUR_GCP_PROJECT_ID>"
region = "asia-northeast1"
service_name = "<YOUR_CLOUD_RUN_SERVICE_NAME>"
github_owner = "<YOUR_GITHUB_USERNAME_OR_ORG_NAME>"
github_repo = "<YOUR_GITHUB_REPO_NAME>"
```

これで、GitHubリポジトリへのプッシュがトリガーとなり、Cloud Buildが動作してCloud Runにアプリケーションがデプロイされるようになります。
