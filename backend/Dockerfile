FROM python:3.10

WORKDIR /src

RUN git clone https://github.com/mchong6/JoJoGAN

COPY requirements.txt /src/requirements.txt

RUN python -m pip install -r requirements.txt

COPY app /src/app

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "3000"]