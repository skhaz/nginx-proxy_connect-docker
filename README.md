This Dockerfile downloads the source of Nginx and compile with the module proxy_connect (ngx_http_proxy_connect_module)

Building

```
docker build --tag proxy:latest .
```

Running

```
docker run -p 8000:8000 -it proxy:latest
```

If you want to allow only one or more domain, add `server_name` between `http.server` with the desired domain:

```
http {
    server {
        listen $PORT;

        server_name *.domain.com;
```

And block all other domains with a new section:

```
server {
    listen 8000;
    server_name ~.+;
    return 404;
}
```
