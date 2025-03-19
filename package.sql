CREATE SCHEMA IF NOT EXISTS contract_package;

-- Функция для добавления нового комментария
CREATE OR REPLACE FUNCTION contract_package.add_comment(
    p_contract_id INT, 
    p_comment_text TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO CONTRACT_COMMENT (contract_id, contract_comment)
    VALUES (p_contract_id, p_comment_text);
END;
$$ LANGUAGE plpgsql;

-- Функция для обновления комментария
CREATE OR REPLACE FUNCTION contract_package.update_comment(
    p_contract_id INT,
    p_comment_text TEXT
) RETURNS VOID AS $$
BEGIN 
    UPDATE CONTRACT_COMMENT 
    SET contract_comment = p_comment_text 
    WHERE contract_id = p_contract_id;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'Comment for contract with ID % not found', p_contract_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция для удаления комментария
CREATE OR REPLACE FUNCTION contract_package.delete_comment(
    p_contract_id INT
) RETURNS VOID AS $$ 
BEGIN 
    DELETE FROM CONTRACT_COMMENT
    WHERE contract_id = p_contract_id;
    
    IF NOT FOUND THEN 
        RAISE EXCEPTION 'Comment for contract with ID % not found', p_contract_id;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Функция для получения количества договоров с двумя и более комментариями
CREATE OR REPLACE FUNCTION contract_package.get_contracts_more_2com()
RETURNS INT AS $$ 
DECLARE 
    count_contact INT; 
BEGIN 
    SELECT COUNT(DISTINCT contract_id) INTO count_contact
    FROM CONTRACT_COMMENT
    WHERE data_create >= date_trunc('month', CURRENT_DATE)
    GROUP BY contract_id
    HAVING COUNT(id) >= 2;
    
    RETURN count_contact;
END;
$$ LANGUAGE plpgsql;

