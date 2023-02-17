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
                stage('llvm x86_64 linux') {
                    agent {
                        dockerfile {
                            filename "Dockerfile.llvm"
                        }
                    }
                    steps {
                        sh('''
                            git clone https://github.com/llvm/llvm-project --branch=llvmorg-14.0.6 --single-branch
                            cd llvm-project
                            git checkout llvmorg-14.0.6

                            mkdir build
                            cd build

                            cmake -GNinja ../llvm \
                                -DLLVM_ENABLE_PROJECTS="clang;lld" \
                                -DLLVM_TARGETS_TO_BUILD="X86" \
                                -DCMAKE_INSTALL_PREFIX=../out/ \
                                -C ../../llvm/Distribution-x86.cmake
                            ninja stage2-install-distribution
                        ''')
                        sh('find llvm-project/out/bin')
                        tar(file: 'clang+llvm-14.0.6-x86_64-linux.tar.gz', dir: 'llvm-project/out/bin', archive: false)
                        script{
                            context.archivePatterns(
                                patterns: ['clang+llvm-14.0.6-x86_64-linux.tar.gz'],
                                path: "swift-toolchains/${context.gitDescribe()}/clang+llvm-14.0.6-x86_64-linux.tar.gz",
                                jenkins: true
                            )
                        }
                    }
                }
            }
        }
    }
}
