FROM python:3.11

RUN pip install poetry mypy black isort flake8
