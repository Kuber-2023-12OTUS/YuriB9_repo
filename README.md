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

## ДЗ № 6. kubernetes-templates

- [x] Задание 1
- [x] Задание 2

## В процессе сделано

1. Скопировал из HW4 манифесты для ресурсов
1. Инициализировал helm template
1. Шаблонизировал манифесты с помощью helm
1. Написал helmfile для Задания #2

## Как запустить проект

- Запустить билд зависимостей:

```bash
ubuntu@k3s1 ~>helm dependency build
```

- Устанавливаем helm-chart приложения web:

```bash
ubuntu@k3s1 ~>helm upgrade --install web web -f values.yaml -n homework --create-namespace
```

## Как проверить работоспособность

- Ресурсы должны быть созданы успешно:

```bash
ubuntu@k3s1 ~> kubectl -n homework get all
```

См. команды из ДЗ #4

## ДЗ № 7. kubernetes-operators

- [x] Задание
- [x] Задание c *
- [ ] Задание c **

## В процессе сделано

1. Создал манифест CRD (kind Mysql)
1. Создал сопутствующие манифесты: ClusterRole, ClusterRoleBinding (сначала широкий набор прав, потом обновлено на миниальный набор прав в соответствии с заданием с *), ServiceAccount
1. Создал манифест Deployment для ранее созданного оператора

## Как запустить проект

- Применить все манифесты:

```bash
ubuntu@k3s1 ~> kubectl apply -f .
clusterrole.rbac.authorization.k8s.io/mysql-operator created
clusterrolebinding.rbac.authorization.k8s.io/mysql-operator created
customresourcedefinition.apiextensions.k8s.io/mysqls.otus.homework created
deployment.apps/mysql-operator created
mysql.otus.homework/mysql created
serviceaccount/mysql-operator created
```

## Как проверить работоспособность

- Убедиться что ресурсы созданы и в рабочем состоянии:

```bash
ubuntu@k3s1 ~> kubectl get all
NAME                                  READY   STATUS    RESTARTS   AGE
pod/mysql-operator-6d79cb54f8-q5nx8   1/1     Running   0          12m
pod/mysql-5b4846bfd6-v7jcq            1/1     Running   0          12m

NAME                 TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)    AGE
service/kubernetes   ClusterIP   10.43.0.1    <none>        443/TCP    122d
service/mysql        ClusterIP   None         <none>        3306/TCP   12m

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mysql-operator   1/1     1            1           12m
deployment.apps/mysql            1/1     1            1           12m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/mysql-operator-6d79cb54f8   1         1         1       12m
replicaset.apps/mysql-5b4846bfd6            1         1         1       12m
```

- Убедиться что все ресурсы удаляются:

```bash
ubuntu@k3s1 ~> kubectl delete -f .
clusterrole.rbac.authorization.k8s.io "mysql-operator" deleted
clusterrolebinding.rbac.authorization.k8s.io "mysql-operator" deleted
customresourcedefinition.apiextensions.k8s.io "mysqls.otus.homework" deleted
deployment.apps "mysql-operator" deleted
mysql.otus.homework "mysql" deleted
persistentvolumeclaim "mysql-pvc" deleted
serviceaccount "mysql-operator" deleted

ubuntu@k3s1 ~> kubectl get all
No resources found in default namespace.

ubuntu@k3s1 ~> kubectl get mysql.otus.homework/mysql
error: the server doesn't have a resource type "mysql"
```

## ДЗ № 8. kubernetes-monitoring

- [x] Задание

## В процессе сделано

1. Создал образ nginx (на основе nginx-unprivileged) отдающий метрики по /metrics
1. Установил prometheus-operator с помощью helm
1. Создал манифесты Deployment (добавлен второй контейнер с nginx prometheus exporter) и Service
1. Создал манифест ServiceMonitor, описывающий сбор метрик

## Как запустить проект

- Создать и запушить в репозиторий кастомный образ с nginx:

```bash
ubuntu@k3s1 ~> docker build . -t nginx:0.1
ubuntu@k3s1 ~> docker image tag nginx:0.1 batkovyu/otus_nginx:0.1
ubuntu@k3s1 ~> docker push batkovyu/otus_nginx:0.1
```

- Установить prometheus-operator:

```bash
ubuntu@k3s1 ~> export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
ubuntu@k3s1 ~> helm upgrade --install kube-prometheus oci://registry-1.docker.io/bitnamicharts/kube-prometheus -n monitoring --create-namespace
Release "kube-prometheus" does not exist. Installing it now.
Pulled: registry-1.docker.io/bitnamicharts/kube-prometheus:9.0.5
Digest: sha256:634c95f08e34ea3e3492909c9d5c654d5e4dcc8e5cd49a334fe7fbe24b646413
NAME: kube-prometheus
LAST DEPLOYED: Sat May  4 06:39:38 2024
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kube-prometheus
CHART VERSION: 9.0.5
APP VERSION: 0.73.2
...

```

- Применить все манифесты:

```bash
ubuntu@k3s1 ~> kubectl apply -f .
deployment.apps/nginx-status created
service/nginx-status created
servicemonitor.monitoring.coreos.com/nginx-status created
```

## Как проверить работоспособность

- Убедиться что ресурсы созданы и в рабочем состоянии:

```bash
ubuntu@k3s1 ~> kubectl get all
NAME                                READY   STATUS    RESTARTS   AGE
pod/nginx-status-65d4c4dcbb-qzggd   2/2     Running   0          61s

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)             AGE
service/kubernetes     ClusterIP   10.43.0.1       <none>        443/TCP             110m
service/nginx-status   ClusterIP   10.43.236.237   <none>        8080/TCP,9113/TCP   61s

NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/nginx-status   1/1     1            1           61s

NAME                                      DESIRED   CURRENT   READY   AGE
replicaset.apps/nginx-status-65d4c4dcbb   1         1         1       61s
```

- Пробросить порт сервиса Prometheus на локальную машину:

```bash
ubuntu@k3s1 ~> kubectl -n monitoring port-forward --address 0.0.0.0 service/kube-prometheus-prometheus 9090:9090
Forwarding from 0.0.0.0:9090 -> 9090
Handling connection for 9090
```

- Зайти адресу http://192.168.1.228:9090 и убедиться, что метрики nginx присутствуют. Пример:

```bash
nginx_connections_accepted{container="nginx-prometheus-exporter", endpoint="metrics", instance="10.42.0.13:9113", job="nginx-status", namespace="default", pod="nginx-status-65d4c4dcbb-qzggd", service="nginx-status"}
103
```

## ДЗ № 9. kubernetes-logging

- [x] Задание

## В процессе сделано

1. Развернул Managed Kubernetes кластер в Yandex cloud с помощью terraform. В кластере два пула нод: worker и infra (taint "node-role=infra:NoSchedule")
1. Развернул S3 бакет (+ сервисаня учетка с правами storage.editor) в Yandex cloud с помощью terraform
1. Установил в k8s с помощью helm-чарта Loki
1. Установил в k8s с помощью helm-чарта Promtail
1. Установил в k8s с помощью helm-чарта Grafana
1. Настроил в Grafana data source к Loki

## Как запустить проект

- Иницализировать terraform и применить конфигурацию:

```bash
ubuntu@k3s1 ~> terraform init
ubuntu@k3s1 ~> terraform apply
```

- Добавить репозиторий с helm-чартами grafana: :

```bash
ubuntu@k3s1 ~> helm repo add grafana https://grafana.github.io/helm-charts
"grafana" has been added to your repositories
```

- Установить Loki:

```bash
ubuntu@k3s1 ~> helm upgrade --values helm/loki_values.yaml --install loki --namespace=loki grafana/loki --create-namespace --version 5.47.0

Release "loki" does not exist. Installing it now.
NAME: loki
LAST DEPLOYED: Sun May  5 12:18:58 2024
NAMESPACE: loki
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
 Welcome to Grafana Loki
 Chart version: 5.47.0
 Loki version: 2.9.6
***********************************************************************

Installed components:
* loki
```

- Установить Promtail:

```bash
ubuntu@k3s1 ~> helm upgrade --values helm/promtail_values.yaml --install promtail --namespace=loki grafana/promtail

Release "promtail" does not exist. Installing it now.
NAME: promtail
LAST DEPLOYED: Sun May  5 12:26:17 2024
NAMESPACE: loki
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
***********************************************************************
 Welcome to Grafana Promtail
 Chart version: 6.15.5
 Promtail version: 2.9.3
***********************************************************************

Verify the application is working by running these commands:
* kubectl --namespace loki port-forward daemonset/promtail 3101
* curl http://127.0.0.1:3101/metrics
```

- Установить Grafana:

```bash
ubuntu@k3s1 ~> helm upgrade --values helm/grafana_/_values.yaml --install grafana --namespace=loki grafana/grafana

Release "grafana" does not exist. Installing it now.
NAME: grafana
LAST DEPLOYED: Sun May  5 12:27:21 2024
NAMESPACE: loki
STATUS: deployed
REVISION: 1
...
```

- Получить пароль админа для Grafana:

```bash
ubuntu@k3s1 ~> kubectl get secret --namespace loki grafana -o jsonpath="{.data.admin-password}"| base64 --decode
```

- Пробросить порты для Grafana:

```bash
ubuntu@k3s1 ~> kubectl port-forward --namespace loki deployments/grafana 3000:3000
```

- Сконфигурировать Data source для Loki:

```bash
http://loki:3100
```

## Как проверить работоспособность

- Проверка taints:

```bash
ubuntu@k3s1 ~> kubectl get node -o wide --show-labels
NAME                        STATUS   ROLES    AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION      CONTAINER-RUNTIME     LABELS
cl1kg1gambf557pu7ccf-ilok   Ready    <none>   6m55s   v1.28.2   10.5.0.30     <none>        Ubuntu 20.04.6 LTS   5.4.0-174-generic   containerd://1.6.28   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,environment=dev,failure-domain.beta.kubernetes.io/zone=ru-central1-a,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1kg1gambf557pu7ccf-ilok,kubernetes.io/os=linux,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,role=worker-01,topology.kubernetes.io/zone=ru-central1-a,yandex.cloud/node-group-id=cat1mocujpo6acesrc4p,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false
cl1tiouo1fpermevv1i4-ymil   Ready    <none>   6m45s   v1.28.2   10.5.0.20     <none>        Ubuntu 20.04.6 LTS   5.4.0-174-generic   containerd://1.6.28   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/instance-type=standard-v3,beta.kubernetes.io/os=linux,environment=infra,failure-domain.beta.kubernetes.io/zone=ru-central1-a,kubernetes.io/arch=amd64,kubernetes.io/hostname=cl1tiouo1fpermevv1i4-ymil,kubernetes.io/os=linux,node.kubernetes.io/instance-type=standard-v3,node.kubernetes.io/kube-proxy-ds-ready=true,node.kubernetes.io/masq-agent-ds-ready=true,node.kubernetes.io/node-problem-detector-ds-ready=true,role=infra-01,topology.kubernetes.io/zone=ru-central1-a,yandex.cloud/node-group-id=catkapm5tjsjnid9v3o0,yandex.cloud/pci-topology=k8s,yandex.cloud/preemptible=false

ubuntu@k3s1 ~> kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
NAME                        TAINTS
cl1kg1gambf557pu7ccf-ilok   <none>
cl1tiouo1fpermevv1i4-ymil   [map[effect:NoSchedule key:node-role value:infra]]
```

- Cмотри скриншоты в папке screenshots

## ДЗ № 10. kubernetes-gitops

- [x] Задание

## В процессе сделано

1. Развернул Managed Kubernetes кластер в Yandex cloud с помощью terraform. В кластере два пула нод: worker и infra (taint "node-role=infra:NoSchedule")
1. Развернул Argo CD в namespace argocd с помощью helm-чарта
1. Примененил манифест для AppProject: имя проекта - otus, источник - репозиторий с ДЗ курса
1. Примененил манифест для Application: имя приложения - kubernetes-networks, namespace - homework1
1. Примененил манифест для Application: имя приложения - kubernetes-templating, namespace - homework2

## Как запустить проект

- Иницализировать terraform и применить конфигурацию:

```bash
ubuntu@k3s1 ~> terraform init
ubuntu@k3s1 ~> terraform apply
```

- Инициализировать kubeconfig:

```bash
ubuntu@k3s1 ~> yc managed-kubernetes cluster get-credentials <k8s_cluster_id> --external
```

- Добавить репозиторий с helm-чартами Argo CD:

```bash
ubuntu@k3s1 ~> helm repo add argo https://argoproj.github.io/argo-helm
"argo" has been added to your repositories
```

- Установить Argo CD:

```bash
ubuntu@k3s1 ~> helm upgrade --install argocd argo/argo-cd -f argocd-values.yaml -n argocd --create-namespace

Release "argocd" does not exist. Installing it now.
NAME: argocd
LAST DEPLOYED: Mon May  6 08:22:35 2024
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
TEST SUITE: None
...
```

- Получить пароль админа для Argo CD:

```bash
ubuntu@k3s1 ~> kubectl get secret --namespace argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

- Пробросить порты для Argo CD:

```bash
ubuntu@k3s1 ~> kubectl port-forward --namespace argocd --address 0.0.0.0 service/argocd-server 8080:80
```

- Примененить манифест для AppProject:

```bash
ubuntu@k3s1 ~> kubectl apply -f app-project.yaml
appproject.argoproj.io/otus created
```

- Примененить манифест для Application kubernetes-networks:

```bash
ubuntu@k3s1 ~> kubectl apply -f app-kubernetes-networks.yaml
application.argoproj.io/kubernetes-networks created
```

- Запустить синхронизацию приложения kubernetes-networks:

```bash
ubuntu@k3s1 ~> argocd app sync kubernetes-networks
```

- Примененить манифест для Application kubernetes-templating:

```bash
ubuntu@k3s1 ~> kubectl apply -f app-kubernetes-templating.yaml
application.argoproj.io/kubernetes-templating created
```

## Как проверить работоспособность

- Ресурсы успешно установлены в соответствующие namespace:

```bash
ubuntu@k3s1 ~> kubectl --namespace homework1 get all
ubuntu@k3s1 ~> kubectl --namespace homework2 get all
```

## ДЗ № 11. kubernetes-vault

- [x] Задание

## В процессе сделано

1. Развернул Managed Kubernetes кластер в Yandex cloud с помощью terraform. В кластере один пул нод infra, с количеством узлов в пуле - 3
1. Развернул Consul в namespace consul с помощью helm-чарта
1. Развернул Vault в namespace vault с помощью helm-чарта

1. Примененил манифест для AppProject: имя проекта - otus, источник - репозиторий с ДЗ курса
1. Примененил манифест для Application: имя приложения - kubernetes-networks, namespace - homework1
1. Примененил манифест для Application: имя приложения - kubernetes-templating, namespace - homework2

## Как запустить проект

- Иницализировать terraform и применить конфигурацию:

```bash
ubuntu@k3s1 ~> terraform init
ubuntu@k3s1 ~> terraform apply
```

- Инициализировать kubeconfig:

```bash
ubuntu@k3s1 ~> yc managed-kubernetes cluster get-credentials <k8s_cluster_id> --external
```

- Склонировать репозиторий с helm-чартами Consul:

```bash
ubuntu@k3s1 ~> git clone git@github.com:hashicorp/consul-k8s.git
Cloning into 'consul-k8s'...
remote: Enumerating objects: 58926, done.
remote: Counting objects: 100% (542/542), done.
remote: Compressing objects: 100% (309/309), done.
remote: Total 58926 (delta 315), reused 368 (delta 226), pack-reused 58384
Receiving objects: 100% (58926/58926), 91.99 MiB | 7.80 MiB/s, done.
Resolving deltas: 100% (41329/41329), done.
Updating files: 100% (1620/1620), done.
```

- Установить Consul:

```bash
ubuntu@k3s1 ~> helm upgrade --install consul consul-k8s/charts/consul/ --set global.name=consul --create-namespace -n consul -f values-consul.yaml

Release "consul" does not exist. Installing it now.
NAME: consul
LAST DEPLOYED: Fri May 10 08:37:04 2024
NAMESPACE: consul
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Consul!

Your release is named consul.
...
```

- Склонировать репозиторий с helm-чартами Vault:

```bash
ubuntu@k3s1 ~> git clone git@github.com:hashicorp/vault-helm.git
Cloning into 'vault-helm'...
remote: Enumerating objects: 4617, done.
remote: Counting objects: 100% (1926/1926), done.
remote: Compressing objects: 100% (497/497), done.
remote: Total 4617 (delta 1680), reused 1561 (delta 1412), pack-reused 2691
Receiving objects: 100% (4617/4617), 1.23 MiB | 4.28 MiB/s, done.
Resolving deltas: 100% (3482/3482), done.
```

- Установить Vault:

```bash
ubuntu@k3s1 ~> helm install vault vault-helm/ --create-namespace -n vault -f values-vault.yaml

NAME: vault
LAST DEPLOYED: Fri May 10 08:40:08 2024
NAMESPACE: vault
STATUS: deployed
REVISION: 1
NOTES:
Thank you for installing HashiCorp Vault!
...
```

- Выполнить инициализацию Vault:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault operator init

Unseal Key 1: removed
Unseal Key 2: removed
Unseal Key 3: removed
Unseal Key 4: removed
Unseal Key 5: removed

Initial Root Token: removed

Vault initialized with 5 key shares and a key threshold of 3.
...
```

- Распечатать все поды хранилища:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-{0,1,2} -- vault operator unseal <Unseal Key 1/2/3>
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
Version         1.16.1
Build Date      2024-04-03T12:35:53Z
Storage Type    consul
Cluster Name    vault-cluster-9729576c
Cluster ID      29e1e5a3-cb04-0938-2a95-ba057fbf8f7e
HA Enabled      true
HA Cluster      https://vault-0.vault-internal:8201
HA Mode         active
Active Since    2024-05-10T06:37:11.171518148Z

...
```

- Авторизоваться в Vault полученным при инициализации токеном:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault login removed
Success! You are now authenticated. The token information displayed below
is already stored in the token helper. You do NOT need to run "vault login"
again. Future Vault requests will automatically use this token.

Key                  Value
---                  -----
token                removed
token_accessor       HEZZnGYX2YlSYdWJdcLWANyA
token_duration       ∞
token_renewable      false
token_policies       ["root"]
identity_policies    []
policies             ["root"]

```

- Создать хранилище секретов otus:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault secrets enable -version=2 -path=otus kv
Success! Enabled the kv secrets engine at: otus/
```

- Создать секрет otus/cred:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault kv put otus/cred username='otus' password='asajkjkahs'
= Secret Path =
otus/data/cred

======= Metadata =======
Key                Value
---                -----
created_time       2024-05-10T06:42:49.234851055Z
custom_metadata    <nil>
deletion_time      n/a
destroyed          false
version            1
```

- Создать сервисный аккаунт:

```bash
ubuntu@k3s1 ~> kubectl apply -f ServiceAccount.yaml
serviceaccount/vault-auth created
```

- Создать секрет:

```bash
ubuntu@k3s1 ~> kubectl apply -f Secret.yaml
secret/vault-auth-token created
```

- Создать ClusterRoleBinding:

```bash
ubuntu@k3s1 ~> kubectl apply -f ClusterRoleBinding.yaml
clusterrolebinding.rbac.authorization.k8s.io/vault-auth-binding created
```

- В Vault включить авторизацию auth/kubernetes:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault auth enable kubernetes
Success! Enabled kubernetes auth method at: kubernetes/
```

- Сконфигурировать авторизацию kubernetes на использование токена для ранее созданного аккаунта:

```bash
ubuntu@k3s1 ~> TOKEN_REVIEW_JWT=$(kubectl --kubeconfig /home/ubuntu/.kube/config -n vault get secret vault-auth-token -o go-template='{{ .data.token }}' | base64 --decode)
ubuntu@k3s1 ~> KUBE_CA_CERT=$(kubectl --kubeconfig /home/ubuntu/.kube/config config view --raw --minify --flatten -o jsonpath='{.clusters[].cluster.certificate-authority-data}' | base64 --decode)
ubuntu@k3s1 ~> KUBE_HOST=$(kubectl --kubeconfig /home/ubuntu/.kube/config config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')

ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault write auth/kubernetes/config token_reviewer_jwt="$TOKEN_REVIEW_JWT" kubernetes_host="$KUBE_HOST" kubernetes_ca_cert="$KUBE_CA_CERT" disable_local_ca_jwt="true"

Success! Data written to: auth/kubernetes/config
```

- Создать политику otus-policy для секрета otus/cred:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault policy write otus-policy - <<EOF
path "otus/data/cred" {
    capabilities = ["read", "list"]
}
EOF
Success! Uploaded policy: otus-policy
```

- В Vault создать роль auth/kubernetes/role/otus:

```bash
ubuntu@k3s1 ~> kubectl -n vault exec -it vault-0 -- vault write auth/kubernetes/role/otus bound_service_account_names=vault-auth bound_service_account_namespaces=vault policies=otus-policy ttl=24h
Success! Data written to: auth/kubernetes/role/otus
```

- Добавить репозиторий external-secrets:

```bash
ubuntu@k3s1 ~> helm repo add external-secrets https://charts.external-secrets.io
"external-secrets" has been added to your repositories
```

- Установить helm чарт с external-secrets:

```bash
ubuntu@k3s1 ~> helm upgrade --install external-secrets external-secrets/external-secrets --create-namespace -n vault
Release "external-secrets" does not exist. Installing it now.
NAME: external-secrets
LAST DEPLOYED: Fri May 10 10:14:53 2024
NAMESPACE: vault
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
external-secrets has been deployed successfully in namespace vault!
...
```

- Создать SecretStore и Секрет:

```bash
ubuntu@k3s1 ~> kubectl apply -f SecretStore.yaml
secretstore.external-secrets.io/otus-secret-store created

ubuntu@k3s1 ~> kubectl apply -f ExternalSecret.yaml
externalsecret.external-secrets.io/otus-external-secret created
```

## Как проверить работоспособность

- Ресурсы успешно установлены в соответствующие namespace:

```bash
ubuntu@k3s1 ~> kubectl --namespace consul get po
NAME                                          READY   STATUS    RESTARTS   AGE
consul-connect-injector-5fc7b8b649-dn27w      1/1     Running   0          99s
consul-server-0                               1/1     Running   0          99s
consul-server-1                               1/1     Running   0          99s
consul-server-2                               1/1     Running   0          98s
consul-webhook-cert-manager-6b864dff9-298ls   1/1     Running   0          99s

ubuntu@k3s1 ~> kubectl --namespace vault get po
NAME                                   READY   STATUS    RESTARTS   AGE
vault-0                                1/1     Running   0          3m5s
vault-1                                1/1     Running   0          3m5s
vault-2                                1/1     Running   0          3m5s
vault-agent-injector-95c7b5566-lgg9r   1/1     Running   0          3m5s
```

- Секрет успешно создан:

```bash
ubuntu@k3s1 ~> kubectl --namespace vault get secret otus-cred
NAME        TYPE     DATA   AGE
otus-cred   Opaque   2      38s

```

- Данные внутри секрета соответствуют заданию:

```bash
ubuntu@k3s1 ~> kubectl --namespace vault get secret otus-cred -o json | jq -r '.data'
{
  "password": "YXNhamtqa2Focw==",
  "username": "b3R1cw=="
}

ubuntu@k3s1 ~> kubectl --namespace vault get secret otus-cred -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}'
password: asajkjkahs
username: otus
```
