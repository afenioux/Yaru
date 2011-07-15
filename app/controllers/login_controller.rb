#!ruby19
#encoding: utf-8

class LoginController < ApplicationController
  #layout "main", :except => :login
  skip_before_filter :authorize
  
  # Display the login form and wait for user to
  # enter a name and password. We then validate
  # these, adding the user object to the session
  # if they authorize. 
  def login

    if request.get?
      session[:login] = nil
    else
      #let assume the password is wrong
      session[:login] = nil

      if AUTH_METHOD == 'LDAP'
        #we connect to the Ldap server as anonymous
        ldap = Net::LDAP.new( :host=> LDAP_HOST , :port=> LDAP_PORT ,
            :base => LDAP_BASE )
        username = "" #useful when wrong user
        #and query for uid=login, that give us full dn
        filter = Net::LDAP::Filter.eq('uid', params[:login])
          ldap.search(:filter => filter) {|entry|
            username = entry.dn
          }
        #trying to bind with username and give password
        if ldap.bind( :method=>:simple, :username=> username , :password=> params[:pass])
          #ok good boy
          session[:login] = params[:login]
        end

      elsif AUTH_METHOD == 'HTAUTH'
        IO.foreach(HTAUTH_FILE) { |line|
          line.chop!
          (login,password) = line.split(':')
          if login == params[:login]
            if password == params[:pass].crypt(password[0,2])
              session[:login] = params[:login]
              break
            end
          end
        }

      elsif AUTH_METHOD == 'PLAIN'
        IO.foreach(PLAIN_FILE) { |line|
          line.chop!
          (login,password) = line.split(':')
          if login == params[:login]
            if password == params[:pass]
              session[:login] = params[:login]
              break
            end
          end
        }

      end
    end

    if session[:login]
      #we know who you are, go uploading!
      redirect_to(:controller => "upload", :action => "new")
    elsif request.post?
      flash[:notice] = t(:invalid_credentials)
    end
  end

  # Log out by clearing the user entry in the session. We then
  # redirect to the login action.
  def logout
    session.clear
    session[:login] = nil
    flash[:notice] = t(:logged_out)
    redirect_to(:action => "login")
  end

  #triggered by application controller, guess locale language form Browser language if not set
 def set_locale
   if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
     I18n.locale = params[:locale]
   else
    logger.debug "* Accept-Language: #{request.env['HTTP_ACCEPT_LANGUAGE']}"
    I18n.locale = extract_locale_from_accept_language_header
    logger.debug "* Locale set to '#{I18n.locale}'"
   end
 end
 
private
 def extract_locale_from_accept_language_header
  request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first
 end

end
