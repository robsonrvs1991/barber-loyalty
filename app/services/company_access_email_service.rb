class CompanyAccessEmailService
  def self.deliver!(user:, company:, login_url:)
    new(
      user: user,
      company: company,
      login_url: login_url
    ).deliver!
  end

  def initialize(user:, company:, login_url:)
    @user = user
    @company = company
    @login_url = login_url
  end

  def deliver!
    ResendEmailService.deliver!(
      to: user.email,
      subject: "Bem-vindo ao Loy! Sua empresa foi cadastrada",
      html: html_body,
      text: text_body
    )
  end

  private

  attr_reader :user, :company, :login_url

  def html_body
    <<~HTML
      <h2>Bem-vindo ao Loy!</h2>

      <p>Olá, #{user.name}!</p>

      <p>
        Sua empresa <strong>#{company.name}</strong> foi cadastrada com sucesso no Loy.
      </p>

      <p>
        A partir de agora, você já pode acessar o painel da sua empresa para:
      </p>

      <ul>
        <li>Cadastrar clientes</li>
        <li>Cadastrar itens e serviços</li>
        <li>Configurar programas de fidelidade</li>
        <li>Registrar atendimentos</li>
        <li>Acompanhar recompensas</li>
      </ul>

      <p>
        <strong>Login:</strong> #{user.email}
      </p>

      <p>
        Acesse o painel pelo link abaixo:<br>
        <a href="#{login_url}">#{login_url}</a>
      </p>

      <p>
        Equipe Loy
      </p>
    HTML
  end

  def text_body
    <<~TEXT
      Bem-vindo ao Loy!

      Olá, #{user.name}!

      Sua empresa #{company.name} foi cadastrada com sucesso no Loy.

      A partir de agora, você já pode acessar o painel da sua empresa para:

      - Cadastrar clientes
      - Cadastrar itens e serviços
      - Configurar programas de fidelidade
      - Registrar atendimentos
      - Acompanhar recompensas

      Login: #{user.email}

      Acesse o painel:
      #{login_url}

      Equipe Loy
    TEXT
  end
end
