FROM python:3.10

WORKDIR /src

RUN python -m pip install streamlit

COPY app.py .

CMD ["streamlit", "run", "app.py", "--server.address", "0.0.0.0", "--server.port", "80"]