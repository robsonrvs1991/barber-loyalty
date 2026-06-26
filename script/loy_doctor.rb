#!/usr/bin/env ruby

require_relative "../config/environment"
require "rack/mock"
require "benchmark"

class LoyDoctor
  GREEN = "\e[32m"
  YELLOW = "\e[33m"
  RED = "\e[31m"
  BLUE = "\e[34m"
  RESET = "\e[0m"

  def initialize
    @ok = []
    @warnings = []
    @errors = []
    @infos = []
  end

  def run
    header

    check_environment
    check_database
    check_models
    check_companies
    check_users
    check_services
    check_loyalty_programs
    check_appointments
    check_rewards
    check_mailers
    check_files
    check_routes_public
    check_routes_authenticated_company
    check_routes_authenticated_customer
    check_routes_authenticated_owner
    check_security
    check_performance
    check_production_readiness

    summary
  end

  private

  def header
    puts
    puts "#{BLUE}================================================#{RESET}"
    puts "#{BLUE}                 LOY DOCTOR                     #{RESET}"
    puts "#{BLUE}================================================#{RESET}"
    puts "Ambiente: #{Rails.env}"
    puts "Data: #{Time.current.strftime('%d/%m/%Y %H:%M:%S')}"
    puts "Rails: #{Rails.version}"
    puts "Ruby: #{RUBY_VERSION}"
    puts
  end

  def section(title)
    puts
    puts "#{BLUE}#{title}#{RESET}"
    puts "-" * title.length
  end

  def ok(message)
    @ok << message
    puts "#{GREEN}✓#{RESET} #{message}"
  end

  def warn(message)
    @warnings << message
    puts "#{YELLOW}⚠#{RESET} #{message}"
  end

  def error(message)
    @errors << message
    puts "#{RED}✗#{RESET} #{message}"
  end

  def info(message)
    @infos << message
    puts "• #{message}"
  end

  def app
    Rails.application
  end

  def request
    @request ||= Rack::MockRequest.new(app)
  end

  def check_environment
    section "Ambiente"

    ok "Aplicação Rails carregou corretamente"

    if Rails.env.production?
      ok "Rodando em production"
    else
      warn "Rodando em #{Rails.env}. Para validação final, rode também em production/staging"
    end

    if Rails.application.credentials.present?
      ok "Credentials carregadas"
    else
      warn "Credentials não encontradas ou vazias"
    end

    if ENV["RAILS_MASTER_KEY"].present?
      ok "RAILS_MASTER_KEY presente"
    else
      warn "RAILS_MASTER_KEY não encontrada no ambiente atual"
    end
  rescue StandardError => e
    error "Falha ao validar ambiente: #{e.class} - #{e.message}"
  end

  def check_database
    section "Banco de dados"

    ActiveRecord::Base.connection.execute("SELECT 1")
    ok "Conexão com banco funcionando"

    pending_migrations = ActiveRecord::MigrationContext.new(
      ActiveRecord::Migrator.migrations_paths,
      ActiveRecord::SchemaMigration
    ).open.pending_migrations

    if pending_migrations.any?
      error "#{pending_migrations.count} migration(s) pendente(s)"
    else
      ok "Nenhuma migration pendente"
    end

    tables = ActiveRecord::Base.connection.tables
    required_tables = %w[
      users
      barbershops
      services
      loyalty_programs
      appointments
      rewards
    ]

    required_tables.each do |table|
      if tables.include?(table)
        ok "Tabela #{table} existe"
      else
        error "Tabela #{table} não encontrada"
      end
    end
  rescue StandardError => e
    error "Falha ao validar banco: #{e.class} - #{e.message}"
  end

  def check_models
    section "Models"

    required_models = {
      "User" => User,
      "Barbershop" => Barbershop,
      "Service" => Service,
      "LoyaltyProgram" => LoyaltyProgram,
      "Appointment" => Appointment,
      "Reward" => Reward
    }

    required_models.each do |name, klass|
      ok "Model #{name} carregado"
      info "#{name}: #{klass.count} registro(s)"
    rescue StandardError => e
      error "Model #{name} falhou: #{e.class} - #{e.message}"
    end
  end

  def check_companies
    section "Empresas"

    total = Barbershop.count

    if total.zero?
      error "Nenhuma empresa cadastrada"
    else
      ok "#{total} empresa(s) cadastrada(s)"
    end

    if column?(Barbershop, "name")
      without_name = Barbershop.where(name: [nil, ""]).count
      without_name.zero? ? ok("Todas as empresas possuem nome") : error("#{without_name} empresa(s) sem nome")
    end

    if column?(Barbershop, "phone")
      without_phone = Barbershop.where(phone: [nil, ""]).count
      without_phone.zero? ? ok("Todas as empresas possuem telefone") : warn("#{without_phone} empresa(s) sem telefone")
    end

    if column?(Barbershop, "subscription_status")
      active = Barbershop.where(subscription_status: "active").count
      blocked = Barbershop.where(subscription_status: "blocked").count
      free = Barbershop.where(subscription_status: "free").count

      info "Assinaturas active: #{active}"
      info "Assinaturas blocked: #{blocked}"
      info "Assinaturas free: #{free}"

      active.positive? ? ok("#{active} empresa(s) ativa(s)") : warn("Nenhuma empresa ativa")
    end

    if association?(Barbershop, :users)
      without_users = Barbershop.left_joins(:users).where(users: { id: nil }).count
      without_users.zero? ? ok("Todas as empresas possuem usuário vinculado") : warn("#{without_users} empresa(s) sem usuário vinculado")
    end

    if defined?(LoyaltyProgram)
      companies_without_program = Barbershop.left_joins(:loyalty_programs).where(loyalty_programs: { id: nil }).count rescue nil
      warn "#{companies_without_program} empresa(s) sem programa de fidelidade" if companies_without_program.to_i.positive?
      ok "Todas as empresas possuem programa de fidelidade" if companies_without_program == 0
    end
  rescue StandardError => e
    error "Falha ao validar empresas: #{e.class} - #{e.message}"
  end

  def check_users
    section "Usuários"

    total = User.count
    customers = User.where(role: "customer").count
    barbers = User.where(role: "barber").count
    owners = User.where(role: "owner").count

    ok "#{total} usuário(s) cadastrado(s)"
    info "Clientes: #{customers}"
    info "Empresas: #{barbers}"
    info "Owners: #{owners}"

    without_email = User.where(email: [nil, ""]).count
    without_email.zero? ? ok("Todos os usuários possuem e-mail") : error("#{without_email} usuário(s) sem e-mail")

    without_name = User.where(name: [nil, ""]).count
    without_name.zero? ? ok("Todos os usuários possuem nome") : warn("#{without_name} usuário(s) sem nome")

    if column?(User, "phone")
      without_phone = User.where(phone: [nil, ""]).count
      without_phone.zero? ? ok("Todos os usuários possuem telefone") : warn("#{without_phone} usuário(s) sem telefone")
    end

    duplicated_emails = User.where.not(email: [nil, ""])
                            .group("LOWER(email)")
                            .having("COUNT(*) > 1")
                            .count

    duplicated_emails.empty? ? ok("Nenhum e-mail duplicado") : error("#{duplicated_emails.size} e-mail(s) duplicado(s)")

    invalid_roles = User.where.not(role: %w[owner barber customer]).count
    invalid_roles.zero? ? ok("Todos os usuários possuem role válida") : error("#{invalid_roles} usuário(s) com role inválida")

    if column?(User, "barbershop_id")
      customers_without_company = User.where(role: "customer", barbershop_id: nil).count
      barbers_without_company = User.where(role: "barber", barbershop_id: nil).count

      customers_without_company.zero? ? ok("Todos os clientes possuem empresa") : error("#{customers_without_company} cliente(s) sem empresa")
      barbers_without_company.zero? ? ok("Todos os usuários empresa possuem empresa") : error("#{barbers_without_company} usuário(s) empresa sem empresa")
    end
  rescue StandardError => e
    error "Falha ao validar usuários: #{e.class} - #{e.message}"
  end

  def check_services
    section "Itens/Serviços"

    total = Service.count
    total.positive? ? ok("#{total} item(ns)/serviço(s) cadastrado(s)") : warn("Nenhum item/serviço cadastrado")

    without_name = Service.where(name: [nil, ""]).count
    without_name.zero? ? ok("Todos os itens/serviços possuem nome") : error("#{without_name} item(ns)/serviço(s) sem nome")

    if column?(Service, "points")
      invalid_points = Service.where("points IS NULL OR points <= 0").count
      invalid_points.zero? ? ok("Todos os itens/serviços possuem pontos válidos") : error("#{invalid_points} item(ns)/serviço(s) com pontos inválidos")
    end

    if column?(Service, "active")
      active = Service.where(active: true).count
      inactive = Service.where(active: false).count

      ok "#{active} item(ns)/serviço(s) ativo(s)"
      warn "#{inactive} item(ns)/serviço(s) inativo(s)" if inactive.positive?
    end

    if column?(Service, "barbershop_id")
      orphan = Service.left_joins(:barbershop).where(barbershops: { id: nil }).count
      orphan.zero? ? ok("Todos os itens/serviços possuem empresa válida") : error("#{orphan} item(ns)/serviço(s) sem empresa válida")
    end

    duplicates = Service.where.not(name: [nil, ""])
                        .group(:barbershop_id, "LOWER(name)")
                        .having("COUNT(*) > 1")
                        .count

    duplicates.empty? ? ok("Nenhum item/serviço duplicado por empresa") : warn("#{duplicates.size} item(ns)/serviço(s) duplicado(s) por empresa")
  rescue StandardError => e
    error "Falha ao validar itens/serviços: #{e.class} - #{e.message}"
  end

  def check_loyalty_programs
    section "Programas de fidelidade"

    total = LoyaltyProgram.count
    total.positive? ? ok("#{total} programa(s) cadastrado(s)") : warn("Nenhum programa de fidelidade cadastrado")

    if column?(LoyaltyProgram, "required_points")
      invalid = LoyaltyProgram.where("required_points IS NULL OR required_points <= 0").count
      invalid.zero? ? ok("Todos os programas possuem meta válida") : error("#{invalid} programa(s) com meta inválida")
    end

    if column?(LoyaltyProgram, "reward_description")
      without_reward = LoyaltyProgram.where(reward_description: [nil, ""]).count
      without_reward.zero? ? ok("Todos os programas possuem recompensa definida") : warn("#{without_reward} programa(s) sem recompensa definida")
    end

    if column?(LoyaltyProgram, "barbershop_id")
      orphan = LoyaltyProgram.left_joins(:barbershop).where(barbershops: { id: nil }).count
      orphan.zero? ? ok("Todos os programas possuem empresa válida") : error("#{orphan} programa(s) sem empresa válida")
    end
  rescue StandardError => e
    error "Falha ao validar programas: #{e.class} - #{e.message}"
  end

  def check_appointments
    section "Atendimentos"

    total = Appointment.count
    total.positive? ? ok("#{total} atendimento(s) cadastrado(s)") : warn("Nenhum atendimento cadastrado")

    if association?(Appointment, :customer)
      orphan_customers = Appointment.left_joins(:customer).where(users: { id: nil }).count
      orphan_customers.zero? ? ok("Todos os atendimentos possuem cliente válido") : error("#{orphan_customers} atendimento(s) sem cliente válido")
    end

    if association?(Appointment, :service)
      orphan_services = Appointment.left_joins(:service).where(services: { id: nil }).count
      orphan_services.zero? ? ok("Todos os atendimentos possuem item/serviço válido") : error("#{orphan_services} atendimento(s) sem item/serviço válido")
    end

    if column?(Appointment, "barbershop_id")
      orphan_companies = Appointment.left_joins(:barbershop).where(barbershops: { id: nil }).count
      orphan_companies.zero? ? ok("Todos os atendimentos possuem empresa válida") : error("#{orphan_companies} atendimento(s) sem empresa válida")
    end

    if column?(Appointment, "paid")
      unpaid = Appointment.where(paid: false).count
      unpaid.zero? ? ok("Nenhum atendimento pendente de pagamento") : warn("#{unpaid} atendimento(s) não pago(s)")
    end

    future = Appointment.where("created_at > ?", Time.current).count
    future.zero? ? ok("Nenhum atendimento com data futura") : warn("#{future} atendimento(s) com data futura")
  rescue StandardError => e
    error "Falha ao validar atendimentos: #{e.class} - #{e.message}"
  end

  def check_rewards
    section "Recompensas"

    total = Reward.count
    total.positive? ? ok("#{total} recompensa(s) cadastrada(s)") : warn("Nenhuma recompensa cadastrada")

    without_code = Reward.where(code: [nil, ""]).count
    without_code.zero? ? ok("Todas as recompensas possuem código") : error("#{without_code} recompensa(s) sem código")

    duplicates = Reward.where.not(code: [nil, ""])
                       .group("UPPER(code)")
                       .having("COUNT(*) > 1")
                       .count

    duplicates.empty? ? ok("Nenhum código de recompensa duplicado") : error("#{duplicates.size} código(s) duplicado(s)")

    if association?(Reward, :customer)
      orphan_customers = Reward.left_joins(:customer).where(users: { id: nil }).count
      orphan_customers.zero? ? ok("Todas as recompensas possuem cliente válido") : error("#{orphan_customers} recompensa(s) sem cliente válido")
    end

    if column?(Reward, "barbershop_id")
      orphan_companies = Reward.left_joins(:barbershop).where(barbershops: { id: nil }).count
      orphan_companies.zero? ? ok("Todas as recompensas possuem empresa válida") : error("#{orphan_companies} recompensa(s) sem empresa válida")
    end

    if column?(Reward, "used") && column?(Reward, "used_at")
      used_without_date = Reward.where(used: true, used_at: nil).count
      used_without_date.zero? ? ok("Todas as recompensas utilizadas possuem data") : error("#{used_without_date} recompensa(s) utilizada(s) sem data")
    end

    if column?(Reward, "description")
      without_description = Reward.where(description: [nil, ""]).count
      without_description.zero? ? ok("Todas as recompensas possuem descrição") : warn("#{without_description} recompensa(s) sem descrição")
    end

    future = Reward.where("created_at > ?", Time.current).count
    future.zero? ? ok("Nenhuma recompensa com data futura") : warn("#{future} recompensa(s) com data futura")
  rescue StandardError => e
    error "Falha ao validar recompensas: #{e.class} - #{e.message}"
  end

  def check_mailers
    section "E-mails"

    mailers = []

    mailers << CustomerMailer if defined?(CustomerMailer)
    mailers << CompanyMailer if defined?(CompanyMailer)
    mailers << PasswordResetMailer if defined?(PasswordResetMailer)

    if mailers.empty?
      warn "Nenhum mailer conhecido encontrado"
      return
    end

    mailers.each do |mailer|
      ok "Mailer #{mailer.name} carregado"

      actions = mailer.action_methods.to_a

      if actions.any?
        info "#{mailer.name}: ações #{actions.join(', ')}"
      else
        warn "#{mailer.name} não possui ações públicas"
      end
    end

    delivery_method = ActionMailer::Base.delivery_method
    info "Delivery method: #{delivery_method}"

    if Rails.env.production? && delivery_method.to_s == "test"
      error "E-mail em production está configurado como :test"
    else
      ok "Configuração de e-mail parece aceitável para o ambiente atual"
    end
  rescue StandardError => e
    error "Falha ao validar e-mails: #{e.class} - #{e.message}"
  end

  def check_files
    section "Arquivos e Views"

    required_files = [
      "app/views/landing/index.html.erb",
      "app/views/sessions/new.html.erb",
      "app/views/client_sessions/new.html.erb",
      "app/views/customers/index.html.erb",
      "app/views/services/index.html.erb",
      "app/views/appointments/index.html.erb",
      "app/views/rewards/index.html.erb",
      "app/views/client_portal/index.html.erb",
      "app/views/layouts/application.html.erb",
      "config/routes.rb"
    ]

    required_files.each do |file|
      if File.exist?(Rails.root.join(file))
        ok "#{file} existe"
      else
        error "#{file} não encontrado"
      end
    end

    logo = Rails.root.join("app/assets/images/logo.png")
    File.exist?(logo) ? ok("Logo encontrado em app/assets/images/logo.png") : warn("Logo não encontrado em app/assets/images/logo.png")

    favicon = Rails.root.join("app/assets/images/favicon.ico")
    File.exist?(favicon) ? ok("Favicon encontrado") : warn("Favicon não encontrado")
  rescue StandardError => e
    error "Falha ao validar arquivos/views: #{e.class} - #{e.message}"
  end

  def check_routes_public
    section "Rotas públicas"

    routes = [
      ["/", "Landing page"],
      ["/login", "Login empresa"],
      ["/cliente/login", "Login cliente"],
      ["/esqueci-senha", "Recuperação de senha"],
      ["/cadastre-se", "Cadastro público"],
      ["/up", "Health check"]
    ]

    routes.each do |path, name|
      check_get_route(path, name)
    end
  end

  def check_routes_authenticated_company
    section "Rotas autenticadas - Empresa"

    user = User.where(role: "barber").first

    unless user
      warn "Nenhum usuário empresa encontrado para testar rotas autenticadas"
      return
    end

    session = Rack::MockSession.new(app)
    mock = Rack::MockRequest.new(session)

    login_response = mock.post(
      "/login",
      params: { email: user.email, password: "123456" },
      "HTTP_HOST" => "localhost"
    )

    if login_response.status.between?(200, 399)
      ok "Login empresa respondeu sem erro técnico"
    else
      warn "Login empresa retornou HTTP #{login_response.status}. Rotas autenticadas podem não ser testadas corretamente"
    end

    routes = [
      ["/app", "Dashboard empresa"],
      ["/customers", "Clientes"],
      ["/services", "Itens/Serviços"],
      ["/loyalty_programs", "Programas de fidelidade"],
      ["/appointments", "Atendimentos"],
      ["/rewards", "Recompensas"],
      ["/barbershop", "Dados da empresa"]
    ]

    routes.each do |path, name|
      response = mock.get(path, "HTTP_HOST" => "localhost")

      if response.status.between?(200, 399)
        ok "#{name} abre sem erro"
      elsif response.status == 302
        warn "#{name} redirecionou. Pode exigir login/senha válida conhecida"
      else
        error "#{name} retornou HTTP #{response.status}"
      end
    rescue StandardError => e
      error "#{name} falhou: #{e.class} - #{e.message}"
    end
  rescue StandardError => e
    error "Falha ao testar rotas empresa: #{e.class} - #{e.message}"
  end

  def check_routes_authenticated_customer
    section "Rotas autenticadas - Cliente"

    user = User.where(role: "customer").first

    unless user
      warn "Nenhum cliente encontrado para testar portal"
      return
    end

    session = Rack::MockSession.new(app)
    mock = Rack::MockRequest.new(session)

    login_response = mock.post(
      "/cliente/login",
      params: { email: user.email, password: "123456" },
      "HTTP_HOST" => "localhost"
    )

    if login_response.status.between?(200, 399)
      ok "Login cliente respondeu sem erro técnico"
    else
      warn "Login cliente retornou HTTP #{login_response.status}. Portal pode não ser testado autenticado"
    end

    response = mock.get("/cliente", "HTTP_HOST" => "localhost")

    if response.status.between?(200, 399)
      ok "Portal cliente abre sem erro"
    elsif response.status == 302
      warn "Portal cliente redirecionou. Pode exigir senha conhecida"
    else
      error "Portal cliente retornou HTTP #{response.status}"
    end
  rescue StandardError => e
    error "Falha ao testar portal cliente: #{e.class} - #{e.message}"
  end

  def check_routes_authenticated_owner
    section "Rotas autenticadas - Owner"

    user = User.where(role: "owner").first

    unless user
      warn "Nenhum owner encontrado para testar Painel Loy"
      return
    end

    session = Rack::MockSession.new(app)
    mock = Rack::MockRequest.new(session)

    login_response = mock.post(
      "/login",
      params: { email: user.email, password: "123456" },
      "HTTP_HOST" => "localhost"
    )

    if login_response.status.between?(200, 399)
      ok "Login owner respondeu sem erro técnico"
    else
      warn "Login owner retornou HTTP #{login_response.status}. Painel Loy pode não ser testado autenticado"
    end

    routes = [
      ["/owner", "Dashboard Owner"],
      ["/owner/companies", "Empresas"]
    ]

    routes.each do |path, name|
      response = mock.get(path, "HTTP_HOST" => "localhost")

      if response.status.between?(200, 399)
        ok "#{name} abre sem erro"
      elsif response.status == 302
        warn "#{name} redirecionou. Pode exigir senha conhecida"
      else
        error "#{name} retornou HTTP #{response.status}"
      end
    rescue StandardError => e
      error "#{name} falhou: #{e.class} - #{e.message}"
    end
  rescue StandardError => e
    error "Falha ao testar rotas owner: #{e.class} - #{e.message}"
  end

  def check_security
    section "Segurança"

    routes_file = Rails.root.join("config/routes.rb").read

    if routes_file.include?("password_resets")
      ok "Rotas de recuperação de senha existem"
    else
      error "Rotas de recuperação de senha não encontradas"
    end

    if ApplicationController.instance_methods.include?(:require_login) || ApplicationController.private_instance_methods.include?(:require_login)
      ok "require_login existe no ApplicationController"
    else
      error "require_login não encontrado no ApplicationController"
    end

    if ApplicationController.instance_methods.include?(:require_barber) || ApplicationController.private_instance_methods.include?(:require_barber)
      ok "require_barber existe no ApplicationController"
    else
      warn "require_barber não encontrado no ApplicationController"
    end

    if ApplicationController.instance_methods.include?(:require_active_subscription) || ApplicationController.private_instance_methods.include?(:require_active_subscription)
      ok "require_active_subscription existe no ApplicationController"
    else
      warn "require_active_subscription não encontrado no ApplicationController"
    end

    if Rails.application.config.force_ssl
      ok "force_ssl ativado"
    else
      warn "force_ssl não está ativado neste ambiente"
    end

    if Rails.application.config.action_controller.allow_forgery_protection
      ok "Proteção CSRF ativa"
    else
      warn "Proteção CSRF aparentemente desativada"
    end
  rescue StandardError => e
    error "Falha ao validar segurança: #{e.class} - #{e.message}"
  end

  def check_performance
    section "Performance básica"

    routes = [
      ["/", "Landing page"],
      ["/login", "Login empresa"],
      ["/cliente/login", "Login cliente"],
      ["/cadastre-se", "Cadastro público"]
    ]

    routes.each do |path, name|
      time = Benchmark.realtime do
        request.get(path, "HTTP_HOST" => "localhost")
      end

      ms = (time * 1000).round(1)

      if ms <= 500
        ok "#{name} respondeu em #{ms}ms"
      elsif ms <= 1000
        warn "#{name} respondeu em #{ms}ms"
      else
        error "#{name} muito lenta: #{ms}ms"
      end
    rescue StandardError => e
      error "Falha ao medir #{name}: #{e.class} - #{e.message}"
    end
  end

  def check_production_readiness
    section "Checklist de produção"

    if Rails.env.production?
      ok "Ambiente production"
    else
      warn "Validação final ainda deve ser feita em production/staging"
    end

    database_url = ENV["DATABASE_URL"]
    database_url.present? ? ok("DATABASE_URL presente") : warn("DATABASE_URL não encontrada neste ambiente")

    if ENV["RAILS_SERVE_STATIC_FILES"].present? || !Rails.env.production?
      ok "Configuração de arquivos estáticos aceitável"
    else
      warn "RAILS_SERVE_STATIC_FILES não encontrada"
    end

    if ENV["SMTP_ADDRESS"].present? || ENV["SENDGRID_API_KEY"].present? || ENV["RESEND_API_KEY"].present? || !Rails.env.production?
      ok "Configuração de SMTP/API de e-mail parece aceitável"
    else
      warn "Nenhuma configuração SMTP/API de e-mail encontrada"
    end

    if File.exist?(Rails.root.join("public/404.html"))
      ok "Página 404 existe"
    else
      warn "Página 404 padrão não encontrada"
    end

    if File.exist?(Rails.root.join("public/500.html"))
      ok "Página 500 existe"
    else
      warn "Página 500 padrão não encontrada"
    end
  rescue StandardError => e
    error "Falha no checklist de produção: #{e.class} - #{e.message}"
  end

  def check_get_route(path, name)
    response = request.get(path, "HTTP_HOST" => "localhost")

    if response.status.between?(200, 399)
      ok "#{name} abre sem erro"
    else
      error "#{name} retornou HTTP #{response.status}"
    end
  rescue StandardError => e
    error "#{name} falhou: #{e.class} - #{e.message}"
  end

  def column?(klass, column_name)
    klass.column_names.include?(column_name)
  end

  def association?(klass, association_name)
    klass.reflect_on_association(association_name).present?
  end

  def summary
    section "Resultado final"

    total = @ok.count + @warnings.count + @errors.count
    score = 100
    score -= @warnings.count * 2
    score -= @errors.count * 10
    score = 0 if score.negative?

    puts "Checks OK: #{@ok.count}"
    puts "Alertas:   #{@warnings.count}"
    puts "Erros:     #{@errors.count}"
    puts "Total:     #{total}"
    puts
    puts "Score de qualidade: #{score}/100"
    puts

    if @errors.any?
      puts "#{RED}STATUS: REPROVADO PARA PRODUÇÃO#{RESET}"
      puts
      puts "Erros encontrados:"
      @errors.each { |message| puts "#{RED}- #{message}#{RESET}" }
    elsif @warnings.any?
      puts "#{YELLOW}STATUS: APROVADO COM ALERTAS#{RESET}"
      puts
      puts "Alertas encontrados:"
      @warnings.each { |message| puts "#{YELLOW}- #{message}#{RESET}" }
    else
      puts "#{GREEN}STATUS: APROVADO PARA PRODUÇÃO#{RESET}"
    end

    puts
    puts "#{BLUE}================================================#{RESET}"
    puts
  end
end

LoyDoctor.new.run
