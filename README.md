Handy for starting a local Discourse instance running through Docker for Skillways on macOS.

```
d/boot_dev -p -e DISCOURSE_DEV_HOSTS=localhost,host.docker.internal -e UNICORN_TIMEOUT=9999 && \
d/bundle install && \
d/unicorn -x
```

Use the following to stop the development environment

```
d/shutdown_dev
```

Handy links

- /admin - the main admin dashboard route
- http://localhost:9292/ - the location of the local development discourse instance
