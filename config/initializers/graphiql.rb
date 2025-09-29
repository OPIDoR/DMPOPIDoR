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
# - Queries and mutations can be nested using filters

#########################
# Example Query: List Plans
#########################
{
  plans(size: 5, page: 1, orderBy: { field: "updated_at", order: "desc" }) {
    items {
      planId
      templateName
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
{
  publicPlans(size: 5, page: 1) {
    items {
      planId
      templateName
      project
    }
    pageInfo {
      page
      total
      totalPages
    }
  }
}

#########################
# Authenticate as a User
#########################
mutation authenticateUser {
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
mutation authenticateClient {
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
