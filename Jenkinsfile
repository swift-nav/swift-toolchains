#!groovy

/**
 * This Jenkinsfile will only work in a Swift Navigation build/CI environment, as it uses
 * non-public docker images and pipeline libraries.
 */

// Use 'ci-jenkins@somebranch' to pull shared lib from a different branch than the default.
// Default is configured in Jenkins and should be from "stable" tag.
@Library("ci-jenkins") import com.swiftnav.ci.*

def context = new Context(context: this)
context.setRepo("swift-toolchains")

/**
 * - Mount the refrepo to keep git operations functional on a repo that uses ref-repo during clone
 **/
String dockerMountArgs = "-v /mnt/efs/refrepo:/mnt/efs/refrepo"

pipeline {
    // Override agent in each stage to make sure we don't share containers among stages.
    agent any
    options {
        // Make sure job aborts after 2 hours if hanging.
        timeout(time: 4, unit: 'HOURS')
        timestamps()
        // Keep builds for 7 days.
        buildDiscarder(logRotator(daysToKeepStr: '7'))
    }

    stages {
        stage('Build') {
            parallel {
                stage('llvm aarch64 darwin') {
                    agent {
                        node('macos-arm64')
                    }
                    steps {
                        gitPrep()
                    }
                    post {
                        always {
                            archiveArtifacts(artifacts: '', allowEmptyArchive: true)
                        }
                    }
                }
                // stage('llvm x86_64 darwin') {
                //     agent {
                //         node('macos')
                //     }
                //     steps {
                //         gitPrep()
                //     }
                //     post {
                //         always {
                //             archiveArtifacts(artifacts: '', allowEmptyArchive: true)
                //         }
                //     }
                // }
                // stage('llvm x86_64 linux') {
                //     agent {
                //         docker {
                //             image ''
                //         }
                //     }
                //     steps {
                //         gitPrep()
                //     }
                //     post {
                //         always {
                //             archiveArtifacts(artifacts: '', allowEmptyArchive: true)
                //         }
                //     }
                // }
            }
        }
    }
}
