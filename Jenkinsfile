pipeline {
    agent any

    triggers {
        githubPush()
    }

    environment {
        TF_VAR_DIR = ''
        ENVIRONMENT = ''
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
                        // root-level changes (main.tf, variables.tf, modules etc.) — ask user
                        env.ENVIRONMENT = input(
                            message: 'Root-level change detected. Select target environment:',
                            parameters: [choice(name: 'ENVIRONMENT', choices: ['dev', 'test', 'prod'])]
                        )
                    }

                    env.TF_VAR_DIR = "environments/${env.ENVIRONMENT}"
                    echo "Target environment: ${env.ENVIRONMENT}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                sh """
                    terraform init \\
                      -backend-config="bucket=backend_state" \\
                      -backend-config="prefix=${env.ENVIRONMENT}/terraform.tfstate" \\
                      -reconfigure
                """
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh """
                    terraform plan \\
                      -var-file="${env.TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/iam.tfvars" \\
                      -out=tfplan
                """
            }
        }

        stage('Approval — prod only') {
            when {
                expression { env.ENVIRONMENT == 'prod' }
            }
            steps {
                input message: "Approve terraform apply on PROD?", ok: 'Deploy to Prod'
            }
        }

        stage('Apply: vpc') {
            steps {
                sh """
                    terraform apply -auto-approve \\
                      -target=module.vpc \\
                      -var-file="${env.TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/iam.tfvars"
                """
            }
        }

        stage('Apply: iam') {
            steps {
                sh """
                    terraform apply -auto-approve \\
                      -target=module.iam \\
                      -var-file="${env.TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/iam.tfvars"
                """
            }
        }

        stage('Apply: firewall') {
            steps {
                sh """
                    terraform apply -auto-approve \\
                      -target=module.firewall \\
                      -var-file="${env.TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/iam.tfvars"
                """
            }
        }

        stage('Apply: vm') {
            steps {
                sh """
                    terraform apply -auto-approve \\
                      -target=module.vm \\
                      -var-file="${env.TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${env.TF_VAR_DIR}/iam.tfvars"
                """
            }
        }
    }

    post {
        success { echo "✅ ${env.ENVIRONMENT} deployed successfully" }
        failure { echo "❌ ${env.ENVIRONMENT} deployment failed" }
        always  { cleanWs() }
    }
}
