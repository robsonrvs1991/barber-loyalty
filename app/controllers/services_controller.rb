class ServicesController < ApplicationController
  before_action :require_login
  before_action :require_barber
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def index
    @services = current_user.barbershop.services.order(:name)
  end

  def show; end

  def new
    @service = current_user.barbershop.services.new(active: true, points: 1)
  end

  def create
    @service = current_user.barbershop.services.new(service_params)
    if @service.save
      redirect_to services_path, notice: "Serviço cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "Serviço atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, notice: "Serviço removido com sucesso."
  end

  private

  def set_service
    @service = current_user.barbershop.services.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :active, :points)
  end
end
