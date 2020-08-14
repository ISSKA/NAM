class UsersController < ApplicationController
  before_action :must_be_proprietary, only: %i[edit update show]

  def new
    add_breadcrumb 'new user'
    @user = User.new
  end

  def create
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
    add_breadcrumb current_logged_user.firstname, user_path(current_logged_user)
    add_breadcrumb 'delete'
  end

  def destroy
    @user = current_logged_user
    if @user.destroy && log_out
      flash[:success] = 'Account successfully deleted.'
      redirect_to root_path
    else
      flash[:danger] = 'Failed to delete your account, ' + @user.errors.full_messages.to_sentence
      redirect_to user_delete_path(@user.id)
    end
  end

  def must_be_proprietary
    @user = User.find_by(id: params[:user_id]) || User.find_by(id: params[:id])
    render_403 if @user != current_logged_user
  end

  def user_params
    params.require(:user).permit(:firstname, :lastname, :mail, :avatar, :password, :password_confirmation)
  end
end
