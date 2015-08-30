Rails.application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

  get 'static_pages/home'
  get 'static_pages/contact'
  get 'static_pages/help'

  get 'submissions/new'
  get 'hint_requests/new'
  get 'hints/new'
  get 'problems/new'
  get 'bracket/new'
  get 'teams/new'
  get 'users/new'

end
