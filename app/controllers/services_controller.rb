class ServicesController < ApplicationController
  before_action :require_login
  before_action :require_barber
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def index
    @page = params[:page].to_i
    @page = 1 if @page < 1

    @per_page = 10

    services_scope = current_user.barbershop.services
                                 .order(active: :desc, name: :asc)

    @total_services = services_scope.count
    @active_services_count = services_scope.where(active: true).count
    @inactive_services_count = services_scope.where(active: false).count

    @total_pages = (@total_services.to_f / @per_page).ceil
    @total_pages = 1 if @total_pages < 1

    @page = @total_pages if @page > @total_pages

    @services = services_scope
                .offset((@page - 1) * @per_page)
                .limit(@per_page)
  end

  def show; end

  def new
    @service = current_user.barbershop.services.new(active: true, points: 1, price: 0)
  end

  def create
    @service = current_user.barbershop.services.new(service_params)

    if @service.save
      redirect_to services_path, notice: "Item/serviço cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @service.update(service_params)
      redirect_to services_path, notice: "Item/serviço atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.destroy
    redirect_to services_path, notice: "Item/serviço removido com sucesso."
  end

  private

  def set_service
    @service = current_user.barbershop.services.find(params[:id])
  end

  def service_params
    params.require(:service).permit(:name, :price, :active, :points)
  end
end