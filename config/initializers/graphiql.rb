# config/initializers/graphiql.rb
GraphiQL::Rails.config.initial_query = <<-'GRAPHQL'
# Welcome to DMP OPIDoR GraphQL API 🚀
#
# This GraphQL API allows you to manage plans, research outputs, and authentication.
# Below you'll find example queries and mutations to get started.
#
# Tips:
# - Press Ctrl+Enter to execute a query
# - Press Ctrl+Space for autocomplete
#
# Authentication:
# To execute authenticated queries or mutations, you must first obtain an accessToken and send it in the request headers.
#
# 1. Get an access token
# You can obtain an access token using one of the following mutations:
#   - authenticateAsUser
#   - authenticateAsApiClient
# Both return an object containing an `accessToken`.
# Example response:
# {
#   "accessToken": "your-access-token"
#   ...
# }
#
# 2. Send the token in request headers
# Use the accessToken in the Authorization header using the Bearer scheme.
# Authorization: Bearer <accessToken>
#
# 3. GraphiQL example
# In GraphiQL, open the Headers panel and add:
# {
#   "Authorization": "Bearer <accessToken>"
# }
#
# Authenticated queries/mutations:
# - plans
# - createPlan

#########################
# Authenticate as a User
#########################
mutation authenticateAsUser {
  authenticate(
    input: {
      grantType: "authorization_code", # Auth type
      email: "user@example.com", # User email
      code: "abcd1234" # API Key
    }
  ) {
    accessToken
    tokenType
    expiresIn
    createdAt
  }
}

#########################
# Authenticate as a Client (API)
#########################
mutation authenticateAsApiClient {
  authenticate(
    input: {
      grantType: "client_credentials", # Auth type
      clientId: "abcd1234", # Client API ID
      clientSecret: "azerty1234" # Client Secret
    }
  ) {
    accessToken
    tokenType
    expiresIn
    createdAt
  }
}

#########################
# Example Query: List Plans
#########################
query getPlans {
  plans {
    items {
      planId
      project
      researchEntity
      budget
      meta
      researchOutput
    }
    pageInfo {
      page
      total
      totalPages
    }
  }
}

#########################
# Example Query: List Public Plans
#########################
query getPublicPlans {
  publicPlans {
    items {
      planId
      project
      researchEntity
      budget
      meta
      researchOutput
    }
    pageInfo {
      page
      total
      totalPages
    }
  }
}

#########################
# Example Mutation: Create a plan
#########################
mutation CreatePlan {
  createPlan(input: {
    clientMutationId: "plan-id",
    locale: EN,
    format: STANDARD,
    context: RESEARCH_PROJECT,
    data: {
      project: "New Project",
      researchEntity: "Entity Name",
      budget: 10000
    }
  }) {
    result {
      success
      message
      code
    }
  }
}

# Note: Use logical filters (AND/OR) to refine plan queries using `LogicalFilterInput`.
# You can filter by className, field, value, and operator (eq, neq, gt, lt, etc.).
GRAPHQL
