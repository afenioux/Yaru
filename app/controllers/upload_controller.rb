class UploadController < ApplicationController
protect_from_forgery :except => 'upload'
before_filter :authorize, :except => [:upload, :download]
before_filter :get_destination, :only => [:upload, :upload_file, :index]

  @@root_destination = "public/data/"
  @@secret_key = "s3cr3t"
  @@salt = "salt"

  #upload action is used with Flash uploader
  def upload
    #create a destination directory
    FileUtils.mkdir_p(@destination) unless File.exist?(@destination)
    #and put the file in the destionation (one by one)
    FileUtils.mv params[:file].path,
      @destination + params[:Filename].sub(/[^\w\.\-]/,'_')
    return render :nothing => true
  end


  #uploadFile action is used with the basic http uploader
  def upload_file
    unless params[:upload].nil?
      #create a destination directory
      FileUtils.mkdir_p(@destination) unless File.exist?(@destination)
      name =  params[:upload]['datafile'].original_filename.sub(/[^\w\.\-]/,'_')
      # create the file path
      path = File.join(@destination, name)
      # write the file
      File.open(path, "wb") { |f| f.write(params[:upload]['datafile'].read) }
      respond_to do |format|
        format.html { redirect_to({:action => 'index'}, :notice => t(:upload_ok)) }
      end
    else
      #The user didn't specified a file to upload
      respond_to do |format|
        format.html { redirect_to({:action => 'new'}, :notice => t(:choose_file)) }
      end
    end
  end

  #index action makes a list of files uploaded
  def index
    @load_js2 = true
    @files = Array.new
    directory = ""
    #we look into the directories and make an Array of the files
    Dir[@destination.gsub( /[\w-]+\/$/, '' ) + '**/*'].each { |file|
      if File.directory?(file)
        directory = File.basename(file)+'/'
        filename = directory
      else
        filename = directory+File.basename(file)
      end
      @files.push(filename)
    }
    respond_to do |format|
      flash[:notice] = t(:upload_ok) if params[:notice] == "ok"
      format.html 
    end
  end

  #the new action, show the form to upload a file
  def new
    #little evil hack
    flash[:notice] = nil if request.env["HTTP_REFERER"] =~ /notice=ok/
    #we need the fancyupload javascript
    @load_js = true
    #because of the Flash uploader, session variables are not sent during XHR
    #so we encrypt the login
    @login = "#{@@salt}$#{session[:login]}".encrypt(:symmetric, :password => @@secret_key).chomp
    #and put the locale for redirection
    @locale = params[:locale]
    #render(:layout => nil)
  end

  #the delete action is used if there is a link to delete a specified file
  #not used anymore
  def delete
    file = @@root_destination + session[:login] + '/' + params[:file]
    if File.exist?(file)
      begin
        File.delete(file)
      rescue => detail
        print detail.backtrace.join("\n")
      end
      respond_to do |format|
        format.html { redirect_to({:action => 'index'},
            :notice => "#{file} was successfully deleted.") }
      end
    else
      respond_to do |format|
        format.html { redirect_to({:action => 'index'},
            :notice => "#{file} does not exist.") }
      end
    end
  end

  #the update action is used to delete multiples files at once
  def update
    params.each {|file|
    if file[1] == "delete_me" and  File.exist?(@@root_destination + session[:login] + '/'+ file[0])
      filename = @@root_destination + session[:login] + '/' + file[0]
      if File.file?(filename)
        File.delete(filename)
      else
        FileUtils.remove_dir(filename)
      end
    end
    }
    respond_to do |format|
      format.html { redirect_to({:action => "index"}, :notice => t(:deletion_ok)) }
    end
  end

  #this action is used to download a file,
  #this version does not scale well
  #look at http://www.therailsway.com/2009/2/22/file-downloads-done-right
  #if you want people to be logged before downloading anything change the before_filter
  def download
    file = @@root_destination + params[:file]
    #small jail...
    file.gsub!('../', '')
    if File.exist?(file)
      send_file file
    else
      respond_to do |format|
        if session[:login]
          format.html { redirect_to({:action => 'index'}, :notice => t(:file_not_existing)) }
        else
          format.html { redirect_to({:controller => :login, :action => 'login'}, :notice => t(:file_not_existing)) }
        end
      end
    end
  end

private
    #is used to get the path to write files
    def get_destination
      if session[:login]
        @login = session[:login]
      else
        @login = params[:login].decrypt(:symmetric, :password => @@secret_key)
        #redirected if we didn't find our salt : somebody tweaked his hidden fields
        redirect_to({:action => "new"}, :notice => 'who are you?') unless @login.gsub!(@@salt+'$', '')
      end
      date = Time.now.strftime("%d-%m-%Y") 
      @destination = @@root_destination + @login + '/' + date + '/'
    end
end
