def call(jenkins) {
    String name = 'armhf-musl-gcc'
    Map options = [
        dockerFile: 'docker/Dockerfile',
    ]
    Closure action = {
        sh """/bin/bash -ex
        git clone --depth 1 https://github.com/richfelker/musl-cross-make.git build/
        cp config.mak build/config.mak && cd build/
        export CFLAGS="-fPIC -g1 \$CFLAGS"
        export TARGET=arm-linux-musleabihf
        make -j4
        make install
        """

        tar(file = "arm-linux-musleabifh-cross.tar.gz", compress = true, dir = 'output', archive = true)
    }

    return createStage(name, options, action)
}

return this
