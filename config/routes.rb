# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  root 'game#index'
  get '/restart', to: 'game#restart'
  get '/index', to: 'game#index'
  get '/try-move', to: 'game#tryv_move'
  get '/edit-prompt', to: 'game#edit_prompt'
  get '/clear-try-move', to: 'game#clear_tryv_move'
  get '/back-try-move', to: 'game#back_tryv_move'
  get '/draw-card', to: 'game#draw_card'
  get '/skip', to: 'game#skip'
  get '/scoreboard', to: 'game#scoreboard'
  get '/give-up', to: 'game#give_up'

  get '/execute', to: 'game#execute'

  get '/cheat-cmd', to: 'game#cmd'
  get '/helper-cmd', to: 'game#cmd'
end
