from __future__ import division, print_function

import dlib
import numpy as np
import torch
import torch.nn as nn
import torchvision
import warnings
from fastapi import FastAPI, UploadFile
from fastapi.responses import JSONResponse, Response
from PIL import Image
from torchvision import transforms

dlib.DLIB_USE_CUDA = False
warnings.filterwarnings("ignore")

app = FastAPI()

app.device = torch.device("cpu")
app.id2age = {
    0: '0-2',
    1: '3-9',
    2: '10-19',
    3: '20-29',
    4: '30-39',
    5: '40-49',
    6: '50-59',
    7: '60-69',
    8: '70+'
}

class FaceNotFoundException(Exception):
    pass

@app.on_event("startup")
def init_models():

    app.cnn_face_detector = dlib.cnn_face_detection_model_v1('models/mmod_human_face_detector.dat')
    app.shape_predictor = dlib.shape_predictor('models/shape_predictor_5_face_landmarks.dat')
    app.model_fair = torchvision.models.resnet34(pretrained=True, progress=False)
    app.model_fair.fc = nn.Linear(app.model_fair.fc.in_features, 18)
    app.model_fair.load_state_dict(torch.load('models/res34_fair_align_multi_7_20190809.pt', map_location=app.device))
    app.model_fair = app.model_fair.to(app.device)
    app.model_fair.eval()


@app.get('/')
def ping():
    return "ok"


@app.post('/predict')
def predict(file: UploadFile):

    # load image
    image = Image.open(file.file)
    np_image = np.array(image)
    try:
        face = detect_face(np_image)
        age = predict_age(face)
        return JSONResponse(content={"age": age}, status_code=200)
    except FaceNotFoundException:
        return Response(content="No face detected!", status_code=422)


def detect_face(image: np.array, default_max_size: int = 800, size: int = 300, padding: float = 0.25) -> np.array:

    old_height, old_width, _ = image.shape

    if old_width > old_height:
        new_width, new_height = default_max_size, int(default_max_size * old_height / old_width)
    else:
        new_width, new_height =  int(default_max_size * old_width / old_height), default_max_size
    image = dlib.resize_image(image, rows=new_height, cols=new_width)

    dets = app.cnn_face_detector(image, 1)
    num_faces = len(dets)
    if num_faces == 0:
       raise FaceNotFoundException("No face detected!")
    # Find the 5 face landmarks we need to do the alignment.
    faces = dlib.full_object_detections()
    for detection in dets:
        rect = detection.rect
        faces.append(app.shape_predictor(image, rect))
    images = dlib.get_face_chips(image, faces, size=size, padding = padding)

    return images[0]

def predict_age(image: np.array) -> str:

    trans = transforms.Compose([
        transforms.ToPILImage(),
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    image = trans(image)
    image = image.view(1, 3, 224, 224)  # reshape image to match model dimensions (1 batch size)
    image = image.to(app.device)

    outputs = app.model_fair(image)
    outputs = outputs.cpu().detach().numpy()
    outputs = np.squeeze(outputs)

    age_outputs = outputs[9:18]

    age_score = np.exp(age_outputs) / np.sum(np.exp(age_outputs))

    age_pred = np.argmax(age_score)

    return app.id2age[age_pred]
