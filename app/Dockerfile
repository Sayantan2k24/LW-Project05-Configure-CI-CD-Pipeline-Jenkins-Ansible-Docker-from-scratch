FROM python:3.9-slim

# Install dependencies
RUN apt-get update && apt-get install -y gcc python3-dev libffi-dev \
    && pip install --no-cache-dir flask netifaces \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy app
COPY app.py .

# Expose port
EXPOSE 5000

# Start Flask app
CMD ["python", "app.py"]