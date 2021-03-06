class SessionsController < ApplicationController
  def new
    @user = User.new
    store_news_item_for_non_logged_in_user
    respond_to do |format|
      format.html
      format.js { render :partial => "header_form", :layout => false }
    end
  end

  def create
    self.current_user = User.authenticate(params[:email], params[:password])
    if logged_in?
      handle_remember_me
      create_current_login_cookie
      update_balance_cookie
      handle_first_donation_for_non_logged_in_user
      handle_first_pledge_for_non_logged_in_user
      redirect_back_or_default('/')
    else
      @user = User.new
      render :action => 'new'
    end
  end

  def destroy
    self.current_user.forget_me if logged_in?
    delete_cookie :auth_token
    delete_cookie :balance_text
    delete_cookie :current_user_full_name
    reset_session
    flash[:notice] = "Later. Hope to see you again soon."
    redirect_back_or_default('/')
  end

  protected

    def handle_first_donation_for_non_logged_in_user
      if session[:news_item_id] && session[:donation_amount]
        self.current_user.donations.create(:pitch_id => session[:news_item_id], :amount => session[:donation_amount])
        session[:news_item_id] = nil
        session[:donation_amount] = nil
      end
    end

    def handle_first_pledge_for_non_logged_in_user
      if session[:news_item_id] && session[:pledge_amount]
        self.current_user.pledges.create(:tip_id => session[:news_item_id], :amount => session[:pledge_amount])
        session[:news_item_id] = nil
        session[:pledge_amount] = nil
      end
    end

    def handle_remember_me
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        set_cookie("auth_token", { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at })
      end
    end

    def store_news_item_for_non_logged_in_user
      session[:news_item_id] ||= params[:news_item_id]
      session[:donation_amount] ||= params[:donation_amount]
      session[:pledge_amount] ||= params[:pledge_amount]
    end

end

