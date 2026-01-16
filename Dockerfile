FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    fuse \
    samba \
    && rm -rf /var/lib/apt/lists/*

# Install mountpoint-s3
RUN ARCH=$(dpkg --print-architecture) \
    && wget -q "https://s3.amazonaws.com/mountpoint-s3-release/latest/${ARCH}/mount-s3.deb" \
    && apt-get update && apt-get install -y ./mount-s3.deb \
    && rm -f mount-s3.deb \
    && rm -rf /var/lib/apt/lists/*

# Create mount point
RUN mkdir -p /mnt/s3

# Copy configuration and entrypoint
COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# SMB port
EXPOSE 445/tcp

ENTRYPOINT ["/entrypoint.sh"]
