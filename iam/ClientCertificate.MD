

//  Gen key
openssl genrsa -out tanzu.key 2048 


// Gen csr
openssl req -new -key tanzu.key -subj "/CN=tanzu" -out tanzu.csr



export BASE64_CSR=$(cat ./tanzu.csr | base64 | tr -d '\n')


cat tanzu-csr.yaml | envsubst | kubectl apply -f -



cat tanzu-csr.yaml | envsubst


kubectl certificate approve tanzu



kc get csr tanzu -o jsonpath='{.status.certificate}' | base64 --decode > tanzu.crt



// inspect
openssl x509 -in ./tanzu.crt -noout -text
