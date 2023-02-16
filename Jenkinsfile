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
                // stage('llvm aarch64 darwin') {
                //     agent {
                //         node('macos-arm64')
                //     }
                //     steps {
                //         sh(''' 
                //             ls -l

                //             git clone https://github.com/llvm/llvm-project
                //             cd llvm-project
                //             git checkout llvmorg-14.0.6

                //             NPROC=$(nproc --all)
                //             echo $NPROC

                //             cmake -S llvm -B build-stage1 \
                //                 -G "Unix Makefiles" \
                //                 -C clang/cmake/caches/Apple-stage1.cmake \
                //                 -DCMAKE_OSX_ARCHITECTURES='arm64' \
                //                 -DCMAKE_C_COMPILER=`which clang` \
                //                 -DCMAKE_CXX_COMPILER=`which clang++` \
                //                 -DCMAKE_BUILD_TYPE=Release \
                //                 -DCMAKE_INSTALL_PREFIX=$PWD/stage1/clang-14.0.6/arm64 \
                //                 -DLLVM_TARGETS_TO_BUILD="AArch64" \
                //                 -DLLVM_HOST_TRIPLE='aarch64-apple-darwin' \
                //                 -DLLVM_DEFAULT_TARGET_TRIPLE='aarch64-apple-darwin' \
                //                 -DLLVM_ENABLE_PROJECTS='clang' \
                //                 -DLLVM_DISTRIBUTION_COMPONENTS='clang'

                //             make -C build-stage1 -j "$NPROC" stage2-install-distribution
                //             find $PWD/stage1/clang-14.0.6/arm64/
                //         ''')
                //         // sh(''' 
                //         //     ls -l

                //         //     git clone https://github.com/llvm/llvm-project
                //         //     cd llvm-project
                //         //     git checkout llvmorg-14.0.6

                //         //     NPROC=$(nproc --all)
                //         //     echo $NPROC

                //         //     cmake -S llvm -B build-stage1 -G "Unix Makefiles" \
                //         //         -DCMAKE_OSX_ARCHITECTURES='arm64' \
                //         //         -DCMAKE_C_COMPILER=`which clang` \
                //         //         -DCMAKE_CXX_COMPILER=`which clang++` \
                //         //         -DCMAKE_BUILD_TYPE=Release \
                //         //         -DCMAKE_INSTALL_PREFIX=$PWD/stage1/clang-14.0.6/arm64 \
                //         //         -DLLVM_TARGETS_TO_BUILD="AArch64" \
                //         //         -DLLVM_HOST_TRIPLE='aarch64-apple-darwin' \
                //         //         -DLLVM_DEFAULT_TARGET_TRIPLE='aarch64-apple-darwin' \
                //         //         -DLLVM_ENABLE_PROJECTS='clang;libcxx;libcxxabi' \
                //         //         -DLLVM_DISTRIBUTION_COMPONENTS='clang;cxx;cxxabi;cxx-headers'

                //         //     make -C build-stage1 -j "$NPROC" install-distribution
                //         //     find $PWD/stage1/clang-14.0.6/arm64/

                //         //     cmake -S llvm -B build-stage2 -G "Unix Makefiles" \
                //         //         -DCMAKE_OSX_ARCHITECTURES='arm64' \
                //         //         -DCMAKE_C_COMPILER=$PWD/stage1/clang-14.0.6/arm64/bin/clang \
                //         //         -DCMAKE_CXX_COMPILER=$PWD/stage1/clang-14.0.6/arm64/bin/clang++ \
                //         //         -DCMAKE_BUILD_TYPE=Release \
                //         //         -DCMAKE_INSTALL_PREFIX=$PWD/stage2/clang-14.0.6/arm64 \
                //         //         -DLLVM_TARGETS_TO_BUILD="AArch64" \
                //         //         -DLLVM_HOST_TRIPLE='aarch64-apple-darwin' \
                //         //         -DLLVM_DEFAULT_TARGET_TRIPLE='aarch64-apple-darwin' \
                //         //         -DLLVM_ENABLE_PROJECTS='clang' \
                //         //         -DLLVM_DISTRIBUTION_COMPONENTS='clang' \
                //         //         -DLLVM_ENABLE_LIBCXX=ON

                //         //     make -C build-stage2 -j "$NPROC" install-distribution
                //         //     find $PWD/stage2/clang-14.0.6/arm64/
                //         // ''')
                //         // sh('''
                //         //     ls -l $HOME/clang-14.0.6/arm64/bin/
                //         // ''')
                //     }
                //     // post {
                //     //     always {
                //     //         archiveArtifacts(artifacts: '', allowEmptyArchive: true)
                //     //     }
                //     // }
                // }
                // stage('llvm x86_64 darwin') {
                //     agent {
                //         node('macos')
                //     }
                //     steps {
                //         gitPrep()
                //     }
                // }
                stage('llvm x86_64 linux') {
                    agent {
                        dockerfile {
                            filename "Dockerfile.llvm"
                        }
                    }
                    steps {
                        sh('''
                            gitPrep()

                            git clone https://github.com/llvm/llvm-project
                            cd llvm-project
                            git checkout llvmorg-14.0.6

                            mkdir build
                            cd build

                            cmake -GNinja ../llvm \
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
