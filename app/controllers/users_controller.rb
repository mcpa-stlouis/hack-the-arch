class UsersController < ApplicationController
	before_action :logged_in_user, only: [:show, :index, :destroy, :edit, :update, :get_stats]
	before_action :registration_active, only: [:new, :create]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: [:index, :destroy]
	before_action :require_payment, only: [:checkout, :charge]

	def index
		@users = User.paginate(page: params[:page])
	end

	def show
		user = User.find(params[:id])
		if user.activated? 
			if view_other_profiles? || current_user?(user) || admin_user?
				@user = user
				@score = @user.get_score
				@submissions = @user.submissions
				@number_of_correct_submissions = @submissions.where(correct: true).count
				@total_number_of_submissions = @submissions.count
				@accuracy = (@total_number_of_submissions == 0) ? 0 : @number_of_correct_submissions.to_f/@total_number_of_submissions.to_f
				@number_of_hints = @user.hint_requests.count
 			else
      	message  = "Access Denied. "
      	message += "You can only view your profile."
      	flash[:warning] = message
  			redirect_to root_url
  		end
		else
      message  = "Account not activated. "
			if current_user?(user)
      	message += "Check your email for the activation link."
			end
      flash[:warning] = message
			redirect_to root_url
		end
	end

	def get_stats
		if @user = User.find_by_id(params[:id])

			@accuracy_data = @user.get_accuracy_data
			@category_data = @user.get_category_data
			render :json => { accuracy_data: @accuracy_data.to_json.html_safe, 
												category_data: @category_data.to_json.html_safe, 
												status: :ok}
		else
      flash[:warning] = "No such user"
			redirect_to root_url
		end
	end

  def new
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save || ( @user.id && User.find(@user) && !@user.paid )
			if require_payment?
				redirect_to checkout_path(@user)
			else
				activate_user(@user)
			end
		else
			render 'new'
		end
	end

	def checkout
		if params[:id]
			@user = User.find(params[:id])
			@cost = entry_cost.to_f
			@discount = 0.00

			if !one_hundred_percent_off.blank? && @user.discount_code == one_hundred_percent_off
				activate_user(@user)
			elsif !fifty_percent_off.blank? && @user.discount_code == fifty_percent_off
				@discount = @cost / 2
			end

		else
			flash[:danger] = "You must begin registration before checking out"
			redirect_to root_url
		end
	end

	def charge
		@user = User.find(params[:user_id])
		if @user && @user.paid
			flash[:info] = "You have already paid!"
			redirect_to @user
		end

		@cost = entry_cost.to_f

		if !fifty_percent_off.blank? && @user.discount_code == fifty_percent_off
			@cost = @cost / 2
		end
		
  	customer = Stripe::Customer.create(
   		:email => params[:stripeEmail],
   		:source  => params[:stripeToken]
  	)
	
  	charge = Stripe::Charge.create(
   		:customer    => customer.id,
   		:amount      => @cost.to_i.to_s,
   		:description => "#{competition_name} registration for: #{@user.email}",
   		:currency    => 'usd'
  	)

		activate_user(@user)

		rescue Stripe::CardError => e
  		flash[:error] = e.message
  		redirect_to checkout_path(@user)

	end

	def destroy
		User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
	end

	def edit
		@edit_user_page = true
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Changes saved successfully"
			redirect_to @user
		else
			render 'edit'
		end
	end

	private
		def user_params
			params.require(:user).permit(:fname, :lname, :username, :email, :password, :password_confirmation, :discount_code)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end

		def require_payment
			unless require_payment?
				flash[:danger] = "Access denied"
				redirect_to root_url
			end
		end
		
		def correct_user
			@user = User.find(params[:id])
			unless current_user?(@user)
				flash[:danger] = "Access denied"
				redirect_to root_url
			end
		end

		def admin_user
    	unless admin_user?
				flash[:danger] = "Access denied"
				redirect_to root_url
			end
    end

		def activate_user(user)
			user.update_attributes(paid: true)
	
			if send_activation_emails?
  			user.create_activation_digest
				user.send_activation_email
    		flash[:info] = "Please check your email to activate your account."
    		redirect_to root_url
			else
				user.activate
				log_in(user)
    		flash[:success] = "Welcome to #{competition_name}!"
    		redirect_to user
			end
		end

		def registration_active
			unless registration_active?
				flash[:info] = "Registration is not open"
				redirect_to root_url
			end
		end

end
