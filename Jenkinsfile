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
                stage('llvm x86_64 darwin') {
                    agent {
                        node('macos')
                    }
                    steps {
                        sh('''
                            git clone https://github.com/llvm/llvm-project --branch=llvmorg-14.0.6 --single-branch
                            cd llvm-project

                            mkdir build
                            cd build

                            cmake -GNinja ../llvm \
                                -DCMAKE_INSTALL_PREFIX=../out/ \
                                -DCMAKE_OSX_ARCHITECTURES='x86_64' \
                                -DCMAKE_C_COMPILER=`which clang` \
                                -DCMAKE_CXX_COMPILER=`which clang++` \
                                -DCMAKE_BUILD_TYPE=Release \
                                -DCMAKE_INSTALL_PREFIX=../out \
                                -DLLVM_ENABLE_PROJECTS='clang' \
                                -DLLVM_DISTRIBUTION_COMPONENTS='clang' \
                                -C ../../llvm/Apple-stage1.cmake
                            ninja help
                            ninja stage2-install-distribution || true
                        ''')
                        sh('find llvm-project/out/')
                        sh('''
                            mkdir -p tar/clang+llvm-14.0.6-x86_64-apple/bin
                            cp llvm-project/out/bin/llvm-ar \
                               llvm-project/out/bin/llvm-cov \
                               llvm-project/out/bin/llvm-dwp \
                               llvm-project/out/bin/llvm-nm \
                               llvm-project/out/bin/llvm-objcopy \
                               llvm-project/out/bin/llvm-objdump \
                               llvm-project/out/bin/llvm-profdata \
                               llvm-project/out/bin/llvm-strip \
                               llvm-project/out/bin/clang-cpp \
                               llvm-project/out/bin/ld.lld \
                               tar/clang+llvm-14.0.6-x86_64-apple/bin
                        ''')
                        tar(file: 'clang+llvm-14.0.6-x86_64-apple.tar.gz', dir: 'tar', archive: false)
                        script{
                            context.archivePatterns(
                                patterns: ['clang+llvm-14.0.6-x86_64-apple.tar.gz'],
                                path: "swift-toolchains/${context.gitDescribe()}/clang+llvm-14.0.6-x86_64-apple.tar.gz",
                                jenkins: true
                            )
                        }
                    }
                }
            }
        }
    }
}
