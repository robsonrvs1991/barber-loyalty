class LoyaltyProgramsController < ApplicationController
  before_action :require_login
  before_action :require_barber

  def show
    @loyalty_program = current_user.barbershop.loyalty_program || current_user.barbershop.build_loyalty_program(required_visits: 10, reward_description: "Corte grátis")
    @loyalty_program.save if @loyalty_program.new_record?
  end

  def edit
    @loyalty_program = current_user.barbershop.loyalty_program || current_user.barbershop.build_loyalty_program(required_visits: 10, reward_description: "Corte grátis")
  end

  def update
    @loyalty_program = current_user.barbershop.loyalty_program || current_user.barbershop.build_loyalty_program
    if @loyalty_program.update(loyalty_program_params)
      redirect_to loyalty_program_path, notice: "Programa de fidelidade atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def loyalty_program_params
    params.require(:loyalty_program).permit(:required_visits, :reward_description)
  end
end
