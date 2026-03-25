# 1. 直接查询组的 DN
docker exec ldap ldapsearch -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -b "cn=admin_staff,ou=people,dc=planetexpress,dc=com" \
  "(objectClass=*)"

# 2. 查询 ou=people 下的所有条目
docker exec ldap ldapsearch -x -H ldap://localhost:10389 \
  -D "cn=admin,dc=planetexpress,dc=com" \
  -w GoodNewsEveryone \
  -b "ou=people,dc=planetexpress,dc=com" \
  "(objectClass=*)" \
  dn