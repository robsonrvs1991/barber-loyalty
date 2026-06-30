class AppointmentsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def index
    @page = params[:page].to_i
    @page = 1 if @page < 1

    @per_page = 10

    scope = current_user.barbershop
                        .appointments
                        .includes(:customer, :barber, :service)
                        .order(created_at: :desc)

    @total_appointments = scope.count
    @total_pages = (@total_appointments.to_f / @per_page).ceil

    @appointments = scope.offset((@page - 1) * @per_page).limit(@per_page)
  end

  def show
    @appointment = current_user.barbershop.appointments.find(params[:id])
  end

  def new
    @appointment = current_user.barbershop.appointments.new(paid: true, price: 0, points: 1)
    load_form_data
  end

  def create
    @appointment = current_user.barbershop.appointments.new(appointment_params)
    @appointment.barber = current_user

    selected_service = current_user.barbershop.services.find_by(id: @appointment.service_id)

    if selected_service
      @appointment.service = selected_service
      @appointment.price = selected_service.price if @appointment.price.blank?
      @appointment.points = selected_service.points if @appointment.points.blank?
    end

    if @appointment.save
      Reward.create_if_earned!(
        @appointment.customer,
        current_user.barbershop,
        service: @appointment.service
      )

      redirect_to customer_path(@appointment.customer),
                  notice: "Atendimento registrado com sucesso."
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def mark_as_paid
    @appointment = current_user.barbershop.appointments.find(params[:id])
    @appointment.update!(paid: true)

    Reward.create_if_earned!(
      @appointment.customer,
      current_user.barbershop,
      service: @appointment.service
    )

    redirect_to appointments_path, notice: "Atendimento marcado como pago."
  end

  private

  def load_form_data
    @customers = current_user.barbershop.customers.order(:name)
    @services = current_user.barbershop.services.where(active: true).order(:name)
  end

  def appointment_params
    params.require(:appointment).permit(:customer_id, :service_id, :price, :points, :paid, :notes)
  end
end