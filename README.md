# fdp-infra-database

DynamoDB tables for the `fdp` platform, London (`eu-west-2`).

## Layout

```
.
├── dynamodb_main.tf   # root: locals (dev/prod config sets) + module "dynamodb" (for_each over tables)
├── providers.tf       # aws provider, region + default_tags
├── backend.tf         # S3 backend, partial config (key supplied at init)
├── versions.tf        # required_version + aws ~> 5.60
├── outputs.tf         # table names / ARNs / stream ARNs, resource_prefix
└── modules/
    └── dynamodb/      # one call == one table, on-demand (PAY_PER_REQUEST)
        ├── dynamodb.tf     # aws_dynamodb_table + attribute / GSI / LSI / TTL / PITR / SSE / stream
        ├── variables.tf
        ├── outputs.tf
        └── versions.tf
```

## Usage

Region is fixed. `var.environment` picks one of the `dev` / `prod` config sets
in [dynamodb_main.tf](dynamodb_main.tf).

This repo ships with **no tables defined** - it provisions the DynamoDB module
and the house conventions around it. A `plan`/`apply` with an empty `tables`
map is a valid no-op.

```bash
terraform init -backend-config="key=fdp-infra-database/dev/terraform.tfstate"
terraform plan  -var="environment=dev"
terraform apply -var="environment=dev"
```

Add a table later by adding an entry under `tables` in **both** the `dev` and
`prod` config sets (the two sets must carry the same keys). Each entry becomes
one call of [modules/dynamodb/](modules/dynamodb/) and one table named
`fdp-<env>-euw2-<key>`.

## Module inputs of note

Every table is on-demand (`PAY_PER_REQUEST`) - there is no capacity or
autoscaling to configure.

| Input | Default | Notes |
|---|---|---|
| `hash_key` / `range_key` | — / `null` | Must appear in `attributes`. |
| `attributes` | — | Only key / index attributes. Type is `S`, `N` or `B`. |
| `global_secondary_indexes` | `[]` | `non_key_attributes` only used with `projection_type = "INCLUDE"`. |
| `local_secondary_indexes` | `[]` | Table creation time only; needs a table `range_key`. |
| `ttl_attribute_name` | `""` | Empty string disables TTL. |
| `point_in_time_recovery_enabled` | `true` | Off in `dev`, on in `prod`. |
| `deletion_protection_enabled` | `true` | Off in `dev`, on in `prod`. |
| `server_side_encryption_enabled` | `true` | `true` + `kms_key_arn = null` uses the AWS-managed `aws/dynamodb` key; set `kms_key_arn` for a CMK. |
| `stream_enabled` / `stream_view_type` | `false` / — | `stream_view_type` required when streams are on. |
| `table_class` | `STANDARD` | Or `STANDARD_INFREQUENT_ACCESS`. |
