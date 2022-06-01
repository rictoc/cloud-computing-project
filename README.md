# Project for Cloud Computing course, a.a. 2021/2022
M.Sc in Computer Science, Sapienza University of Rome

The aim of our project will be the creation and deployment of a Deep Learning based web application. In particular we want to build an application based on the open-source, pretrained GAN (Generative Adversarial Network ) models presented in the 2021 paper [JoJoGAN: One Shot Face Stylization](https://arxiv.org/abs/2112.11641).

## Start the compose stack for development
```
docker compose -f docker-compose.dev.yaml up --build
```

## Roadmap 🛣

### Backend service
- [ ] Download models
- [ ] Convert models to .mar format
- [ ] Custom TorchServe handler
### Frontend service
- [x] File upload
- [x] Preview uploaded file
- [x] Implement call to prediction endpoint
- [x] Input history
### Deployment
- [x] Docker compose file
- [ ] Local testing
- [ ] Docker compose file for ECS
- [ ] Cloud formation integrations for network infrastructure
- [ ] Cloud test
### Testing
- [ ] Collect client side metrics
- [ ] Collect cloud side ECS metrics
- [ ] Calculate thresholds
- [ ] Final evaluation
### Report
- [ ] Write report
