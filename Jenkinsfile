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

        stage('Terraform Init') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform init \\
                          -backend-config="bucket=backend_state" \\
                          -backend-config="prefix=${env.ENVIRONMENT}/terraform.tfstate" \\
                          -reconfigure
                    """
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                script {
                    def tfVarDir = "environments/${env.ENVIRONMENT}"
                    sh """
                        terraform plan \\
                          -var-file="${tfVarDir}/common.tfvars" \\
                          -var-file="${tfVarDir}/vpc.tfvars" \\
                          -var-file="${tfVarDir}/firewall.tfvars" \\
                          -var-file="${tfVarDir}/vm.tfvars" \\
                          -var-file="${tfVarDir}/iam.tfvars" \\
                          -out=tfplan
                    """
                }
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
        always  { cleanWs() }
    }
}
