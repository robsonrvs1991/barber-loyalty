#!/usr/bin/env ruby

require_relative "../config/environment"

class LoyQualityCheck
  def initialize
    @checks = []
    @warnings = []
    @errors = []
  end

  def run
    header

    check_database
    check_companies
    check_users
    check_services
    check_loyalty_programs
    check_appointments
    check_rewards
    check_duplicates
    check_routes

    summary
  end

  private

  def header
    puts
    puts "========================================"
    puts "          LOY QUALITY CHECK"
    puts "========================================"
    puts "Ambiente: #{Rails.env}"
    puts "Data: #{Time.current.strftime('%d/%m/%Y %H:%M')}"
    puts
  end

  def ok(message)
    @checks << message
    puts "✓ #{message}"
  end

  def warn(message)
    @warnings << message
    puts "⚠ #{message}"
  end

  def error(message)
    @errors << message
    puts "✗ #{message}"
  end

  def check_database
    puts "Banco de dados"

    ActiveRecord::Base.connection.execute("SELECT 1")
    ok "Conexão com banco de dados funcionando"

    puts
  rescue StandardError => e
    error "Erro ao conectar no banco: #{e.class} - #{e.message}"
    puts
  end

  def check_companies
    puts "Empresas"

    total = Barbershop.count

    if total.zero?
      error "Nenhuma empresa cadastrada"
    else
      ok "#{total} empresa(s) cadastrada(s)"
    end

    if Barbershop.column_names.include?("subscription_status")
      active = Barbershop.where(subscription_status: "active").count
      warn "Nenhuma empresa com assinatura ativa" if active.zero?
      ok "#{active} empresa(s) com assinatura ativa" if active.positive?
    end

    if User.column_names.include?("barbershop_id")
      companies_without_owner = Barbershop.left_joins(:users)
                                          .where(users: { id: nil })
                                          .count

      if companies_without_owner.positive?
        warn "#{companies_without_owner} empresa(s) sem usuário vinculado"
      else
        ok "Todas as empresas possuem usuário vinculado"
      end
    end

    puts
  rescue StandardError => e
    error "Erro ao validar empresas: #{e.class} - #{e.message}"
    puts
  end

  def check_users
    puts "Usuários e clientes"

    total_users = User.count
    total_customers = User.where(role: "customer").count
    total_barbers = User.where(role: "barber").count
    total_owners = User.where(role: "owner").count

    ok "#{total_users} usuário(s) cadastrado(s)"
    ok "#{total_customers} cliente(s)"
    ok "#{total_barbers} usuário(s) empresa"
    ok "#{total_owners} usuário(s) owner"

    users_without_email = User.where(email: [nil, ""]).count
    users_without_name = User.where(name: [nil, ""]).count

    if users_without_email.positive?
      error "#{users_without_email} usuário(s) sem e-mail"
    else
      ok "Todos os usuários possuem e-mail"
    end

    if users_without_name.positive?
      warn "#{users_without_name} usuário(s) sem nome"
    else
      ok "Todos os usuários possuem nome"
    end

    if User.column_names.include?("phone")
      users_without_phone = User.where(phone: [nil, ""]).count

      if users_without_phone.positive?
        warn "#{users_without_phone} usuário(s) sem telefone"
      else
        ok "Todos os usuários possuem telefone"
      end
    end

    puts
  rescue StandardError => e
    error "Erro ao validar usuários: #{e.class} - #{e.message}"
    puts
  end

  def check_services
    puts "Itens/Serviços"

    total = Service.count

    if total.zero?
      warn "Nenhum item/serviço cadastrado"
    else
      ok "#{total} item(ns)/serviço(s) cadastrado(s)"
    end

    if Service.column_names.include?("active")
      active = Service.where(active: true).count
      inactive = Service.where(active: false).count

      ok "#{active} item(ns)/serviço(s) ativo(s)"
      warn "#{inactive} item(ns)/serviço(s) inativo(s)" if inactive.positive?
    end

    if Service.column_names.include?("points")
      invalid_points = Service.where("points IS NULL OR points <= 0").count

      if invalid_points.positive?
        error "#{invalid_points} item(ns)/serviço(s) com pontos inválidos"
      else
        ok "Todos os itens/serviços possuem pontuação válida"
      end
    end

    services_without_name = Service.where(name: [nil, ""]).count

    if services_without_name.positive?
      error "#{services_without_name} item(ns)/serviço(s) sem nome"
    else
      ok "Todos os itens/serviços possuem nome"
    end

    puts
  rescue StandardError => e
    error "Erro ao validar itens/serviços: #{e.class} - #{e.message}"
    puts
  end

  def check_loyalty_programs
    puts "Programas de fidelidade"

    total = LoyaltyProgram.count

    if total.zero?
      warn "Nenhum programa de fidelidade cadastrado"
    else
      ok "#{total} programa(s) de fidelidade cadastrado(s)"
    end

    if LoyaltyProgram.column_names.include?("required_points")
      invalid_required_points = LoyaltyProgram.where("required_points IS NULL OR required_points <= 0").count

      if invalid_required_points.positive?
        error "#{invalid_required_points} programa(s) com meta de pontos inválida"
      else
        ok "Todos os programas possuem meta de pontos válida"
      end
    end

    if LoyaltyProgram.column_names.include?("reward_description")
      without_reward = LoyaltyProgram.where(reward_description: [nil, ""]).count

      if without_reward.positive?
        warn "#{without_reward} programa(s) sem descrição de recompensa"
      else
        ok "Todos os programas possuem descrição de recompensa"
      end
    end

    puts
  rescue StandardError => e
    error "Erro ao validar programas de fidelidade: #{e.class} - #{e.message}"
    puts
  end

  def check_appointments
    puts "Atendimentos"

    total = Appointment.count

    if total.zero?
      warn "Nenhum atendimento cadastrado"
    else
      ok "#{total} atendimento(s) cadastrado(s)"
    end

    if Appointment.column_names.include?("customer_id")
      orphan_customers = Appointment.left_joins(:customer)
                                     .where(users: { id: nil })
                                     .count

      if orphan_customers.positive?
        error "#{orphan_customers} atendimento(s) sem cliente válido"
      else
        ok "Todos os atendimentos possuem cliente válido"
      end
    end

    if Appointment.column_names.include?("service_id")
      orphan_services = Appointment.left_joins(:service)
                                    .where(services: { id: nil })
                                    .count

      if orphan_services.positive?
        error "#{orphan_services} atendimento(s) sem item/serviço válido"
      else
        ok "Todos os atendimentos possuem item/serviço válido"
      end
    end

    if Appointment.column_names.include?("paid")
      unpaid = Appointment.where(paid: false).count
      warn "#{unpaid} atendimento(s) marcado(s) como não pago(s)" if unpaid.positive?
      ok "Nenhum atendimento pendente de pagamento" if unpaid.zero?
    end

    future = Appointment.where("created_at > ?", Time.current).count

    if future.positive?
      warn "#{future} atendimento(s) com data futura"
    else
      ok "Nenhum atendimento com data futura"
    end

    puts
  rescue StandardError => e
    error "Erro ao validar atendimentos: #{e.class} - #{e.message}"
    puts
  end

  def check_rewards
    puts "Recompensas"

    total = Reward.count

    if total.zero?
      warn "Nenhuma recompensa cadastrada"
    else
      ok "#{total} recompensa(s) cadastrada(s)"
    end

    if Reward.column_names.include?("customer_id")
      orphan_customers = Reward.left_joins(:customer)
                               .where(users: { id: nil })
                               .count

      if orphan_customers.positive?
        error "#{orphan_customers} recompensa(s) sem cliente válido"
      else
        ok "Todas as recompensas possuem cliente válido"
      end
    end

    rewards_without_code = Reward.where(code: [nil, ""]).count

    if rewards_without_code.positive?
      error "#{rewards_without_code} recompensa(s) sem código"
    else
      ok "Todas as recompensas possuem código"
    end

    if Reward.column_names.include?("used") && Reward.column_names.include?("used_at")
      used_without_date = Reward.where(used: true, used_at: nil).count

      if used_without_date.positive?
        error "#{used_without_date} recompensa(s) utilizada(s) sem data de uso"
      else
        ok "Todas as recompensas utilizadas possuem data de uso"
      end
    end

    future = Reward.where("created_at > ?", Time.current).count

    if future.positive?
      warn "#{future} recompensa(s) com data futura"
    else
      ok "Nenhuma recompensa com data futura"
    end

    puts
  rescue StandardError => e
    error "Erro ao validar recompensas: #{e.class} - #{e.message}"
    puts
  end

  def check_duplicates
    puts "Duplicidades"

    duplicated_emails = User.group("LOWER(email)")
                            .having("COUNT(*) > 1")
                            .count

    if duplicated_emails.any?
      error "#{duplicated_emails.size} e-mail(s) duplicado(s) em usuários"
    else
      ok "Nenhum e-mail duplicado em usuários"
    end

    duplicated_reward_codes = Reward.group("UPPER(code)")
                                    .having("COUNT(*) > 1")
                                    .count

    if duplicated_reward_codes.any?
      error "#{duplicated_reward_codes.size} código(s) de recompensa duplicado(s)"
    else
      ok "Nenhum código de recompensa duplicado"
    end

    puts
  rescue StandardError => e
    error "Erro ao validar duplicidades: #{e.class} - #{e.message}"
    puts
  end

  def check_routes
    puts "Rotas principais"

    routes = [
      ["/", "Landing page"],
      ["/login", "Login empresa"],
      ["/cliente/login", "Login cliente"],
      ["/esqueci-senha", "Recuperação de senha"],
      ["/cadastre-se", "Cadastro público"],
      ["/up", "Health check"]
    ]

    routes.each do |path, name|
      begin
        app = Rails.application
        response = Rack::MockRequest.new(app).get(path, "HTTP_HOST" => "localhost")

        if response.status.between?(200, 399)
          ok "#{name} abre sem erro"
        else
          warn "#{name} retornou HTTP #{response.status}"
        end
      rescue StandardError => e
        error "#{name} falhou: #{e.class} - #{e.message}"
      end
    end

    puts
  end

  def summary
    puts "========================================"
    puts "              RESULTADO"
    puts "========================================"
    puts "Checks OK: #{@checks.count}"
    puts "Alertas:   #{@warnings.count}"
    puts "Erros:     #{@errors.count}"
    puts

    score = calculate_score

    puts "Score de qualidade: #{score}/100"
    puts

    if @errors.any?
      puts "Status: REPROVADO PARA PRODUÇÃO"
      puts
      puts "Corrija os erros antes de subir."
    elsif @warnings.any?
      puts "Status: APROVADO COM ALERTAS"
      puts
      puts "Pode subir em beta fechado, mas revise os alertas."
    else
      puts "Status: APROVADO PARA PRODUÇÃO"
    end

    puts
  end

  def calculate_score
    total_items = @checks.count + @warnings.count + @errors.count
    return 0 if total_items.zero?

    score = 100
    score -= @warnings.count * 2
    score -= @errors.count * 8
    score = 0 if score.negative?
    score
  end
end

LoyQualityCheck.new.run
