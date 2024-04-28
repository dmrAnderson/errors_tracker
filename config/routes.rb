# frozen_string_literal: true

Rails.application.routes.draw do
  resources :organizations do
    scope module: 'organizations' do
      resources :projects
    end
  end

  resources :projects, only: [], shallow: true do
    scope module: 'projects' do
      resources :integrations
    end
  end

  resources :integrations, only: [], shallow: true do
    scope module: 'integrations' do
      resources :confirmations, only: %i[create update]
    end
  end

  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'organizations#index'
end
OpenSSL::PKey::EC.new('secp256k1')