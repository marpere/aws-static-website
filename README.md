# Terraform for static content on AWS S3 + AWS Cloudfront
My take on hosting static website with S3 and Cloudfront.
## Features
- Bucket not publicly accessible
- Cloudfront cache invalidation in each deploy
- Cloudfront HTTPS certificate

## Problems dealt

### 1. Cloudfront cache

Cloudfront serve the static files through CDN, which cache the files in his mirrors all over the world.

By default, this cache expires only after 24 hours. So, if this files are replaced, will only be visible after this time.

The only way to deal with this is to manually invalidate this cache, but this feature is not available through AWS API or AWS SDK, so terrafrom, out of the box, can't do this.

The solution found was to run the following AWS CLI command as a terraform resource:

```aws cloudfront create-invalidation```

So in each new upload, this command runs to invalidate the cache.

### 2. Mime Types

As opposed of files uploaded by AWS CLI, files uploaded in Terraform do not automatically are assigned a MIME type. 

This way, when the browser requests this files, they will have the Content Type ```application/octet-stream```, and will not be served by the browser but be downloaded insted.

The way to solve this problem is to manually set the MIME Content type of each file.

So I created a file (mime.json) with a map with the extensions and the right content types, for in each upload, the file extension is checked into this map and get the right content type.

### 3. Bucket Access

Some time ago, the way to allow S3 to be publicly accessible, would be to open all accesses to the bucket, and front those files with CloudFront.

A problem, in this case, would be that people could still access the S3 bucket content without the need to use the Cloudfront.

To solve this, now is possible to let the bucket be private, and allow only the Cloudfront to access its content through an Origin Access Control.

This way, the only way to access the static content is through Cloudfront.

### 4. Upload the same content to the bucket

If the same static content is sent again to the S3 bucket, this will be uploaded again. 

To prevent this, the hashes of every individual file are calculated in each upload, so when is time to upload do the bucket again, will only do if those hashes have changed.
