import os
import random
from locust import LoadTestShape, HttpUser, task, between, events

@events.init.add_listener
def on_locust_init(environment, **kwargs):
    environment.test_images = [f"test-images/{path}" for path in os.listdir("test-images") \
                                if not path.startswith(".")]

class BackendUser(HttpUser):

    wait_time = between(30, 60)

    @task
    def get_prediction(self):
        n_test_images = len(self.environment.test_images)
        image_path = self.environment.test_images[random.randint(0, n_test_images - 1)]
        files = [('file', (image_path, open(image_path, 'rb'), 'image/jpeg'))]
        self.client.post("/predict", files=files, timeout=120)

class WebUser(HttpUser):

    wait_time = between(15, 30)

    @task
    def get_home(self):
        self.client.get("/")

class StagesShape(LoadTestShape):
    """Generate load in 4 steps:
    Warm up - Ramp up - Steady - Ramp down
    """

    time_limit = 3000 # *2000
    min_users = 1000 # 5000 - 2500 - *1000
    peak_users = 4000 # 50000 - 10000 - *4000

    warmup_spawn_rate = min_users // (time_limit*0.25)
    ramp_spawn_rate = peak_users // (time_limit*0.25)

    stages = [
        {"duration": time_limit*0.25, "users": min_users, "spawn_rate": warmup_spawn_rate},
        {"duration": time_limit*0.5, "users": peak_users, "spawn_rate": ramp_spawn_rate},
        {"duration": time_limit*0.75, "users": peak_users, "spawn_rate": 1},
        {"duration": time_limit*1.0, "users": min_users, "spawn_rate": ramp_spawn_rate},
    ]

    def tick(self):
        run_time = self.get_run_time()

        for stage in self.stages:

            if run_time < stage["duration"]:
                tick_data = (stage["users"], stage["spawn_rate"])
                return tick_data

        return None