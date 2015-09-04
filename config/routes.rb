Rails.application.routes.draw do
  get 'password_resets/new'

  get 'password_resets/edit'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 						 'static_pages#home'
  get 'contact' => 'static_pages#contact'
  get 'help' 		=> 'static_pages#help'
  get 'about' 	=> 'static_pages#about'
  get 'signup'	=> 'users#new'
	get    'login'  => 'sessions#new'
	post   'login'  => 'sessions#create'
	delete 'logout' => 'sessions#destroy'
	resources :users
	resources :account_activations, only: [:edit]
	resources :password_resets,     only: [:new, :create, :edit, :update]

  get 'submissions/new'
  get 'hint_requests/new'
  get 'hints/new'
  get 'problems/new'
  get 'bracket/new'
  get 'teams/new'

end
