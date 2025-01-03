# selfhostedagents
in az cli

# Azure Container Registry erstellen

Wenn Docker lokal nicht installiert werden kann, kannst du dennoch eine Azure Container Registry (ACR) nutzen, indem du das Docker-Image in der Cloud erstellst. Dafür gibt es folgende Ansätze:

Azure Container Registry Build-Service
Du kannst ACR nutzen, um Images direkt in der Cloud zu bauen.

Hier ist eine detaillierte Anleitung:
'''
bash
Code kopieren
az acr create \
  --resource-group myResourceGroup \
  --name myACRRegistry \
  --sku Basic
'''

Hole den Login-Server der Registry:

'''bash
Code kopieren
az acr show --name myACRRegistry --query "loginServer" --output tsv
'''
Notiere den Login-Server, z. B. myacrregistry.azurecr.io.

2. Docker-Image mit ACR Tasks bauen
Mit ACR kannst du ein Docker-Image direkt aus einer GitHub-Repository oder lokalen Dateien erstellen.

Quellcode vorbereiten
Erstelle lokal einen Ordner azure-devops-agent mit den Dateien Dockerfile und start.sh (siehe oben in der Anleitung).

Dateien in eine ZIP-Datei packen
Packe alle benötigten Dateien in eine ZIP-Datei (z. B. azure-devops-agent.zip).

ZIP-Datei hochladen
Lade die Datei in einen Azure Storage Account oder nutze GitHub.

ACR Task erstellen
Erstelle den Build direkt in ACR:

bash
Code kopieren
az acr build \
  --registry myACRRegistry \
  --image azure-devops-agent:latest \
  --file Dockerfile .

Hier ist eine detaillierte Anleitung, wie du ein Azure Kubernetes Service (AKS)-Cluster erstellst und das Docker-Image aus deiner Azure Container Registry (ACR) im Kubernetes-Cluster nutzt.

1. Azure Kubernetes Cluster erstellen
1.1 Erstelle eine Ressourcengruppe
Falls noch keine Ressourcengruppe existiert:

bash
Code kopieren
az group create --name myResourceGroup --location northeurope
1.2 Erstelle das AKS-Cluster
Erstelle das AKS-Cluster mit aktivierter Autoskalierung:

bash
Code kopieren
az aks create \
  --resource-group myResourceGroup \
  --name myAKSCluster \
  --node-count 1 \
  --enable-cluster-autoscaler \
  --min-count 1 \
  --max-count 5 \
  --enable-addons monitoring \
  --generate-ssh-keys
Hole die Kubernetes-Konfigurationsdatei, um mit dem Cluster zu arbeiten:

bash
Code kopieren
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
Hinweis: Nach diesem Schritt kannst du mit kubectl auf das Cluster zugreifen.

2. ACR mit dem AKS-Cluster verbinden
2.1 AKS und ACR verknüpfen
Ermögliche dem AKS-Cluster Zugriff auf die ACR:

bash
Code kopieren
az aks update \
  --name myAKSCluster \
  --resource-group myResourceGroup \
  --attach-acr myACRRegistry
2.2 Zugriff überprüfen
Überprüfe, ob die Verknüpfung erfolgreich war:

bash
Code kopieren
az aks show --name myAKSCluster --resource-group myResourceGroup --query "servicePrincipalProfile"
3. Deployment für Kubernetes vorbereiten
3.1 Erstelle ein Namespace
Organisiere die Ressourcen in einem Namespace:

bash
Code kopieren
kubectl create namespace azure-devops-agents
3.2 Deployment-Datei erstellen
Erstelle eine YAML-Datei azure-devops-agent-deployment.yaml mit folgendem Inhalt:

yaml
Code kopieren
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-devops-agent
  namespace: azure-devops-agents
spec:
  replicas: 2  # Anzahl der Agenten-Pods
  selector:
    matchLabels:
      app: azure-devops-agent
  template:
    metadata:
      labels:
        app: azure-devops-agent
    spec:
      containers:
      - name: azure-devops-agent
        image: myacrregistry.azurecr.io/azure-devops-agent:latest
        env:
        - name: AZP_URL
          value: "https://dev.azure.com/<Organization>"
        - name: AZP_TOKEN
          value: "<PersonalAccessToken>"
        - name: AZP_POOL
          value: "Kubernetes-Pool"
        resources:
          limits:
            cpu: "2"
            memory: "4Gi"
          requests:
            cpu: "1"
            memory: "2Gi"
Ersetze:

myacrregistry.azurecr.io mit deinem ACR-Login-Server.
<Organization> mit deiner Azure DevOps Organisation.
<PersonalAccessToken> mit deinem PAT.
4. Deployment in Kubernetes anwenden
4.1 Deployment anwenden
Deploye die Datei in Kubernetes:

bash
Code kopieren
kubectl apply -f azure-devops-agent-deployment.yaml
4.2 Deployment überprüfen
Überprüfe den Status des Deployments:

bash
Code kopieren
kubectl get pods -n azure-devops-agents
Zeige die Logs eines Pods an, um zu prüfen, ob der Agent erfolgreich gestartet wurde:

bash
Code kopieren
kubectl logs <pod-name> -n azure-devops-agents
5. Optional: Horizontal Pod Autoscaler (HPA) einrichten
Um die Anzahl der Pods dynamisch zu skalieren, basierend auf der CPU-Last:

bash
Code kopieren
kubectl autoscale deployment azure-devops-agent \
  --cpu-percent=70 \
  --min=1 \
  --max=10 \
  -n azure-devops-agents
Prüfe den Status des Autoscalers:

bash
Code kopieren
kubectl get hpa -n azure-devops-agents
6. Monitoring und Logs
6.1 Ressourcenverbrauch anzeigen
Verwende kubectl top, um den Ressourcenverbrauch der Pods und Nodes zu prüfen:

bash
Code kopieren
kubectl top pods -n azure-devops-agents
kubectl top nodes
6.2 Logs sammeln
Falls du Azure Monitor aktiviert hast, kannst du Logs über das Azure-Portal oder CLI sammeln.

Zusammenfassung
Diese Schritte erstellen:

Ein AKS-Cluster mit Zugriff auf eine ACR.
Ein Deployment, das das Docker-Image für Azure DevOps Agents nutzt.
Optional: Automatische Skalierung basierend auf der Last.
Soll ich bei weiteren Optimierungen oder Terraform-Automatisierungen helfen?
