Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 									 'static_pages#home'
  get 'contact' 			=> 'static_pages#contact'
  get 'help' 					=> 'static_pages#help'
  get 'about' 				=> 'static_pages#about'
  get 'signup'				=> 'users#new'
	get	'admin'					=> 'settings#edit'
	get 'login'		  		=> 'sessions#new'
	get 'scoreboard'		=> 'scoreboard#index'

	get 'teams/get_score_data' => 'scoreboard#get_score_data'
	get 'users/get_stats'			 => 'users#get_stats'
	get 'users/:id/checkout'	 => 'users#checkout', as: 'checkout'

	post 'login' 		 			=> 'sessions#create'
	post 'request_hint' 	=> 'hint_requests#create'
	post 'submit' 				=> 'submissions#create'
	post 'join'       		=> 'teams#join'
	post 'remove_member'	=> 'teams#remove_member'
	post 'add_hint'				=> 'hints#new'

	post 'problems/add_hint' => 'problems#add_hint'
	post 'users/:id/charge'	 => 'users#charge', as: 'charge'

	delete 'logout'					=> 'sessions#destroy'
	delete 'remove_hint'		=> 'problems#remove_hint'
	delete 'remove_bracket'	=> 'brackets#destroy'

	patch 'settings' => 'settings#update'

	resources :users
	resources :problems
	resources :teams
	resources :charges
	resources :account_activations, only: [:edit]
	resources :hints,								only: [:new, :edit, :create, :update]
	resources :password_resets,     only: [:new, :create, :edit, :update]
	resources :brackets,						only: [:new, :create, :edit, :update]

end
