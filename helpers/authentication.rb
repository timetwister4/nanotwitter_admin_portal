require_relative '../models/user.rb'
require "byebug"

#Weren't we supposed to use Rack::Auth? I think we forgot. Fix!
def authenticate!
	 #when we solve the require relative problem write the line: unless session[:user_id] && User.where(id: session[:user_id])

		if session[:user_id] && User.where(id: session[:user_id]).exists? #if the user id saved in session does not belong to any user, also direct to general homepage
			true
		else
			session[:original_request] = request.path_info
			false
		end
end


def current_user
	current_user_id = session[:user_id]
	return nil if current_user_id.nil?
	User.find(current_user_id)
end


def login (params)

	u = nil

	# Allows for both login by username and login by email
	if params[:email]
		u = User.find_by_email(params[:email])
	elsif params[:user_name]
		u = User.find_by_user_name(params[:user_name])
	else
		return false
	end

  if u && u.password == params[:password]
	   session[:user_id] = u.id
     session[:expires_at] = Time.current + 10.minutes
     return session
  else
    return nil
  end
end

# logs current user out
def log_out_now
	session[:user_id] = nil
end

def logged_in?
	!session[:user_id].nil?
end
