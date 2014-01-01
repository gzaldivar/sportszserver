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
      respond_to do |format|
        format.html { redirect_to [@sport, contact], notice: "Contact created!" }
        format.json { render json: { contact: contact, request: [@sport, @contact] } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to :back, alert: e.message }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
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
      respond_to do |format|
        format.html { redirect_to [@sport, contact], notice: "Contact updated!" }
        format.json { render json: { contact: contact, request: [@sport, @contact] } }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back, alert: "Error updating contact: " + e.message }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def destroy
    begin
      @sport.contacts.find(params[:id]).destroy
      respond_to do |format|
        format.html { redirect_to site_contacts_path, notice: "Contact deleted" }
        format.json { render json: { success: "success", request: @sport } }
      end
    rescue Exception => e
      respond_to do |format|
        format.html { redirect_to site_contacts_path, alert: "Error deleting contact: " + e.message }
        format.json { render status: 404, json: { error: e.message, request: @sport } }
      end
    end
  end
  
  def index
    @contacts = @sport.contacts

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
