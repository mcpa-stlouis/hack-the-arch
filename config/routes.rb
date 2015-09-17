Rails.application.routes.draw do

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 								 'static_pages#home'
  get 'contact' 		=> 'static_pages#contact'
  get 'help' 				=> 'static_pages#help'
  get 'about' 			=> 'static_pages#about'
  get 'signup'			=> 'users#new'
  get 'new_problem'	=> 'problems#new'
	get	'admin'				=> 'settings#edit'
	get 'login'		  	=> 'sessions#new'

	get 'teams/get_score_data' => 'teams#get_score_data'

	post 'login' 		 			=> 'sessions#create'
	post 'request_hint' 	=> 'hint_requests#create'
	post 'submit' 				=> 'submissions#create'
	post 'create_team'		=> 'teams#create'
	post 'join'       		=> 'teams#join'
	post 'remove_member'	=> 'teams#remove_member'
	post 'add_hint'				=> 'hints#new'
	post 'edit_hint'			=> 'hints#edit'

	delete 'logout'				=> 'sessions#destroy'
	delete 'remove_hint'	=> 'problems#remove_hint'

	patch 'settings' => 'settings#update'

	resources :users
	resources :teams
	resources :problems
	resources :settings
	resources :hints
	resources :hint_requests
	resources :account_activations, only: [:edit]
	resources :password_resets,     only: [:new, :create, :edit, :update]

end
