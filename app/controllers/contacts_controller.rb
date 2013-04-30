class ContactsController < ApplicationController
  before_filter [:authenticate_user!, :site_owner?],  only: [:new, :create, :edit, :update, :destroy]
  before_filter :get_site
  before_filter :correct_contact,       only: [:show, :update, :edit, :destroy]

  def new
    @contact = Contact.new
  end
  
  def create
    begin
      contact = @sport.contacts.create!(params[:contact])
      redirect_to [@sport, contact], notice: "Contact created!"
    rescue Exception => e
        redirect_to :back, alert: e.message
    end
  end
  
  def show
    respond_to do |format|
      format.html
      format.json
    end
  end
  
  def edit
  end
  
  def update
    contact = @sport.contacts.find(params[:id])
    if contact.update_attributes(params[:contact])      
      redirect_to [@sport,contact], notice: "Contact updated!"
    else
      redirect_to :back, alert: "Error updating contact"
    end
  end
  
  def destroy
    if @sport.contacts.find(params[:id]).destroy
      flash[:notice] = "Contact deleted!"
    else
      flash[:error] = "Error deleting contact"
    end
    redirect_to site_contacts_path
  end
  
  def index
    @contacts = []
    @sport.contacts.each_with_index do |c, cnt|
      @contacts[cnt] = c
    end

    respond_to do |format|
      format.html
      format.json
    end
  end

  private

    def correct_contact
      @contact = Contact.find(params[:id])
    end
    
    def get_site
      @sport = Sport.find(params[:sport_id])
    end

end
