To use the created bucket as terraform s3 backend add the following to each terraform root module.
Make sure to update bucket,key, and region according to your requirements and backend s3 attributes.
```
terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-up-and-running-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}
```

To avoid replication of these settings in every module, one option is to use the following configs.
```
# backend.hcl
bucket         = "terraform-up-and-running-state"
region         = "us-east-2"
dynamodb_table = "terraform-up-and-running-locks"
encrypt        = true
```

```
terraform {
  backend "s3" {
    key            = "example/terraform.tfstate"
  }
}
```

Then set backend on command line:
```
terraform init -backend-config=backend.hcl
```

Terragrant makes this easier.