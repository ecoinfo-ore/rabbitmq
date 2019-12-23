# rabbitmq 

### Commands :

```
    docker build -t rabbitmq-stomp . 

    docker run -d                          \
               --name rabbitmq-stomp       \
               -p 1883:1883                \
               -p 5672:5672                \
               -p 8181:15672               \
               -p 15674:15674 rabbitmq-stomp

```

Or with env variables : 


```
    docker run -d                                                \
               --env VIRTUAL_HOST=/                              \
               --env ADMIN_LOGIN=admin                           \
               --env ADMIN_PASSWORD=admin                        \
               --env USER_LOGIN=user                             \
               --env USER_PASSWORD=user                          \
               --env COBY_ADMIN_EXCHANGE=coby-log-admin-exchange \
               --env COBY_USER_EXCHANGE=coby-log-user-exchange   \
                --name rabbitmq-stomp                            \
               -p 1883:1883                                      \
               -p 5672:5672                                      \
               -p 8181:15672                                     \
               -p 15674:15674 rabbitmq-stomp
```


Go to : http://localhost:8181  - ( admin/admin - user/user )

