require "test_helper"

class LoySmokeTest < ActionDispatch::IntegrationTest
  setup do
    @password = "123456"

    @company = Barbershop.find_or_create_by!(name: "Empresa Smoke Test") do |company|
      company.phone = "48999999999" if company.respond_to?(:phone=)
      company.address = "Rua Teste, 123" if company.respond_to?(:address=)
      company.subscription_status = "active" if company.respond_to?(:subscription_status=)
      company.plan = "Pro" if company.respond_to?(:plan=)
      company.monthly_price = 49.90 if company.respond_to?(:monthly_price=)
      company.trial_ends_at = 30.days.from_now if company.respond_to?(:trial_ends_at=)
    end

    @barber = User.find_or_initialize_by(email: "empresa.smoke@loy.test")
    @barber.name = "Empresa Smoke"
    @barber.phone = "48999999999" if @barber.respond_to?(:phone=)
    @barber.role = "barber"
    @barber.barbershop = @company if @barber.respond_to?(:barbershop=)
    @barber.password = @password
    @barber.password_confirmation = @password
    @barber.save!

    @customer = User.find_or_initialize_by(email: "cliente.smoke@loy.test")
    @customer.name = "Cliente Smoke"
    @customer.phone = "48988888888" if @customer.respond_to?(:phone=)
    @customer.role = "customer"
    @customer.barbershop = @company if @customer.respond_to?(:barbershop=)
    @customer.password = @password
    @customer.password_confirmation = @password
    @customer.save!

    @owner = User.find_or_initialize_by(email: "owner.smoke@loy.test")
    @owner.name = "Owner Smoke"
    @owner.phone = "48977777777" if @owner.respond_to?(:phone=)
    @owner.role = "owner"
    @owner.password = @password
    @owner.password_confirmation = @password
    @owner.save!

    @service = @company.services.find_or_create_by!(name: "Serviço Smoke") do |service|
      service.points = 1 if service.respond_to?(:points=)
      service.active = true if service.respond_to?(:active=)
    end
  end

  test "paginas publicas principais abrem sem erro" do
    assert_page_ok root_path
    assert_page_ok login_path
    assert_page_ok signup_path
    assert_page_ok client_login_path
    assert_page_ok new_password_reset_path
    assert_page_ok rails_health_check_path
  end

  test "login da empresa e menus principais abrem sem erro" do
    post login_path, params: {
      email: @barber.email,
      password: @password
    }

    assert_response :redirect

    assert_page_ok app_dashboard_path
    assert_page_ok customers_path
    assert_page_ok services_path
    assert_page_ok loyalty_programs_path
    assert_page_ok appointments_path
    assert_page_ok rewards_path
    assert_page_ok barbershop_path
  end

  test "login do cliente e portal abrem sem erro" do
    post client_login_path, params: {
      email: @customer.email,
      password: @password
    }

    assert_response :redirect

    assert_page_ok client_portal_path
  end

  test "login owner e painel loy abrem sem erro" do
    post login_path, params: {
      email: @owner.email,
      password: @password
    }

    assert_response :redirect

    assert_page_ok owner_dashboard_path
    assert_page_ok owner_companies_path
  end

  private

  def assert_page_ok(path)
    get path

    assert_response :success,
                    "Esperava sucesso ao abrir #{path}, mas retornou #{@response.status}"
  end
end
