class UsersController < ApplicationController
  before_action :must_be_proprietary, only: %i[edit update show]
  before_action :admin_user, :only => :destroy
  
  add_breadcrumb 'utilisateurs'

  def index
    @titre = "Tous les utilisateurs"
    @users = User.all
		@sort = params[:sort]
		if @sort == nil
			@users = User.all.order('created_at desc')
		else
			if @sort == 'prenom'
				@users = User.all.order('firstname desc')
			elsif @sort == 'nom'
				@users = User.all.order('lastname desc')
			elsif @sort == 'admin'
				@users = User.all.order('admin desc')
			else
				@users = User.all.order('created_at desc')
			end
		end
  end
  
  def new
    add_breadcrumb 'new user'
    @user = User.new
  end

  def create
		puts "user = #{@user}"
    @user = User.new(user_params)
    @user.gen_token_and_salt
    if @user.save
      log_in_session(@user)
      redirect_to user_path(@user.id)
    else
      flash.now[:danger] = 'Failed to create ' + @user.firstname + ', ' + @user.errors.full_messages.to_sentence + '.'
      render 'new'
    end
  end

  def show
    add_breadcrumb current_logged_user.firstname
  end

  def edit
    add_breadcrumb current_logged_user.firstname, user_path(current_logged_user)
    add_breadcrumb 'edit'
  end

  def update
    if user_params.key?(:password) && user_params.key?(:password_confirmation)
      @user.password = user_params['password']
      @user.password_confirmation = user_params['password_confirmation']
      if @user.password == @user.password_confirmation 
        @user.gen_token_and_salt
        @user.change_password(@user.password)
      end
    end

    if @user.update(user_params.except(:password, :password_confirmation))
      flash[:success] = 'Profil successfully updated.'
      redirect_to user_path(@user.id)
    else
      flash[:danger] = 'Failed to update ' + @user.firstname + ', ' + @user.errors.full_messages.to_sentence + '.'
      redirect_to edit_user_path(@user.id)
    end
  end

  def delete
	@user = User.find_by(id: params[:id])
    #add_breadcrumb current_logged_user.firstname, user_path(current_logged_user)
	add_breadcrumb @user.firstname, user_path(@user)
    add_breadcrumb 'delete'
  end

  def destroy
    #@user = current_logged_user
	@user = User.find_by(id: params[:id])
    if @user.destroy
	  if @user == current_logged_user
	    log_out
	  end
      flash[:success] = 'Account successfully deleted.'
      redirect_to root_path
    else
      flash[:danger] = 'Failed to delete your account, ' + @user.errors.full_messages.to_sentence
      redirect_to user_delete_path(@user.id)
    end
  end
  
  def set_admin
    @user = User.find_by(id: params[:user_id])
	if @user.update_attribute(:admin, true)
      flash[:success] = 'Action successfully executed.'
    else
      flash[:danger] = 'Action failed.'
    end
	redirect_to users_path
  end
  
  def remove_admin
    @user = User.find_by(id: params[:user_id])
	if @user.update_attribute(:admin, false)
      flash[:success] = 'Action successfully executed.'
    else
      flash[:danger] = 'Action failed.'
    end
	redirect_to users_path
  end

  def must_be_proprietary
    @user = User.find_by(id: params[:user_id]) || User.find_by(id: params[:id])
    render_403 if @user != current_logged_user
  end
  
  def admin_user
    redirect_to(root_path) unless current_logged_user.admin?
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :mail, :avatar, :password, :password_confirmation, :admin)
  end
end
