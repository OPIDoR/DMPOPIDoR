# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  namespace :super_admin do
    resources :registries do
      post 'sort_values', on: :collection
      get 'download'
    end
    resources :registry_values, only: %i[edit update destroy]
    resources :madmp_schemas, only: %i[index new create edit update destroy]
  end

  resources :madmp_fragments, only: %i[create update destroy] do
    get 'load_new_form', action: :load_form, on: :collection
    get 'load_form/:id', action: :load_form, on: :collection
    get 'change_form/:id', action: :change_form, on: :collection
    get 'new_edit_linked', on: :collection, constraints: { format: [:js] }
    get 'show_linked', on: :collection, constraints: { format: [:js] }
    get 'create_from_registry', action: :create_from_registry_value, on: :collection
    get 'create_contributor', action: :create_contributor, on: :collection
    delete 'destroy_contributor', action: :destroy_contributor, on: :collection
    get 'load_fragments', action: :load_fragments, on: :collection
  end

  get '/codebase/run', to: 'madmp_codebase#run', constraints: { format: [:json] }
  get '/codebase/anr_search', to: 'madmp_codebase#anr_search', constraints: { format: [:json] }

  resources :registries, only: [] do
    get 'load_values', action: :load_values, on: :collection
  end

  resources :api_client_roles, only: %i[create update destroy]

  namespace :api, defaults: { format: :json } do
    namespace :v0 do
      namespace :madmp do
        get 'dmp_fragments/:id', controller: "madmp_fragments", action: 'dmp_fragments'
        resources :dmp_fragments, controller: "madmp_fragments", action: "dmp_fragments"
        resources :madmp_fragments, only: %i[show update], controller: "madmp_fragments", path: "fragments"
        resources :madmp_schemas, only: [:show], controller: "madmp_schemas", path: "schemas"
        resources :plans, only: [:show]
      end
    end

    namespace :v1 do
      namespace :madmp do
        get 'dmp_fragments/:id', controller: "madmp_fragments", action: 'dmp_fragments'
        resources :madmp_fragments, only: %i[show update], controller: "madmp_fragments", path: "fragments"
        resources :madmp_schemas, only: %i[index show], controller: "madmp_schemas", path: "schemas"
        resources :registries, only: %i[index show], controller: "registries", param: :name
        resources :plans, only: [:show] do
          get 'research_outputs/:uuid', action: :show, on: :collection, as: :show
          collection do
            post :import
          end
        end
      end
    end
  end

  namespace :paginable do
    # Paginable actions for registries
    resources :registries, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for madmp schemas
    resources :madmp_schemas, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for registry values
    resources :registry_values, only: [] do
      get ':id/index/:page', action: :index, on: :collection, as: :index
    end
  end
end
# rubocop:enable Metrics/BlockLength