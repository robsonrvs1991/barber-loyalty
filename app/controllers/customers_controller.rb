class CustomersController < ApplicationController
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
      flash[:notice] = "Cliente cadastrado. Senha temporária: #{@temporary_password}"
      redirect_to customer_path(@customer)
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
end
