CREATE TABLE client (
    id bigint PRIMARY KEY,
    first_name text NOT NULL,
    last_name text NOT NULL
);

CREATE TABLE command_state (
    state text PRIMARY KEY
);

CREATE TABLE command (
    id bigint PRIMARY KEY,
    dt date NOT NULL,
    id_client bigint REFERENCES client (id) NOT NULL,
    state text REFERENCES command_state(state) NOT NULL
);

CREATE TABLE command_line (
    id bigint PRIMARY KEY,
    id_command bigint REFERENCES command(id) NOT NULL,
    price numeric NOT NULL
);

INSERT INTO client (id, first_name, last_name)
    SELECT i, 'firstname ' || i, 'lastname ' || i
    FROM generate_series(1,10000) i;

INSERT INTO command_state(state) VALUES
    ('payed'),
    ('shipped'),
    ('returned');

INSERT INTO command (id, dt, id_client, state)
    SELECT i,
        '2000-01-01'::date + floor(random()*365*15) * interval '1 day',
        floor(random()*10000)+1,
        CASE WHEN i % 1000 = 0 THEN 'returned' ELSE 'shipped' END
    FROM generate_series(1,100000) i;

INSERT INTO command_line (id, id_command, price)
    SELECT i,
        floor(random()*100000)+1,
        floor(random()*1000)+50
    FROM generate_series(1,1000000) i;
