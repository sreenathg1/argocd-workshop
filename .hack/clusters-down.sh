#!/bin/bash
set -e

# Teardown the clusters
minikube delete -p argocd-cluster
minikube delete -p dev-cluster
minikube delete -p prod-cluster

