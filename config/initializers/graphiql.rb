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

#########################
# Example Mutation: Authenticate as a User
# Access: Public (before authentication)
#
# Description:
# Authenticates a user using an authorization code and returns an access token.
#
# Features:
# - Uses `grantType: authorization_code`
# - Requires `email` and `code` (API key)
# - Returns accessToken, token type, expiration, and creation timestamp
#
# Notes:
# - The returned `accessToken` should be included in the Authorization header for subsequent requests:
#   Authorization: Bearer <accessToken>
#########################
mutation authenticateAsUser {
  authenticate(
    input: {
      grantType: "authorization_code", # Auth type
      email: "user@example.com",       # User email
      code: "abcd1234"                 # API Key
    }
  ) {
    accessToken
    tokenType
    expiresIn
    createdAt
  }
}

#########################
# Example Mutation: Authenticate as API Client
# Access: Public (before authentication)
#
# Description:
# Authenticates a client using client credentials and returns an access token.
#
# Features:
# - Uses `grantType: client_credentials`
# - Requires `clientId` and `clientSecret`
# - Returns accessToken, token type, expiration, and creation timestamp
#
# Notes:
# - The returned `accessToken` should be used in the Authorization header for subsequent requests:
#   Authorization: Bearer <accessToken>
#########################
mutation authenticateAsApiClient {
  authenticate(
    input: {
      grantType: "client_credentials",  # Auth type
      clientId: "abcd1234",             # Client API ID
      clientSecret: "azerty1234"        # Client Secret
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
# Access: Authenticated
#
# Description:
# Retrieves a paginated list of public plans, 
# with optional filtering, sorting, and research output filtering.
#########################
query getPlans {
  publicPlans {
    pageInfo {
      total
      totalPages
      page
    }
    items {
      planId
      researchOutput
    }
  }
}

# Example: get plans by language (in french)
query getPlansByLanguage {
  plans(
    size: 1000
    page: 1
    filter: {
      and: [
        {
          field: "$.meta.dmpLanguage"
          value: "fra"
          operator: "eq"
        }
      ]
    }
  ) {
    pageInfo {
      total
      totalPages
      page
    }
    items {
      planId
      researchOutput
    }
  }
}

#########################
# Example Query: List Public Plans
# Access: Public
# 
# Description:
# Retrieves a paginated list of plans belonging to the current user, 
# with optional filtering, sorting, and research output filtering.
#########################
query getPublicPlans {
  publicPlans {
    pageInfo {
      total
      totalPages
      page
    }
    items {
      planId
      researchOutput
    }
  }
}

# Example: get public plans by language (in french)
query getPublicPlansByLanguage {
  publicPlans(
    size: 1000
    page: 1
    filter: {
      and: [
        {
          field: "$.meta.dmpLanguage"
          value: "fra"
          operator: "eq"
        }
      ]
    }
  ) {
    pageInfo {
      total
      totalPages
      page
    }
    items {
      planId
      researchOutput
    }
  }
}

#########################
# Example Mutation: Create a Plan
# Access: Authenticated
#
# Description:
# Creates a new plan for the current user.
#
# Features:
# - Requires authentication
# - Specify locale, format, context, and plan data
# - Returns a success status, message, and code
#
# Notes:
# - `clientMutationId` is optional but useful for tracking
# - `data` object must include at least project, researchEntity, and budget
#########################
mutation createPlan {
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
GRAPHQL
