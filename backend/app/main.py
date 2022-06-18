import sys
sys.path.append('/src/JoJoGAN')

from argparse import Namespace
from copy import deepcopy
from io import BytesIO

import torch
from fastapi import FastAPI, Response, UploadFile
from JoJoGAN.e4e.models.psp import pSp
from JoJoGAN.model import *
from JoJoGAN.util import *
from PIL import Image
from torchvision import transforms

torch.backends.cudnn.benchmark = True

app = FastAPI()
app.device = 'cpu'
app.styles = {
   'Jinx': '/src/models/arcane_jinx_preserve_color.pt',
   'Jojo': '/src/models/jojo_preserve_color.pt',
   'Disney': '/src/models/disney_preserve_color.pt'
}


@app.on_event("startup")
def init_models():
    print("Initializing models")
    app.models = {}

    print("Loading original generator")
    latent_dim = 512
    stylegan_ckpt = torch.load('/src/models/stylegan2-ffhq-config-f.pt', map_location=app.device)
    original_generator = Generator(1024, latent_dim, 8, 2).to(app.device)
    original_generator.load_state_dict(stylegan_ckpt["g_ema"], strict=False)
    
    print("Loading finetuned generators")
    for name, path in app.styles.items():
        generator = deepcopy(original_generator)
        model = torch.load(path, map_location=app.device)
        generator.load_state_dict(model["g"], strict=False)
        app.models[name] = generator

    e2e_model_path = '/src/models/e4e_ffhq_encode.pt'
    e2e_ckpt = torch.load(e2e_model_path, map_location=app.device)
    opts = e2e_ckpt['opts']
    opts['checkpoint_path'] = e2e_model_path
    opts= Namespace(**opts)
    app.e2e_net = pSp(opts, app.device).eval().to(app.device)
    print("done !")


@app.get('/')
def ping():
    return "Pong!"


@app.post('/predict/{style}')
async def predict(file: UploadFile, style: str):

    # load image
    image = Image.open(file.file)
    print("Requested model", style)
   
    my_w = projection(image).unsqueeze(0)
    generator = app.models[style]

    with torch.no_grad():
        generator.eval()
        my_sample = generator(my_w, input_is_latent=True)

    image = transforms.ToPILImage(my_sample)
    # save image to in-memory file object
    output = BytesIO()
    image.save(output, 'png')

    return Response(output.getvalue(), media_type='image/png')

@torch.no_grad()
def projection(img):

    transform = transforms.Compose(
        [
            transforms.Resize(256),
            transforms.CenterCrop(256),
            transforms.ToTensor(),
            transforms.Normalize([0.5, 0.5, 0.5], [0.5, 0.5, 0.5]),
        ]
    )

    img = transform(img).unsqueeze(0).to(app.device)
    __, w_plus = app.e2e_net(img, randomize_noise=False, return_latents=True)

    return w_plus[0]

# def image_preparation(image):
#     # aligns and crops face
#     # aligned_face = align_face(img.info["filename"])
#     # filepath = os.path.splitext(img.info["filename"])[0]
#     # name = filepath+'.pt'
#     # my_w = restyle_projection(aligned_face, name, device, n_iters=1).unsqueeze(0)
#     my_w = projection(image).unsqueeze(0)
#     return my_w

# def inference(image, style):
    
#     my_w = projection(image).unsqueeze(0)
#     generator = app.models[style]

#     with torch.no_grad():
#         generator.eval()
#         my_sample = generator(my_w, input_is_latent=True)
    
#     return my_sample
