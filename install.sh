curl -LO https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

wget https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64
chmod +x kustomize_3.2.0_linux_amd64
sudo mv kustomize_3.2.0_linux_amd64 /usr/local/bin/kustomize

curl -LO https://storage.googleapis.com/minikube/releases/v1.22.0/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
chmod +x minikube-linux-amd64
sudo mv minikube-linux-amd64 /usr/local/bin/minikube

git clone https://github.com/kubeflow/manifests.git
cd manifests

systemctl start docker

minikube start --cpus $1 --memory $2

while ! kustomize build example | kubectl apply -f -; do echo "Retrying to apply resources"; sleep 10; done

kustomize build common/user-namespace/base | kubectl apply -f -

kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com

# run kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80 to start kubeflow

# useful commands
# 1. kubectl apply -f random.yaml for hyper parameter tuning
# 2. kubectl create -f https://raw.githubusercontent.com/kubeflow/training-operator/master/examples/tensorflow/simple.yaml for model training 

# 1a. to monitor it kubectl -n kubeflow-user-example-com get experiment random -o yaml
# 2a. to monitor it kubectl -n kubeflow get tfjob tfjob-simple -o yaml


