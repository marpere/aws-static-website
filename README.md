# Terraform for static content on AWS S3 + AWS Cloudfront
## Features
- Bucket not publicly accessible
- Cloudfront invalidation in each deploy
- HTTPS certificate

## Problems dealt

### 1. Cloudfront cache

Cloudfront serve the static file through CDN, which cache the files in his mirrors all over the world.

By default, this cache expires after 24 hours. So, new files would only be visible after this time.

The only way to deal with this is to manually invalidate this cache, but this feature is not available through AWS API or SDK, so terrafrom, out of the box, is prevented to do something.

The solution is to run the following AWS CLI command:

```aws cloudfront create-invalidation```

So in every new redistribution to Cloudfront, this command runs to invalidate the cache.

### 2. Mime Types

As opposed of files uploaded by AWS CLI, files uploaded in Terraform do not automatically  assign MIME types. Causing the problem of, when these files are tied to be accessed they will have the Content Type application/octet-stream, not allowing the browser to server these files correctly but downloading them.

The way to olve this problem is to manually set the MIME Content type of each file.

So I created a file (mime.json) with a map with the extensions and the right content types, for in each upload, the file extension is checked into this map and get the right content type.

### 3. Bucket Access

Some time before, the way to allow S3 to be publicly accessible would be to open all accesses to the bucket, and allow it to server static content and front this with a Cloudfront distribution.

A problem, in this case, would be that people could access the S3 bucket content without the need to use the Cloudfront.

To solve this, now is possible to let the bucket be private, and allow only the Cloudfront to access its content through an Origin Access Control.

This way, the only way to access the static content is through the Cloudfront.

### 4. Content update in S3

If the same static content would be sent again to the bucket, this would be uploaded again. 

To prevent this, the hashes of every individual file are calculated, so when is time to upload do the bucket, only do if those hashes have changed.
