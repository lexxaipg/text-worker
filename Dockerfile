FROM python:3.11-slim

WORKDIR /worker

COPY requirements-scribe.txt .

RUN pip install --no-cache-dir -r requirements-scribe.txt

COPY .. .

EXPOSE 443

CMD ["python", "-s", "bridge_scribe.py"]