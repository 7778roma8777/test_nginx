# Используем официальный образ Ubuntu
FROM ubuntu:22.04

# Обновляем пакеты и устанавливаем необходимые программы
RUN apt-get update && \
    apt-get install -y openssh-server sudo supervisor && \
    mkdir /var/run/sshd

# Создаем пользователя ansibleuser и задаем пароль
RUN useradd -m -s /bin/bash ansibleuser && \
    echo "ansibleuser:111" | chpasswd && \
    usermod -aG sudo ansibleuser

# Настраиваем sudo, чтобы ansibleuser мог использовать sudo без пароля
RUN echo "ansibleuser ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Настраиваем SSH для разрешения входа по паролю и ключам
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config

# Настраиваем Supervisor для управления сервисами
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Открываем порты для SSH и Nginx
EXPOSE 2222 80

# Запускаем Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
