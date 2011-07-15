class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale, :except => :switch_lang

  def set_locale
    # if params[:locale] is not supported then I18n.default_locale will be used
    if params[:locale] && I18n.available_locales.include?(params[:locale].to_sym)
      I18n.locale = params[:locale]
    else
      I18n.locale = I18n.default_locale
    end
  end

  def switch_lang
    url = request.env["HTTP_REFERER"].sub(/\?locale=?\w*/, "?locale=#{params[:lang]}")
    if ( I18n.available_locales.include?(params[:lang].to_sym) &&
      url != request.env["HTTP_REFERER"])
      redirect_to url
    else
      redirect_to :back
    end
  end

  def authorize
        unless (session[:login])
          redirect_to(:controller => "/login", :action => "login")
          return false
        end
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    #{ :locale => I18n.locale }
    options.merge({ :locale => I18n.locale })
end

end
