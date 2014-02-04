# encoding: utf-8

class SettingsController < ApplicationController

    def index
       if current_user.has_role?(:admin)
            @settings = Setting.all
		
	    # On récupère les paramètres du serveur mail
	    #@webmail_connections = WebmailConnection.all
			@webmail_connection = WebmailConnection.first
       else
            flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.do')).gsub('[undefined_article]', t('app.default.undefine_article_female')).gsub('[model]', t('app.controllers.Settings'))
			redirect_to root_url
			return false
       end
    end
    
    def update_attribute
        if current_user.has_role?(:admin)
            setting = Setting.get(params[:setting][:key])
            @response = { :error => false, :errcode => nil, :errMessage => nil, :saved => true }
            if (params[:setting][:type] == 'file') 
                file_data = params[:setting][:file]
                if (!save_uploaded_file(file_data, setting)) 
                    @response[:saved] = false
                    @response[:error] = true
                    @response[:errMessage] = "Le fichier uploadÃ© ne contient rien."
                end
            elsif (params[:setting][:type] == 'text')
                setting.update_attribute(:value, params[:setting][:value])
            elsif (params[:setting][:type] == 'boolean')
                setting.update_attribute(:value, (!params[:setting][:value].nil?))
            end
            
            render :json => @response
        else
            @response = { :error => true, :errcode => 403, :errMessage => 'Forbidden', :saved => false }
            render :json => @response
        end
    end
    
    def create_key
        if current_user.has_role?(:admin)
            @response = { :error => false, errcode => nil, errMessage => nil, saved => true }
            render :json => @response
        else
            @response = { :error => true, errcode => 403, errMessage => 'Forbidden', saved => false }
            render :json => @response
        end
    end
    
    def delete_old_uploaded_file(pathname)
        if (!pathname.blank?)
            path = Rails.root.join('public', pathname)
            if (File.exist?(path))
                File.delete(path)
            end
        end
    end
    
    def save_uploaded_file(file_data, setting)
        if (!file_data.nil?)
            original_name = file_data.original_filename
            if (!file_data.nil?)
            pathArray = [
                'public',
                'system',
                'settings',
                setting.key
            ]
            path = Rails.root
            pathArray.each do |dir|
                path = path.join(dir)
                if (!path.exist?)
                    path.mkdir
                end
            end
            logger.log(0, "SAVE FILE: #{original_name} to #{path.to_s}")
            
            path = path.join(original_name)
            
            pathArray[0] = ''
            relative_path = pathArray.join('/').concat("/#{original_name}")
            
            delete_old_uploaded_file(setting.value)
            File.open(path, "wb") { |f| 
                f.write(file_data.read) 
            }
            setting.set(relative_path.to_s)
            end
        else
            setting.set('')
            return false
        end
        
    end

end

