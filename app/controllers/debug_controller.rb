if Rails.env.development?
  class DebugController < ApplicationController
    before_filter :authorization_required

    # make the user assume the identity of another user
    def become
      @user = User.find_by_login(params[:id])
      session[:user] = @user.id
      redirect_to (params[:url] || '/')
    end

    # call the debugger so we can set breakpoints
    def break
      debugger
      redirect_to (params[:url] || '/')
    end

    protected

    def authorized?
      Rails.env.development?
    end
  end
end
