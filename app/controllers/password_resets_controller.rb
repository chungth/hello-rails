class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t('message.account.reset_password_sent')
      redirect_to root_url
    else
      flash.now[:danger] = t('message.account.email_not_found')
      render 'new'
    end
  end

  def edit
  end
  
  def update
    if @user.password_reset_expired?
      flash[:danger] = t('message.account.reset_password_expired')
      redirect_to new_password_reset_url
    elsif @user.update_attributes(user_params)
      if (params[:user][:password].blank? &&
          params[:user][:password_confirmation].blank?)
        flash.now[:danger] = t('message.account.password_blank')
        render 'edit'
      else
        flash[:success] = t('message.account.password_reset_success')
        log_in @user
        redirect_to @user
      end
    else
      render 'edit'
    end
  end
  
  private 
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    def get_user
      @user = User.find_by(email: params[:email])
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
end