# devops-javafullstack-final-project

# 📘 Twitter-App — Spring Boot + Kubernetes + GitOps

## 📌 Project Overview  
*Twitter-App* is a full-stack backend application built using *Spring Boot*, designed to simulate core features of a microblogging platform. The project is engineered with production-grade DevOps practices, including:

- *Kubernetes Deployment*
- *GitOps with ArgoCD*
- *Prometheus & Grafana Monitoring*
- *MySQL & H2 Database Support*
- *Layered Docker Image Build*
- *Modular Kustomize Environments*

The project demonstrates a complete DevOps + backend engineering lifecycle, suitable for real-world cloud-native applications.

---

## 🛠 Tech Stack  
### *Backend*
- *Spring Boot 3.3.2*
  - Web
  - Data JPA
  - Security
  - Thymeleaf
  - Actuator
- *Java 17*
- *Maven*

### *Databases*
- *MySQL 8* (Production)
- *H2* (Development / Testing)

### *DevOps & Cloud*
- *Docker*
- *Kubernetes (K8s)*
- *Kustomize*
- *ArgoCD (GitOps)*
- *Prometheus*
- *Grafana*

### *Monitoring & Metrics*
- Micrometer  
- Spring Boot Actuator Prometheus endpoint  

### *Testing*
- JUnit 5  
- Mockito  
- Spring Security Test  
- Spring Boot Starter Test  

---

## 🏛 Architecture  

├── Spring Boot Application
│   ├── MVC architecture (Controllers, Services, Repositories)
│   ├── JPA ORM with MySQL/H2
│   ├── Security (Spring Security)
│   ├── Thymeleaf templating engine
│   └── Actuator metrics for monitoring
│
└── Kubernetes Infrastructure
    ├── Namespaces (monitoring, db, twitter-app)
    ├── MySQL Stateful Deployment
    ├── App Deployment (2 replicas)
    ├── Services + PVC storage
    ├── Prometheus & Grafana Monitoring Stack
    └── ArgoCD GitOps for automatic sync


---

## ✨ Features  
- 🔐 *User Authentication* via Spring Security  
- 📝 *Tweet publishing & viewing*  
- 🗃 *Database abstraction* using Spring Data JPA  
- 📝 *Thymeleaf-based UI frontend*  
- 📊 *Real-time Prometheus metrics*  
- 🚀 *Kubernetes auto-deploy with ArgoCD*  
- 📦 *Layered Docker image for optimized build times*  
- 📁 *Environment Profiles* (dev, mysql, postgres)  
- 📈 *Full monitoring dashboard (Grafana + Prometheus)*  

---

## 🧪 Testing  
This project includes full test support using:

- spring-boot-starter-test
- spring-security-test
- *Unit Tests for Services*
- *MockMvc Controller Tests*
- *Repository Tests using H2*

Run tests with:


mvn test


---

## 📂 Folder Structure  

project/
│
├── pom.xml
├── src/
│
├── k8s/
│   ├── db/
│   ├── twitter-app/
│   ├── monitoring/
│   ├── namespaces/
│   ├── argocd/
│   └── kustomization.yaml
│
└── Dockerfile (image: rabiaadel/final-project)


---

## ▶ How to Run the Project  

### *⿡ Local Development (H2 Database)*

mvn spring-boot:run


---

### *⿢ Build the Application*

mvn clean package


---

### *⿣ Docker Build*

docker build -t twitter-app .


---

### *⿤ Run with Docker*

docker run -p 8080:8080 twitter-app


---

### *⿥ Deploy on Kubernetes*

kubectl apply -k k8s/


---

### *⿦ ArgoCD GitOps Deployment*  
Push to the GitHub repo and ArgoCD will auto-sync:

- k8s/twitter-app
- k8s/monitoring

---

## 🚀 Future Improvements  
- Add *Swagger* documentation  
- Add user profiles, likes, comments  
- Implement *Redis* caching  
- Introduce *OpenTelemetry* tracing  
- Add *CI/CD pipeline*  
- Implement integration tests using Testcontainers  
- Add ingress routing (NGINX, Traefik)  

---
