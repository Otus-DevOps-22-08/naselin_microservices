# naselin_microservices
naselin microservices repository
---
<!-- MarkdownTOC autolink=true -->

- [HW-12 (lessons-16:17). Технология контейнеризации. Введение в Docker.](#hw12)
- [HW-13 (lesson-18). Docker-образы. Микросервисы.](#hw13)
- [HW-14 (lesson-19). Docker: сети, docker-compose.](#hw14)
- [HW-15 (lesson-23). Введение в мониторинг. Системы мониторинга.](#hw15)
- [HW-16 (lesson-26). Логирование и распределенная трассировка.](#hw16)
- [HW-17 (lesson-27). Введение в kubernetes.](#hw17)
- [HW-18 (lesson-28). Устройство Gitlab CI. Построение процесса непрерывной поставки.](#hw18)
- [HW-19 (lesson-30). Kubernetes. Запуск кластера и приложения. Модель безопасности.](#hw19)
- [HW-20 (lesson-31). Kubernetes. Networks, Storages.](#hw20)

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

---
## HW-16 (lesson-26). <a name="hw16"> </a>
#### Логирование и распределенная трассировка.
1. Создан compose-файл для системы логирования, Dockerfile и конфигурация для `Fluentd`.
2. Собраны logging-enable образы приложения, настроена отправка логов `post` во `Fluentd`, запущена система логирования.
3. Создан индекс в `Kibana`, опробован поиск по полям, добавлены фильтры во `Fluentd` для парсинга структурированных логов.
4. Настроена отправка логов `ui` во `Fluentd`, добавлен фильтр в виде regexp.
5. Регулярные выражения заменены на шаблоны `grok`, (* включая формат вида:
```service=ui | event=request | path=/new | request_id=fc733abc-6157-4c2c-8530-c9c041a3ca70 | remote_addr=1.2.3.4 | method= POST | response_status=303 ```
6. В систему логгирования добавлен `Zipkin`, ииследованы трейсы.
7. Проведен траблшутинг UI-экспириенса (`bugged-code`):
   1. страница с любым постом загружается более 3 секунд;
   2. с помощью `Zipkin` найден источник проблемы: route `/post/<id>` -> функция `find_post(id)` -> инструкция `time.sleep(3)`;
   3. проблема в коде устранена, после пересборки образа загрузка любой страницы занимает ~60-70 мс.

Запуск проекта:
```
$ cd $REPO_ROOT/logging/fluentd && docker build -t $USER_NAME/fluentd .
$ cd $REPO_ROOT/docker && docker-compose -f docker-compose-logging.yml -f docker-compose.yml up -d
```

Проверка работоспособности:

перейти по ссылке
1. `http://{{ external_vm_ip_address }}:9292` - приложение;
2. `http://{{ external_vm_ip_address }}:5601` - Kibana;
3. `http://{{ external_vm_ip_address }}:9411` - Zipkin.

---
## HW-17 (lesson-27). <a name="hw17"> </a>
#### Введение в kubernetes.
1. Созданы заготовки манифестов `post-deployment.yml`, `ui-deployment.yml`, `comment-deployment.yml`, `mongo-deployment.yml`.
2. С помощью terraform развёрнуты 2 VM.
3. С помощью ansible установлено необходимое ПО, развёрнут кластер k8s.
4. После установки, ноды в состоянии `NotReady`. Для решения проблемы в playbook добавлена установка `calico`. Результат:
```
$ kubectl get nodes
NAME        STATUS   ROLES           AGE   VERSION
k8s-node0   Ready    control-plane   18m   v1.26.2
k8s-node1   Ready    <none>          17m   v1.26.2
```
5. Применены созданные в п.1 манифесты (`kubectl apply -f <filename.yml>`):
```
$ kubectl get pods
NAME                                  READY   STATUS    RESTARTS   AGE
comment-deployment-7d7f4cd5d4-8bx5j   1/1     Running   0          11m
mongo-deployment-5b955d497d-mfbf5     1/1     Running   0          12m
post-deployment-756db975b8-cgrqm      1/1     Running   0          12m
ui-deployment-5c4544b6bd-s4jgn        1/1     Running   0          11m
```

Запуск проекта (после настройки переменных `terraform`):
```
$ cd kubernetes && bash setup_infra.sh
```

Проверка работоспособности:

выполнить команду `ssh -i ~/.ssh/appuser ubuntu@x.x.x.x kubectl get nodes` (x.x.x.x - IP-адрес мастер-ноды), убедиться что ноды в статусе `Ready`.

---
## HW-18 (lesson-28). <a name="hw18"> </a>
#### Устройство Gitlab CI. Построение процесса непрерывной поставки.
1. С помощью terraform развёрнута VM.
2. С помощью ansible установлено необходимое ПО, развёрнут Gitlab (omnibus-установка).
3. Создана группа и проект, добавлен remote к своему репозиторию.
4. В файле `.gitlab-ci.yml.` описано определение CI/CD Pipeline.
5. В интерфейсе найден токен, добавлен и зарегистрирован раннер.
6. В репозиторий добавлен исходный код reddit, добавлены тесты в пайплайне.
7. Добавлены окружения dev, staging и production.
8. Добавлены и проверены (пуш с тэгами) условия для задач.
9. Добавлены динамические окружения, проверено их создание для новых веток.
10. Суть задания про запуск reddit в контейнере не до конца осознал. Поэтому, использовал собранный в одном из предудыщих заданий образ с reddit-контейнером.
11. Для автоматизации развёртывания gitlab-runner был выбран вариант с ansible-playbook.
12. Настроены оповещения в канале Slack, канал доступен по <a href=https://devops-team-otus.slack.com/archives/C044H5AU3KJ>ссылке</a>.

P.S. В ходе экспериментов свободная оперативная памть VM внезапно закончилась (и раннеры начали непредсказуемо падать в случайных местах).
В связи с этим, увеличил цифру в terraform до 8GB.

Запуск проекта:
1. настроить переменные terraform, развернуть VM: `$ cd $REPO_ROOT/gitlab-ci/terraform && terraform apply`;
2. настроить IP в ansible inventory, развернуть docker: `$ cd $REPO_ROOT/gitlab-ci/ansible && ansible-playbook setup-docker.yml -i inventory`
3. развернуть gitlab: `$ cd $REPO_ROOT/gitlab-ci/ansible && ansible-playbook setup-gitlab.yml -i inventory`;
4. залогиниться на VM: `$ ssh -i ~/.ssh/appuser ubuntu@x.x.x.x` (где `x.x.x.x` - внешний IP-адрес VM), дождаться запуска ПО;
5. получить пароль root: `$ sudo docker exec -it gitlab_web_1 grep 'Password:' /etc/gitlab/initial_root_password`;
6. перейти по ссылке: `http://x.x.x.x`, залогиниться, создать необходимые сущности (группа и проект);
7. найти в интерфейсе токен (ниже - YourToken), развернуть и зарегистрировать раннер:
`$ cd $REPO_ROOT/gitlab-ci/ansible && ansible-playbook setup-runner.yml -i inventory --extra-vars=registration_token=YourToken`.

---
## HW-19 (lesson-30). <a name="hw19"> </a>
#### Kubernetes. Запуск кластера и приложения. Модель безопасности.
1. Установлен `kubectl` по <a href=https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management>документации</a>.
2. Установлен и запущен `minikube` по <a href=https://minikube.sigs.k8s.io/docs/start/>документации</a>:
```
✗ kubectl get nodes
NAME       STATUS   ROLES           AGE    VERSION
minikube   Ready    control-plane   5m9s   v1.26.1
```
4. Подправлен манифест и запущен `ui`-компонент.
5. Проверена работоспособность через проброс портов (`kubectl port-forward ui-deployment-b9c4c5b97-bf7nc 8080:9292`).
6. Аналогичным образом запущены и проверены остальные сервисы (`post`, `comment`).
7. Созданы объекты `service`, с помощью сервисов и переменных окружения решена проблема доступа контейнеров к БД.
8. По <a href=https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/>документации</a> развёрнут и исследован `dashboard` (по умолчанию был отключен).
Все необходимые манифесты находятся в директории `$REPO_ROOT/kubernetes/dashboard`.
9. Создан новый `namespace` (`dev`), в нём развёрнуто приложение.
10. Вручную развёрнут `k8s` в YC (Yandex Cloud Managed Service for kubernetes), запущено приложение.
11. Автоматизировано развёртывание `k8s` в YC с помощью `terraform`.

Запуск проекта:
1. настроить переменные terraform, развернуть k8s: `cd $REPO_ROOT/kubernetes/terraform && terraform apply`. Предполагается, что все необходимые сущности (сервисные аккаунты и т.п.) созданы заранее;
2. подключиться к k8s: `yc managed-kubernetes cluster get-credentials test-cluster --external`;
3. убедиться, что текущий контекст верный:
```
$ kubectl config current-context
yc-test-cluster
```
4. создать namespace: `kubectl apply -f $REPO_ROOT/kubernetes/reddit/dev-namespace.yml`;
5. развернуть приложение: `kubectl apply -f $REPO_ROOT/kubernetes/reddit/ -n dev`;
6. найти внешний IP-адрес ноды: `kubectl get nodes -o wide` и порт публикации сервиса ui: `kubectl describe service ui -n dev | grep NodePort`.

Проверка работоспособности:
- перейти по ссылке, используя найденные выше адрес и порт: http://EXTERNAL-IP:NodePort

---
## HW-20 (lesson-31). <a name="hw20"> </a>
#### Kubernetes. Networks, Storages.
1. Проведена проверка, что при нулевом количестве реплик kube-dns сервисы недоступны по именам.
2. Тип сервиса ui изменен на `LoadBalancer`, проверена доступность.
3. Установлен и настроен ingress по <a href=https://kubernetes.github.io/ingress-nginx/deploy/>актуальной документации</a>.
4. Создан `ui-ingress.yml`, также с использованием <a href=https://kubernetes.io/docs/concepts/services-networking/ingress/>актуальной документации</a>.
5. Вручную создан сертификат и объект Secret, Ingress настроен на работу только по HTTPs.
6. Для описания объекта Secret в виде Kubernetes-манифеста применён "путь наименьшего сопротивления":
`kubectl get secret ui-ingress -n dev -o=yaml > ui-ingress-secret.yml` с последущей небольшой подчисткой.
7. Для ограничения трафика к mongodb применён инструмент NetworkPolicy (доступ имеют только сервисы post и comment).
8. Создан PersistentVolume под хранилище для БД, и PersitentVolumeClaim - запрос на выдачу ресурса.

Запуск проекта:
1. выполнить действия, аналогичные пп. 1-4 предыдущего задания;
2. развернуть Ingress: `$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.6.4/deploy/static/provider/cloud/deploy.yaml
`;
3. развернуть приложение: `kubectl apply -f $REPO_ROOT/kubernetes/reddit/ -n dev` (предполагается, что отдельный диск создан заранее и прописан в `mongo-volume.yml`);
4. найти внешний `ADDRESS`: `kubectl get ingress -n dev`.

Проверка работоспособности:
- перейти по ссылке, используя найденные выше адрес: http://ADDRESS
