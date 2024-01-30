# Репозиторий для выполнения домашних заданий курса "Инфраструктурная платформа на основе Kubernetes-2023-12"

## ДЗ № 1. kubernetes-intro

- [x] Основное ДЗ
- [ ] Задание со *

## В процессе сделано

1. Установил k3s
1. Написал и применил манифест для namespace: содержит имя namespace в котором будут разворачиваться ресурсы - `namespace.yaml`
1. Написал и применил манифест для configmap: содержит nginx.conf с указанием порта и места хранения index.html - `nginx-cm.yaml`
1. Написал и применил манифест для pod - `pod.yaml` :

- Используется init контейнер, пишущий текущее время в index.html
- После остановки контейнера с веб сервером, файл index.html удаляется
- Используется volume для хранения конфига веб сервера на основе configMap
- Используется volume для хранения содержимого веб сервера на основе emptyDir

## Как запустить проект

- Создать ресурсы:

```bash
kubectl apply -f namespace.yaml
kubectl apply -f nginx-cm.yaml
kubectl apply -f pod.yaml
```

## Как проверить работоспособность

- Узнать IP адрес пода:
`kubectl -n homework get po -o wide`

- Проверить ответ от веб сервера:
`curl <Pod_IP_Address>:8000`

## ДЗ № 2. kubernetes-intro

- [x] Основное ДЗ
- [x] Задание со *

## В процессе сделано

1. Скопировал из HW1 манифест для namespace: содержит имя namespace в котором будут разворачиваться ресурсы - `namespace.yaml`
1. Скопировал из HW1 манифест для configmap : содержит nginx.conf с указанием порта и места хранения index.html - `nginx-cm.yaml`
1. Написал и применил манифест для deployment - `deployment.yaml` :

- Создается в namespace homework
- Запускает 3 экземпляра пода, полностью аналогичных подам из HW1
- Имеет readiness пробу, проверяющую наличие файла /homework/index.html
- Имеет стратегию обновления подов RollingUpdate, maxUnavailable = 1
- Добавлен раздел nodeSelector, который гарантирует, что поды будут запущены только на нодах с меткой homework=true

## Как запустить проект

- Создать ресурсы:

```bash
ubuntu@k3s1 ~>kubectl apply -f namespace.yaml
ubuntu@k3s1 ~>kubectl apply -f nginx-cm.yaml
ubuntu@k3s1 ~>kubectl apply -f deployment.yaml
```

## Как проверить работоспособность

- Проверить статус деплоймента:

```bash
ubuntu@k3s1 ~>kubectl -n homework get deployment

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
homework-deployment   0/3     3            0           13s
```

- Проверить статус подов:

```bash
ubuntu@k3s1 ~>kubectl -n homework get po

NAME                                  READY   STATUS    RESTARTS   AGE
homework-deployment-5c9867b9b-njmbv   0/1     Pending   0          20s
homework-deployment-5c9867b9b-n4kb2   0/1     Pending   0          20s
homework-deployment-5c9867b9b-x4bmt   0/1     Pending   0          20s
```

- Проверить сообщения указывающий на причину статуса `Pending`:

```bash
ubuntu@k3s1 ~>kubectl -n homework events --for pod/homework-deployment-5c9867b9b-njmbv

LAST SEEN   TYPE      REASON             OBJECT                                    MESSAGE
2m3s        Warning   FailedScheduling   Pod/homework-deployment-5c9867b9b-njmbv   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
```

- Узнать имена нод:

```bash
ubuntu@k3s1 ~>kubectl get nodes

NAME   STATUS   ROLES                  AGE   VERSION
k3s1   Ready    control-plane,master   22d   v1.28.4+k3s2
```

- Применить лейбл к ноде:

```bash
ubuntu@k3s1 ~>kubectl label nodes k3s1 homework=true

node/k3s1 labeled
```

- Проверить что поды начали автоматически разворачиваться:

```bash
ubuntu@k3s1 ~>kubectl -n homework events --for pod/homework-deployment-5c9867b9b-njmbv

LAST SEEN   TYPE      REASON             OBJECT                                    MESSAGE
4m10s       Warning   FailedScheduling   Pod/homework-deployment-5c9867b9b-njmbv   0/1 nodes are available: 1 node(s) didn't match Pod's node affinity/selector. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..
13s         Normal    Pulling            Pod/homework-deployment-5c9867b9b-njmbv   Pulling image "busybox:latest"
12s         Normal    Scheduled          Pod/homework-deployment-5c9867b9b-njmbv   Successfully assigned homework/homework-deployment-5c9867b9b-njmbv to k3s1
9s          Normal    Pulled             Pod/homework-deployment-5c9867b9b-njmbv   Successfully pulled image "busybox:latest" in 3.878s (3.878s including waiting)
9s          Normal    Created            Pod/homework-deployment-5c9867b9b-njmbv   Created container init
9s          Normal    Started            Pod/homework-deployment-5c9867b9b-njmbv   Started container init
9s          Normal    Pulling            Pod/homework-deployment-5c9867b9b-njmbv   Pulling image "nginxinc/nginx-unprivileged"
1s          Normal    Pulled             Pod/homework-deployment-5c9867b9b-njmbv   Successfully pulled image "nginxinc/nginx-unprivileged" in 8.026s (8.026s including waiting)
1s          Normal    Created            Pod/homework-deployment-5c9867b9b-njmbv   Created container web
0s          Normal    Started            Pod/homework-deployment-5c9867b9b-njmbv   Started container web
```

- Проверить статус деплоймента:

```bash
ubuntu@k3s1 ~>kubectl -n homework get deployment

NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
homework-deployment   3/3     3            3           4m30s
```

- Обновить образ для `web` контейнера в деплойменте:

```bash
ubuntu@k3s1 ~>kubectl -n homework set image deployment/homework-deployment web=nginxinc/nginx-unprivileged:1.25.0-al
pine3.17

deployment.apps/homework-deployment image updated
```

- Проверить статус обновления деплоймента:

```bash
ubuntu@k3s1 ~>kubectl -n homework rollout status deployment

Waiting for deployment "homework-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "homework-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "homework-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "homework-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "homework-deployment" rollout to finish: 2 out of 3 new replicas have been updated...
Waiting for deployment "homework-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "homework-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "homework-deployment" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "homework-deployment" rollout to finish: 2 of 3 updated replicas are available...
deployment "homework-deployment" successfully rolled out
```

## ДЗ № 3. kubernetes-networks

- [x] Основное ДЗ
- [x] Задание со *

## В процессе сделано

1. Скопировал из HW2 манифест для namespace: содержит имя namespace в котором будут разворачиваться ресурсы - `namespace.yaml`
1. Скопировал из HW2 манифест для configmap : содержит nginx.conf с указанием порта и места хранения index.html - `nginx-cm.yaml`
1. Скопировал из HW2 манифест для deployment: содержит описание необходимых контейнеров, их конфигов и общего количества - `deployment.yaml` :
1. Написал и применил манифест для service - `service.yaml` :

- Создается в namespace homework
- Применяется к подам с лейблом `app: homework-app`
- Сервис слушает порт 80, перенаправляет запросы на порт 8000

1. Написал и применил манифест для ingress - `ingress.yaml` :

- Применяется для хоста с именем `homework.otus`
- Перенправляет запросы с `/` и `/homepage` на ранее созданный сервис на 80 порту

1. Написал и применил манифест для middleware - `middleware.yaml` :
В IngressController на основе traefik (устанавливается в k3s по-умолчанию) не предусмотрена возможность использования rewrite правил.
Вместо них ипользуется другой подход с использованием Routers/Middlewares.

- Убирается префикс /homepage из пути перед пересылкой запроса.

## Как запустить проект

- Создать ресурсы:

```bash
ubuntu@k3s1 ~>kubectl apply -f namespace.yaml
ubuntu@k3s1 ~>kubectl apply -f nginx-cm.yaml
ubuntu@k3s1 ~>kubectl apply -f deployment.yaml
ubuntu@k3s1 ~>kubectl apply -f service.yaml
ubuntu@k3s1 ~>kubectl apply -f middleware.yaml
ubuntu@k3s1 ~>kubectl apply -f ingress.yaml
```

- Добавить homework.otus в /etc/hosts

```bash
192.168.1.228   homework.otus
```

## Как проверить работоспособность

- Проверить статус сервиса:

```bash
ubuntu@k3s1 ~>kubectl -n homework get svc

NAME               TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
homework-service   ClusterIP   10.43.243.206   <none>        80/TCP    74m
```

- Проверить статус ингресса:

```bash
ubuntu@k3s1 ~>kubectl -n homework get ing

NAME               CLASS     HOSTS           ADDRESS         PORTS   AGE
homework-ingress   traefik   homework.otus   192.168.1.228   80      28m
```

- Проверить доступность сайта по путям:

```bash
ubuntu@k3s1 ~> curl http://homework.otus/
Wed Jan 24 14:01:02 UTC 2024

ubuntu@k3s1 ~> curl http://homework.otus/homepage
Wed Jan 24 14:01:13 UTC 2024

ubuntu@k3s1 ~> curl http://homework.otus/index.html
Wed Jan 24 14:00:46 UTC 2024
```
