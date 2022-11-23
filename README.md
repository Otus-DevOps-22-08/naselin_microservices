# naselin_microservices
naselin microservices repository
---
<!-- MarkdownTOC autolink=true -->

- [HW-12 (lessons-16:17). Технология контейнеризации. Введение в Docker](#HW12)

<!-- /MarkdownTOC -->
---
## HW-12 (lessons-16:17). <a name="HW12"></a>
#### Технология контейнеризации. Введение в Docker
1. Установлен Docker, запущены контейнеры.
2. Создан image из запущенного контейнера.
3. Создан Docker-хост в Yandex Cloud.
4. Собран образ с приложением reddit, запущен контейнер на его основе.
5. Образ загружен на Docker Hub, проверен запуск контейнера с загрузкой образа.
6. Автоматизировано развёртывание инфраструктуры и контейнеров:
   1. подготовлена конфигурация Terraform для поднятия нескольких инстансов (количество задаётся переменной);
   2. подготовлены плейбуки Ansible с использованием динамического инвентори для установки докера и запуска там образа приложения;
   3. подготовлен шаблон Packer, который делает образ с уже установленным Docker;
   4. с помошью шаблона собран образ с установленным Docker.

Запуск проекта (от корня репозитория, после настройки переменных):
1. поднять инстансы `$ cd docker-monolith/infra/terraform/ && terraform apply`
2. развернуть приложение `cd docker-monolith/infra/ansible/ && ansible-playbook playbooks/site_docker.yml`
3. (опционально) собрать образ Packer  `cd docker-monolith/infra/ && packer build -var-file=packer/variables.json packer/docker_host.json`

Проверка работоспособности:
перейти по ссылке `http://{{ external_ip_address_app }}` для каждого из созданных инстансов.
