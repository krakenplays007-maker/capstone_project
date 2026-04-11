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

        stage('Validate tfvars') {
            steps {
                script {
                    ['dev', 'test', 'prod'].each { e ->
                        def missing = ['common','vpc','firewall','vm','iam']
                            .findAll { !fileExists("environments/${e}/${it}.tfvars") }
                        if (missing) {
                            echo "⚠️  ${e}: missing [${missing.join(', ')}] — will be skipped"
                        } else {
                            echo "✅ ${e}: all tfvars present"
                        }
                    }
                }
            }
        }

        stage('Plan: all environments') {
            parallel {
                stage('Plan: dev') {
                    steps {
                        script {
                            def varFlags = ['common','vpc','firewall','vm','iam']
                                .findAll { fileExists("environments/dev/${it}.tfvars") }
                                .collect { "-var-file=\"environments/dev/${it}.tfvars\"" }
                                .join(" \\\n                              ")
                            sh """
                                rm -rf \$WORKSPACE/tf-dev && mkdir -p \$WORKSPACE/tf-dev
                                cp -r \$WORKSPACE/. \$WORKSPACE/tf-dev/ 2>/dev/null || true
                                cd \$WORKSPACE/tf-dev
                                terraform init -input=false \\
                                  -backend-config="bucket=backend_state" \\
                                  -backend-config="prefix=dev/terraform.tfstate" \\
                                  -reconfigure
                                terraform plan -input=false \\
                                  ${varFlags} \\
                                  -out=\$WORKSPACE/tf-dev/tfplan-dev
                            """
                        }
                    }
                }
                stage('Plan: test') {
                    steps {
                        script {
                            def varFlags = ['common','vpc','firewall','vm','iam']
                                .findAll { fileExists("environments/test/${it}.tfvars") }
                                .collect { "-var-file=\"environments/test/${it}.tfvars\"" }
                                .join(" \\\n                              ")
                            sh """
                                rm -rf \$WORKSPACE/tf-test && mkdir -p \$WORKSPACE/tf-test
                                cp -r \$WORKSPACE/. \$WORKSPACE/tf-test/ 2>/dev/null || true
                                cd \$WORKSPACE/tf-test
                                terraform init -input=false \\
                                  -backend-config="bucket=backend_state" \\
                                  -backend-config="prefix=test/terraform.tfstate" \\
                                  -reconfigure
                                terraform plan -input=false \\
                                  ${varFlags} \\
                                  -out=\$WORKSPACE/tf-test/tfplan-test
                            """
                        }
                    }
                }
                stage('Plan: prod') {
                    steps {
                        script {
                            def varFlags = ['common','vpc','firewall','vm','iam']
                                .findAll { fileExists("environments/prod/${it}.tfvars") }
                                .collect { "-var-file=\"environments/prod/${it}.tfvars\"" }
                                .join(" \\\n                              ")
                            sh """
                                rm -rf \$WORKSPACE/tf-prod && mkdir -p \$WORKSPACE/tf-prod
                                cp -r \$WORKSPACE/. \$WORKSPACE/tf-prod/ 2>/dev/null || true
                                cd \$WORKSPACE/tf-prod
                                terraform init -input=false \\
                                  -backend-config="bucket=backend_state" \\
                                  -backend-config="prefix=prod/terraform.tfstate" \\
                                  -reconfigure
                                terraform plan -input=false \\
                                  ${varFlags} \\
                                  -out=\$WORKSPACE/tf-prod/tfplan-prod
                            """
                        }
                    }
                }
            }
        }

        stage('Apply: dev + test') {
            parallel {
                stage('Apply: dev') {
                    stages {
                        stage('Apply dev: vpc') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/dev/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/dev/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-dev
                                        terraform apply -auto-approve -input=false -target=module.vpc[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply dev: iam') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/dev/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/dev/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-dev
                                        terraform apply -auto-approve -input=false -target=module.iam[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply dev: firewall') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/dev/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/dev/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-dev
                                        terraform apply -auto-approve -input=false -target=module.firewall[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply dev: vm') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/dev/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/dev/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-dev
                                        terraform apply -auto-approve -input=false -target=module.vm[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                    }
                }
                stage('Apply: test') {
                    stages {
                        stage('Apply test: vpc') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/test/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/test/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-test
                                        terraform apply -auto-approve -input=false -target=module.vpc[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply test: iam') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/test/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/test/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-test
                                        terraform apply -auto-approve -input=false -target=module.iam[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply test: firewall') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/test/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/test/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-test
                                        terraform apply -auto-approve -input=false -target=module.firewall[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                        stage('Apply test: vm') {
                            steps {
                                script {
                                    def varFlags = ['common','vpc','firewall','vm','iam']
                                        .findAll { fileExists("environments/test/${it}.tfvars") }
                                        .collect { "-var-file=\"environments/test/${it}.tfvars\"" }
                                        .join(" \\\n                                      ")
                                    sh """
                                        cd \$WORKSPACE/tf-test
                                        terraform apply -auto-approve -input=false -target=module.vm[0] \\
                                          ${varFlags}
                                    """
                                }
                            }
                        }
                    }
                }
            }
        }

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
                script {
                    def varFlags = ['common','vpc','firewall','vm','iam']
                        .findAll { fileExists("environments/prod/${it}.tfvars") }
                        .collect { "-var-file=\"environments/prod/${it}.tfvars\"" }
                        .join(" \\\n                          ")
                    sh """
                        cd \$WORKSPACE/tf-prod
                        terraform apply -auto-approve -input=false -target=module.vpc[0] \\
                          ${varFlags}
                    """
                }
            }
        }

        stage('Apply prod: iam') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                script {
                    def varFlags = ['common','vpc','firewall','vm','iam']
                        .findAll { fileExists("environments/prod/${it}.tfvars") }
                        .collect { "-var-file=\"environments/prod/${it}.tfvars\"" }
                        .join(" \\\n                          ")
                    sh """
                        cd \$WORKSPACE/tf-prod
                        terraform apply -auto-approve -input=false -target=module.iam[0] \\
                          ${varFlags}
                    """
                }
            }
        }

        stage('Apply prod: firewall') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                script {
                    def varFlags = ['common','vpc','firewall','vm','iam']
                        .findAll { fileExists("environments/prod/${it}.tfvars") }
                        .collect { "-var-file=\"environments/prod/${it}.tfvars\"" }
                        .join(" \\\n                          ")
                    sh """
                        cd \$WORKSPACE/tf-prod
                        terraform apply -auto-approve -input=false -target=module.firewall[0] \\
                          ${varFlags}
                    """
                }
            }
        }

        stage('Apply prod: vm') {
            when { expression { env.PROD_APPROVED == 'true' } }
            steps {
                script {
                    def varFlags = ['common','vpc','firewall','vm','iam']
                        .findAll { fileExists("environments/prod/${it}.tfvars") }
                        .collect { "-var-file=\"environments/prod/${it}.tfvars\"" }
                        .join(" \\\n                          ")
                    sh """
                        cd \$WORKSPACE/tf-prod
                        terraform apply -auto-approve -input=false -target=module.vm[0] \\
                          ${varFlags}
                    """
                }
            }
        }
    }

    post {
        success { echo "✅ Pipeline completed successfully" }
        failure { echo "❌ Pipeline failed" }
        always  {
            sh 'rm -rf $WORKSPACE/tf-dev $WORKSPACE/tf-test $WORKSPACE/tf-prod || true'
            cleanWs()
        }
    }
}
