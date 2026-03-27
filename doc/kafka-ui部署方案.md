# Kafka-UI LDAP 认证部署方案

## 方案说明

当前的部署情况：
* 主机在腾讯云，主机上部署了kafka-ui和ldap
* 外网clb是：49.51.78.21
* 这个clb上开启了tcp端口8086监听


## 第一步：准备 LDAP 配置文件

### 1.1 创建目录结构

```bash
mkdir -p /opt/kafka-ui/conf

```

### 1.2 RBAC 配置文件
/Users/liliang/work/Code_and_Docs/code/project/kafka-ui/doc/kafka-ui-config.yml


## 第二步：部署 kafka-ui

### 3.1 LDAP 和 kafka-ui 在同一台服务器

可以使用 Docker 网络连接：

```bash
# 创建 Docker 网络
docker network create kafka-ui-network

mkdir -p /opt/kafka-ui/ldap/data
mkdir -p /opt/kafka-ui/ldap/config

# 启动 LDAP（加入网络，数据持久化）
docker run -d --name ldap \
  --restart=always \
  --network kafka-ui-network \
  -p 10389:389 \
  -v /opt/kafka-ui/ldap/data:/var/lib/ldap \
  -v /opt/kafka-ui/ldap/config:/etc/ldap/slapd.d \
  -e LDAP_ORGANISATION="Planet Express" \
  -e LDAP_DOMAIN="planetexpress.com" \
  -e LDAP_BASE_DN="dc=planetexpress,dc=com" \
  -e LDAP_ADMIN_PASSWORD="GoodNewsEveryone" \
  osixia/openldap:latest


# 重新启动 kafka-ui（加入网络，使用容器名访问 LDAP）
docker stop kafka-ui
docker rm kafka-ui
docker run -d --name kafka-ui \
  --restart=always \
  --network kafka-ui-network \
  -p 8086:8080 \
  -v /opt/kafka-ui/conf/kafka-ui-config.yml:/etc/kafkaui/dynamic_config.yaml \
  -e DYNAMIC_CONFIG_ENABLED=true \
  -e AUTH_TYPE=LDAP \
  -e SPRING_LDAP_URLS=ldap://ldap:389 \
  -e SPRING_LDAP_BASE="cn={0},ou=people,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_USER="cn=admin,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_PASSWORD="GoodNewsEveryone" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_BASE="dc=planetexpress,dc=com" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_FILTER="(&(uid={0})(objectClass=inetOrgPerson))" \
  -e SPRING_LDAP_GROUP_FILTER_SEARCH_BASE="ou=people,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_GROUP_FILTER_SEARCH_FILTER="(uniqueMember={0})" \
  -e LOGGING_LEVEL_COM_PROVECTUS=INFO \
  -e LOGGING_LEVEL_ROOT=INFO \
  -e LOGGING_LEVEL_REACTOR_NETTY_HTTP_SERVER_ACCESSLOG=INFO \
 kafka-ui-custom:1.0



# 关闭动态添加Kafka集群（推荐使用此配置）
docker run -d --name kafka-ui \
  --restart=always \
  --network kafka-ui-network \
  -p 8086:8080 \
  -v /opt/kafka-ui/conf/kafka-ui-config.yml:/config/application.yml \
  -e DYNAMIC_CONFIG_ENABLED=false \
  -e SPRING_CONFIG_ADDITIONAL_LOCATION=/config/application.yml \
  -e AUTH_TYPE=LDAP \
  -e SPRING_LDAP_URLS=ldap://ldap:10389 \
  -e SPRING_LDAP_BASE="cn={0},ou=people,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_USER="cn=admin,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_PASSWORD="GoodNewsEveryone" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_BASE="dc=planetexpress,dc=com" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_FILTER="(&(uid={0})(objectClass=inetOrgPerson))" \
  -e SPRING_LDAP_GROUP_FILTER_SEARCH_BASE="ou=people,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_GROUP_FILTER_SEARCH_FILTER="(uniqueMember={0})" \
  -e LOGGING_LEVEL_COM_PROVECTUS=INFO \
  -e LOGGING_LEVEL_ROOT=INFO \
  -e LOGGING_LEVEL_REACTOR_NETTY_HTTP_SERVER_ACCESSLOG=INFO \
 kafka-ui-custom:1.0


```


