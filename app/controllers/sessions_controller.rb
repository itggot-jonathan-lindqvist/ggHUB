# frozen_string_literal: true

# Used to valited the session cookies
class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      if user.activated?
        log_in user
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        redirect_back_or root_url
      else
        message  = 'Account not activated. '
        message += 'Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  # TODO: Figure what '?' does. https://www.railstutorial.org/book/advanced_login#code-branch_raise
  # def create
  #   ?user = User.find_by(email: params[:session][:email].downcase)
  #   if ?user && ?user.authenticate(params[:session][:password])
  #     log_in ?user
  #     params[:session][:remember_me] == '1' ? remember(?user) : forget(?user)
  #     redirect_to ?user
  #   else
  #     flash.now[:danger] = 'Invalid email/password combination'
  #     render 'new'
  #   end
  # end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
