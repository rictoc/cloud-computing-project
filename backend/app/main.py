from fastapi import FastAPI, UploadFile, Response
from io import BytesIO
from PIL import Image, ImageOps

app = FastAPI()


@app.get('/')
def ping():
    return "Pong!"


@app.post('/predict')
async def predict(file: UploadFile):

    # load image
    image = Image.open(file.file)

    # do some manipulations
    image = ImageOps.grayscale(image)

    # save image to in-memory file object
    output = BytesIO()
    image.save(output, 'png')

    return Response(output.getvalue(), media_type='image/png')
