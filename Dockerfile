# Use Ubuntu 24.04 as base image
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
    python3-full \
    python3-pip \
    ffmpeg \
    curl \
    && rm -rf /var/lib/apt/lists/*
    
WORKDIR /app
# Create and activate virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Upgrade pip
RUN python3 -m pip install --upgrade pip

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --timeout=1000 -r requirements.txt

# Copy application files
COPY . /app

# Create storage directory
RUN mkdir -p /app/.storage

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV STORAGE_DIR=/app/.storage

# Expose port
EXPOSE 8000

# Add health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

# Verify installations
RUN echo "Verifying installations:" && \
    echo "Ubuntu version:" && cat /etc/os-release && \
    echo "FFmpeg version:" && ffmpeg -version && \
    echo "Python version:" && python3 --version && \
    echo "Pip version:" && pip --version && \
    echo "Installed packages:" && pip list

# Command to run when container starts
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]