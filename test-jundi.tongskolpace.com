# PROXY-PASS
server {

     server_name test-jundi.tongkolspace.com www.test-jundi.tongkolspace.com;

    access_log /var/log/nginx/test-jundi.tongkolspace.com.access.log rt_cache;
    error_log /var/log/nginx/test-jundi.tongkolspace.com.error.log;


    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/test-jundi.tongkolspace.com-0001/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/test-jundi.tongkolspace.com-0001/privkey.pem; # managed by Certbot
    include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot

    location ^~ /amanah-v2/ {

        proxy_pass          http://127.0.0.1:7000;
        proxy_set_header    Host                $host;
        proxy_set_header    X-Real-IP           $remote_addr;
        proxy_set_header    X-Forwarded-For     $proxy_add_x_forwarded_for;
        proxy_set_header    X-Forwarded-Host    $host;
        proxy_set_header    X-Forwarded-Prefix  "/amanah-v2";
        proxy_set_header    X-Forwarded-Proto   https;
    }

}

server {
    if ($host = test-jundi.tongkolspace.com) {
        return 301 https://$host$request_uri;
    } # managed by Certbot


        listen 80;
        listen [::]:80;
        server_name test-jundi.tongkolspace.com;
        return 404; # managed by Certbot


}


# LARAVEL JALAN DI PORT 7000

server {
 server_name test-jundi.tongkolspace.com www.test-jundi.tongkolspace.com;
 listen 127.0.0.1:7000;

    access_log /var/log/nginx/amanah-v2.access.log rt_cache;
    error_log /var/log/nginx/amanah-v2.error.log;

    root /var/www/amanah-v2/htdocs/public;
    index index.php index.html index.htm;

    include common/php81.conf;
    include common/locations-wo.conf;
}
