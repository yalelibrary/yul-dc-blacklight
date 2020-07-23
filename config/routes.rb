# frozen_string_literal: true

Rails.application.routes.draw do
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :marc_viewable, Blacklight::Marc::Routes::MarcViewable.new
  devise_for :users, skip: [:sessions, :registrations, :passwords], controllers: { omniauth_callbacks: "omniauth_callbacks" }
  get '/auth/:provider/callback', to: 'sessions#create', as: :new_user_session
  devise_scope :user do
    # get 'sign_in', to:  "auth/cas#callback", as: :new_user_session
    post 'sign_in', :to => 'omniauth_callbacks#cas', as: :session#, :as => :user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
    get 'users/edit' => 'devise/registrations#edit', :as => :edit_user_registration
    put 'users' => 'devise/registrations#update', :as => :user_registration
  end

  mount Blacklight::Engine => '/'
  root to: "catalog#index"
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
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
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
