# naselin_microservices
naselin microservices repository
---
<!-- MarkdownTOC autolink=true -->

- [HW-12 (lessons-16:17). Технология контейнеризации. Введение в Docker.](#hw12)
- [HW-13 (lesson-18). Docker-образы. Микросервисы.](#hw13)
- [HW-14 (lesson-19). Docker: сети, docker-compose.](#hw14)
- [HW-15 (lesson-23). Введение в мониторинг. Системы мониторинга.](#hw15)

<!-- /MarkdownTOC -->
---
## HW-12 (lessons-16:17). <a name="hw12"> </a>
#### Технология контейнеризации. Введение в Docker.
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

---
## HW-13 (lesson-18). <a name="hw13"> </a>
#### Docker-образы. Микросервисы.
0. Установлен hadolint, в дальнейшем использован для проверки и исправления Dockerfile'ов.
1. Загружен и распакован архив с новой структурой приложения.
2. Для каждого сервиса написан `Dockerfile`, собраны соответствующие образы.
3. Создана специальная сеть для приложения, запущены контейнеры, выполнена проверка работоспособности.
4. Контейнеры перезапущены с другими сетевыми алиасами без пересборки образов:
```
$ docker run -d --network=reddit --network-alias=post_db_new --network-alias=comment_db_new mongo:latest
$ docker run -d --network=reddit --network-alias=post_new -e POST_DATABASE_HOST='post_db_new' naselin/post:1.0
$ docker run -d --network=reddit --network-alias=comment_new -e COMMENT_DATABASE_HOST='comment_db_new' naselin/comment:1.0
$ docker run -d --network=reddit -p 9292:9292 -e POST_SERVICE_HOST='post_new' -e COMMENT_SERVICE_HOST='comment_new' naselin/ui:1.0
```
5. Пересобран образ `ui`, размер уменьшился с 770 до 412MB.
6. Проделаны дальнейшие шаги по оптимизации размера образа:
   1. использование более компактных базовых образов;
   2. использование опций для отключения кэширования;
   3. удаление пакетов и данных, не нужных для работы сервиса.
7. Проверенные подходы примемены ко всем образам (см. файлы `Dockerfile.*` для соответствующих сервисов). Итого:
   1. `comment` 760MB -> 66.3MB;
   2. `post` 116MB -> 74.1MB;
   3. `ui` 412MB -> 63.5MB.
8. Создан `volume`, при перезапуске контейнеров с опцией `-v` старые посты сохраняются.

Запуск проекта:
1. собрать образы;
2. создать сеть `reddit`;
3. создать volume `reddit_db`;
4. запустить контейнеры
```
$ docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
$ docker run -d --network=reddit --network-alias=post <your_login>/post:<version>
$ docker run -d --network=reddit --network-alias=comment <your_login>/comment:<version>
$ docker run -d --network=reddit -p 9292:9292 <your_login>/ui:<version>
```

Проверка работоспособности:
перейти по ссылке `http://{{ external_vm_ip_address }}:9292`

---
## HW-14 (lesson-19). <a name="hw14"> </a>
#### Docker: сети, docker-compose.
1. Запущены контейнеры с разными типами сети (`none`, `host`, `bridge`), рассмотрены их особенности.
2. Создана bridge-сеть в docker, в этой сети запущен проект `reddit`.
3. Проект `reddit` запущен в 2-х bridge-сетях (сервис `ui` не имеет доступа к БД).
4. Проект `reddit` запущен  с помощью `docker-compose`, `docker-compose.yml` модифицирован для использования 2-х сетей (аналогично п.3).
5. С помощью переменных окружения параметризованы: порт публикации сервиса `ui`, версии сервисов, `username` (файл `.env`).
```
Базовое имя проекта по умолчанию основано на названии каталога.
Можно переопределить с помошью ключа "-p" или переменной среды "COMPOSE_PROJECT_NAME".
```
6. Создан `docker-compose.override.yml` с целью:
   1. изменять код каждого из приложений, не выполняя сборку образа (используем `volume`);
   2. запускать puma для руби приложений в дебаг режиме с двумя воркерами.

Запуск проекта:
```
$ cd src && docker-compose up -d
```

Проверка работоспособности:

перейти по ссылке `http://{{ external_vm_ip_address }}:9292`

---
## HW-15 (lesson-23). <a name="hw15"> </a>
#### Введение в мониторинг. Системы мониторинга.
1. В контейнере запущен `Prometheus`, бегло изучен веб-интерфейс.
2. Реорганизована структура каталогов.
3. Собраны и выложены на `Docker Hub` все образы (доступны по <a href=https://hub.docker.com/u/naselin>ссылке</a>).
4. Исследован мониторинг состояния микросервисов.
5. Запущены `exporters` для мониторинга состояния хоста и сервисов (`prom/node`, `percona/mongodb`, `prom/blackbox`).
6. Написан `Makefile` для быстрой сборки и запуска контейнеров.

Запуск проекта:
```
$ cd docker && make && make start
```

Проверка работоспособности:

перейти по ссылке `http://{{ external_vm_ip_address }}:9090`
