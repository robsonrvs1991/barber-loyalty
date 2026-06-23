class BarbershopsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def show
    @barbershop = current_user.barbershop
  end

  def edit
    @barbershop = current_user.barbershop
  end

  def update
    @barbershop = current_user.barbershop
    if @barbershop.update(barbershop_params)
      redirect_to barbershop_path, notice: "Barbearia atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def barbershop_params
    params.require(:barbershop).permit(:name, :phone, :address)
  end
end
