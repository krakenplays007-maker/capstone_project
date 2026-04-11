pipeline {
    agent any

    parameters {
        choice(name: 'ENVIRONMENT', choices: ['dev', 'test', 'prod'], description: 'Target environment')
        choice(name: 'ACTION',      choices: ['plan', 'apply', 'destroy'],  description: 'Terraform action')
    }

    environment {
        TF_VAR_DIR  = "environments/${params.ENVIRONMENT}"
        TF_VAR_FILES = """-var-file="${TF_VAR_DIR}/common.tfvars" \
                         -var-file="${TF_VAR_DIR}/vpc.tfvars" \
                         -var-file="${TF_VAR_DIR}/firewall.tfvars" \
                         -var-file="${TF_VAR_DIR}/vm.tfvars" \
                         -var-file="${TF_VAR_DIR}/iam.tfvars\""""
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/krakenplays007-maker/capstone_project'
            }
        }

        stage('Terraform Init') {
            steps {
                sh """
                    terraform init \\
                      -backend-config="bucket=backend_state" \\
                      -backend-config="prefix=${params.ENVIRONMENT}/terraform.tfstate" \\
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
                      -var-file="${TF_VAR_DIR}/common.tfvars" \\
                      -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                      -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                      -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                      -var-file="${TF_VAR_DIR}/iam.tfvars" \\
                      -out=tfplan
                """
            }
        }

        stage('Approval') {
            when {
                expression { params.ACTION in ['apply', 'destroy'] }
            }
            steps {
                input message: "Proceed with terraform ${params.ACTION} on ${params.ENVIRONMENT}?", ok: 'Confirm'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            stages {
                // Step 1: VPC must exist first — firewall and vm depend on it
                stage('Apply: vpc') {
                    steps {
                        sh """
                            terraform apply -auto-approve \\
                              -target=module.vpc \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                // Step 2: IAM (service account) must exist before VM
                stage('Apply: iam') {
                    steps {
                        sh """
                            terraform apply -auto-approve \\
                              -target=module.iam \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                // Step 3: Firewall depends on vpc
                stage('Apply: firewall') {
                    steps {
                        sh """
                            terraform apply -auto-approve \\
                              -target=module.firewall \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                // Step 4: VM depends on vpc + iam
                stage('Apply: vm') {
                    steps {
                        sh """
                            terraform apply -auto-approve \\
                              -target=module.vm \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            stages {
                // Destroy in reverse dependency order: vm → firewall → iam → vpc
                stage('Destroy: vm') {
                    steps {
                        sh """
                            terraform destroy -auto-approve \\
                              -target=module.vm \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                stage('Destroy: firewall') {
                    steps {
                        sh """
                            terraform destroy -auto-approve \\
                              -target=module.firewall \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                stage('Destroy: iam') {
                    steps {
                        sh """
                            terraform destroy -auto-approve \\
                              -target=module.iam \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
                stage('Destroy: vpc') {
                    steps {
                        sh """
                            terraform destroy -auto-approve \\
                              -target=module.vpc \\
                              -var-file="${TF_VAR_DIR}/common.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vpc.tfvars" \\
                              -var-file="${TF_VAR_DIR}/firewall.tfvars" \\
                              -var-file="${TF_VAR_DIR}/vm.tfvars" \\
                              -var-file="${TF_VAR_DIR}/iam.tfvars"
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "Pipeline completed successfully for ${params.ENVIRONMENT} — ${params.ACTION}" }
        failure { echo "Pipeline failed for ${params.ENVIRONMENT} — ${params.ACTION}" }
        always  { cleanWs() }
    }
}
