\set ncli 10000
\set ncmd 100000
\set ncmdline 1000000
\set cliid random_gaussian(1,:ncli,20)

SELECT com.id, sum(c_l.price) as total_price FROM command com JOIN command_line c_l ON com.id = c_l.id_command JOIN client cli ON cli.id = com.id_client WHERE cli.id = :cliid GROUP BY com.id;
