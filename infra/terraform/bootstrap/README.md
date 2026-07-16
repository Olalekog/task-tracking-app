# Terraform Deployment Role Bootstrap

The infrastructure workflow assumes the AWS role in the GitHub variable
`ROLE_TO_ASSUME`. That role must be able to create the IAM roles, instance
profiles, policies, and EKS OIDC provider used by the Terraform stack.

Attach `github-actions-iam-policy.json` as an inline policy, or as a managed
customer policy, to the role referenced by `ROLE_TO_ASSUME`.

Example:

```bash
aws iam put-role-policy \
  --role-name Reactjs-application-role \
  --policy-name TaskTrackingTerraformIamManagement \
  --policy-document file://infra/terraform/bootstrap/github-actions-iam-policy.json
```

The policy is scoped to `task-tracking-*` IAM roles, instance profiles, and
customer managed policies, with separate permissions for the EKS OIDC provider
and the Elastic Load Balancing service-linked role.
