#!/bin/sh

eval($minikube -p polar docker-env)

echo "\n📦 Initializing Kubernetes cluster...\n"

minikube start --cpus 2 --memory 4g --driver docker --profile polar

echo "\n🔌 Enabling NGINX Ingress Controller...\n"

minikube addons enable ingress --profile polar

sleep 15

echo "\n📦 Deploying platform services...\n"
kubectl apply -f services

sleep 5

echo "\n⌛ Waiting for PostgreSQL to be deployed...\n"

while [ $(kubectl get pod -l db=polar-postgres | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for PostgreSQL to be ready...\n"

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-postgres \
  --timeout=180s

echo "\n⌛ Waiting for Redis to be deployed...\n"

while [ $(kubectl get pod -l db=polar-redis | wc -l) -eq 0 ] ; do
  sleep 5
done

echo "\n⌛ Waiting for Redis to be ready...\n"

kubectl wait \
  --for=condition=ready pod \
  --selector=db=polar-redis \
  --timeout=180s

echo "\n⛵ Happy Sailing!\n"
