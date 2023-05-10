# Terraform for static content on AWS S3 + AWS Cloudfront

My take on creating the infra and send the files to host a static website in AWS using a S3 Bucket and a Cloudfront to serve this files with a HTTPS certificate.

## Problems dealt

1. Cloudfront cache

Cloudfront serve the static file throught CDN, which cache the files in his mirrors all over the world.
By default this cache expires after 24 hours. So, new files would only be visible after this time.
The only way to deal with this is to manually invalidate this cache, but this feature is not availabe through AWS API or SDK, so terrafrom, out of the box, is prevented to do something.
The solution is to run the following AWS CLI command:
```aws cloudfront create-invalidation```
So in every new redistribution to Cloudfront, this command runs to invalidate the cache.

2. Mime Types

As oposed of files uploaded by AWS CLI, files uploaded in Terraform do not automatically are assigned MIME types. Causing the problem of, when this files are tied to be acceced they will have the Content Type application/octet-stream, not allowing the browser to server this files correctly but downloading them.
The way to resolve this problem is to manually set the MIME Content type of each file.
So I created a file (mime.json) with a map with the extensions and the right content types, for in each upload, the file extension is checked into this map and get the right content type.
