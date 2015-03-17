# Sistema de Consulta do Moodle

## Objetivo deste Sistema
Esse sistema visa consultar os alunos da base de dados do moodle, para que seja possível ter uma lista de e-mail sempre atualizada.
Já que, os e-mails do moodle são verificados e são os próprios alunos que mantem seus perfis.

## Requisitos do Sistema
* Esta aplicação é em Rails 4, necessita de ao menos 1 GB de ram e espaço em HD de 5GB.
* É necessário um usuário na base de dados do moodle, de preferência com permissões de somente consulta nas tabelas.


## Instalação

Antes de qualquer coisa atualizar o sistema para evitar problemas futuros:

`sudo apt-get update`
`sudo apt-get upgrade`

Instalar alguns pacotes de dependências

`sudo apt-get install build-essential libmysqlclient-dev libssl-dev libyaml-dev libreadline-dev openssl curl git-core zlib1g-dev bison libxml2-dev libxslt1-dev libcurl4-openssl-dev nodejs libsqlite3-dev sqlite3`

Verificar a versão stable do ruby: https://www.ruby-lang.org/en/downloads/

`wget http://cache.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz` Alterar esse link sempre que tiver nova versão (a versão 2.2.1 tava falhando no comando make, caso falhar pegar a versão stable anterior)

`tar -xzf ruby-2.1.5.tar.gz`

`cd ruby-2.1.5`

`./configure`

`make`

`sudo make install`

Verificar a versão do ruby
`ruby -v`

Se tiver tudo ok, remover os arquivos de instalação do ruby
`cd ..`
`rm -rf ~/ruby-2.1.5`
`rm ruby-2.1.5.tar.gz`


Adicionar as chaves para download da última versão do NGINX
`sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7`

edita o arquivo de source do apt-get

`sudo nano /etc/apt/sources.list`

No final do arquivo colocar
`deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main`

Atualizar os pacotes e instalar o NGINX e Passenger
`sudo apt-get update`
`sudo apt-get install nginx-extras passenger`

Com isso algumas vezes as dependencias serão instaladas e sobreescreverá nossa versão do Ruby, assim precisamos voltar a versão atualizando o bin do ruby.

`sudo rm /usr/bin/ruby`
`sudo ln -s /usr/local/bin/ruby /usr/bin/ruby`


Feito isso precisamos criar a pasta onde ficará nossa aplicação:
`mkdir ~/app`


Editar o arquivo /etc/nginx/nginx.conf
`sudo nano /etc/nginx/nginx.conf`

Nas linhas onde estiver, descomentar as linhas tirando o '#'
`
passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
passenger_ruby /usr/bin/ruby;
`

Editar o arquivo /etc/nginx/sites-enabled/default
`sudo nano /etc/nginx/sites-enabled/default`

Comentar o bloco server existente e adicionar esse abaixo, trocando seuusuario pelo seu Usuário e colocando o IP do seu servidor no server_name:
`
server {
  listen 80;

  root /home/seuusuario/app/moodle_alunos/current/public;
  passenger_enabled on;
  passenger_app_env production;

  # Make site accessible from the IP
  server_name 192.168.103.208;

}`

Feito isso, reiniciar o nginx
`sudo service nginx restart`

Instalar o bundler responsável pelas dependências do projeto
`sudo gem install bundler`

Instalar o banco de dados a ser utilizado
`sudo apt-get install mysql-server`

Colocar a senha para o root etc, entrar no prompt do mysql executando o comando abaixo e colocando a senha do mysql
`mysql -p -u root`

Criar o banco de dados da aplicação
`create database moodle_alunos;`

Para sair `\q`

Agora faremos a publicação da aplicação no servidor via Capistrano
Na sua máquina com o projeto clonado, deverá atualizar o IP de deploy no arquivo e o usuário que está sendo utilizado.
`nano config/deploy/production.rb`

Depois atualizar o arquivo, colocando o caminho correto da pasta app
`nano config/deploy.rb`


Executar o comando, ele executará, criará umas pastas e dará erro que o arquivo config/database.yml está faltando
`cap production deploy`

No servidor criar o arquivo database.yml na pasta shared
`~/app/moodle_alunos/shared/config/database.yml`

e colocar os dados das conexões dos bancos:

`
production:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: moodle_alunos
  username: root
  password: 'suasenha'
  pool: 5
  host: localhost
  port: 3306

moodle:
  adapter: mysql2
  encoding: utf8
  reconnect: false
  database: moodle
  pool: 5
  username: usuariodobandodomoodle
  password: 'senhadousuariodobancodomoodle'
  host: 192.168.103.xxx
  port: 3306

`

Criar o arquivo secrets.yml colocando uma chave secreta no ambiente de produção, como exemplo, (ALTERAR, não deixar a mesma!)
`~/app/moodle_alunos/shared/config/secrets.yml`

Dados do arquivo secrets.yml

`production:
  secret_key_base: b38c6d5ef3c8048bea9a41ff4ea20676e505404e973446c3efc9d281fe65acaab402f85547f8c16e65b870b900448a21365ad48977d642cd5b85616a1bd7382b`

Voltar a máquina local e executar o comando para deploy da aplicação:
`cap production deploy`

Será feito o bundle, compilado os assets e executado migrações no banco.
Para criar o usuário admin da aplicação é necessário entar no servidor e ir na pasta da aplicação atual:
`cd ~/app/moodle_alunos/current`
`bundle exec rake db:seed RAILS_ENV=production`

Caso seja necessário reiniciar o nginx, é possível da pasta do projeto executar:
`cap production deploy:restart`

Acho que é isso! (-_-)

Para auxílio sti@feliz.ifrs.edu.br
