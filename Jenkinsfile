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
                script {
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
        }

        stage('Plan: test') {
            steps {
                script {
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
        }

        stage('Plan: prod') {
            steps {
                script {
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
        }

        // ── Apply detected environment ───────────────────────────────────────

        stage('Approval — prod only') {
            when {
                expression { env.ENVIRONMENT == 'prod' }
            }
            steps {
                script {
                    def userInput = input(
                        message: "Terraform plan complete. Approve apply on PROD?",
                        ok: 'Deploy to Prod',
                        submitterParameter: 'APPROVER'
                    )
                    echo "Approved by: ${userInput}"
                }
            }
        }

        stage('Init: target env') {
            steps {
                script {
                    sh """
                        terraform init \\
                          -backend-config="bucket=backend_state" \\
                          -backend-config="prefix=${env.ENVIRONMENT}/terraform.tfstate" \\
                          -reconfigure
                    """
                }
            }
        }

        stage('Apply: vpc') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform apply -auto-approve \\
                          -target=module.vpc \\
                          -var-file="${tfVarDir}/common.tfvars" \\
                          -var-file="${tfVarDir}/vpc.tfvars" \\
                          -var-file="${tfVarDir}/firewall.tfvars" \\
                          -var-file="${tfVarDir}/vm.tfvars" \\
                          -var-file="${tfVarDir}/iam.tfvars"
                    """
                }
            }
        }

        stage('Apply: iam') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform apply -auto-approve \\
                          -target=module.iam \\
                          -var-file="${tfVarDir}/common.tfvars" \\
                          -var-file="${tfVarDir}/vpc.tfvars" \\
                          -var-file="${tfVarDir}/firewall.tfvars" \\
                          -var-file="${tfVarDir}/vm.tfvars" \\
                          -var-file="${tfVarDir}/iam.tfvars"
                    """
                }
            }
        }

        stage('Apply: firewall') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform apply -auto-approve \\
                          -target=module.firewall \\
                          -var-file="${tfVarDir}/common.tfvars" \\
                          -var-file="${tfVarDir}/vpc.tfvars" \\
                          -var-file="${tfVarDir}/firewall.tfvars" \\
                          -var-file="${tfVarDir}/vm.tfvars" \\
                          -var-file="${tfVarDir}/iam.tfvars"
                    """
                }
            }
        }

        stage('Apply: vm') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform apply -auto-approve \\
                          -target=module.vm \\
                          -var-file="${tfVarDir}/common.tfvars" \\
                          -var-file="${tfVarDir}/vpc.tfvars" \\
                          -var-file="${tfVarDir}/firewall.tfvars" \\
                          -var-file="${tfVarDir}/vm.tfvars" \\
                          -var-file="${tfVarDir}/iam.tfvars"
                    """
                }
            }
        }
    }

    post {
        success { echo "✅ ${env.ENVIRONMENT} deployed successfully" }
        failure { echo "❌ ${env.ENVIRONMENT} deployment failed" }
        aborted { echo "🚫 ${env.ENVIRONMENT} deployment aborted" }
        always  { cleanWs() }
    }
}
