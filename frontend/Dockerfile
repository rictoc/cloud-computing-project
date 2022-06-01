FROM python:3.10

WORKDIR /src

COPY requirements.txt /src

RUN python -m pip install -r requirements.txt

COPY src /src

CMD ["streamlit", "run", "main.py", "--server.address", "0.0.0.0", "--server.port", "80"]