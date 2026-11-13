# Cognito email allow list

A Terraform module that creates a Cognito **Pre Sign-up** Lambda trigger
(TypeScript compiled to an ES module, `nodejs24.x`) and a DynamoDB allow-list
table. People can only register if their email is in the table. Everyone else,
and any sign-up where the lookup fails, gets rejected.

The compiled Lambda is committed at `lambda/dist/index.mjs`, so using the module
needs only Terraform: no Node.js or build step.

## Usage

```hcl
module "allow_list" {
  source  = "<namespace>/cognito-allow-list/aws"
  version = "~> 1.0"

  name          = "my-app-allow-list"
  user_pool_arn = aws_cognito_user_pool.this.arn
}

resource "aws_cognito_user_pool" "this" {
  # ...
  lambda_config {
    pre_sign_up = module.allow_list.lambda_function_arn
  }
}
```

The module can't attach the trigger to your pool itself (that setting lives on
the `aws_cognito_user_pool` resource), so set `lambda_config.pre_sign_up` as
above. If the pool isn't managed by Terraform, attach it in the console under
**User pool → Extensions → Add Lambda trigger → Sign-up → Pre sign-up**.

## Managing the allow list

Store emails **lowercase**. The handler lowercases and trims the email before the lookup.
Add entries with `aws_dynamodb_table_item` (see the example) or the CLI:

```bash
aws dynamodb put-item --table-name <table_name> --item '{"email": {"S": "alice@example.com"}}'
```

```bash
aws dynamodb delete-item --table-name <table_name> --key '{"email": {"S": "alice@example.com"}}'
```

## Things to know

- Rejected users see `deny_message` with Cognito's own prefix in front, e.g.
  `PreSignUp failed with error This email is not authorized to sign up.` The prefix comes
  from Cognito and can't be changed, so write the message to read well after it. Managed
  login may display the text slightly differently from the API.
- The check runs for all three pre sign-up paths: self sign-up, admin-created users
  (`AdminCreateUser`), and a user's first sign-in through a federated provider (Google,
  SAML, etc.). For federated users, the email comes from the provider's attribute mapping,
  so map the provider's email to the pool's `email` attribute or they'll all be rejected.
- It only gates **creating** an account. Removing an email from the table doesn't affect a
  user who already exists; disable or delete them in the pool (and run
  `admin-user-global-sign-out`) to cut off access.
- A user who signs up with an allowed email can still change their `email` attribute later
  unless you make it immutable for app clients (don't grant write access to `email` in the
  app client's write attributes).
