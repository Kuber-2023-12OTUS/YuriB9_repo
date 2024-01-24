# ДЗ № 1. kubernetes-intro

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
