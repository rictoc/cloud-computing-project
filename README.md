# Project for Cloud Computing course
M.Sc in Computer Science, Sapienza University of Rome, a.a. 2021/2022

The aim of our project is the creation and deployment on AWS of an age prediction deep learning based web application
using pre-trained models from [FairFace](https://github.com/dchen236/FairFace).

## Start the compose stack for development
```
docker compose up --build
```

## Roadmap 🛣

### Backend service
- [ ] Download models
- [x] Write  input alignment code
- [x] Write inference code
### Frontend service
- [x] File upload
- [x] Preview uploaded file
- [x] Implement call to prediction endpoint
- [x] Input history
- [ ] Tweak streamlit configuration for deployment
- [x] Send style information to backend
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
