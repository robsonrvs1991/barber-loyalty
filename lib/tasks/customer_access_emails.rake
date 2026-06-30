namespace :customers do
  desc "Envia e-mails de acesso para clientes"

  task send_access_emails: :environment do
    app_host = ENV.fetch("APP_HOST", "loynow.com")

    companies =
      if ENV["COMPANY_ID"].present?
        Barbershop.where(id: ENV["COMPANY_ID"])
      else
        Barbershop.order(:id)
      end

    total_sent = 0
    total_failed = 0
    total_skipped = 0

    companies.find_each do |company|
      puts
      puts "=========================================="
      puts "Empresa: #{company.name}"
      puts "=========================================="

      customers = company.users.where(role: "customer")

      customers.find_each do |customer|
        if customer.email.blank?
          puts "Ignorado: #{customer.name} (sem e-mail)"
          total_skipped += 1
          next
        end

        email = customer.email.downcase.strip

        if email.end_with?(".test") ||
           email.include?("example") ||
           email.include?("@test")
          puts "Ignorado: #{email}"
          total_skipped += 1
          next
        end

        temporary_password = SecureRandom.alphanumeric(8)

        customer.update!(
          password: temporary_password,
          password_confirmation: temporary_password
        )

        CustomerAccessEmailService.deliver!(
          customer: customer,
          temporary_password: temporary_password,
          company: company,
          login_url: "https://#{app_host}/cliente/login"
        )

        total_sent += 1

        puts "✓ #{customer.name} <#{email}>"

      rescue => e
        total_failed += 1
        puts "✗ #{customer.name} <#{customer.email}>"
        puts "  #{e.class}: #{e.message}"
      end
    end

    puts
    puts "=========================================="
    puts "FINALIZADO"
    puts "=========================================="
    puts "Enviados : #{total_sent}"
    puts "Ignorados: #{total_skipped}"
    puts "Falhas   : #{total_failed}"
    puts "=========================================="
  end
end