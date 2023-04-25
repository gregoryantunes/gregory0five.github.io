# Shell Script para Instalação e Configuração do Zabbix Server
Este Shell Script automatiza a instalação e configuração do Zabbix Server em um servidor com sistema operacional CentOS 8.

### O script realiza as seguintes ações:

* Desativa e para o serviço firewalld
* Desabilita o SELinux
* Instala o repositório Percona e o Percona Server
* Configura o MySQL, criando o usuário zabbix e o banco de dados zabbix
* Instala o repositório Zabbix, o Zabbix Server, Zabbix Agent e o Zabbix Web
* Configura o Zabbix Server e Zabbix Web
* Reinicia e habilita os serviços do Zabbix Server, Zabbix Agent, Apache e PHP-FPM
* Exibe a URL, usuário e senha do Zabbix Web para acesso

### Observações:

* A senha do usuário root do MySQL é obtida a partir do log de instalação do MySQL
* A senha de acesso ao banco de dados do Zabbix e a senha de acesso ao Zabbix Web são definidas como N@8815fm5, sendo possível modificá-las diretamente no script

### Utilização:

1. Clone o repositório em seu servidor CentOS 8
2. Execute o comando sudo chmod +x install-zabbix.sh para tornar o script executável
3. Execute o comando sudo ./install-zabbix.sh para iniciar a instalação e configuração do Zabbix Server
4. Acesse o Zabbix Web através da URL exibida no final da instalação, utilizando o usuário "Admin" e senha "zabbix"

#### Observações adicionais
* É recomendado que seja feito um backup dos arquivos de configuração do MySQL e do Zabbix antes de executar o script, a fim de evitar perda de dados ou problemas na configuração já existente
* É possível modificar as configurações do Zabbix diretamente no arquivo /etc/zabbix/web/zabbix.conf.php, após a instalação e configuração do mesmo.
