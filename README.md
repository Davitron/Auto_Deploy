# Auto_Deploy

## About
Auto_Deploy is a script that automatically deploys a nodejs project from github to an `Ubuntu server` on Amazon AWS

#### Dependencies
These project uses:
1. [`pm2`](http://pm2.keymetrics.io/) An advanced process manager for production Node.js applications.
2.  [`nginx`](https://www.nginx.com/) A web server used as a reverse proxy
3.  [`Certbot`](https://github.com/certbot/certbot) Automatically enable HTTPS on your website with EFF's Certbot, deploying Let's Encrypt certificates.

#### Security Group
>- The following configurations for security groups should be used when setting up an instance:
>- set `type`:`HTTP` to `source` of `Anywhere`
>- set `type`:`HTTPS` to `source` of `Anywhere`
>- set `type`:`Custom TCP` to `port`:8000 of `source`: `MY IP`
>- set `type`:`SSH` to `source` of `MY IP`


#### Instructions

1. Clone the repository and cd into it
    ```
    git clone https://github.com/Davitron/Auto_Deploy.git
    cd  Auto_Deploy
    ```
2. Add the required environment variables to the `declareEnv` function from `line 16 to 19`
3. Specified the domain names in the `configureNGINX` function located in the `deploy.sh` function
4. To run the script, run
    ```
    bash deploy.sh
    ```