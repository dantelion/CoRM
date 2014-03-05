# encoding: utf-8

class EmailsController < ApplicationController

  ##
  # Render the page to edit one email
  #
  def edit
		@email = Email.find(params[:id])
  end

  def index
		@emails = Email.where("user_id = ?", current_user.id).order("id")
		@accounts = Account.all
  end

  def destroy
		@email = Email.find_by_id(params[:id])
		@email.destroy
		redirect_to notifications_url, :notice => "L'email a été supprimé."
  end

  def update
		@email = Email.find(params[:email][:id])
		if @email.update_attributes(params[:email])
			redirect_to notifications_url, :notice => "L'email a été modifié."
		else
			redirect_to notifications_url
		end
  end

  def convert
        # Récupération de l'email
		@email = Email.find(params[:email])
		@email.convert
		redirect_to notifications_url, :notice => "L'email a été traité avec succès."
  end
	
end
