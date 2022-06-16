from fastapi import FastAPI, UploadFile, Response
from io import BytesIO
from PIL import Image, ImageOps
import torch
torch.backends.cudnn.benchmark = True
from util import *
from torchvision import transforms, utils
import numpy as np
from torch import nn, autograd, optim
from torch.nn import functional as F
from model import *
from e4e_projection import projection as e4e_projection
import os

app = FastAPI()
device = 'cuda'
stls = {}
stls['Jinx'] = 'models/arcane_jinx_preserve_color.pt'
stls['Jojo'] = 'models/jojo_preserve_color.pt'
stls['Disney'] = 'models/disney_preserve_color.pt'
ckpt = torch.load('models/stylegan2-ffhq-config-f.pt', map_location=lambda storage, loc: storage)
original_generator = Generator(1024, latent_dim, 8, 2).to(device)
original_generator.load_state_dict(ckpt["g_ema"], strict=False)
mean_latent = original_generator.mean_latent(10000)
transform = transforms.Compose(
    [
        transforms.Resize((1024, 1024)),
        transforms.ToTensor(),
        transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5)),
    ]
)
seed = 3000


@app.get('/')
def ping():
    return "Pong!"


@app.post('/predict/{style}')
async def predict(file: UploadFile, style: str):

    # load image
    image = Image.open(file.file)
    print("Requested model", style)
   
    # do some manipulations
    #image = ImageOps.grayscale(image)
    trans = transforms.ToPILImage()
    #from tensor to PIL Image
    image = trans(inference(image,style))
    # save image to in-memory file object
    output = BytesIO()
    image.save(output, 'png')

    return Response(output.getvalue(), media_type='image/png')
 
def image_preparation(img):
    # aligns and crops face
    aligned_face = align_face(img.info["filename"])
    filepath = os.path.splitext(img.info["filename"])[0]
    name = filepath+'.pt'
    # my_w = restyle_projection(aligned_face, name, device, n_iters=1).unsqueeze(0)
    my_w = e4e_projection(aligned_face, name, device).unsqueeze(0)
    return my_w

def inference(img,style):
    generator = deepcopy(original_generator)
    model = torch.load(stls[style], map_location=lambda storage, loc: storage)
    generator.load_state_dict(model["g"], strict=False)
    
    my_w = image_preparation(img)
    with torch.no_grad():
        generator.eval()
        original_my_sample = original_generator(my_w, input_is_latent=True)
        my_sample = generator(my_w, input_is_latent=True)
    
    return my_sample
    
    