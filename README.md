# Project for Cloud Computing course
M.Sc in Computer Science, Sapienza University of Rome, a.a. 2021/2022

The aim of our project will be the creation and deployment of a Deep Learning based web application. In particular we want to build an application based on the open-source, pretrained GAN (Generative Adversarial Network ) models presented in the 2021 paper [JoJoGAN: One Shot Face Stylization](https://arxiv.org/abs/2112.11641).

## Start the compose stack for development
```
docker compose up --build
```

## Roadmap 🛣

### Backend service
- [ ] Download models
- [ ] Write inference code
### Frontend service
- [x] File upload
- [x] Preview uploaded file
- [x] Implement call to prediction endpoint
- [x] Input history
- [ ] Tweak streamlit configuration for deployment
### Deployment
- #### Local
  - [x] Docker compose file for local development
- #### Network infrastructure
  - [x] VPC
  - [x] Subnets
  - [x] NAT Gateways
  - [x] Internet Gateway
- #### Load balancing
  - [x] External load balancer
  - [x] Internal load balancer
  - [x] Enable sticky session for frontend
- #### Services and autoscaling
  - [x] Launch configurations
  - [x] Autoscaling groups
  - [ ] Decide autoscaling policies
  - [ ] Investigate warmup and cooldown time 
  - [ ] Aggregate instances logging
### Testing
- [ ] Collect client side metrics
- [ ] Collect cloud side metrics
- [ ] Calculate best thresholds for autoscaling policies
- [ ] Final evaluation
### Report
- [ ] Write report
