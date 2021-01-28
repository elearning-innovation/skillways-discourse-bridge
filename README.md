Handy for starting a local Discourse instance running through Docker for Skillways on macOS.

```
d/boot_dev -p -e DISCOURSE_DEV_HOSTS=localhost,host.docker.internal -e UNICORN_TIMEOUT=9999
d/unicorn -x
```
