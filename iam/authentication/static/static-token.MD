# Static Token 

This guide run through the creation and implementation of static token in kubernetes 

The token should be arranged in the following format

```bash
<token>,<username>,<userid>,"<group1>,<group2>,<group3>"
```

## Pre-Req
 - A running kubernetes cluster 

## Steps

 - Create static token as the above format 
   ```bash
    ## you can create the token with the following command 
    > openssl rand -base64 32
    sample output :: C5qXAbzLb3/kz5KnzSvEALtsIpXQ8q8R/XOYKCSCd2Q=

    ## token can be generated with the following command 
    TOKEN=$(openssl rand -base64 32)
    USER_NAME="tanzu"
    USER_ID=00001
    USER_GROUPS="system:masters"

    echo $TOKEN,$USER_NAME,$USER_ID,'"'$USER_GROUPS'"' >> tanzu-token.csv

    #or
    
    TOKEN=$(openssl rand -base64 32)
    USER_NAME="tanzu-dev"
    USER_ID=00002
    USER_GROUPS="dev:dayone,dev:daytwo"

    echo $TOKEN,$USER_NAME,$USER_ID,'"'$USER_GROUPS'"' >> tanzu-token.csv 

   ```
  
 - Head to master node and amend static pod definition to include the following
   ```yml
    ## file located at /etc/kubernetes/manifests/kube-apiserver.yaml
    kind: Pod
    apiVersion: v1
    metadata:
      name: kube-apiserver-learnk8s-control-plane
      namespace: kube-system
     ......
    spec:
      volumes:
        ....
        ## add usr-security volumes to host tanzu-token.csv
        - name: usr-security 
          hostPath:
            path: /usr/share/security
            type: DirectoryOrCreate
      containers:
        - name: kube-apiserver
          image: 'k8s.gcr.io/kube-apiserver:v1.19.1'
          command:
            - kube-apiserver
          .....
            ## add flag for server to read the file upon startup
            - '--token-auth-file=/usr/share/security/tanzu-token.csv'
          volumeMounts:
          .....
            ## add usr-security volumes to host tanzu-token.csv
            - name: usr-security
              readOnly: true
              mountPath: /usr/share/security ## tanzu-token.csv should be availabe in this host path
         ......
   ```
