class CustomersController < ApplicationController
  before_action :require_login
  before_action :require_barber
  before_action :require_active_subscription
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @customers = current_barbershop.users.where(role: "customer").order(:name)
  end

  def show
    @appointments = Appointment.where(customer_id: @customer.id).order(created_at: :desc)
    @rewards = Reward.where(customer_id: @customer.id).order(created_at: :desc)
  end

  def new
    @customer = current_barbershop.users.new(role: "customer")
  end

  def create
    @customer = current_barbershop.users.new(customer_params)
    @customer.role = "customer"
    @temporary_password = SecureRandom.alphanumeric(8)
    @customer.password = @temporary_password
    @customer.email = @customer.email.to_s.downcase

    if @customer.save
      send_customer_access_email
      redirect_to customer_path(@customer), notice: "Cliente cadastrado. Enviamos o acesso por e-mail."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    attrs = customer_params
    attrs[:email] = attrs[:email].to_s.downcase if attrs[:email].present?

    if @customer.update(attrs)
      redirect_to customer_path(@customer), notice: "Cliente atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @customer.destroy
    redirect_to customers_path, notice: "Cliente removido."
  end

  private

  def set_customer
    @customer = current_barbershop.users.where(role: "customer").find(params[:id])
  end

  def customer_params
    params.require(:user).permit(:name, :email, :phone)
  end

  def send_customer_access_email
    CustomerMailer.with(
      customer: @customer,
      temporary_password: @temporary_password,
      company: current_barbershop,
      login_url: "#{request.base_url}/cliente/login"
    ).welcome_email.deliver_now
  rescue StandardError => e
    Rails.logger.error("[CustomerMailer] Falha ao enviar acesso: #{e.class} - #{e.message}")
    flash[:alert] = "Cliente cadastrado, mas não foi possível enviar o e-mail. Senha temporária: #{@temporary_password}"
  end
end
