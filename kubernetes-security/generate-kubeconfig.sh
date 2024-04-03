
SA_NAME=cd
CONTEXT=$(kubectl config current-context) #default
NAMESPACE=homework

NEW_CONTEXT=cd
KUBECONFIG_FILE="kubeconfig-cd"

SECRET_NAME=cd-token
TOKEN_DATA=$(kubectl get secret ${SECRET_NAME} --context ${CONTEXT} --namespace ${NAMESPACE} -o jsonpath='{.data.token}')
TOKEN=$(echo ${TOKEN_DATA} | base64 -d)

# Create dedicated kubeconfig
kubectl config view --flatten --minify > ${KUBECONFIG_FILE}
# Rename context
kubectl config --kubeconfig ${KUBECONFIG_FILE} rename-context ${CONTEXT} ${NEW_CONTEXT}
# Create token user
kubectl config --kubeconfig ${KUBECONFIG_FILE} set-credentials ${NEW_CONTEXT}-${NAMESPACE}-sa-token --token ${TOKEN}
# Set context to use token user
kubectl config --kubeconfig ${KUBECONFIG_FILE} set-context ${NEW_CONTEXT} --user ${NEW_CONTEXT}-${NAMESPACE}-sa-token
# Set context to correct namespace
kubectl config --kubeconfig ${KUBECONFIG_FILE} set-context ${NEW_CONTEXT} --namespace ${NAMESPACE}

