class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      flash[:success] = t('message.account.activated')
      log_in user
      redirect_to user
    else
      flash[:danger] = t('message.account.invalid_activation_link')
      redirect_to root_url
    end
  end
end
