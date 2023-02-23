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

                            mkdir build
                            cd build

                            cmake -GNinja ../llvm \
                                -DCMAKE_INSTALL_PREFIX=../out/ \
                                -C ../../llvm/Distribution.cmake
                            ninja install-distribution

                            find ../out/
                        ''')
                        uploadDistribution("clang+llvm-14.0.6-x86_64-linux", context)
                    }
                }
                // stage('llvm aarch64 darwin') {
                //     agent {
                //         node('macos-arm64')
                //     }
                //     steps {
                //         sh('''
                //             git clone https://github.com/llvm/llvm-project --branch=llvmorg-14.0.6 --single-branch
                //             cd llvm-project

                //             mkdir build
                //             cd build

                //             cmake -GNinja ../llvm \
                //                 -DCMAKE_INSTALL_PREFIX=../out/ \
                //                 -DCMAKE_OSX_ARCHITECTURES='arm64' \
                //                 -DCMAKE_C_COMPILER=`which clang` \
                //                 -DCMAKE_CXX_COMPILER=`which clang++` \
                //                 -DCMAKE_BUILD_TYPE=Release \
                //                 -C ../../llvm/Distribution.cmake
                //             ninja stage2-install-distribution
                //         ''')
                //         uploadDistribution("clang+llvm-14.0.6-arm64-apple-darwin", context)
                //     }
                // }
                // stage('llvm x86_64 darwin') {
                //     agent {
                //         node('macos')
                //     }
                //     steps {
                //         sh('''
                //             git clone https://github.com/llvm/llvm-project --branch=llvmorg-14.0.6 --single-branch
                //             cd llvm-project
                //             mkdir build
                //             cd build
                //             cmake -GNinja ../llvm \
                //                 -DCMAKE_INSTALL_PREFIX=../out/ \
                //                 -DCMAKE_OSX_ARCHITECTURES='x86_64' \
                //                 -DLLVM_ENABLE_RUNTIMES='compiler-rt;libcxx;libcxxabi' \
                //                 -DCMAKE_C_COMPILER=`which clang` \
                //                 -DCMAKE_CXX_COMPILER=`which clang++` \
                //                 -DCMAKE_BUILD_TYPE=Release \
                //                 -C ../../llvm/Distribution.cmake
                //             ninja stage2-install-distribution
                //         ''')
                //         uploadDistribution("clang+llvm-14.0.6-x86_64-apple-darwin", context)
                //     }
                // }
            }
        }
    }
}

def uploadDistribution(name, context) {
    sh("""
        mkdir -p tar/${name}/
        cp -rH llvm-project/out/* tar/${name}/
    """)
    tar(file: "${name}.tar.gz", dir: 'tar', archive: true)
    script{
        context.archivePatterns(
            patterns: ["${name}.tar.gz"],
            path: "swift-toolchains/${context.gitDescribe()}/${name}.tar.gz",
            jenkins: false
        )
    }
}
