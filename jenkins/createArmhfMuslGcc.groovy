def call(jenkins) {
    String name = 'armhf-musl-gcc'
    Map options = [
        dockerFile: 'docker/Dockerfile',
        node: 'docker.fast',
        env: [
            CC: 'sccache gcc',
            CXX: 'sccache g++'
        ]
    ]
    Closure action = {
        sh """/bin/bash -ex
        git clone --depth 1 https://github.com/richfelker/musl-cross-make.git
        cd musl-cross-make && cp config.mak musl-cross-make/config.mak
        export CFLAGS="-fPIC -g1 \$CFLAGS"
        export TARGET=arm-linux-musleabihf
        make -j4
        make install
        """

        sh 'echo $(pwd)'
        tar(file: 'arm-linux-musleabifh-cross.tar.gz', compress: true, dir: 'musl-cross-make/output', archive: true)
    }

    return createStage(name, options, action)
}

return this
