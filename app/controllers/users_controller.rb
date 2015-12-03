class UsersController < ApplicationController
	before_action :logged_in_user, only: [:show, :index, :destroy, :edit, :update, :get_stats]
	before_action :correct_user, only: [:edit, :update]
	before_action :admin_user, only: [:index, :destroy]

	def index
		@users = User.paginate(page: params[:page])
	end

	def show
		user = User.find(params[:id])
		if user.activated? 
# Uncomment if users can only view their own profiles
#			if current_user?(user)
				@user = user
				@score = @user.get_score
				@submissions = @user.submissions
				@number_of_correct_submissions = @submissions.where(correct: true).count
				@total_number_of_submissions = @submissions.count
				@accuracy = (@total_number_of_submissions == 0) ? 0 : @number_of_correct_submissions.to_f/@total_number_of_submissions.to_f
				@number_of_hints = @user.hint_requests.count
#			else
#     	message  = "Access Denied. "
#     	message += "You can only view your profile."
#     	flash[:warning] = message
# 			redirect_to root_url
# 		end
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
		if @user = User.find(params[:id])

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
		@new_user_page = require_payment?
		@amount = entry_cost
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save || ( @user.id && User.find(@user) && !@user.paid )

			if require_payment?
  			customer = Stripe::Customer.create(
    			:email => params[:stripeEmail],
    			:source  => params[:stripeToken]
  			)

  			charge = Stripe::Charge.create(
    			:customer    => customer.id,
    			:amount      => entry_cost,
    			:description => 'Rails Stripe customer',
    			:currency    => 'usd'
  			)
			end
	
			@user.update_attributes(paid: true)

			if send_activation_emails?
				@user.send_activation_email
      	flash[:info] = "Please check your email to activate your account."
      	redirect_to root_url
			else
				@user.activate
				log_in(@user)
      	flash[:success] = "Welcome to #{competition_name}!"
      	redirect_to @user
			end
		else
  		flash[:info] = "Payment not processed"
			render 'new'
		end

		rescue Stripe::CardError => e
  		flash[:error] = e.message
  		render 'new'

	end

	def destroy
		User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
	end

	def edit
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
			params.require(:user).permit(:fname, :lname, :email, :password, :password_confirmation)
		end

		def logged_in_user
			unless logged_in?
				store_location
				flash[:danger] = "Please log in."
				redirect_to login_url
			end
		end
		
		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end

		def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
