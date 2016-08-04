# Docker Implementation for Masterstream 2.0 (using symfony3)
    
   Teck Stack: Nginx - MySQL - PHP7.0-FPM - Redis - ELK 
   
   (Elasticsearch, Logstash, Kibana)

## Installation
   
   1. Retrieve git project
   
       ```bash
       $ git clone https://github.com/mwitt9999/masterstream2-docker
       ```
   
   2. In the docker-compose file, indicate where's your Symfony project
   
       ```yml
       services:
           php:
               volumes:
                   - /path/to/your/masterstream/code:/var/www/masterstream
       ```
   
   3. Build containers with (with and without detached mode)
   
       ```bash
       $ docker-compose up
       $ docker-compose up -d
       ```
   
   4. Update your host file (add masterstream.dev && kibana.masterstream.dev)
   
       ```bash
       # get containers IP address and update host (replace IP according to your configuration)
       $ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -f name=nginx -q)
       
       # unix only (on Windows, edit C:\Windows\System32\drivers\etc\hosts)
       
       $ sudo echo "171.17.0.1 masterstream.dev" >> /etc/hosts (for main masterstream app)
       $ sudo echo "171.17.0.1 kibana.masterstream.dev" >> /etc/hosts (for kibana GUI)
       
       ```
   
       **Note:** If it's empty, run `docker inspect $(docker ps -f name=nginx -q) | grep IPAddress` instead.
   
   5. Prepare Masterstream app
       1. Retrieve DB&Redis IP
   
           ```bash
           $ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -f name=db -q)
           $ docker inspect --format '{{ .NetworkSettings.IPAddress }}' $(docker ps -f name=redis -q)
           ```
   
           **Note:** If it's empty, run `docker inspect $(docker ps -f name=db -q) | grep IPAddress` instead.
   
       2. Update app/config/parameters.yml
   
           ```yml
           # path/to/sfApp/app/config/parameters.yml
           parameters:
               redis_host: redis
               database_host: mysqldb
           ```
   
       3. Composer install & create database
   
           ```bash
           $ docker-compose exec -t -i masterstream2-php /bin/bash
           $ composer install
           $ sf doctrine:database:create
           $ sf doctrine:schema:update --force
           ```
   6. Copy .env.example from root of project to .env 
       1. Make sure to update any config variables (defaults point to docker containers)
       
   ## Usage
   
   Just run `docker-compose -d`, then:
   
   * Masterstream app: visit [masterstream.dev](http://masterstream.dev)  
   * Masterstream dev mode: visit [masterstream.dev/app_dev.php](http://symfony.dev/app_dev.php)  
   * (Kibana): [kibana.masterstream.dev](http://kibana.masterstream.dev)
   * Logs (files location): logs/nginx and logs/masterstream
   
   ## How it works?
   
   Have a look at the `docker-compose.yml` file, here are the `docker-compose` built images:
   
   * `db`: This is the MySQL database container,
   * `php`: This is the PHP-FPM container in which the application volume is mounted,
   * `nginx`: This is the Nginx webserver container in which application volume is mounted too,
   * `elk`: This is a ELK stack container which uses Logstash to collect logs, send them into Elasticsearch and visualize them with Kibana,
   * `redis`: This is a redis database container.
   
   This results in the following running containers:
   
   ```bash
   $ docker-compose ps
              Name                          Command               State              Ports            
   --------------------------------------------------------------------------------------------------
   masterstream2_db_1            /entrypoint.sh mysqld            Up      0.0.0.0:3306->3306/tcp      
   masterstream2_elk_1           /usr/bin/supervisord -n -c ...   Up      0.0.0.0:81->80/tcp          
   masterstream2_nginx_1         nginx                            Up      443/tcp, 0.0.0.0:80->80/tcp
   masterstream2_php_1           php-fpm                          Up      0.0.0.0:9000->9000/tcp      
   masterstream2_redis_1         /entrypoint.sh redis-server      Up      0.0.0.0:6379->6379/tcp      
   ```
   
   ## Redis Example 
   (see documentation [Predis Github](https://github.com/nrk/predis))
   
   ```php 
     use Predis; <---- import Predis
     
     $redisParams = [
         'scheme' => 'tcp',
         'host'   => getenv('REDIS_HOST'),  <---- Make sure to set .env variables (see .env.example)
         'port'   => getenv('REDIS_PORT'),
     ];
    
     try {
         $client = new Predis\Client($redisParams);
         $client->connect();
     } catch(Predis\Connection\ConnectionException $e) {
         echo $e->getMessage();
     }
    
     $client->set('key', 'value');
     $key = $client->get('key');
    
     return $key;
     
   ```

   
  ## ElasticSearch Example 
  (see documentation @ [ElasticSearch PHP Github](https://github.com/elastic/elasticsearch-php))
  
  ```php 
        $esHost = getenv('ELASTICSEARCH_HOST');
        $esPort = getenv('ELASTICSEARCH_PORT');

        $host = [
            $esHost.':'.$esPort
        ];

        $client = ClientBuilder::create()->setHosts($host)->build();

        $params = [
            'index' => 'brand_new',
            'body' => [
                'settings' => [
                    'number_of_shards' => 2,
                    'number_of_replicas' => 0
                ]
            ]
        ];

        $response = $client->indices()->create($params);

        $params = [
            'index' => 'test',
            'type' => 'test_type',
            'id' => 'test_id',
            'body' => ['testField' => 'testValue']
        ];

        $response = $client->index($params);

        return $response;
    
  ```
   
   ## Useful commands
   
   ```bash
   # bash commands
   $ docker-compose exec php bash
   
   # Composer (e.g. composer update)
   $ docker-compose exec php composer update
   
   # SF commands (Tips: there is an alias inside php container)
   $ docker-compose exec php php /var/www/symfony/bin/console cache:clear # Symfony3
   # Same command by using alias
   $ docker-compose exec php bash
   $ sf cache:clear
   
   # MySQL commands
   $ docker-compose exec db mysql -uroot -p"root"
   
   # Redis commands
   $ docker-compose exec redis redis-cli
   
   # Permissions for cache/logs folder
   $ sudo chmod -R 777 var/cache var/logs # Symfony3
   
   # Check CPU consumption
   $ docker stats $(docker inspect -f "{{ .Name }}" $(docker ps -q))
   
   # Delete all containers
   $ docker rm $(docker ps -aq)
   
   # Delete all images
   $ docker rmi $(docker images -q)
   ```
  