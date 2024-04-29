# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organizations do
    scope module: 'organizations' do
      resources :projects
      resources :logs, only: %i[index]
    end
  end

  resources :projects, only: [], shallow: true do
    scope module: 'projects' do
      resources :integrations
    end
  end

  resources :integrations, only: [], shallow: true do
    scope module: 'integrations' do
      resources :confirmations, only: %i[create]
    end
  end

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      namespace :webhooks do
        resources :logs, only: %i[create]
      end
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'organizations#index'
end
