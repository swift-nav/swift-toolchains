def call(jenkins) {
    String name = 'armhf-musl-gcc'
    Map options = [
        dockerFile: 'docker/Dockerfile',
    ]
    Closure action = {
        sh """/bin/bash -ex
        echo "hello world!"
        """
    }

    return createStage(name, options, action)
}
