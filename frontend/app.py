import time
import streamlit as st


st.title('Cloud computing project')

if 'history' not in st.session_state:
    st.session_state.history = []


def process_file(file, style):

    # TODO implementare qui chiamata al backend
    processed_file = file
    time.sleep(2)
    st.session_state.history.append((file, processed_file))
    print(st.session_state)

    return processed_file


def display_history():

    if st.session_state.history:

        input_col, output_col = st.columns(2)

        for element in st.session_state.history:

            with input_col:
                st.image(element[0])
            with output_col:
                st.image(element[1])


style_frame, file_frame = st.columns(2)
with style_frame:
    style = st.selectbox("Choose style",
                            ('style 1', 'style 2', 'style 3'))
with file_frame:
    uploaded_file = st.file_uploader("Upload file")

if uploaded_file is not None:

    with st.container():
        
        input_frame, output_frame = st.columns(2)

        with input_frame:
            st.image(uploaded_file)

        with output_frame:
            start_time = time.time()
            st.image(process_file(uploaded_file, style), caption="")
            st.success('Done in %.2fs' % (time.time() - start_time))

    with st.expander("Show history"):
        display_history()
