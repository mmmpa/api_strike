Rails.application.routes.draw do
  get '', to: 'strike#show', as: :root
  post '', to: 'strike#strike'
end
