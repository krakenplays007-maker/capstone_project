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

        // ── Plan all 3 environments in parallel ──────────────────────────────

        stage('Plan: all environments') {
            parallel {
                stage('Plan: dev') {
                    steps {
                        sh """
                            mkdir -p /tmp/tf-dev && cp -r . /tmp/tf-dev/
                            cd /tmp/tf-dev && terraform init -input=false \\
                              -backend-config="bucket=backend_state" \\
                              -backend-config="prefix=dev/terraform.tfstate" \\
                              -reconfigure
                            cd /tmp/tf-dev && terraform plan -input=false \\
                              -var-file="environments/dev/common.tfvars" \\
                              -var-file="environments/dev/vpc.tfvars" \\
                              -var-file="environments/dev/firewall.tfvars" \\
                              -var-file="environments/dev/vm.tfvars" \\
                              -var-file="environments/dev/iam.tfvars" \\
                              -out=tfplan-dev
                        """
                    }
                }
                stage('Plan: test') {
                    steps {
                        sh """
                            mkdir -p /tmp/tf-test && cp -r . /tmp/tf-test/
                            cd /tmp/tf-test && terraform init -input=false \\
                              -backend-config="bucket=backend_state" \\
                              -backend-config="prefix=test/terraform.tfstate" \\
                              -reconfigure
                            cd /tmp/tf-test && terraform plan -input=false \\
                              -var-file="environments/test/common.tfvars" \\
                              -var-file="environments/test/vpc.tfvars" \\
                              -var-file="environments/test/firewall.tfvars" \\
                              -var-file="environments/test/vm.tfvars" \\
                              -var-file="environments/test/iam.tfvars" \\
                              -out=tfplan-test
                        """
                    }
                }
                stage('Plan: prod') {
                    steps {
                        sh """
                            mkdir -p /tmp/tf-prod && cp -r . /tmp/tf-prod/
                            cd /tmp/tf-prod && terraform init -input=false \\
                              -backend-config="bucket=backend_state" \\
                              -backend-config="prefix=prod/terraform.tfstate" \\
                              -reconfigure
                            cd /tmp/tf-prod && terraform plan -input=false \\
                              -var-file="environments/prod/common.tfvars" \\
                              -var-file="environments/prod/vpc.tfvars" \\
                              -var-file="environments/prod/firewall.tfvars" \\
                              -var-file="environments/prod/vm.tfvars" \\
                              -var-file="environments/prod/iam.tfvars" \\
                              -out=tfplan-prod
                        """
                    }
                }
            }
        }

        // ── Apply dev + test in parallel (auto) ──────────────────────────────

        stage('Apply: dev + test') {
            parallel {
                stage('Apply: dev') {
                    stages {
                        stage('Apply dev: vpc') {
                            steps {
                                sh """
                                    cd /tmp/tf-dev
                                    terraform apply -auto-approve -input=false -target=module.vpc \\
                                      -var-file="environments/dev/common.tfvars" \\
                                      -var-file="environments/dev/vpc.tfvars" \\
                                      -var-file="environments/dev/firewall.tfvars" \\
                                      -var-file="environments/dev/vm.tfvars" \\
                                      -var-file="environments/dev/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply dev: iam') {
                            steps {
                                sh """
                                    cd /tmp/tf-dev
                                    terraform apply -auto-approve -input=false -target=module.iam \\
                                      -var-file="environments/dev/common.tfvars" \\
                                      -var-file="environments/dev/vpc.tfvars" \\
                                      -var-file="environments/dev/firewall.tfvars" \\
                                      -var-file="environments/dev/vm.tfvars" \\
                                      -var-file="environments/dev/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply dev: firewall') {
                            steps {
                                sh """
                                    cd /tmp/tf-dev
                                    terraform apply -auto-approve -input=false -target=module.firewall \\
                                      -var-file="environments/dev/common.tfvars" \\
                                      -var-file="environments/dev/vpc.tfvars" \\
                                      -var-file="environments/dev/firewall.tfvars" \\
                                      -var-file="environments/dev/vm.tfvars" \\
                                      -var-file="environments/dev/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply dev: vm') {
                            steps {
                                sh """
                                    cd /tmp/tf-dev
                                    terraform apply -auto-approve -input=false -target=module.vm \\
                                      -var-file="environments/dev/common.tfvars" \\
                                      -var-file="environments/dev/vpc.tfvars" \\
                                      -var-file="environments/dev/firewall.tfvars" \\
                                      -var-file="environments/dev/vm.tfvars" \\
                                      -var-file="environments/dev/iam.tfvars"
                                """
                            }
                        }
                    }
                }
                stage('Apply: test') {
                    stages {
                        stage('Apply test: vpc') {
                            steps {
                                sh """
                                    cd /tmp/tf-test
                                    terraform apply -auto-approve -input=false -target=module.vpc \\
                                      -var-file="environments/test/common.tfvars" \\
                                      -var-file="environments/test/vpc.tfvars" \\
                                      -var-file="environments/test/firewall.tfvars" \\
                                      -var-file="environments/test/vm.tfvars" \\
                                      -var-file="environments/test/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply test: iam') {
                            steps {
                                sh """
                                    cd /tmp/tf-test
                                    terraform apply -auto-approve -input=false -target=module.iam \\
                                      -var-file="environments/test/common.tfvars" \\
                                      -var-file="environments/test/vpc.tfvars" \\
                                      -var-file="environments/test/firewall.tfvars" \\
                                      -var-file="environments/test/vm.tfvars" \\
                                      -var-file="environments/test/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply test: firewall') {
                            steps {
                                sh """
                                    cd /tmp/tf-test
                                    terraform apply -auto-approve -input=false -target=module.firewall \\
                                      -var-file="environments/test/common.tfvars" \\
                                      -var-file="environments/test/vpc.tfvars" \\
                                      -var-file="environments/test/firewall.tfvars" \\
                                      -var-file="environments/test/vm.tfvars" \\
                                      -var-file="environments/test/iam.tfvars"
                                """
                            }
                        }
                        stage('Apply test: vm') {
                            steps {
                                sh """
                                    cd /tmp/tf-test
                                    terraform apply -auto-approve -input=false -target=module.vm \\
                                      -var-file="environments/test/common.tfvars" \\
                                      -var-file="environments/test/vpc.tfvars" \\
                                      -var-file="environments/test/firewall.tfvars" \\
                                      -var-file="environments/test/vm.tfvars" \\
                                      -var-file="environments/test/iam.tfvars"
                                """
                            }
                        }
                    }
                }
            }
        }

        // ── Prod: approval then apply ─────────────────────────────────────────

        stage('Approval: prod') {
            steps {
                script {
                    try {
                        input message: "Approve apply on PROD?", ok: 'Deploy to Prod'
                        env.PROD_APPROVED = 'true'
                    } catch (err) {
                        env.PROD_APPROVED = 'false'
                        echo "🚫 Prod deployment aborted — skipping apply"
                    }
                }
            }
        }

        stage('Apply prod: vpc') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    cd /tmp/tf-prod
                    terraform apply -auto-approve -input=false -target=module.vpc \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: iam') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    cd /tmp/tf-prod
                    terraform apply -auto-approve -input=false -target=module.iam \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: firewall') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    cd /tmp/tf-prod
                    terraform apply -auto-approve -input=false -target=module.firewall \\
                      -var-file="environments/prod/common.tfvars" \\
                      -var-file="environments/prod/vpc.tfvars" \\
                      -var-file="environments/prod/firewall.tfvars" \\
                      -var-file="environments/prod/vm.tfvars" \\
                      -var-file="environments/prod/iam.tfvars"
                """
            }
        }

        stage('Apply prod: vm') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                sh """
                    cd /tmp/tf-prod
                    terraform apply -auto-approve -input=false -target=module.vm \\
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
        success { echo "✅ Pipeline completed successfully" }
        failure { echo "❌ Pipeline failed" }
        always  {
            sh 'rm -rf /tmp/tf-dev /tmp/tf-test /tmp/tf-prod || true'
            cleanWs()
        }
    }
}
