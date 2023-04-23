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
        cp config.mak musl-cross-make/config.mak && cd musl-cross-make
        export CFLAGS="-fPIC -g1 \$CFLAGS"
        export TARGET=arm-linux-musleabihf
        make -j4
        make install
        """

        sh 'echo $(pwd)'
        tar(file: 'arm-linux-musleabifh-cross.tar.gz', compress: true, dir: '/tmp/musl', archive: true)
    }

    return createStage(name, options, action)
}

return this
