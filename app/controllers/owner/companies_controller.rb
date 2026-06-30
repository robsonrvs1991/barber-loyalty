module Owner
  class CompaniesController < BaseController
    before_action :set_company, only: [:show, :edit, :update, :destroy, :reset_owner_password]

    def index
      @query = params[:q].to_s.strip

      @companies = Company.includes(:subscription, :users).order(created_at: :desc)

      if @query.present?
        @companies = @companies.where(
          "name ILIKE :q OR legal_name ILIKE :q OR email ILIKE :q OR whatsapp ILIKE :q",
          q: "%#{@query}%"
        )
      end
    end

    def show
      @owner_user = @company.owner_user
      @subscription = @company.subscription
      @loyalty_programs = @company.loyalty_programs.includes(:service).order(active: :desc, created_at: :desc)

      @customers_count = @company.users.where(role: "customer").count
      @services_count = @company.services.count
      @appointments_count = @company.appointments.count
      @rewards_count = @company.rewards.count
      @used_rewards_count = @company.rewards.where(used: true).count
      @available_rewards_count = @company.rewards.where(used: false).count

      @recent_customers = @company.users.where(role: "customer").order(created_at: :desc).limit(5)
      @recent_appointments = @company.appointments.includes(:customer, :service).order(created_at: :desc).limit(5)
      @recent_rewards = @company.rewards.includes(:customer).order(created_at: :desc).limit(5)
    end

    def new
      @company = Company.new(active: true)
      @owner_user = User.new(role: "business")
      @subscription = Subscription.new(price: 19.90, status: "trial", trial_until: 30.days.from_now)
    end

    def create
      @company = Company.new(company_params)
      @company.active = true if @company.active.nil?

      @owner_user = @company.users.new(owner_user_params)
      @owner_user.role = "business"

      temporary_password = SecureRandom.alphanumeric(10)
      @owner_user.password = temporary_password
      @owner_user.password_confirmation = temporary_password

      ActiveRecord::Base.transaction do
        @company.save!

        @company.loyalty_programs.create!(
          name: "Programa de fidelidade",
          required_visits: 10,
          reward_description: "Recompensa grátis",
          active: true
        ) if @company.loyalty_programs.none?

        @company.create_subscription!(subscription_params)
        @owner_user.save!
      end

      email_sent = send_company_access_email(@owner_user, @company, temporary_password)

      notice_message = if email_sent
                         "Empresa criada. A senha temporária foi enviada por e-mail. Senha temporária: #{temporary_password}"
                       else
                         "Empresa criada, mas não foi possível enviar o e-mail. Senha temporária: #{temporary_password}"
                       end

      redirect_to owner_company_path(@company), notice: notice_message
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      @subscription ||= Subscription.new(subscription_params)
      render :new, status: :unprocessable_entity
    end

    def edit
      @owner_user = @company.owner_user || @company.users.new(role: "business")
      @subscription = @company.subscription || @company.build_subscription(price: 19.90, status: "trial")
    end

    def update
      @owner_user = @company.owner_user
      @subscription = @company.subscription || @company.build_subscription

      ActiveRecord::Base.transaction do
        @company.update!(company_params)
        @subscription.update!(subscription_params)

        if params[:owner_user].present?
          @owner_user ||= @company.users.new(role: "business")

          if @owner_user.new_record?
            temporary_password = SecureRandom.alphanumeric(10)
            @owner_user.password = temporary_password
            @owner_user.password_confirmation = temporary_password
          end

          @owner_user.update!(owner_user_params)
        end
      end

      redirect_to owner_company_path(@company), notice: "Empresa atualizada."
    rescue ActiveRecord::RecordInvalid => e
      flash.now[:alert] = e.record.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end

    def reset_owner_password
      user = @company.owner_user
      return redirect_to owner_company_path(@company), alert: "Empresa sem responsável cadastrado." unless user

      temporary_password = SecureRandom.alphanumeric(10)

      user.update!(
        password: temporary_password,
        password_confirmation: temporary_password
      )

      email_sent = send_company_access_email(user, @company, temporary_password)

      notice_message = if email_sent
                         "Senha redefinida e enviada por e-mail. Nova senha temporária: #{temporary_password}"
                       else
                         "Senha redefinida, mas não foi possível enviar o e-mail. Nova senha temporária: #{temporary_password}"
                       end

      redirect_to owner_company_path(@company), notice: notice_message
    end

    def destroy
      @company.destroy
      redirect_to owner_companies_path, notice: "Empresa removida."
    end

    private

    def set_company
      @company = Company.find(params[:id])
    end

    def company_params
      params.require(:company).permit(:name, :legal_name, :document, :email, :phone, :whatsapp, :address, :active)
    end

    def owner_user_params
      params.require(:owner_user).permit(:name, :email, :phone)
    end

    def subscription_params
      params.require(:subscription).permit(:plan, :price, :status, :free, :blocked, :trial_until, :expires_at, :last_payment_at)
    end

    def send_company_access_email(user, company, temporary_password)
      CompanyAccessEmailService.deliver!(
        user: user,
        company: company,
        login_url: "#{request.base_url}/login",
        password: temporary_password
      )

      true
    rescue StandardError => e
      Rails.logger.error("[CompanyAccessEmailService] Falha ao enviar acesso: #{e.class} - #{e.message}")
      false
    end
  end
end