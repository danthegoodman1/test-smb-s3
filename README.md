# SMB Server over S3 (R2) via Docker

Exposes a Cloudflare R2 (or S3-compatible) bucket as an SMB share.

Had to use SMB, nfs v4 kept panicking the kernel on writes, and v3 kept disconnecting.

Sometimes SMB connects when mountpoint-s3 goes nuts about out of order writes.

## Setup

1. Create a `.env` file:

```bash
AWS_ACCESS_KEY_ID=your_r2_access_key_id
AWS_SECRET_ACCESS_KEY=your_r2_secret_access_key
AWS_ENDPOINT_URL=https://ACCOUNT_ID.r2.cloudflarestorage.com
AWS_REGION=auto
S3_BUCKET=your-bucket-name
```

2. Build and run:

```bash
docker compose up --build
```

3. Mount on macOS:

```bash
mount -t smbfs //guest@localhost/s3 /tmp/smb-s3
```

Or via Finder: Cmd+K, then enter `smb://localhost/s3`

4. Unmount:

```bash
umount /tmp/smb-s3
```

## Notes

- Uses mountpoint-s3 to mount the S3 bucket inside the container
- Samba serves the mount over SMB
- Container runs in privileged mode for FUSE support
- Port 445 is exposed for SMB traffic
- Guest access enabled (no password required)

## Limitations

- mountpoint-s3 only supports sequential writes to new files
- Cannot append to or modify existing files
- Complex file operations (editors, downloads) may have issues
