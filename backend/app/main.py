from fastapi import FastAPI, UploadFile
from PIL import Image

app = FastAPI()

@app.get('/')
def ping():
    return "Pong!"

@app.post('/predict')
async def predict(file: UploadFile):
    image = Image.open(file.file)
    return {"image_size": image.size}
