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
    - Перенаправляет запросы с `/` и `/homepage` на ранее созданный сервис на 80 порту
1. Написал и применил манифест для middleware - `middleware.yaml` :
    - Убирается префикс /homepage из пути перед пересылкой запроса.

_В IngressController на основе traefik (устанавливается в k3s по умолчанию) не предусмотрена возможность использования rewrite правил. Вместо них используется другой подход с использованием Routers/Middlewares._

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

## ДЗ № 4. kubernetes-volumes

- [x] Основное ДЗ
- [x] Задание со *

## В процессе сделано

1. Скопировал из HW3 манифест для namespace: содержит имя namespace в котором будут разворачиваться ресурсы - `namespace.yaml`
1. Скопировал из HW3 манифест для configmap : содержит nginx.conf с указанием порта и места хранения index.html - `nginx-cm.yaml`
1. Скопировал из HW3 манифест для deployment: содержит описание необходимых контейнеров, их конфигов и общего количества - `deployment.yaml`
1. Скопировал из HW3 манифест для service: объединяет набор реплик (подов) в единый интерфейс, определяет селектор, который указывает, какие поды считаются частью сервиса
1. Скопировал из HW3 манифест для ingress: пределяет хосты и пути, по которым происходит маршрутизация трафика к сервису
1. Скопировал из HW3 манифест для middleware: убирает префикс /homepage из пути перед использованием в ингрессе.
1. Написал и применил манифест для storageClass - `storageClass.yaml` :
    - Использует provisioner: driver.longhorn.io
    - Использует reclaim policy: Retain
1. Написал и применил манифест для PersistentVolumeClaim - `pvc.yaml` :
    - Запрашивает 1Гб из ранее созданного pvc `longhorn-storage`
1. Написал и применил манифест для configMap - `cm.yaml` :
    - Содержит тестовые данные

## Как запустить проект

_В k3s по умолчанию доступен только Local Path Provisioner. Для более полноценной работы необходимо установить `driver.longhorn.io` Provisioner._

- Установить `driver.longhorn.io` Provisioner:

```bash
ubuntu@k3s1 ~> kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/v1.5.3/deploy/longhorn.yaml

namespace/longhorn-system created
serviceaccount/longhorn-service-account created
serviceaccount/longhorn-support-bundle created
configmap/longhorn-default-setting created
configmap/longhorn-storageclass created
customresourcedefinition.apiextensions.k8s.io/backingimagedatasources.longhorn.io created
...
```

- Проверить необходимые поды для Provisioner:

```bash
ubuntu@k3s1 ~> kubectl -n longhorn-system get pod
NAME                                                READY   STATUS    RESTARTS       AGE
longhorn-ui-5b974686f-8r76n                         1/1     Running   0              2m24s
longhorn-ui-5b974686f-2fz97                         1/1     Running   0              2m24s
longhorn-manager-b56q5                              1/1     Running   1 (2m3s ago)   2m24s
longhorn-driver-deployer-54d5cddccc-zbjl9           1/1     Running   0              2m24s
csi-attacher-79b44f5d-nmhfl                         1/1     Running   0              111s
csi-attacher-79b44f5d-nmgkh                         1/1     Running   0              111s
csi-provisioner-c5bb4fff7-27zrt                     1/1     Running   0              111s
csi-attacher-79b44f5d-wpdw9                         1/1     Running   0              111s
csi-provisioner-c5bb4fff7-c42j7                     1/1     Running   0              111s
csi-provisioner-c5bb4fff7-zrrrk                     1/1     Running   0              111s
longhorn-csi-plugin-xhpn6                           3/3     Running   0              110s
csi-snapshotter-58bb8475bc-gxq2q                    1/1     Running   0              111s
csi-snapshotter-58bb8475bc-vz98p                    1/1     Running   0              111s
csi-snapshotter-58bb8475bc-4l879                    1/1     Running   0              111s
csi-resizer-8cc975c7f-kb55q                         1/1     Running   0              111s
csi-resizer-8cc975c7f-x55kx                         1/1     Running   0              111s
csi-resizer-8cc975c7f-hj6cw                         1/1     Running   0              111s
instance-manager-62de104bb6082e841721360eaa5564dd   1/1     Running   0              118s
engine-image-ei-68f17757-ts2dc                      1/1     Running   0              118s

```

- Проверить необходимый storageclass:

```bash
ubuntu@k3s1 ~> kubectl get storageclass
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  28d
longhorn (default)     driver.longhorn.io      Delete          Immediate              true                   2m23s
```

- Создать ресурсы:

```bash
ubuntu@k3s1 ~>kubectl apply -f namespace.yaml
ubuntu@k3s1 ~>kubectl apply -f nginx-cm.yaml
ubuntu@k3s1 ~>kubectl apply -f cm.yaml
ubuntu@k3s1 ~>kubectl apply -f storageClass.yaml
ubuntu@k3s1 ~>kubectl apply -f pvc.yaml
ubuntu@k3s1 ~>kubectl apply -f deployment.yaml
ubuntu@k3s1 ~>kubectl apply -f service.yaml
ubuntu@k3s1 ~>kubectl apply -f middleware.yaml
ubuntu@k3s1 ~>kubectl apply -f ingress.yaml
```

## Как проверить работоспособность

- Проверить наличие **storageClass** `longhorn-storage`:

```bash
ubuntu@k3s1 ~> k -n homework get storageClass

NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  28d
longhorn-storage       driver.longhorn.io      Retain          Immediate              false                  5h57m
longhorn (default)     driver.longhorn.io      Delete          Immediate              true                   5h48m
```

- Проверить статус **pvc** - должен быть `Bound`:

```bash
ubuntu@k3s1 ~> kubectl get pvc

NAME           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
homework-pvc   Bound    pvc-3ad7d226-31ff-4686-9120-7f7bfcc8e2d7   1Gi        RWO            longhorn-storage   9m28s
```

- Проверить статус **pv** - должен быть `Bound`:

```bash
ubuntu@k3s1 ~> kubectl get pv

NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                  STORAGECLASS       REASON   AGE
pvc-3ad7d226-31ff-4686-9120-7f7bfcc8e2d7   1Gi        RWO            Retain           Bound    default/homework-pvc   longhorn-storage            112s
```

- Проверить доступность сайта по путям:

```bash
ubuntu@k3s1 ~> curl http://homework.otus/
Tue Jan 30 14:10:30 UTC 2024

ubuntu@k3s1 ~> curl http://homework.otus/homepage
Tue Jan 30 14:10:30 UTC 2024

ubuntu@k3s1 ~> curl http://homework.otus/index.html
Tue Jan 30 14:10:30 UTC 2024
```

- Проверить наличие данных из `homework-cm` ConfigMap:

```bash
ubuntu@k3s1 ~> kubectl -n homework exec -it po/homework-deployment-644b8d59f4-5snk6 sh

$ cd /homework/conf
$ ls
test-key-name
$ cat /homework/conf/test-key-name
test-key-value
```

## ДЗ № 5. kubernetes-security

- [x] Основное ДЗ
- [] Задание со *

## В процессе сделано

1. Скопировал из HW4 манифест для ресурса Deployment
1. Написал и применил манифест для ServiceAccount - `sa-monitoring.yaml` :
    - Разрешает `get`, `list` к ресурсу `metrics-server`
    - Разрешает `get` к эндпоинту `/metrics`
1. Изменил манифест для Deployment - `deployment.yaml` :
    - Запускает контейнеры от имени сервисного аккаунка `monitoring`
1. Написал и применил манифест для ServiceAccount - `sa-cd` :
    - Дает роль `admin` в рамках namespace `homework`
1. Создал `kubeconfig` для ServiceAccount `cd`
1. Сгенерировал для ServiceAccount `cd` токен с временем действия 1 день и сохранил его в файл `token`

## Как запустить проект

- Создать ресурсы для сервисных аккаунтов:

```bash
ubuntu@k3s1 ~>kubectl apply -f sa-monitoring.yaml
ubuntu@k3s1 ~>kubectl apply -f sa-cd.yaml
```

- Обновить ресурс Deployment:

```bash
ubuntu@k3s1 ~>kubectl apply -f deployment.yaml
```

- Создать `kubeconfig` для ServiceAccount `cd`:

```bash
ubuntu@k3s1 ~>./generate-kubeconfig.sh
```

- Создать `token` для ServiceAccount `cd`:

```bash
ubuntu@k3s1 ~>kubectl -n homework create token cd --duration=24h > token
```

## Как проверить работоспособность

- Проверить доступность эндпоинта `/metrics` из-под сервисного аккаунта `monitoring`:

```bash
ubuntu@k3s1 ~> k -n homework exec --stdin --tty po/homework-deployment-546b5dddf8-9k2gs -- bash


nginx@homework-deployment-546b5dddf8-9k2gs:/$ SA=/var/run/secrets/kubernetes.io/serviceaccount
nginx@homework-deployment-546b5dddf8-9k2gs:/$ TOKEN=$(cat ${SA}/token)

nginx@homework-deployment-546b5dddf8-9k2gs:/$ curl -k -s --header "Authorization: Bearer ${TOKEN}" -X GET https://192.168.1.228:6443/metrics | head -5

# HELP aggregator_discovery_aggregation_count_total [ALPHA] Counter of number of times discovery was aggregated
# TYPE aggregator_discovery_aggregation_count_total counter
aggregator_discovery_aggregation_count_total 1408
# HELP aggregator_unavailable_apiservice [ALPHA] Gauge of APIServices which are marked as unavailable broken down by APIService name.
# TYPE aggregator_unavailable_apiservice gauge
```

- Проверить доступность апи - доступ должен отсутствовать:

```bash
nginx@homework-deployment-546b5dddf8-9k2gs:/$ CACERT=${SA}/ca.crt
nginx@homework-deployment-546b5dddf8-9k2gs:/$ curl -ks --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://192.168.1.228:6443/api/v1/namespaces/kube-system/endpoints

{
  "kind": "Status",
  "apiVersion": "v1",
  "metadata": {},
  "status": "Failure",
  "message": "endpoints is forbidden: User \"system:serviceaccount:homework:monitoring\" cannot list resource \"endpoints\" in API group \"\" in the namespace \"kube-system\"",
  "reason": "Forbidden",
  "details": {
    "kind": "endpoints"
  },
  "code": 403
}
```

- Проверить доступность ресурса `metric-server` - должен быть доступен:

```bash
nginx@homework-deployment-546b5dddf8-9k2gs:/$curl -ks --cacert ${CACERT} --header "Authorization: Bearer ${TOKEN}" -X GET https://192.168.1.228:6443/api/v1/namespaces/kube-system/endpoints/metrics-server

{
  "kind": "Endpoints",
  "apiVersion": "v1",
  "metadata": {
    "name": "metrics-server",
    "namespace": "kube-system",
    "uid": "3879fa0d-3985-4d8a-9be6-301e7b15b7b8",
    "resourceVersion": "3362935",
    "creationTimestamp": "2024-01-02T13:02:26Z",
    "labels": {
      "kubernetes.io/cluster-service": "true",
      "kubernetes.io/name": "Metrics-server",
      "objectset.rio.cattle.io/hash": "a5d3bc601c871e123fa32b27f549b6ea770bcf4a"
    },
    "annotations": {
      "endpoints.kubernetes.io/last-change-trigger-time": "2024-04-02T13:57:33Z"
    }
(сокращено)
```

- Проверить доступность ресурсов в namespace `homework` для сервисного аккаунта `cd`:

```bash
ubuntu@k3s1 ~> kubectl -n homework --kubeconfig kubeconfig-cd  get deployments
NAME                  READY   UP-TO-DATE   AVAILABLE   AGE
homework-deployment   3/3     3            3           63d
```

- Проверить недоступность ресурсов в других namespace  для сервисного аккаунта `cd`:

```bash
ubuntu@k3s1 ~> kubectl -n default --kubeconfig kubeconfig-cd  get deployments
Error from server (Forbidden): deployments.apps is forbidden: User "system:serviceaccount:homework:cd" cannot list resource "deployments" in API group "apps" in the namespace "default"
```
