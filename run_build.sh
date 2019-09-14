docker run -it --rm \
  -v /etc/localtime:/etc/localtime:ro \
  -v $PWD:/pwd \
  --entrypoint /pwd/build.sh \
  ubuntu:16.04
