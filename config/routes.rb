# frozen_string_literal: true

Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  devise_for :users, skip: [:sessions, :registrations, :passwords], controllers: { omniauth_callbacks: "omniauth_callbacks" }
  devise_scope :user do
    delete 'sign_out', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  root to: 'application#landing'

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  mount BlacklightAdvancedSearch::Engine => '/'

  concern :searchable, Blacklight::Routes::Searchable.new

  get 'mirador/:oid', to: 'mirador#show'

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable
  end
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns [:exportable, :marc_viewable]
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # Custom error pages
  match '/404' => 'errors#not_found', via: :all
  # NOTE(alishaevn): Breadcrumb in case custom error pages are ever desired for the routes below
  # match '/422' => 'errors#not_found', via: :all
  # match '/500' => 'errors#internal_server_error', via: :all

  # This route needs to be the very last route in this file, because it's a wildcard and will glob everything
  get '/manifests/*id', to: 'manifests#show', as: :manifest
  get '/pdfs/not_found.html', to: 'pdfs#not_found'
  get '/pdfs/*id', to: 'pdfs#show', as: :pdf
  get '/check-iiif', to: 'iiif#show', as: :iiif
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Stop throwing 404s on missing map files. This route should be LAST
  get '/*path/*file.map', to: proc { [200, {}, ['']] }
end
