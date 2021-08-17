# docker-cpp-dev-environment

基于docker的cpp开发环境

# 使用方式

1、docker-compose up 用于批量化启动服务

    reference: https://www.runoob.com/docker/docker-compose.html
    
2、docker ps -a 查询所有的容器（包括已停止的）

3、docker start 容器NAME/ID

    docker exec -it 容器NAME/ID
    
4、另一种启动方式：docker run -p 45678:22 -p 8730:873 -it ubuntu_cpp_env /bin/bash --name ubuntu_cpp

    reference: https://www.runoob.com/docker/docker-run-command.html
    
