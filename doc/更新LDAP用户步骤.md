# 更新LDAP用户步骤


```shell
#管理员：patsnap_admin / 
#只读用户：kafka_read / 
#admin_staff 组包含 patsnap_admin
#ship_crew 组包含 kafka_read
```


## 1. 上传LDIF文件到服务器

将以下两个文件上传到腾讯云服务器：
- `ldap-new-users.ldif` - 新用户定义
- `ldap-new-groups.ldif` - 新组定义

```bash
# 在本地执行（假设服务器IP是你的腾讯云IP）
scp ldap-new-users.ldif root@你的服务器IP:/tmp/
scp ldap-new-groups.ldif root@你的服务器IP:/tmp/
```

## 2. 删除旧用户和旧组

登录到腾讯云服务器，执行以下命令：

```bash
# 删除旧的用户
docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Hubert J. Farnsworth,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Hermes Conrad,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Philip J. Fry,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Turanga Leela,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Turanga Leela,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Amy Wong+sn=Kroker,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=Bender Bending Rodríguez,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=John A. Zoidberg,ou=people,dc=planetexpress,dc=com"

# 删除旧的组
docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=admin_staff,ou=people,dc=planetexpress,dc=com"

docker exec ldap ldapdelete -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  "cn=ship_crew,ou=people,dc=planetexpress,dc=com"
```

## 3. 添加新用户

```bash
# 添加新用户
docker exec -i ldap ldapadd -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone < ./ldap-new-users.ldif
```

## 4. 添加新组

```bash
# 添加新组
docker exec -i ldap ldapadd -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone < ./ldap-new-groups.ldif
```

## 5. 验证新用户

```bash
# 查看所有用户
docker exec ldap ldapsearch -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  -b "ou=people,dc=planetexpress,dc=com" "(objectClass=inetOrgPerson)" cn uid

# 查看所有组
docker exec ldap ldapsearch -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  -b "ou=people,dc=planetexpress,dc=com" "(objectClass=groupOfUniqueNames)" cn uniqueMember
```

## 6. 测试登录

访问 http://你的服务器IP:8086

**管理员登录：**
- 用户名：patsnap_admin
- 密码：tzh9y4Vo2mto7LkD

**只读用户登录：**
- 用户名：kafka_read
- 密码：o8YHgjfeXVbi

## 注意事项

1. 不需要修改 kafka-ui 的配置文件，因为组名（admin_staff 和 ship_crew）没有变化
2. 不需要重启 kafka-ui 容器
3. 只需要重启 LDAP 容器（如果添加用户失败）：`docker restart ldap`
4. 新用户的 uid 字段用于登录，分别是 `patsnap_admin` 和 `kafka_read`

## 如果遇到问题

如果添加用户时提示"Already exists"，说明旧用户没有删除干净，可以：

```bash
# 查看所有现有用户
docker exec ldap ldapsearch -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" -w GoodNewsEveryone \
  -b "dc=planetexpress,dc=com" "(objectClass=inetOrgPerson)"

# 根据查询结果，手动删除对应的DN
```
