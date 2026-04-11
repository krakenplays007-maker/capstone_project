pipeline {
    agent any

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Detect Environment') {
            steps {
                script {
                    def changedFiles = sh(
                        script: "git diff --name-only HEAD~1 HEAD",
                        returnStdout: true
                    ).trim()

                    echo "Changed files:\n${changedFiles}"

                    if (changedFiles.contains('environments/prod')) {
                        env.ENVIRONMENT = 'prod'
                    } else if (changedFiles.contains('environments/test')) {
                        env.ENVIRONMENT = 'test'
                    } else if (changedFiles.contains('environments/dev')) {
                        env.ENVIRONMENT = 'dev'
                    } else {
                        env.ENVIRONMENT = input(
                            message: 'Root-level change detected. Select target environment:',
                            parameters: [choice(name: 'ENVIRONMENT', choices: ['dev', 'test', 'prod'])]
                        )
                    }

                    echo "Target environment: ${env.ENVIRONMENT}"
                }
            }
        }

        // ── Plan all 3 environments ──────────────────────────────────────────

        stage('Plan: dev') {
            steps {
                sh """
                    terraform init \\
                      -backend-config="bucket=backend_state" \\
                      -backend-config="prefix=dev/terraform.tfstate" \\
                      -reconfigure
                    terraform plan \\
                      -var-file="environments/dev/common.tfvars" \\
                      -var-file="environments/dev/vpc.tfvars" \\
                      -var-file="environments/dev/firewall.tfvars" \\
                      -var-file="environments/dev/vm.tfvars" \\
                      -var-file="environments/dev/iam.tfvars"
                """
            }
        }

        stage('Plan: test') {
            steps {
                sh """
                    terraform init \\
                      -backend-config="bucket=backend_state" \\
                      -backend-config="prefix=test/terraform.tfstate" \\
                      -reconfigure
                    terraform plan \\
                      -var-file="environments/test/common.tfvars" \\
                      -var-file="environments/test/vpc.tfvars" \\
                      -var-file="environments/test/firewall.tfvars" \\
                      -var-file="environments/test/vm.tfvars" \\
                      -var-file="environments/test/iam.tfvars"
                """
            }
        }

        stage('Plan: prod') {
            steps {
                sh """
                    terraform init \\
                      -backend-config="bucket=backend_state" \\
                      -backend-config="prefix=prod/terraform.tfstate" \\
                      -reconfigure
                    terraform plan \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        // ── Apply dev (auto) ─────────────────────────────────────────────────

        stage('Apply dev: vpc') {
            when { expression { env.ENVIRONMENT == 'dev' } }
            steps {
                sh """
                    terraform init -backend-config="bucket=backend_state" -backend-config="prefix=dev/terraform.tfstate" -reconfigure
                    terraform apply -auto-approve -target=module.vpc \\
                      -var-file="environments/dev/common.tfvars" \\
                      -var-file="environments/dev/vpc.tfvars" \\
                      -var-file="environments/dev/firewall.tfvars" \\
                      -var-file="environments/dev/vm.tfvars" \\
                      -var-file="environments/dev/iam.tfvars"
                """
            }
        }

        stage('Apply dev: iam') {
            when { expression { env.ENVIRONMENT == 'dev' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.iam \\
                      -var-file="environments/dev/common.tfvars" \\
                      -var-file="environments/dev/vpc.tfvars" \\
                      -var-file="environments/dev/firewall.tfvars" \\
                      -var-file="environments/dev/vm.tfvars" \\
                      -var-file="environments/dev/iam.tfvars"
                """
            }
        }

        stage('Apply dev: firewall') {
            when { expression { env.ENVIRONMENT == 'dev' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.firewall \\
                      -var-file="environments/dev/common.tfvars" \\
                      -var-file="environments/dev/vpc.tfvars" \\
                      -var-file="environments/dev/firewall.tfvars" \\
                      -var-file="environments/dev/vm.tfvars" \\
                      -var-file="environments/dev/iam.tfvars"
                """
            }
        }

        stage('Apply dev: vm') {
            when { expression { env.ENVIRONMENT == 'dev' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.vm \\
                      -var-file="environments/dev/common.tfvars" \\
                      -var-file="environments/dev/vpc.tfvars" \\
                      -var-file="environments/dev/firewall.tfvars" \\
                      -var-file="environments/dev/vm.tfvars" \\
                      -var-file="environments/dev/iam.tfvars"
                """
            }
        }

        // ── Apply test (auto) ────────────────────────────────────────────────

        stage('Apply test: vpc') {
            when { expression { env.ENVIRONMENT == 'test' } }
            steps {
                sh """
                    terraform init -backend-config="bucket=backend_state" -backend-config="prefix=test/terraform.tfstate" -reconfigure
                    terraform apply -auto-approve -target=module.vpc \\
                      -var-file="environments/test/common.tfvars" \\
                      -var-file="environments/test/vpc.tfvars" \\
                      -var-file="environments/test/firewall.tfvars" \\
                      -var-file="environments/test/vm.tfvars" \\
                      -var-file="environments/test/iam.tfvars"
                """
            }
        }

        stage('Apply test: iam') {
            when { expression { env.ENVIRONMENT == 'test' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.iam \\
                      -var-file="environments/test/common.tfvars" \\
                      -var-file="environments/test/vpc.tfvars" \\
                      -var-file="environments/test/firewall.tfvars" \\
                      -var-file="environments/test/vm.tfvars" \\
                      -var-file="environments/test/iam.tfvars"
                """
            }
        }

        stage('Apply test: firewall') {
            when { expression { env.ENVIRONMENT == 'test' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.firewall \\
                      -var-file="environments/test/common.tfvars" \\
                      -var-file="environments/test/vpc.tfvars" \\
                      -var-file="environments/test/firewall.tfvars" \\
                      -var-file="environments/test/vm.tfvars" \\
                      -var-file="environments/test/iam.tfvars"
                """
            }
        }

        stage('Apply test: vm') {
            when { expression { env.ENVIRONMENT == 'test' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.vm \\
                      -var-file="environments/test/common.tfvars" \\
                      -var-file="environments/test/vpc.tfvars" \\
                      -var-file="environments/test/firewall.tfvars" \\
                      -var-file="environments/test/vm.tfvars" \\
                      -var-file="environments/test/iam.tfvars"
                """
            }
        }

        // ── Apply prod (manual approval) ─────────────────────────────────────

        stage('Approval: prod') {
            when { expression { env.ENVIRONMENT == 'prod' } }
            steps {
                script {
                    try {
                        input message: "Approve apply on PROD?", ok: 'Deploy to Prod'
                        env.PROD_APPROVED = 'true'
                    } catch (err) {
                        env.PROD_APPROVED = 'false'
                        echo "🚫 Prod deployment aborted by user — skipping apply"
                    }
                }
            }
        }

        stage('Apply prod: vpc') {
            when { expression { env.ENVIRONMENT == 'prod' && env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    terraform init -backend-config="bucket=backend_state" -backend-config="prefix=prod/terraform.tfstate" -reconfigure
                    terraform apply -auto-approve -target=module.vpc \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: iam') {
            when { expression { env.ENVIRONMENT == 'prod' && env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.iam \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: firewall') {
            when { expression { env.ENVIRONMENT == 'prod' && env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.firewall \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: vm') {
            when { expression { env.ENVIRONMENT == 'prod' && env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    terraform apply -auto-approve -target=module.vm \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }
    }

    post {
        success { echo "✅ ${env.ENVIRONMENT} pipeline completed successfully" }
        failure { echo "❌ ${env.ENVIRONMENT} pipeline failed" }
        always  { cleanWs() }
    }
}
