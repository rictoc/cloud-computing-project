import os
import time
from io import BytesIO

import httpx
import streamlit as st
from PIL import Image


PREDICTION_SERVICE_HOSTNAME = os.environ["PREDICTION_SERVICE_HOSTNAME"]
PREDICTION_SERVICE_PORT = os.environ["PREDICTION_SERVICE_PORT"]
STYLES = ('style 1', 'style 2', 'style 3')

st.set_page_config(
     page_title="CC Project",
     page_icon="🎭",
     layout="centered"
 )

md_text = """
            <style>
            #MainMenu {visibility: hidden;}
            </style>
            # Project for Cloud Computing course
            M.Sc in Computer Science, Sapienza University of Rome, a.a. 2021/2022

            The aim of our project is the creation and deployment of a Deep Learning based web application.
            In particular we want to build an application based on the open-source, pretrained GAN (Generative Adversarial Network )
            models presented in the 2021 paper [JoJoGAN: One Shot Face Stylization](https://arxiv.org/abs/2112.11641).
          """
st.markdown(md_text, unsafe_allow_html=True)

if 'history' not in st.session_state:
    st.session_state.history = []


def process_image(image, style):

    response = httpx.post(
        f'http://{PREDICTION_SERVICE_HOSTNAME}:{PREDICTION_SERVICE_PORT}/predict/{style}',
        files={'file': image}
    )
    response_buffer = BytesIO(response.content)
    processed_image = Image.open(response_buffer)
    st.session_state.history.append((image, processed_image))

    return processed_image


def display_history():

    if st.session_state.history:

        input_col, output_col = st.columns(2)

        for element in st.session_state.history:

            with input_col:
                st.image(element[0])
            with output_col:
                st.image(element[1])


style_column, file_column = st.columns([0.5, 1])

with style_column:
    style = st.selectbox("Choose style", STYLES)

with file_column:
    uploaded_image = st.file_uploader("Upload image")

if uploaded_image is not None:

    with st.container():
        
        input_column, output_column = st.columns(2)

        with input_column:

            st.image(uploaded_image)

            with st.spinner("Processing image..."):
                start_time = time.time()
                processed_image = process_image(uploaded_image, style)
                elapsed_time = time.time() - start_time

        with output_column:
           st.image(processed_image)
           st.success('Done in %.2fs' % elapsed_time)

    with st.expander("Show history"):
        display_history()
