import os
import time
import json
import httpx
import streamlit as st

PREDICTION_SERVICE_HOSTNAME = os.environ["PREDICTION_SERVICE_HOSTNAME"]
PREDICTION_SERVICE_PORT = os.environ["PREDICTION_SERVICE_PORT"]

st.set_page_config(
     page_title="How old do you look?",
     page_icon="👴",
     layout="centered"
 )

md_text = """
            <style>
            #MainMenu {visibility: hidden;}
            </style>
            # How old do you look?
            Project for Cloud Computing course


            M.Sc in Computer Science, Sapienza University of Rome, a.a. 2021/2022

            The aim of our project is the creation and deployment on AWS of an age prediction deep learning based web application
            using pre-trained models from [FairFace](https://github.com/dchen236/FairFace).
          """
st.markdown(md_text, unsafe_allow_html=True)

uploaded_image = st.file_uploader("Upload image")

if uploaded_image is not None:
    st.image(uploaded_image)

submitted = st.button("Submit")
if submitted and uploaded_image is not None:
    with st.spinner("Processing image..."):
                start_time = time.time()
                response = httpx.post(
                                f'http://{PREDICTION_SERVICE_HOSTNAME}:{PREDICTION_SERVICE_PORT}/predict',
                                files={'file': uploaded_image},
                                timeout=60.0)
                if response.status_code == 200:
                    response_dict = response.json()
                    st.success(response_dict["age"])
                elif response.status_code == 422:
                    st.error("No face detected")
                elapsed_time = time.time() - start_time
    st.success('Done in %.2fs' % elapsed_time)
