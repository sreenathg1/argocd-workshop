#!/bin/bash


# Teardown the clusters
minikube delete -p argocd-cluster
minikube delete -p dev-cluster
minikube delete -p prod-cluster

