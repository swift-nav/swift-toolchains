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
                        sh('''
                            export ARCHFLAGS="-arch arm64"

                            git clone https://github.com/llvm/llvm-project --branch=llvmorg-14.0.6 --single-branch
                            cd llvm-project
                            git checkout llvmorg-14.0.6

                            mkdir build
                            cd build

                            cmake -GNinja ../llvm \
                                -DCMAKE_INSTALL_PREFIX=../out/ \
                                -DCMAKE_OSX_ARCHITECTURES='arm64' \
                                -DCMAKE_C_COMPILER=`which clang` \
                                -DCMAKE_CXX_COMPILER=`which clang++` \
                                -DCMAKE_BUILD_TYPE=Release \
                                -DCMAKE_INSTALL_PREFIX=../out \
                                -DLLVM_TARGETS_TO_BUILD="AArch64" \
                                -DLLVM_HOST_TRIPLE='aarch64-apple-darwin' \
                                -DLLVM_DEFAULT_TARGET_TRIPLE='aarch64-apple-darwin' \
                                -DLLVM_ENABLE_PROJECTS='clang' \
                                -DLLVM_DISTRIBUTION_COMPONENTS='clang' \
                                -C ../../Apple-stage1.cmake
                            ninja help
                            ninja stage2-install-distribution
                        ''')
                        sh('find llvm-project/out/bin')
                    }
                }
            }
        }
    }
}
