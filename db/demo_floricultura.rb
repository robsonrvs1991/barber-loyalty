puts "Criando demo Floricultura..."

def assign_if_column(record, attrs)
  attrs.each do |key, value|
    record[key] = value if record.has_attribute?(key)
  end
end

company = Barbershop.find_or_initialize_by(name: "Flor & Afeto Floricultura")
assign_if_column(company, {
  phone: "48991234567",
  address: "Rua das Flores, 128 - Centro",
  email: "contato@floreafeto.test"
})
company.save!

owner = User.find_or_initialize_by(email: "floricultura@loy.test")
assign_if_column(owner, {
  name: "Marina Flores",
  phone: "48991234567",
  role: "barber",
  barbershop_id: company.id
})
owner.password = "123456"
owner.password_confirmation = "123456"
owner.save!

if defined?(Subscription)
  subscription = Subscription.find_or_initialize_by(barbershop_id: company.id)
  assign_if_column(subscription, {
    status: "active",
    plan_name: "Demo",
    price_cents: 1990,
    amount: 19.90,
    active: true
  })
  subscription.save!
end

services_data = [
  ["Buquê de Rosas", 2],
  ["Arranjo de Mesa", 2],
  ["Orquídea Presente", 3],
  ["Cesta de Café da Manhã", 4],
  ["Box de Flores", 3],
  ["Decoração Pequena", 5],
  ["Cartão Presente", 1],
  ["Entrega Especial", 1]
]

services = services_data.map do |name, points|
  service = Service.find_or_initialize_by(name: name, barbershop_id: company.id)
  assign_if_column(service, {
    points: points,
    active: true,
    price: rand(49..299),
    description: "Serviço/produto participante do programa de fidelidade."
  })
  service.save!
  service
end

program = LoyaltyProgram.find_or_initialize_by(barbershop_id: company.id)

assign_if_column(program, {
  name: "Clube Flor & Afeto",
  description: "Acumule pontos em compras e troque por recompensas especiais.",
  reward_name: "R$ 50 de desconto",
  reward_description: "Ganhe R$ 50 de desconto em compras acima de R$ 150.",
  points_required: 10,
  required_points: 10,
  goal_points: 10,
  required_visits: 10,
  active: true
})

program.save!

customers_data = [
  ["Ana Carolina", "ana.carolina@demo.test", "48990000001"],
  ["Bruno Almeida", "bruno.almeida@demo.test", "48990000002"],
  ["Camila Souza", "camila.souza@demo.test", "48990000003"],
  ["Daniel Martins", "daniel.martins@demo.test", "48990000004"],
  ["Eduarda Lima", "eduarda.lima@demo.test", "48990000005"],
  ["Fernanda Rocha", "fernanda.rocha@demo.test", "48990000006"],
  ["Gabriel Costa", "gabriel.costa@demo.test", "48990000007"],
  ["Helena Ramos", "helena.ramos@demo.test", "48990000008"],
  ["Igor Pereira", "igor.pereira@demo.test", "48990000009"],
  ["Juliana Castro", "juliana.castro@demo.test", "48990000010"],
  ["Lucas Vieira", "lucas.vieira@demo.test", "48990000011"],
  ["Mariana Teixeira", "mariana.teixeira@demo.test", "48990000012"]
]

customers = customers_data.map do |name, email, phone|
  customer = User.find_or_initialize_by(email: email)
  assign_if_column(customer, {
    name: name,
    phone: phone,
    role: "customer",
    barbershop_id: company.id
  })
  customer.password = "123456"
  customer.password_confirmation = "123456"
  customer.save!
  customer
end

customers.each_with_index do |customer, index|
  rand(3..9).times do
    service = services.sample

    appointment = Appointment.new
    assign_if_column(appointment, {
      barbershop_id: company.id,
      customer_id: customer.id,
      barber_id: owner.id,
      service_id: service.id,
      paid: true,
      created_at: rand(1..45).days.ago,
      updated_at: Time.current
    })
    appointment.save!
  end
end

customers.first(5).each_with_index do |customer, index|
  reward = Reward.new
  assign_if_column(reward, {
    barbershop_id: company.id,
    customer_id: customer.id,
    loyalty_program_id: program.id,
    code: "LOY-FLOR#{index + 1}#{SecureRandom.alphanumeric(3).upcase}",
    used: index.even?,
    created_at: rand(1..20).days.ago,
    updated_at: Time.current
  })
  reward.save!
end

puts "Demo criada com sucesso!"
puts "Empresa: Flor & Afeto Floricultura"
puts "Login empresa: floricultura@loy.test"
puts "Senha: 123456"
puts "Cliente exemplo: ana.carolina@demo.test"
puts "Senha cliente: 123456"
