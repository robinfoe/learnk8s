# x509 Client Certificate Token 

This guide run through the creation and implementation of x509 Client Certificate

## Pre-Req
 - A running kubernetes cluster
 - Tools such as openssl


## Steps

 - Generate KEY and CSR with the following command 

```bash
USER_NAME="tanzu-dev"
USER_GROUPS="/O=developer/O=appowner"

openssl genrsa -out $USER_NAME.key 2048

openssl req -new -key $USER_NAME.key -subj "/CN="$USER_NAME$USER_GROUPS -out $USER_NAME.csr

```

 - Inspect the generated CSR 
```bash
openssl req -text -noout -verify -in $USER_NAME.csr
## sample output
verify OK
Certificate Request:
    Data:
        Version: 0 (0x0)
        Subject: CN=tanzu-dev, O=developer, O=appowner ## this line represent Username, Group 1 , Group 2
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
               .....

```

- Convert Generated CSR to base64 and request kubernetes to sign approve the CSR 

```bash

export BASE64_CSR=$(cat ./$USER_NAME.csr | base64 | tr -d '\n')
export CSR_NAME=$USER_NAME

## Deploy to kubernetes cluster 
cat tanzu-csr.yaml | envsubst | kubectl apply -f -

```

- Verify, Review and Approve CSR 
```bash

## Verify 
> kubectl get csr 

NAME        AGE   SIGNERNAME                     REQUESTOR          CONDITION
tanzu-dev   21s   kubernetes.io/legacy-unknown   kubernetes-admin   Pending

## Approve
> kubectl certificate approve tanzu-dev
certificatesigningrequest.certificates.k8s.io/tanzu-dev approved

## Result 
> kubectl get csr 
NAME        AGE     SIGNERNAME                     REQUESTOR          CONDITION
tanzu-dev   2m22s   kubernetes.io/legacy-unknown   kubernetes-admin   Approved,Issued
```

 - Retrive approved Certificate  and Certificate Authority
```bash

## approved certificate
kubectl get csr $CSR_NAME -o jsonpath='{.status.certificate}' | base64 --decode > $CSR_NAME.crt


## get CA 
kubectl get configmap cluster-info  -n kube-public -o jsonpath='{.data.kubeconfig}' | \
    grep  'certificate-authority-data:' | awk '{split($0 ,a ,": "); print a[2]}' | base64 --decode >> $CSR_NAME-ca.crt
```
