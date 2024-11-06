CREATE TABLE Usuario (
  uid VARCHAR(28) PRIMARY KEY,
  nome_completo VARCHAR(300) NOT NULL,
  nome_usuario VARCHAR(20) NOT NULL UNIQUE,
  cpf VARCHAR(11) NOT NULL UNIQUE,
  email VARCHAR(250) NOT NULL UNIQUE,
  senha VARCHAR(500) NOT NULL,
  telefone VARCHAR(11) NOT NULL UNIQUE,
  data_nascimento DATE NOT NULL,
  genero INTEGER NOT NULL
);

CREATE TABLE Plano (
  plano_id SERIAL PRIMARY KEY,
  nome VARCHAR(100) NOT NULL UNIQUE,
  descricao VARCHAR(255) NOT NULL,
  valor DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Produto (
  produto_id SERIAL PRIMARY KEY,
  nome_produto VARCHAR(250) NOT NULL,
  estoque INTEGER NOT NULL,
  descricao VARCHAR(500) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL,
  desconto DECIMAL(10, 2),
  condicao BOOLEAN NOT NULL,
  imagem VARCHAR(500),
  usuario_id VARCHAR(28) NOT NULL,
  topico INTEGER NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE
);

CREATE TABLE Servico (
  servico_id SERIAL PRIMARY KEY,
  usuario_id VARCHAR(28) NOT NULL,
  nome_servico VARCHAR(100) NOT NULL,
  descricao VARCHAR(500) NOT NULL,
  preco DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE
);

CREATE TABLE Endereco_Usuario (
  endereco_usuario_id SERIAL PRIMARY KEY,
  cep VARCHAR(8) NOT NULL,
  uf VARCHAR(2) NOT NULL,
  cidade VARCHAR(23) NOT NULL,
  bairro VARCHAR(53) NOT NULL,
  rua VARCHAR(75) NOT NULL,
  numero VARCHAR(20),
  complemento VARCHAR(150),
  usuario_id VARCHAR(28) NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE
);

CREATE TABLE Plano_Usuario (
  plano_usuario_id SERIAL PRIMARY KEY,
  usuario_id VARCHAR(28) NOT NULL,
  plano_id INTEGER NOT NULL,
  data_assinatura DATE NOT NULL,
  data_final DATE NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE,
  FOREIGN KEY (plano_id) REFERENCES Plano(plano_id) ON DELETE CASCADE
);

CREATE TABLE Pagamento_Plano (
  pagamento_plano_id SERIAL PRIMARY KEY,
  plano_id INTEGER NOT NULL,
  usuario_id VARCHAR(28) NOT NULL,
  valor DECIMAL(10, 2) NOT NULL,
  tipo_pagamento VARCHAR(20) NOT NULL,
  data_pagamento DATE NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE,
  FOREIGN KEY (plano_id) REFERENCES Plano(plano_id) ON DELETE CASCADE
);

CREATE TABLE Carrinho (
  carrinho_id SERIAL PRIMARY KEY,
  identificador INTEGER NOT NULL,
  usuario_id VARCHAR(28) NOT NULL,
  produto_id INTEGER NOT NULL,
  produto_img VARCHAR(500),
  quantidade INTEGER NOT NULL,
  valor_total DECIMAL(10, 2),
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE,
  FOREIGN KEY (produto_id) REFERENCES Produto(produto_id) ON DELETE CASCADE
);

CREATE TABLE Pedido (
  pedido_id SERIAL PRIMARY KEY,
  usuario_id VARCHAR(28) NOT NULL,
  valor_total DECIMAL(10, 2) NOT NULL,
  valor_frete DECIMAL(10, 2) NOT NULL,
  cupom VARCHAR(20),
  valor_desconto DECIMAL(10, 2),
  data_pedido DATE NOT NULL,
  data_entrega DATE NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE
);

CREATE TABLE Item_Pedido (
  item_pedido_id SERIAL PRIMARY KEY,
  produto_id INTEGER NOT NULL,
  pedido_id INTEGER NOT NULL,
  quantidade INTEGER NOT NULL,
  preco_unitario DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (produto_id) REFERENCES Produto(produto_id) ON DELETE CASCADE,
  FOREIGN KEY (pedido_id) REFERENCES Pedido(pedido_id) ON DELETE CASCADE
);

CREATE TABLE Pagamento_Produto (
  pagamento_produto_id SERIAL PRIMARY KEY,
  pedido_id INTEGER NOT NULL,
  usuario_id VARCHAR(28) NOT NULL,
  data_pagamento DATE NOT NULL,
  tipo_pagamento VARCHAR(20) NOT NULL,
  valor_total DECIMAL(10, 2) NOT NULL,
  valor_frete DECIMAL(10, 2),
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE,
  FOREIGN KEY (pedido_id) REFERENCES Pedido(pedido_id) ON DELETE CASCADE
);

CREATE TABLE Pagamento_Servico (
  pagamento_servico_id SERIAL PRIMARY KEY,
  servico_id INTEGER NOT NULL,
  usuario_id VARCHAR(28) NOT NULL,
  valor_servico DECIMAL(10, 2) NOT NULL,
  tipo_pagamento VARCHAR(20) NOT NULL,
  data_pagamento DATE NOT NULL,
  FOREIGN KEY (usuario_id) REFERENCES Usuario(uid) ON DELETE CASCADE,
  FOREIGN KEY (servico_id) REFERENCES Servico(servico_id) ON DELETE CASCADE
);

CREATE TABLE Categoria (
  categoria_id SERIAL PRIMARY KEY,
  nome VARCHAR(250) NOT NULL UNIQUE
);

CREATE TABLE TagServico (
  tag_servico_id SERIAL PRIMARY KEY,
  nome VARCHAR(100),
  preco_medio DECIMAL(10, 2) NOT NULL
);

CREATE TABLE TagServico_Servico (
  tag_servico_id INTEGER,
  servico_id INTEGER,
  PRIMARY KEY (tag_servico_id, servico_id),
  FOREIGN KEY (tag_servico_id) REFERENCES TagServico(tag_servico_id) ON DELETE CASCADE,
  FOREIGN KEY (servico_id) REFERENCES Servico(servico_id) ON DELETE CASCADE
);

CREATE TABLE Categoria_Produto (
  produto_id INTEGER,
  categoria_id INTEGER,
  PRIMARY KEY (produto_id, categoria_id),
  FOREIGN KEY (produto_id) REFERENCES Produto(produto_id) ON DELETE CASCADE,
  FOREIGN KEY (categoria_id) REFERENCES Categoria(categoria_id) ON DELETE CASCADE
);



-- MODELAGEM DE DADOS: PROCEDURE 

-- 1. Cadastrar Novo Usuário
CREATE OR REPLACE FUNCTION registrar_user(
    p_uid VARCHAR(28),
    p_nome_completo VARCHAR(300),
    p_nome_usuario VARCHAR(20),
    p_cpf VARCHAR(11),
    p_email VARCHAR(250),
    p_senha VARCHAR(500),
    p_telefone VARCHAR(11),
    p_data_nascimento DATE,
    p_genero INTEGER
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Usuario (uid, nome_completo, nome_usuario, cpf, email, senha, telefone, data_nascimento, genero)
    VALUES (p_uid, p_nome_completo, p_nome_usuario, p_cpf, p_email, p_senha, p_telefone, p_data_nascimento, p_genero);
END;
$$ LANGUAGE plpgsql;

-- 2. Adicionar Novo Produto
CREATE OR REPLACE FUNCTION add_produto(
    p_nome_produto VARCHAR(250),
    p_estoque INTEGER,
    p_descricao VARCHAR(500),
    p_preco DECIMAL(10, 2),
    p_desconto DECIMAL(10, 2),
    p_condicao BOOLEAN,
    p_imagem VARCHAR(500),
    p_usuario_id VARCHAR(28),
    p_topico INTEGER
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Produto (nome_produto, estoque, descricao, preco, desconto, condicao, imagem, usuario_id, topico)
    VALUES (p_nome_produto, p_estoque, p_descricao, p_preco, p_desconto, p_condicao, p_imagem, p_usuario_id, p_topico);
END;
$$ LANGUAGE plpgsql;


-- 3. Registrar Pagamento do Plano
CREATE OR REPLACE FUNCTION registrar_pagamento_plano(
    p_plano_id INTEGER,
    p_usuario_id VARCHAR(28),
    p_valor DECIMAL(10, 2),
    p_data_pagamento DATE,
    p_status VARCHAR(50)
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO Pagamento_Plano (plano_id, usuario_id, valor, data_pagamento, status)
    VALUES (p_plano_id, p_usuario_id, p_valor, p_data_pagamento, p_status);
END;
$$ LANGUAGE plpgsql;


-- MODELAGEM DE DADOS: TRIGGERS E LOG
-- Tabela de Log para Usuario
CREATE TABLE Log_Usuario (
    log_id SERIAL PRIMARY KEY,
    uid VARCHAR(28),
    nome_completo VARCHAR(300),
    nome_usuario VARCHAR(20),
    cpf VARCHAR(11),
    email VARCHAR(250),
    telefone VARCHAR(11),
    data_nascimento DATE,
    genero INTEGER,
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Usuario (uid, nome_completo, nome_usuario, cpf, email, telefone, data_nascimento, genero, operation)
        VALUES (NEW.uid, NEW.nome_completo, NEW.nome_usuario, NEW.cpf, NEW.email, NEW.telefone, NEW.data_nascimento, NEW.genero, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Usuario (uid, nome_completo, nome_usuario, cpf, email, telefone, data_nascimento, genero, operation)
        VALUES (OLD.uid, OLD.nome_completo, OLD.nome_usuario, OLD.cpf, OLD.email, OLD.telefone, OLD.data_nascimento, OLD.genero, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_usuario_trigger
AFTER INSERT OR UPDATE OR DELETE ON Usuario
FOR EACH ROW EXECUTE FUNCTION log_novo_usuario();

-- Tabela de Log para Produto
CREATE TABLE Log_Produto (
    log_id SERIAL PRIMARY KEY,
    produto_id INTEGER,
    nome_produto VARCHAR(250),
    estoque INTEGER,
    descricao VARCHAR(500),
    preco DECIMAL(10, 2),
    desconto DECIMAL(10, 2),
    usuario_id VARCHAR(28),
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_produto()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Produto (produto_id, nome_produto, estoque, descricao, preco, desconto, usuario_id, operation)
        VALUES (NEW.produto_id, NEW.nome_produto, NEW.estoque, NEW.descricao, NEW.preco, NEW.desconto, NEW.usuario_id, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Produto (produto_id, nome_produto, estoque, descricao, preco, desconto, usuario_id, operation)
        VALUES (OLD.produto_id, OLD.nome_produto, OLD.estoque, OLD.descricao, OLD.preco, OLD.desconto, OLD.usuario_id, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_produto_trigger
AFTER INSERT OR UPDATE OR DELETE ON Produto
FOR EACH ROW EXECUTE FUNCTION log_novo_produto();

-- Tabela de Log para Plano

CREATE TABLE Log_Plano (
    log_id SERIAL PRIMARY KEY,
    plano_id INTEGER,
    nome VARCHAR(100),
    descricao VARCHAR(255),
    valor DECIMAL(10, 2),
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_plano()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Plano (plano_id, nome, descricao, valor, operation)
        VALUES (NEW.plano_id, NEW.nome, NEW.descricao, NEW.valor, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Plano (plano_id, nome, descricao, valor, operation)
        VALUES (OLD.plano_id, OLD.nome, OLD.descricao, OLD.valor, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_plano_trigger
AFTER INSERT OR UPDATE OR DELETE ON Plano
FOR EACH ROW EXECUTE FUNCTION log_novo_plano();

-- Extras MODELAGEM DE DADOS
-- Log para Tabela Plano_Usuario
CREATE TABLE Log_Plano_Usuario (
    log_id SERIAL PRIMARY KEY,
    plano_usuario_id INTEGER,
    usuario_id VARCHAR(28),
    plano_id INTEGER,
    data_assinatura DATE,
    data_final DATE,
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_plano_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Plano_Usuario (plano_usuario_id, usuario_id, plano_id, data_assinatura, data_final, operation)
        VALUES (NEW.plano_usuario_id, NEW.usuario_id, NEW.plano_id, NEW.data_assinatura, NEW.data_final, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Plano_Usuario (plano_usuario_id, usuario_id, plano_id, data_assinatura, data_final, operation)
        VALUES (OLD.plano_usuario_id, OLD.usuario_id, OLD.plano_id, OLD.data_assinatura, OLD.data_final, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_plano_usuario_trigger
AFTER INSERT OR UPDATE OR DELETE ON Plano_Usuario
FOR EACH ROW EXECUTE FUNCTION log_novo_plano_usuario();

-- Log para Pagamento_Plano
CREATE TABLE Log_Pagamento_Plano (
    log_id SERIAL PRIMARY KEY,
    pagamento_plano_id INTEGER,
    plano_id INTEGER,
    usuario_id VARCHAR(28),
    valor DECIMAL(10, 2),
    data_pagamento DATE,
    status VARCHAR(50),
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_pagamento_plano()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Pagamento_Plano (pagamento_plano_id, plano_id, usuario_id, valor, data_pagamento, status, operation)
        VALUES (NEW.pagamento_plano_id, NEW.plano_id, NEW.usuario_id, NEW.valor, NEW.data_pagamento, NEW.status, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Pagamento_Plano (pagamento_plano_id, plano_id, usuario_id, valor, data_pagamento, status, operation)
        VALUES (OLD.pagamento_plano_id, OLD.plano_id, OLD.usuario_id, OLD.valor, OLD.data_pagamento, OLD.status, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_pagamento_plano_trigger
AFTER INSERT OR UPDATE OR DELETE ON Pagamento_Plano
FOR EACH ROW EXECUTE FUNCTION log_novo_pagamento_plano();

-- Log para Tabela Endereco_Usuario

CREATE TABLE Log_Endereco_Usuario (
    log_id SERIAL PRIMARY KEY,
    endereco_usuario_id INTEGER,
    cep VARCHAR(8),
    uf VARCHAR(2),
    cidade VARCHAR(23),
    bairro VARCHAR(53),
    rua VARCHAR(75),
    numero VARCHAR(20),
    complemento VARCHAR(150),
    usuario_id VARCHAR(28),
    operation VARCHAR(10),
    operation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_novo_endereco_usuario()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
        INSERT INTO Log_Endereco_Usuario (endereco_usuario_id, cep, uf, cidade, bairro, rua, numero, complemento, usuario_id, operation)
        VALUES (NEW.endereco_usuario_id, NEW.cep, NEW.uf, NEW.cidade, NEW.bairro, NEW.rua, NEW.numero, NEW.complemento, NEW.usuario_id, TG_OP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO Log_Endereco_Usuario (endereco_usuario_id, cep, uf, cidade, bairro, rua, numero, complemento, usuario_id, operation)
        VALUES (OLD.endereco_usuario_id, OLD.cep, OLD.uf, OLD.cidade, OLD.bairro, OLD.rua, OLD.numero, OLD.complemento, OLD.usuario_id, TG_OP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER novo_endereco_usuario_trigger
AFTER INSERT OR UPDATE OR DELETE ON Endereco_Usuario
FOR EACH ROW EXECUTE FUNCTION log_novo_endereco_usuario();

-- Novas Actions
-- Procedure para Atualizar Preço
CREATE OR REPLACE FUNCTION desconto_produto(p_produto_id INTEGER, p_desconto DECIMAL(10, 2))
RETURNS VOID AS $$
BEGIN
    UPDATE Produto
    SET preco = preco - (preco * p_desconto / 100)
    WHERE produto_id = p_produto_id;
END;
$$ LANGUAGE plpgsql;

--Trigger 
CREATE OR REPLACE FUNCTION update_fim_plano()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE Plano_Usuario
        SET data_final = data_assinatura + INTERVAL '30 days'  -- Exemplo de 30 dias
        WHERE usuario_id = NEW.usuario_id AND plano_id = NEW.plano_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_fim_plano_trigger
AFTER INSERT ON Pagamento_Plano
FOR EACH ROW EXECUTE FUNCTION update_fim_plano();

-- Procedure para Deletar Usuario
CREATE OR REPLACE FUNCTION deletar_usuario(p_usuario_id VARCHAR(28))
RETURNS VOID AS $$
BEGIN
    DELETE FROM Pagamento_Plano WHERE usuario_id = p_usuario_id;
    DELETE FROM Plano_Usuario WHERE usuario_id = p_usuario_id;
    DELETE FROM Endereco_Usuario WHERE usuario_id = p_usuario_id;
    DELETE FROM Servico WHERE usuario_id = p_usuario_id;
    DELETE FROM Produto WHERE usuario_id = p_usuario_id;
    DELETE FROM Usuario WHERE uid = p_usuario_id;
END;
$$ LANGUAGE plpgsql;



