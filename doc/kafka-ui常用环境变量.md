# Kafka-UI 常用环境变量配置

## 核心配置

### 1. 动态配置开关
```bash
# 是否允许在界面上动态添加/修改集群配置
-e DYNAMIC_CONFIG_ENABLED=false  # 推荐设置为false，防止误操作

# 动态配置文件路径（当DYNAMIC_CONFIG_ENABLED=true时使用）
-e DYNAMIC_CONFIG_PATH=/etc/kafkaui/dynamic_config.yaml
```

### 2. 静态配置文件
```bash
# 指定静态配置文件路径（当DYNAMIC_CONFIG_ENABLED=false时使用）
-e SPRING_CONFIG_ADDITIONAL_LOCATION=/config/application.yml
```

### 3. Groovy脚本过滤
```bash
# 是否允许使用Groovy脚本过滤消息（有安全风险，建议关闭）
-e FILTERING_GROOVY_ENABLED=false
```

## 日志配置

### 4. 日志级别
```bash
# 根日志级别
-e LOGGING_LEVEL_ROOT=INFO

# kafka-ui自身日志级别（默认是DEBUG，建议改为INFO）
-e LOGGING_LEVEL_COM_PROVECTUS=INFO

# Spring Security日志（调试认证问题时可以开启）
-e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_SECURITY=INFO

# LDAP日志（调试LDAP问题时可以开启）
-e LOGGING_LEVEL_ORG_SPRINGFRAMEWORK_LDAP=INFO

# Netty访问日志
-e LOGGING_LEVEL_REACTOR_NETTY_HTTP_SERVER_ACCESSLOG=INFO
```

## 认证配置

### 5. 认证类型
```bash
# 认证类型：DISABLED, LOGIN_FORM, LDAP, OAUTH2
-e AUTH_TYPE=LDAP
```

### 6. LDAP配置
```bash
# LDAP服务器地址
-e SPRING_LDAP_URLS=ldap://ldap:10389

# 用户DN模板
-e SPRING_LDAP_BASE="cn={0},ou=people,dc=planetexpress,dc=com"

# LDAP管理员账号（用于查询组信息）
-e SPRING_LDAP_ADMIN_USER="cn=admin,dc=planetexpress,dc=com"
-e SPRING_LDAP_ADMIN_PASSWORD="GoodNewsEveryone"

# 用户搜索配置
-e SPRING_LDAP_USER_FILTER_SEARCH_BASE="dc=planetexpress,dc=com"
-e SPRING_LDAP_USER_FILTER_SEARCH_FILTER="(&(uid={0})(objectClass=inetOrgPerson))"

# 组搜索配置
-e SPRING_LDAP_GROUP_FILTER_SEARCH_BASE="ou=people,dc=planetexpress,dc=com"
```

## 性能配置

### 7. 消息轮询配置
```bash
# 轮询超时时间（毫秒）
-e KAFKA_POLLING_POLLTIMEOUTMS=1000

# 每页最大消息数
-e KAFKA_POLLING_MAXPAGESIZE=100

# 默认每页消息数
-e KAFKA_POLLING_DEFAULTPAGESIZE=20
```

### 8. Admin客户端超时
```bash
# Kafka Admin客户端超时时间（毫秒）
-e KAFKA_ADMINCLIENTTIMEOUT=30000
```

## 监控配置

### 9. 健康检查和指标
```bash
# 启用健康检查端点
-e MANAGEMENT_ENDPOINT_HEALTH_ENABLED=true

# 启用info端点
-e MANAGEMENT_ENDPOINT_INFO_ENABLED=true

# 暴露的端点（逗号分隔）
-e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,prometheus
```

## 其他配置

### 10. 服务器端口
```bash
# 应用端口（容器内部端口，通常不需要改）
-e SERVER_PORT=8080
```

### 11. 内部Topic前缀
```bash
# 内部topic前缀（用于识别内部topic）
-e KAFKA_INTERNALTOPICPREFIX=__
```

## 完整示例（生产环境推荐配置）

```bash
docker run -d --name kafka-ui \
  --restart=always \
  --network kafka-ui-network \
  -p 8086:8080 \
  -v /opt/kafka-ui/application.yml:/config/application.yml \
  \
  # 核心配置
  -e DYNAMIC_CONFIG_ENABLED=false \
  -e SPRING_CONFIG_ADDITIONAL_LOCATION=/config/application.yml \
  -e FILTERING_GROOVY_ENABLED=false \
  \
  # 日志配置（关闭debug）
  -e LOGGING_LEVEL_ROOT=INFO \
  -e LOGGING_LEVEL_COM_PROVECTUS=INFO \
  -e LOGGING_LEVEL_REACTOR_NETTY_HTTP_SERVER_ACCESSLOG=INFO \
  \
  # LDAP认证
  -e AUTH_TYPE=LDAP \
  -e SPRING_LDAP_URLS=ldap://ldap:10389 \
  -e SPRING_LDAP_BASE="cn={0},ou=people,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_USER="cn=admin,dc=planetexpress,dc=com" \
  -e SPRING_LDAP_ADMIN_PASSWORD="GoodNewsEveryone" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_BASE="dc=planetexpress,dc=com" \
  -e SPRING_LDAP_USER_FILTER_SEARCH_FILTER="(&(uid={0})(objectClass=inetOrgPerson))" \
  -e SPRING_LDAP_GROUP_FILTER_SEARCH_BASE="ou=people,dc=planetexpress,dc=com" \
  \
  # 性能配置
  -e KAFKA_POLLING_DEFAULTPAGESIZE=20 \
  -e KAFKA_ADMINCLIENTTIMEOUT=30000 \
  \
  # 监控配置
  -e MANAGEMENT_ENDPOINT_HEALTH_ENABLED=true \
  -e MANAGEMENT_ENDPOINT_INFO_ENABLED=true \
  -e MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE=health,info,prometheus \
  \
  provectuslabs/kafka-ui:latest
```

## 环境变量命名规则

Spring Boot的环境变量命名规则：
- 配置文件中的点(.)用下划线(_)替换
- 全部大写
- 中括号[]用下划线和数字替换

示例：
- `logging.level.com.provectus` → `LOGGING_LEVEL_COM_PROVECTUS`
- `kafka.clusters[0].name` → `KAFKA_CLUSTERS_0_NAME`
- `spring.ldap.urls` → `SPRING_LDAP_URLS`

## 更多配置

完整的配置选项请参考官方文档：
https://docs.kafka-ui.provectus.io/configuration/misc-configuration-properties
