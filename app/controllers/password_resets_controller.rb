class PasswordResetsController < ApplicationController
  # before_action :require_login, only: [:show, :edit, :update, :destroy]
  before_action :require_login
  before_action :check_app_auth, except: [:index]

  def new

  end

  def create
    @user = User.find_by_email(params[:email])

    # This line sends an email to the user with instructions on how to reset their password (a url with a random token)
    if @user
      @user.generate_reset_password_token!
      redirect_to(edit_password_reset_path(@user.reset_password_token))
    else
      flash[:danger] = 'Такого пользователя не существует!'
      render action: 'new'
      # redirect_to(new_password_reset_path, :notice => 'Такого пользователя не существует!')
    end
    # Tell the user instructions have been sent whether or not email was found.
    # This is to not leak information to attackers about which emails exist in the system.


    # redirect_to(root_path, :notice => 'Инструкции по смене пароля отправлены на Вашу электронную почту.')

  end

  def edit
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end
  end

  def update
    @token = params[:id]
    @user = User.load_from_reset_password_token(params[:id])

    if @user.blank?
      not_authenticated
      return
    end

    # the next line makes the password confirmation validation work
    @user.password_confirmation = params[:user][:password_confirmation]
    # the next line clears the temporary token and updates the password
    if @user.change_password!(params[:user][:password])
      redirect_to(root_path, :notice => 'Пароль успешно изменён.')
    else
      render :action => "edit"
    end
  end
end
