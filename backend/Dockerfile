FROM python:3.7

WORKDIR /src

RUN apt-get update && apt-get -y install cmake protobuf-compiler

COPY requirements.txt /src/requirements.txt

RUN python -m pip install -r requirements.txt

COPY app /src/app
COPY models /src/models

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "80"]