-- account table
CREATE SEQUENCE IF NOT EXISTS account_id_seq
    INCREMENT BY 1
    MINVALUE 1
    NO MAXVALUE
    START WITH 1;

CREATE TABLE IF NOT EXISTS account (
    id integer NOT NULL DEFAULT nextval('account_id_seq'),
    username varchar(100) NOT NULL,
    name varchar(100),
    email varchar(200),
    PRIMARY KEY (id)
);

ALTER SEQUENCE account_id_seq OWNED BY account.id;
