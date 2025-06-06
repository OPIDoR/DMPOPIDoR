# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Rails.application.routes.draw do
  mount ActionCable.server => ENV.fetch('ACTON_CABLE_SERVER', '/cable')
  mount Rswag::Ui::Engine => ENV.fetch('RSWAG_UI', '/api-docs')
  mount Rswag::Api::Engine => ENV.fetch('RSWAG_API', '/api-docs')

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  devise_for(:users, controllers: {
               registrations: 'registrations',
               passwords: 'passwords',
               sessions: 'sessions',
               omniauth_callbacks: 'users/omniauth_callbacks',
               invitations: 'users/invitations'
             }) do
    get '/users/sign_out', to: 'devise/sessions#destroy'
  end

  delete '/users/identifiers/:id', to: 'identifiers#destroy', as: 'destroy_user_identifier'

  get '/orgs/shibboleth', to: 'orgs#shibboleth_ds', as: 'shibboleth_ds'
  get '/orgs/shibboleth/:org_id', to: 'orgs#shibboleth_ds_passthru'
  post '/orgs/shibboleth', to: 'orgs#shibboleth_ds_passthru'

  resources :users, path: 'users', only: [] do
    resources :org_swaps, only: [:create],
                          controller: 'super_admin/org_swaps'

    member do
      put 'update_email_preferences'
      get 'refresh_token'
    end

    post '/acknowledge_notification', to: 'users#acknowledge_notification'
  end

  # organisation admin area
  resources :users, path: 'org/admin/users', only: [] do
    collection do
      get 'admin_index'
    end
    member do
      get 'admin_grant_permissions'
      put 'admin_update_permissions'
      put 'activate'
    end
  end

  # You can have the root of your site routed with 'root'
  # just remember to delete public/index.html.

  patch 'locale/:locale' => 'session_locales#update', as: 'locale'

  root to: 'home#index'
  get 'login', to: 'home#login'
  get 'about_us', to: 'static/static_pages#show', name: 'about_us'
  get 'terms', to: 'static/static_pages#show', name: 'termsuse'
  get 'privacy', to: 'static/static_pages#show', name: 'privacy'
  get 'roadmap', to: 'static/static_pages#show', name: 'roadmap'
  get 'research_output_types', to: 'static/static_pages#show', name: 'research_output_types'
  get 'about_registries', to: 'static/static_pages#show', name: 'about_registries'

  get 'help', to: 'static_pages#help'
  get 'glossary', to: 'static_pages#glossary'
  get 'tutorials', to: 'static_pages#tutorials'
  get 'news_feed', to: 'static_pages#news_feed'
  get 'optout', to: 'static_pages#optout'
  get 'public_plans' => 'public_pages#plan_index'
  get 'public_templates' => 'public_pages#template_index'
  get 'template_export/:id' => 'public_pages#template_export', as: 'template_export'
  get 'public_guidance_groups' => 'public_pages#guidance_group_index'
  # Guidance group export
  get 'guidance_group_export/:id', to: 'public_pages#guidance_group_export', as: 'guidance_group_export'
  # Static pages
  namespace :static do
    get ':name', to: 'static_pages#show'
  end

  # AJAX call used to search for Orgs based on user input into autocompletes
  post 'orgs' => 'orgs#search', as: 'orgs_search'
  resources :orgs, constraints: { format: [:json] } do
    get 'list', on: :collection
  end
  resources :orgs, path: 'org/admin', only: [] do
    member do
      get 'admin_edit'
      put 'admin_update'
    end
    resources :departments, controller: 'org_admin/departments'
  end

  # This should be made more restful and placed within the `org_admin` or a new
  # `admin` namespace. For example:
  #     namespace :admin
  #       resources :guidances, except: %i[show]
  #     end
  resources :guidances, path: 'org/admin/guidance', only: [] do
    post 'render_themes', on: :collection, constraints: { format: [:json] }
    member do
      get 'admin_index'
      get 'admin_edit'
      get 'admin_new'
      delete 'admin_destroy'
      post 'admin_create'
      put 'admin_update'
      put 'admin_publish'
      put 'admin_unpublish'
    end
  end

  # This should be made more restful and placed within the `org_admin` or a new
  # `admin` namespace. For example:
  #     namespace :admin
  #       resources :guidance_groups, except: %i[show]
  #     end
  resources :guidance_groups, path: 'org/admin/guidancegroup', only: [] do
    member do
      get 'admin_show'
      get 'admin_new'
      get 'admin_edit'
      delete 'admin_destroy'
      post 'admin_create'
      put 'admin_update'
      put 'admin_update_publish'
      put 'admin_update_unpublish'
    end
  end

  resources :answers, only: [] do
    post 'create_or_update', on: :collection
    post 'set_answers_as_common', on: :collection
    get 'notes', constraints: { format: [:json] }
    get 'new_form', on: :collection, constraints: { format: [:json] }
  end

  # Question Formats controller, currently just the one action
  get 'question_formats/rda_api_address' => 'question_formats#rda_api_address'

  resources :notes, only: %i[create update archive] do
    member do
      post 'create', constraints: { format: [:json] }
      patch 'archive', constraints: { format: [:json] }
      put 'update', constraints: { format: [:json] }
    end
  end

  resources :feedback_requests, only: [:create]

  resources :plans do
    get 'import', action: :import, on: :collection
    post 'import', action: :import_plan, on: :collection
    resource :export, only: [:show], controller: 'plan_exports'

    resources :contributors, except: %i[show]

    resources :research_outputs, except: %i[show]

    member do
      get 'structured_edit'
      get 'answer'
      get 'share'
      get 'request_feedback'
      get 'download'
      get 'budget'
      get 'guidance_groups', constraints: { format: [:json] }
      post 'guidance_groups', action: :select_guidance_groups, constraints: { format: [:json] }
      get 'guidances', action: :question_guidances, constraints: { format: [:json] }
      get 'research_outputs_data', constraints: { format: [:json] }
      get 'contributors_data', constraints: { format: [:json] }
      post 'duplicate'
      post 'visibility', constraints: { format: [:json] }
      post 'set_test', constraints: { format: [:json] }
      get 'overview'
    end
    resources :research_outputs, only: %i[index update destroy], controller: 'research_outputs'
  end

  resources :research_outputs, only: %i[index show create destroy update], constraints: { format: [:json] } do
    get 'create_remote', on: :collection
    delete 'destroy_remote', on: :collection
    patch 'update_remote', on: :collection
    post 'sort', on: :collection
    post 'import', on: :collection, constraints: { format: [:json] }
  end

  resources :research_outputs, only: [] do
    post 'sort', on: :collection

    # Ajax endpoint for ResearchOutput.output_type selection
    get 'output_type_selection', controller: 'research_outputs', action: 'select_output_type'

    # Ajax endpoint for ResearchOutput.license_id selection
    get 'license_selection', controller: 'research_outputs', action: 'select_license'

    # AJAX endpoints for repository search and selection
    get :repository_search, controller: 'research_outputs'
    # AJAX endpoints for metadata standards search and selection
    get :metadata_standard_search, controller: 'research_outputs'
  end

  resources :usage, only: [:index]
  post 'usage_plans_by_template', controller: 'usage', action: 'plans_by_template'
  get 'usage_all_plans_by_template', controller: 'usage', action: 'all_plans_by_template'
  get 'usage_global_statistics', controller: 'usage', action: 'global_statistics'
  get 'usage_org_statistics', controller: 'usage', action: 'org_statistics'
  get 'usage_yearly_users', controller: 'usage', action: 'yearly_users'
  get 'usage_yearly_plans', controller: 'usage', action: 'yearly_plans'

  resources :usage_downloads, only: [:index]

  resources :roles, only: %i[create update destroy] do
    member do
      put :deactivate
    end
  end

  namespace :settings do
    resources :plans, only: [:update]
  end

  namespace :api, defaults: { format: :json } do
    namespace :v0 do
      resources :departments, only: %i[create index] do
        collection do
          get :users
        end
        member do
          patch :unassign_users
          patch :assign_users
        end
      end
      resources :guidances, only: [:index], controller: 'guidance_groups', path: 'guidances'
      resources :plans, only: %i[create index]
      resources :templates, only: :index
      resource  :statistics, only: [], controller: 'statistics', path: 'statistics' do
        member do
          get :users_joined
          get :completed_plans
          get :created_plans
          get :using_template
          get :plans_by_template
          get :plans
        end
      end
      resources :themes, param: :slug, only: [] do
        member do
          get 'extract', to: 'themes#extract'
        end
      end
    end

    namespace :v1 do
      get :heartbeat, controller: 'base_api'
      post :authenticate, controller: 'authentication'

      resources :plans, only: %i[create show index]
      resources :templates, only: [:index]

      resources :themes, param: :slug, only: [] do
        member do
          get 'extract', to: 'themes#extract'
        end
      end
    end
  end

  namespace :paginable do
    resources :orgs, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for plans
    resources :plans, only: [] do
      get 'privately_visible/:page',
          action: :privately_visible, on: :collection, as: :privately_visible

      get 'organisationally_or_publicly_visible/:page',
          action: :organisationally_or_publicly_visible,
          on: :collection, as: :organisationally_or_publicly_visible

      get 'publicly_visible/:page', action: :publicly_visible,
                                    on: :collection, as: :publicly_visible

      get 'org_admin/:page', action: :org_admin, on: :collection, as: :org_admin

      # Paginable actions for contributors
      resources :contributors, only: %i[index] do
        get 'index/:page', action: :index, on: :collection, as: :index
      end
      # Paginable actions for research_outputs
      resources :research_outputs, only: %i[index] do
        get 'index/:page', action: :index, on: :collection, as: :index
      end
    end

    # Paginable actions for users
    resources :users, only: %i[index] do
      member do
        resources :plans, only: %(index)
      end
    end
    # Paginable actions for themes
    resources :themes, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for notifications
    resources :notifications, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for templates
    resources :templates, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
      get 'customisable/:page', action: :customisable, on: :collection, as: :customisable
      get 'organisational/:page', action: :organisational, on: :collection, as: :organisational
      get 'modules/:page', action: :modules, on: :collection, as: :modules
      get 'publicly_visible/:page', action: :publicly_visible,
                                    on: :collection, as: :publicly_visible
      get ':id/history/:page', action: :history, on: :collection, as: :history
    end
    # Paginable actions for guidances
    resources :guidances, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for guidance_groups
    resources :guidance_groups, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
      get 'publicly_visible/:page', action: :publicly_visible, on: :collection, as: :publicly_visible
    end
    # Paginable actions for static pages
    resources :static_pages, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
      get 'publicly_visible/:page', action: :publicly_visible, on: :collection, as: :publicly_visible
    end
    # Paginable actions for departments
    resources :departments, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
    # Paginable actions for api_clients
    resources :api_clients, only: [] do
      get 'index/:page', action: :index, on: :collection, as: :index
    end
  end

  resources :template_options, only: [:index], constraints: { format: /json/ } do
    get 'default', action: :default, on: :collection, as: :default
    get 'recommend', action: :recommend, on: :collection, as: :recommend
  end

  # ORG ADMIN specific pages
  namespace :org_admin do
    resources :users, only: %i[edit update], controller: 'users' do
      member do
        get 'user_plans'
      end
    end

    resources :question_options, only: [:destroy], controller: 'question_options'

    resources :questions, only: [] do
      get 'open_conditions'
      resources :conditions, only: %i[new show]
    end

    resources :plans, only: [:index] do
      member do
        get 'feedback_complete'
      end
    end

    resources :templates do
      resources :customizations, only: [:create], controller: 'template_customizations'

      resources :copies, only: [:create],
                         controller: 'template_copies',
                         constraints: { format: [:json] }

      resources :customization_transfers, only: [:create],
                                          controller: 'template_customization_transfers'

      member do
        get 'history'
        get 'template_export', action: :template_export
        patch 'publish', action: :publish, constraints: { format: [:json] }
        patch 'unpublish', action: :unpublish, constraints: { format: [:json] }
      end

      # Used for the organisational and customizable views of index
      collection do
        get 'organisational'
        get 'customisable'
        get 'modules'
      end

      resources :phases, except: [:index] do
        resources :versions, only: [:create], controller: 'phase_versions'

        member do
          get 'preview'
          post 'sort'
        end

        resources :sections, only: %i[index show edit update create destroy] do
          resources :questions, only: %i[show edit new update create destroy]
        end
      end
    end

    get 'download_plans' => 'plans#download_plans'
  end

  scope '/super_admin', module: 'org_admin', as: 'super_admin' do
    resources :templates, controller: 'templates' do
      resources :customizations, only: [:create], controller: 'template_customizations'

      resources :copies, only: [:create],
                controller: 'template_copies',
                constraints: { format: [:json] }

      resources :customization_transfers, only: [:create],
                controller: 'template_customization_transfers'

      member do
        get 'history'
        get 'template_export', action: :template_export
        patch 'publish', action: :publish, constraints: { format: [:json] }
        patch 'unpublish', action: :unpublish, constraints: { format: [:json] }
      end

      collection do
        get 'organisational'
        get 'customisable'
        get 'modules'
      end

      resources :phases, except: [:index] do
        resources :versions, only: [:create], controller: 'phase_versions'

        member do
          get 'preview'
          post 'sort'
        end

        resources :sections, only: %i[index show edit update create destroy] do
          resources :questions, only: %i[show edit new update create destroy]
        end
      end
    end

    get 'download_plans' => 'plans#download_plans'
  end

  namespace :super_admin do
    resources :orgs, only: %i[index new create destroy] do
      member do
        post 'merge_analyze'
        post 'merge_commit'
      end
    end

    resources :themes, only: %i[index new create edit update destroy] do
      post 'sort', on: :collection
    end
    resources :users, only: %i[edit update] do
      member do
        put :merge
        put :archive
        get :search
      end
    end

    resources :notifications, except: [:show] do
      member do
        post 'enable', constraints: { format: [:json] }
      end
    end
    resources :static_pages

    resources :api_clients do
      member do
        get :email_credentials
        get :refresh_credentials
      end
    end
  end

  get 'research_projects/search', action: 'search',
                                  controller: 'research_projects',
                                  constraints: { format: 'json' }

  get 'research_projects/(:type)', action: 'index',
                                   controller: 'research_projects',
                                   constraints: { format: 'json' }

  get "healthz" => "rails/health#show", as: :rails_health_check

  # mount MadmpOpidor::Engine => '/madmp_opidor', as: 'madmp_opidor'
end
# rubocop:enable Metrics/BlockLength
