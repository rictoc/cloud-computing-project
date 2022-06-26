import os
import random
from locust import HttpUser, task, between, events  

@events.init.add_listener
def on_locust_init(environment, **kwargs):
    environment.test_images = [f"test-images/{path}" for path in os.listdir("test-images") \
                                if not path.startswith(".")]

class BackendUser(HttpUser):
    wait_time = between(1, 5)

    @task
    def get_prediction(self):
        n_test_images = len(self.environment.test_images)
        image_path = self.environment.test_images[random.randint(0, n_test_images - 1)]
        files = [('file', (image_path, open(image_path, 'rb'), 'image/jpeg'))]
        self.client.post("/predict", files=files, timeout=60.0)

class FrontendUser(HttpUser):
    
    @task
    def get_home(self):
        self.client.get("/")

    def upload_image(self):
        pass
