# Prerequisites 

- There needs to be specific versions of kustomize, kubectl, and minikube in order for this to work so make sure that those 3 are completely uninstalled from your environment. The install.sh script will install the correct versions
- You also need to have another user since you can't run systemctl start docker as root. You can add another user with the following: 
``` 
adduser (username)
sudo usermod -aG sudo (username)
sudo usermod -aG docker (username) && newgrp docker
sudo passwd (username) #enter password for user here
su (username) 
- Re-Login or Restart the Server
```
- When trying to run Kubeflow, it may need a certain amount of resources or it won't work. This specifically worked for me ```minikube start --cpus 8 --memory 64000``` but it could work with less 

# Installation

- Run source install.sh (cpu size) (memory size)
- That's it 

# Useful commands 

- Check that everything is up and running or else Kubeflow won't work. You can do that with: 
```
kubectl get pods -n cert-manager
kubectl get pods -n istio-system
kubectl get pods -n auth
kubectl get pods -n knative-eventing
kubectl get pods -n knative-serving
kubectl get pods -n kubeflow
kubectl get pods -n kubeflow-user-example-com
```
- Once everything is up and running you can run ```kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80``` and go to http://localhost:8080

# Testing examples

Pipeline guide is in the notebook that's included named pipeline.ipynb 

Training files have already been included in here:

```
kubectl apply -f random.yaml for hyper parameter tuning
kubectl apply -f simple.yaml for model training
```

You can check and monitor these with:

```
kubectl -n kubeflow-user-example-com get experiment random -o yaml
kubectl -n kubeflow get tfjob tfjob-simple -o yaml 
```

To serve a model and make an API out of it you can run the following: 

``` 
kubectl create namespace kserve-test
kubectl apply -f sklearn.yaml -n kserve-test (sklearn.yaml has already been included) 
kubectl get inferenceservices sklearn-iris -n kserve-test
kubectl get svc istio-ingressgateway -n istio-system
```
```
# GKE
export INGRESS_HOST=worker-node-address
# Minikube
export INGRESS_HOST=$(minikube ip)
# Other environment(On Prem)
export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
```

iris-input.json has the request body to be sent in. Make sure to add your session cookie for authservice_session. You can find it through your cookies then copy and paste that into the placeholder 

```
#Example request
SERVICE_HOSTNAME=$(kubectl get inferenceservice sklearn-iris -n kserve-test -o jsonpath='{.status.url}' | cut -d "/" -f 3)
curl -v -L -H "Host: ${SERVICE_HOSTNAME}" -H "Cookie: authservice_session=add_authservice_session_cookie_value_from_browser" http://${INGRESS_HOST}:${INGRESS_PORT}/v1/models/sklearn-iris:predict -d @./iris-input.json
```

Result should look like 

```
*   Trying 10.152.183.241...
* TCP_NODELAY set
* Connected to 10.152.183.241 (10.152.183.241) port 80 (#0)
> POST /v1/models/sklearn-iris:predict HTTP/1.1
> Host: sklearn-iris.admin.example.com
> User-Agent: curl/7.58.0
> Accept: */*
> Cookie: authservice_session=MTU4OTI5NDAzMHxOd3dBTkVveldFUlRWa3hJUVVKV1NrZE1WVWhCVmxSS05GRTFSMGhaVmtWR1JrUlhSRXRRUmtnMVRrTkpUekpOTTBOSFNGcElXRkU9fLgsofp8amFkZv4N4gnFUGjCePgaZPAU20ylfr8J-63T
> Content-Length: 76
> Content-Type: application/x-www-form-urlencoded
> 
* upload completely sent off: 76 out of 76 bytes
< HTTP/1.1 200 OK
< content-length: 23
< content-type: text/html; charset=UTF-8
< date: Tue, 12 May 2020 14:38:50 GMT
< server: istio-envoy
< x-envoy-upstream-service-time: 7307
< 
* Connection #0 to host 10.152.183.241 left intact
{"predictions": [1, 1]}
```

# Useful Resources 

- https://qiita.com/maxtaq/items/81c6d08250b03ef02dfd
- https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
- https://minikube.sigs.k8s.io/docs/start/
- https://github.com/kubeflow/manifests#installation
- https://github.com/kserve/kserve/tree/master/docs/samples/istio-dex
- https://kserve.github.io/website/0.7/get_started/first_isvc/#run-your-first-inferenceservice
- https://kserve.github.io/website/0.9/get_started/first_isvc/#1-create-a-namespace
- https://v1-5-branch.kubeflow.org/docs/components/pipelines/
- https://v1-5-branch.kubeflow.org/docs/components/katib/overview/
- https://v1-5-branch.kubeflow.org/docs/components/training/
