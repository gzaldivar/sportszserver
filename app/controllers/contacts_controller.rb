class ContactsController < ApplicationController
  before_filter :authenticate_user!,   only: [:new, :create, :edit, :update, :destroy]
  before_filter :site_owner?,           only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_site
  before_filter :correct_contact,       only: [:show, :update, :edit, :destroy]

  def new
    @contact = Contact.new
  end
  
  def create
    if @contact = @site.contacts.create!(params[:contact])
      redirect_to [@site, @contact], notice: "Contact created!"
    else
      redirect_to :back, error: e.message
    end
  end
  
  def show
  end
  
  def edit
  end
  
  def update
    contact = @site.contacts.find(params[:id])
    if contact.update_attributes(params[:contact])      
      redirect_to [@site,contact], notice: "Contact updated!"
    else
      redirect_to :back, error: "Error updating contact"
    end
  end
  
  def destroy
    if @site.contacts.find(params[:id]).destroy
      flash[:notice] = "Contact deleted!"
    else
      flash[:error] = "Error deleting contact"
    end
    redirect_to site_contacts_path
  end
  
  def index
    @contacts = []
    @site.contacts.each_with_index do |c, cnt|
      @contacts[cnt] = c
    end
  end

  private

    def correct_contact
      @contact = Contact.find(params[:id])
    end
    
    def get_site
      @site = Site.find(params[:site_id])
    end

end
