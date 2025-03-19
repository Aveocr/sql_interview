-- Таблица пользователей
CREATE TABLE IF NOT EXISTS "USER" (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL
);

-- Таблица контрактов
CREATE TABLE IF NOT EXISTS CONTRACTS (
    contract_id INT PRIMARY KEY,  -- Исправлено имя столбца
    data_contract DATE DEFAULT CURRENT_DATE, 
    number_phone VARCHAR(20),
    data_create TIMESTAMP,              -- Дата создания
    user_id INT,                        -- Автор (пользователь, создавший запись)
    date_update TIMESTAMP,              -- Дата обновления
    user_update_id INT,                 -- Редактор (пользователь, обновивший запись)
    FOREIGN KEY (user_id) REFERENCES "USER"(user_id),
    FOREIGN KEY (user_update_id) REFERENCES "USER"(user_id)
);

CREATE SEQUENCE CONTRACTS_SEQ 
START WITH 1
INCREMENT BY 1 
NO CYCLE;

-- Таблица коментариев контрактов
CREATE TABLE IF NOT EXISTS CONTRACT_COMMENT  (
    id int PRIMARY KEY,  -- Исправлено имя столбца
    contract_id int, 
    contract_comment text,
    data_create TIMESTAMP,              -- Дата создания
    user_id INT,                        -- Автор (пользователь, создавший запись)
    date_update TIMESTAMP,              -- Дата обновления
    user_update_id INT,                 -- Редактор (пользователь, обновивший запись)
  	FOREIGN KEY (contract_id) REFERENCES CONTRACTS(contract_id),
    FOREIGN KEY (user_id) REFERENCES "USER"(user_id),
    FOREIGN KEY (user_update_id) REFERENCES "USER"(user_id)
);

-- Заполнение через sequence 
CREATE SEQUENCE CONTRACTS_COMMENT_SEQ 
START WITH 1
INCREMENT BY 1 
NO CYCLE;


/* Начало блока с функциями */
-- Функция для заполнения полей при вставке
CREATE OR REPLACE FUNCTION set_create_fields() 
RETURNS TRIGGER AS 
$$
BEGIN 
  NEW.data_create := NOW();  -- Устанавливаем дату создания
  NEW.user_id := (SELECT user_id FROM "USER" WHERE username = CURRENT_USER);  -- Устанавливаем автора
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Функция для заполнения полей при обновлении
CREATE OR REPLACE FUNCTION set_update_fields()
RETURNS TRIGGER AS $$
BEGIN 
    NEW.date_update := NOW();  -- Устанавливаем дату обновления
    NEW.user_update_id := (SELECT user_id FROM "USER" WHERE username = 5);  -- Устанавливаем редактора
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/*Конец блока с функциями, начало блока с триггерами */

-- Триггер для вставки
CREATE TRIGGER CONTRACTS_BI
BEFORE INSERT ON CONTRACTS
FOR EACH ROW
EXECUTE FUNCTION set_create_fields();

-- Триггер для обновления
CREATE TRIGGER CONTRACTS_BU
BEFORE UPDATE ON CONTRACTS
FOR EACH ROW
EXECUTE FUNCTION set_update_fields();


-- Триггер для вставки
CREATE TRIGGER CONTRACT_COMMENT_BI
BEFORE INSERT ON CONTRACT_COMMENT
FOR EACH ROW
EXECUTE FUNCTION set_create_fields();

-- Триггер для обновления
CREATE TRIGGER CONTRACT_COMMENT_BU
BEFORE UPDATE ON CONTRACT_COMMENT
FOR EACH ROW
EXECUTE FUNCTION set_update_fields();

/* Блок с триггерами закончился.*/
/*Начался блок с представлениями */

-- Представление содержащющее информациюю по комментарию на номерах
CREATE OR REPLACE VIEW ALL_COMMENTS AS
 	SELECT CONTRACTS.number_phone, CONTRACT_COMMENT.data_create, CONTRACT_COMMENT.contract_comment FROM CONTRACT_COMMENT
  JOIN CONTRACTS ON CONTRACT_COMMENT.contract_id = CONTRACTS.contract_id;

-- Представление, содержащие все записи моложе одной недели   
 CREATE OR REPLACE VIEW LAST_WEEK_COMMENTS AS
   	SELECT number_phone, data_create, contract_comment FROM ALL_COMMENTS
   	where data_create >= CURRENT_DATE - INTERVAL '7 days';
-- Представление, содержащие количество комментариев 
CREATE OR REPLACE VIEW COUNT_COMMENTS AS 
  SELECT contract_id, COUNT(contract_comment) from CONTRACT_COMMENT 
  GROUP BY contract_id
  order by count(contract_comment);

-- Представление, содержащие имена, чьи догвоора были созданы пользователем с фамилей "*ков"
CREATE OR REPLACE VIEW SURNAME as 
  SELECT username, CONTRACTS.number_phone FROM "USER"
  join CONTRACTS ON "USER".user_id = CONTRACTS.user_id
  WHERE LOWER(username) LIKE '%ков';
