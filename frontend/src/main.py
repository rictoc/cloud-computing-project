import os
import time
from io import BytesIO

import httpx
import streamlit as st
from PIL import Image

PREDICTION_SERVICE_HOSTNAME = os.environ["PREDICTION_SERVICE_HOSTNAME"]
PREDICTION_SERVICE_PORT = os.environ["PREDICTION_SERVICE_PORT"]
STYLES = ('style 1', 'style 2', 'style 3')

st.title('Cloud computing project')

if 'history' not in st.session_state:
    st.session_state.history = []


def process_image(image, style):

    response = httpx.post(
        f'http://{PREDICTION_SERVICE_HOSTNAME}:{PREDICTION_SERVICE_PORT}/predict',
        files={'file': image}
    )
    processed_image = Image.open(BytesIO(response.content))
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
