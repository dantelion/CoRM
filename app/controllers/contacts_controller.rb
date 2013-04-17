# encoding: utf-8

##
# This class manage Contacts and render all pages necessary for CRUD and for add/remove tags
# 
class ContactsController < ApplicationController
  
  ##
  # Show the full list of Contact by paginate_by
  #
  # GET /contacts
  # GET /contacts.json
  def index
    @contacts = Contact.order("surname").page(params[:page])
    
    #infos typeahead
    @autocomplete_accounts = Account.find(:all,:select=>'company').map(&:company)
    @autocomplete_contacts = Contact.find(:all,:select=>'surname').map(&:surname)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @contacts }
    end
  end

  ##
  # Show one occurence of Contact
  #
  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @contact = Contact.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @contact }
    end
  end

  ##
  # Show the form to create a new Contact
  #
  # GET /contacts/new
  # GET /contacts/new.json
  def new
    if @ability.can? :create, Contact
      @contact = Contact.new

      respond_to do |format|
        format.html # new.html.erb
        format.json { render :json => @contact }
      end
    else
      flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.new')).gsub('[undefined_article]', t('app.default.undefine_article_male')).gsub('[model]', t('app.controllers.Contact'))
      redirect_to contacts_url
      return false
    end
  end

  ##
  # Show the filled form with the Contact you want to modify
  #
  # GET /contacts/1/edit
  def edit
    if @ability.can? :update, Contact
      @contact = Contact.find(params[:id])
    else
      flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.edit')).gsub('[undefined_article]', t('app.default.undefine_article_male')).gsub('[model]', t('app.controllers.Contact'))
      redirect_to contacts_url
      return false
    end
  end

  ##
  # Create action for a Contact
  #
  # POST /contacts
  # POST /contacts.json
  def create
    if @ability.can? :create, Contact
      @contact = Contact.new(params[:contact])
      @contact.created_by = current_user.id
  
      # Manage the has_and_belongs relation between Accounts and Tags
      # if there is no one associate tag, we delete links
      if params[:display_contact_produit].nil?
        @contact.tags.clear
      else
        tag = Tag.find(params[:display_contact_tag])
        @contact.tags.clear
        @contact.tags << tag
      end
          
      respond_to do |format|
        if @contact.save
          format.html {
            if  (@contact.account).nil?  then redirect_to contacts_path, :notice => 'Le contact a été créé.'
            else redirect_to account_events_url(@contact.account_id), :notice => 'Le contact a été créé.'
            end
          }
          format.json { render :json => @contact, :status => :created, :location => @contact }
        else
          flash[:error] = t('app.save_undefined_error')
          format.html { render :action => "new" }
          format.json { render :json => @contact.errors, :status => :unprocessable_entity }
        end
      end
    else
      flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.create')).gsub('[undefined_article]', t('app.default.undefine_article_male')).gsub('[model]', t('app.controllers.Contact'))
      redirect_to contacts_url
      return false
    end
  end

  ##
  # Save a Contact which already exists
  #
  # PUT /contacts/1
  # PUT /contacts/1.json
  def update
    if @ability.can? :update, Contact
      @contact = Contact.find(params[:id])
      @contact.modified_by = current_user.id
      
      # same treatment as #create
      if params[:display_contact_tag].nil?
        @contact.tags.clear
      else
        tag = Tag.find(params[:display_contact_tag])
        @contact.tags.clear
        @contact.tags << tag
      end
      respond_to do |format|
        if @contact.update_attributes(params[:contact])
          format.html {
            if  (@contact.account).nil?  then redirect_to contacts_path, :notice => 'Le contact a été mis à jour.'
            else redirect_to account_events_url(@contact.account_id), :notice => 'Le contact a été mis à jour.'
            end }
          format.json { head :no_content }
        else
          flash[:error] = t('app.save_undefined_error')
          format.html { render :action => "edit" }
          format.json { render :json => @contact.errors, :status => :unprocessable_entity }
        end
      end
    else
      flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.update')).gsub('[undefined_article]', t('app.default.undefine_article_male')).gsub('[model]', t('app.controllers.Contact'))
      redirect_to contacts_url
      return false
    end
  end

  ##
  # Remove a Contact from the DataBase
  #
  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    if @ability.can? :destroy, Contact
      @contact = Contact.find(params[:id])
      @contact.destroy
  
      respond_to do |format|
        format.html { redirect_to contacts_url }
        format.json { head :no_content }
      end
    else
      flash[:error] = t('app.cancan.messages.unauthorized').gsub('[action]', t('app.actions.destroy')).gsub('[undefined_article]', t('app.default.undefine_article_male')).gsub('[model]', t('app.controllers.Contact'))
      redirect_to contacts_url
      return false
    end
  end
  
  ##
  # Filter Contact on the index page
  #
  def filter

    #infos typeahead
    @autocomplete_accounts = Account.find(:all,:select=>'company').map(&:company)
    @autocomplete_contacts = Contact.find(:all,:select=>'surname').map(&:surname)

    # filter data
    company = params[:filter][:company]
    surname = params[:filter][:surname]
    tel = params[:filter][:tel]
    # sort contacts with filter values
    @contacts = Contact.by_company(company).by_surname(surname).by_tel(tel)
    @contacts = @contacts.order("surname ASC").page(params[:page])
    
    respond_to do |format|
      format.html  { render :action => "index" }
      format.json { render :json => @contacts }
    end
  end
  
  
  
end
